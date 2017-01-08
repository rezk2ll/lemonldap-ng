package Lemonldap::NG::Common::Session::REST;

use strict;
use Mouse;

sub separator {
    $_[0]->{multiValuesSeparator} || $_[0]->conf->{multiValuesSeparator};
}

sub hAttr {
    $_[0]->{hiddenAttributes} || $_[0]->conf->{hiddenAttributes};
}

sub delSession {
    my ( $self, $req ) = @_;
    return $self->sendJSONresponse( $req, { result => 1 } )
      if ( $self->{demoMode} );
    my $mod = $self->getMod($req)
      or return $self->sendError( $req, undef, 400 );
    my $id = $req->params('sessionId')
      or return $self->sendError( $req, 'sessionId is missing', 400 );
    my $session = $self->getApacheSession( $mod, $id );
    $session->remove;
    if ( $session->error ) {
        return $self->sendError( $req, $session->error, 200 );
    }
    return $self->sendJSONresponse( $req, { result => 1 } );
}

sub session {
    my ( $self, $req, $id, $skey ) = @_;
    my ( %h, $res );
    return $self->sendError( $req, 'Bad request', 400 ) unless($id);
    my $mod = $self->getMod($req)
      or return $self->sendError( $req, undef, 400 );

    # Try to read session
    my $apacheSession = $self->getApacheSession( $mod, $id )
      or return $self->sendError( $req, undef, 400 );

    my %session = %{ $apacheSession->data };

    foreach my $k ( keys %session ) {
        $session{$k} = '**********'
          if ( $self->hAttr =~ /\b$k\b/ );
        $session{$k} = [ split /$self->separator/o, $session{$k} ]
          if ( $session{$k} =~ /$self->separator/o );
    }

    if ($skey) {
        return $self->sendJSONresponse( $req, $session{$skey} );
    }
    else {
        return $self->sendJSONresponse( $req, \%session );
    }

    # TODO: check for utf-8 problems
}

sub getApacheSession {
    my ( $self, $mod, $id ) = @_;
    my $apacheSession = Lemonldap::NG::Common::Session->new(
        {
            storageModule        => $mod->{module},
            storageModuleOptions => $mod->{options},
            cacheModule =>
              Lemonldap::NG::Handler::PSGI::API->tsv->{sessionCacheModule},
            cacheModuleOptions =>
              Lemonldap::NG::Handler::PSGI::API->tsv->{sessionCacheOptions},
            id   => $id,
            kind => $mod->{kind},
        }
    );
    if ( $apacheSession->error ) {
        $self->error( $apacheSession->error );
        return undef;
    }
    return $apacheSession;
}

sub getMod {
    my ( $self, $req ) = @_;
    my ( $s, $m );
    unless ( $s = $req->params('sessionType') ) {
        $self->error('Session type is required');
        return ();
    }
    unless ( $m = $self->conf->{$s} ) {
        $self->error('Unknown (or unconfigured) session type');
        return ();
    }
    return $m;
}

1;
