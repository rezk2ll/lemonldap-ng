package Lemonldap::NG::Common::Session::REST;

use strict;
use Mouse;
use Lemonldap::NG::Common::Conf::Constants;

our $VERSION = '2.0.0';

has sessionTypes => ( is => 'rw' );

sub setTypes {
    my ( $self, $conf ) = @_;
    foreach my $type (@sessionTypes) {
        if ( my $tmp =
            $self->{ $type . 'Storage' } || $conf->{ $type . 'Storage' } )
        {
            $self->{sessionTypes}->{$type}->{module} = $tmp;
            $self->{sessionTypes}->{$type}->{options} =
                 $self->{ $type . 'StorageOptions' }
              || $conf->{ $type . 'StorageOptions' }
              || {};
            $self->{sessionTypes}->{$type}->{kind} =
              ( $type eq 'global' ? 'SSO' : ucfirst($type) );
        }
    }
}

sub separator {
    $_[0]->{multiValuesSeparator} || $_[0]->conf->{multiValuesSeparator};
}

sub hAttr {
    $_[0]->{hiddenAttributes} || $_[0]->conf->{hiddenAttributes};
}

### SEE LEMONLDAP::NG::COMMON::SESSION FOR AVAILABLE FUNCTIONS

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
    Lemonldap::NG::Handler::PSGI::Main->localUnlog( $req, $id );
    if ( $session->error ) {
        return $self->sendError( $req, $session->error, 200 );
    }
    return $self->sendJSONresponse( $req, { result => 1 } );
}

sub deleteU2FKey {
    my ( $self, $req ) = @_;
    return $self->sendJSONresponse( $req, { result => 1 } )
      if ( $self->{demoMode} );
    my $mod = $self->getMod($req)
      or return $self->sendError( $req, undef, 400 );
    my $id = $req->params('sessionId')
      or return $self->sendError( $req, 'sessionId is missing', 400 );

    # Try to read session
    my $session = $self->getApacheSession( $mod, $id )
      or return $self->sendError( $req, undef, 400 );

    # Delete U2F key attributs and update session
    $session->data->{_u2fKeyHandle} = '';
    $session->data->{_u2fUserKey}   = '';
    $session->update( \%{ $session->data } );

    Lemonldap::NG::Handler::PSGI::Main->localUnlog( $req, $id );
    if ( $session->error ) {
        return $self->sendError( $req, $session->error, 200 );
    }
    return $self->sendJSONresponse( $req, { result => 1 } );
}

sub addU2FKey {
    my ( $self, $req ) = @_;
    return $self->sendJSONresponse( $req, { result => 1 } )
      if ( $self->{demoMode} );
    my $mod = $self->getMod($req)
      or return $self->sendError( $req, undef, 400 );
    my $id = $req->params('sessionId')
      or return $self->sendError( $req, 'sessionId is missing', 400 );

    # Try to read session
    my $session = $self->getApacheSession( $mod, $id )
      or return $self->sendError( $req, undef, 400 );

    # Delete U2F key attributs and update session
    $session->data->{_u2fKeyHandle} = 'TOF';
    $session->data->{_u2fUserKey}   = 'TOF';
    $session->update( \%{ $session->data } );

    Lemonldap::NG::Handler::PSGI::Main->localUnlog( $req, $id );
    if ( $session->error ) {
        return $self->sendError( $req, $session->error, 200 );
    }
    return $self->sendJSONresponse( $req, { result => 1 } );
}

sub verifyU2FKey {
    my ( $self, $req ) = @_;
    return $self->sendJSONresponse( $req, { result => 1 } )
      if ( $self->{demoMode} );
    my $mod = $self->getMod($req)
      or return $self->sendError( $req, undef, 400 );
    my $id = $req->params('sessionId')
      or return $self->sendError( $req, 'sessionId is missing', 400 );

    # Try to read session
    my $session = $self->getApacheSession( $mod, $id )
      or return $self->sendError( $req, undef, 400 );

    # Delete U2F key attributs and update session
    $session->data->{_u2fKeyHandle} = 'OK';
    $session->data->{_u2fUserKey}   = 'OK';
    $session->update( \%{ $session->data } );

    Lemonldap::NG::Handler::PSGI::Main->localUnlog( $req, $id );
    if ( $session->error ) {
        return $self->sendError( $req, $session->error, 200 );
    }
    return $self->sendJSONresponse( $req, { result => 1 } );
}

sub session {
    my ( $self, $req, $id, $skey ) = @_;
    my ( %h, $res );
    return $self->sendError( $req, 'Bad request', 400 ) unless ($id);
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
        if ( $skey =~ s/^\[(.*)\]$/$1/ ) {
            my @sk = split /,/, $skey;
            my $res = {};
            $res->{$_} = $session{$_} foreach (@sk);
            return $self->sendJSONresponse( $req, $res );
        }
        return $self->sendJSONresponse( $req, $session{$skey} );
    }
    else {
        return $self->sendJSONresponse( $req, \%session );
    }

    # TODO: check for utf-8 problems
}

sub getApacheSession {
    my ( $self, $mod, $id, $info, $force ) = @_;
    my $apacheSession = Lemonldap::NG::Common::Session->new(
        {
            storageModule        => $mod->{module},
            storageModuleOptions => $mod->{options},
            cacheModule =>
              Lemonldap::NG::Handler::PSGI::Main->tsv->{sessionCacheModule},
            cacheModuleOptions =>
              Lemonldap::NG::Handler::PSGI::Main->tsv->{sessionCacheOptions},
            id    => $id,
            force => $force,
            kind  => $mod->{kind},
            ( $info ? ( info => $info ) : () ),
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
    unless ( $m = $self->sessionTypes->{$s} ) {
        $self->error('Unknown (or unconfigured) session type');
        return ();
    }
    return $m;
}

1;
