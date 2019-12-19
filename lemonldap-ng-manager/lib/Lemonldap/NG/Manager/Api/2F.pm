package Lemonldap::NG::Manager::Api::2F;
our $VERSION = '2.0.7';

package Lemonldap::NG::Manager::Api;

use 5.10.0;
use utf8;
use Mouse;
use JSON;

use Lemonldap::NG::Common::Session;

sub getSecondFactors {
    my ( $self, $req ) = @_;
    my ( $uid, $res);

    $uid = $req->params('uid')
      or return $self->sendError( $req, 'uid is missing', 400 );

    $self->logger->debug("[API] 2F for $uid requested");

    $res = $self->_get2F($uid);
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, $res->{code} );
    }

    return $self->sendJSONresponse( $req, $res->{secondFactors} );
}

sub getSecondFactorsByType {
    my ( $self, $req ) = @_;
    my ( $uid, $type, $res);

    $uid = $req->params('uid')
      or return $self->sendError( $req, 'Uid is missing', 400 );

    $type = $req->params('type')
      or return $self->sendError( $req, 'Type is missing', 400 );

    $self->logger->debug("[API] 2F for $uid with type $type requested");

    $res = $self->_get2F($uid, uc $type);
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, $res->{code} );
    }

    return $self->sendJSONresponse( $req, $res->{secondFactors} );
}

sub getSecondFactorsById {
    my ( $self, $req ) = @_;
    my ( $uid, $id, $res);

    $uid = $req->params('uid')
      or return $self->sendError( $req, 'uid is missing', 400 );

    $id = $req->params('id')
      or return $self->sendError( $req, 'id is missing', 400 );

    $self->logger->debug("[API] 2F for $uid with id $id requested");

    $res = $self->_get2F($uid, undef,  $id);
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, $res->{code} );
    }

    return $self->sendJSONresponse( $req, $res->{secondFactors} );
}

sub deleteSecondFactors {
    my ( $self, $req ) = @_;
    my ( $uid, $res);

    $uid = $req->params('uid')
      or return $self->sendError( $req, 'uid is missing', 400 );

    $self->logger->debug("[API] Delete all 2F for $uid requested");

    $res = $self->_delete2F($uid);
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, $res->{code} );
    }

    return $self->sendJSONresponse( $req, { message => $res->{msg} } );
}

sub deleteSecondFactorsById {
    my ( $self, $req ) = @_;
    my ( $uid, $id, $res);

    $uid = $req->params('uid')
      or return $self->sendError( $req, 'uid is missing', 400 );

    $id = $req->params('id')
      or return $self->sendError( $req, 'id is missing', 400 );

    $self->logger->debug("[API] Delete 2F for $uid with id $id requested");

    $res = $self->_delete2F($uid, undef, $id);
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, $res->{code} );
    }

    return $self->sendJSONresponse( $req, { message => $res->{msg} } );
}

sub deleteSecondFactorsByType {
    my ( $self, $req ) = @_;
    my ( $uid, $type, $res);

    $uid = $req->params('uid')
      or return $self->sendError( $req, 'uid is missing', 400 );

    $type = $req->params('type')
      or return $self->sendError( $req, 'type is missing', 400 );

    $self->logger->debug("[API] Delete all 2F for $uid with type $type requested");

    $res = $self->_delete2F($uid, uc $type);
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, $res->{code} );
    }

    return $self->sendJSONresponse( $req, { message => $res->{msg} } );
}

sub _get2F {
    my ( $self, $uid, $type, $id ) = @_;
    my ($res, $psessions, @secondFactors);

    if (defined $type) {
        $res = $self->_checkType($type);
        return $res if ($res->{res} ne 'ok');
    }

    $psessions = $self->_getPSessions2F($uid, ('_session_uid', '_2fDevices'));

    foreach ( keys %{ $psessions } ) {
        my $devices = from_json( $psessions->{$_}->{_2fDevices}, { allow_nonref => 1 } );
        foreach my $device ( @{$devices} ) {
            push @secondFactors, { id => $device->{epoch}, type => $device->{type}, name => $device->{name} }
                unless (
                  ( defined $type and $type ne $device->{type} )
                  or ( defined $id and $id ne $device->{epoch} )
                );
        }
    }
    return { res => 'ok', secondFactors => scalar @secondFactors ? @secondFactors : [] };
}

sub _getMod2F {
    my ( $self ) = @_;
    my $mod = $self->sessionTypes->{persistent};
    $mod->{options}->{backend} = $mod->{module};
    return $mod;
}
sub _getPSessions2F {
    my ( $self, $uid, @fields ) = @_;
    $self->logger->debug("Looking for psessions for uid $uid ...");
    my $psessions = Lemonldap::NG::Common::Apache::Session->searchOn($self->_getMod2F->{options},
            '_session_uid', $uid, @fields );
    $self->logger->debug("Found " . scalar (keys %{ $psessions })  . " psessions for uid $uid.");
    return $psessions;
}

sub getSession2F {
    my ( $self, $sessionId ) = @_;
    $self->logger->debug("Looking for session with sessionId $sessionId ...");
    my $session = $self->getApacheSession( $self->_getMod2F, $sessionId );
    $self->logger->debug(defined $session ? "Session $sessionId found." : " No session found for sessionId $sessionId");
    return $session;
}

sub _delete2F {
    my ( $self, $uid, $type, $id ) = @_;
    my ($res, $psessions, $sessionId, $session, $devices, @keep, $total, $removed, $lremoved, $localStorage);

    $localStorage = Lemonldap::NG::Handler::PSGI::Main->tsv->{refLocalStorage};

    if (defined $type) {
        $res = $self->_checkType($type);
        return $res if ($res->{res} ne 'ok');
    }

    $psessions = $self->_getPSessions2F($uid, ('_session_uid', '_session_id', '_2fDevices'));

    foreach ( keys %{ $psessions } ) {

        $sessionId = $psessions->{$_}->{_session_id};
        $session = $self->getSession2F( $sessionId )
           or return { res => 'ko', code => 500, msg => $@ };

        $self->logger->debug("Looking for 2F Device(s) attached to session $sessionId...");

        if ( $session->data->{_2fDevices} ) {

            $devices = from_json( $session->data->{_2fDevices}, { allow_nonref => 1 } );
            $total = scalar @$devices;
            $self->logger->debug("Found $total 2F devices attached to session $sessionId.");
            @keep = ();
            while (@$devices) {
                my $element = shift @$devices;
                push @keep, $element
                  if (( defined $type or defined $id ) and
                    (( defined $type and $type ne $element->{type} ) or
                     ( defined $id and $id ne $element->{epoch} )));
            }
            $lremoved = $total - scalar @keep;
            if ($lremoved > 0) {
                # Update session
                $self->logger->debug("Removing $lremoved 2F device(s) attached to session $sessionId ...");
                $session->data->{_2fDevices} = to_json( \@keep );
                $session->update( \%{ $session->data } );

                # Delete local cache
                if ( $localStorage and $localStorage->get($sessionId) ) {
                    $self->logger->debug("Delete local cache for $sessionId ...");
                    $localStorage->remove($sessionId);
                } else {
                    $self->logger->debug("Local cache will not be cleared for $sessionId");
                }
            } else {
                $self->logger->debug("No matching 2F devices attached to session $sessionId were selected for removal.");
            }
        } else {
            $self->logger->debug("No 2F devices attached to session $sessionId were found.");
        }

        $removed += $lremoved;
    }
    return {
        res => 'ok',
        msg => $removed > 0 ? "Successful operation: " . $removed . " 2F were removed" : "No operation performed"
    };
}

sub _checkType {
    my ( $self, $type ) = @_;

    return {res => "ko", code=> 405, msg => "Invalid input: Type \"$type\" does not exist. Allowed values for type are: \"U2F\", \"TOTP\" or \"UBK\"" }
        unless ( $type =~ /\b(?:U2F|TOTP|UBK)\b/ );

    return { res => "ok" };
}

1;
