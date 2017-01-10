package Lemonldap::NG::Portal::Lib::SOAPProxy;

use strict;
use Mouse;
use SOAP::Lite;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR PE_BADCREDENTIALS);

our $VERSION = '2.0.0';

# INITIALIZATION

sub init {
    my ($self) = @_;
    $self->conf->{remoteCookieName}    ||= $self->conf->{cookieName};
    $self->conf->{proxySessionService} ||= $self->conf->{proxyAuthService};

    unless ( defined $self->conf->{proxyAuthService} ) {
        $self->error("Missing proxyAuthService parameter");
        return 0;
    }
    return 1;
}

# RUNNING METHODS

no warnings 'once';

*authenticate = *getUser;

sub getUser {
    my ( $self, $req ) = @_;
    return PE_OK if ( $req->datas->{_proxyQueryDone} );
    my $soap = SOAP::Lite->proxy( $self->conf->{proxyAuthService} )
      ->uri('urn:Lemonldap/NG/Common/PSGI/SOAPService');
    my $r = $soap->getCookies( $req->{user}, $req->datas->{password} );
    if ( $r->fault ) {
        $self->lmLog(
            "Unable to query authentication service: "
              . $r->fault->{faultstring},
            'error'
        );
        return PE_ERROR;
    }
    my $res = $r->result();

    # If authentication failed, display error
    if ( $res->{errorCode} ) {
        $self->p->userError(
            "Authentication failed for $req->{user}: error $res->{errorCode}");
        return PE_BADCREDENTIALS;
    }
    unless ( $req->datas->{_remoteId} =
        $res->{cookies}->{ $self->conf->{remoteCookieName} } )
    {
        $self->lmLog( "No cookie named $self->{remoteCookieName}", 'error' );
        return PE_ERROR;
    }
    $req->datas->{_proxyQueryDone}++;
    PE_OK;
}

sub setSessionInfo {
    my ( $self, $req ) = @_;
    return PE_OK if ( $req->datas->{_setSessionInfoDone} );
    my $soap = SOAP::Lite->proxy( $self->conf->{proxySessionService} )
      ->uri('urn:Lemonldap/NG/Common/PSGI/SOAPService');
    my $r = $soap->getAttributes( $req->datas->{_remoteId} );
    if ( $r->fault ) {
        $self->lmLog(
            "Unable to query authentication service" . $r->fault->{faultstring},
            'error'
        );
    }
    my $res = $r->result();
    if ( $res->{error} ) {
        $self->userError("Unable to get attributes for $self->{user} ");
        return PE_ERROR;
    }
    foreach ( keys %{ $res->{attributes} } ) {
        $req->{sessionInfo}->{$_} ||= $res->{attributes}->{$_}
          unless (/^_/);
    }
    $req->datas->{_setSessionInfoDone}++;
    PE_OK;
}

sub authLogout {
    PE_OK;
}

1;
