package Lemonldap::NG::Portal::Auth::Apache;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;

our $VERSION = '2.0.12';

extends 'Lemonldap::NG::Portal::Main::Auth';

# INITIALIZATION

sub init {
    return 1;
}

# RUNNING METHODS

sub extractFormInfo {
    my ( $self, $req ) = @_;
    unless ( $req->env->{REMOTE_USER} ) {
        $self->logger->error('Apache is not configured to authenticate users!');
        return PE_ERROR;
    }
    $req->user( $req->env->{REMOTE_USER} );

    # This is needed for Kerberos authentication
    $req->user( $req->user =~ s/^(.*)@.*$/$1/gr );
    return PE_OK;
}

sub authenticate {
    return PE_OK;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    my $sessionInfo = $req->sessionInfo;
    $sessionInfo->{authenticationLevel} = $self->conf->{apacheAuthnLevel};
    $req->sessionInfo($sessionInfo);
    return PE_OK;
}

sub authLogout {
    return PE_OK;
}

sub getDisplayType {
    return 'logo';
}

1;
