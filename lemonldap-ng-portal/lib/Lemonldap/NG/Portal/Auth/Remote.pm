package Lemonldap::NG::Portal::Auth::Remote;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;

our $VERSION = '2.0.12';

extends 'Lemonldap::NG::Portal::Main::Auth',
  'Lemonldap::NG::Portal::Lib::Remote';

# RUNNING METHODS

sub extractFormInfo {
    my ( $self, $req ) = @_;
    my $r = $self->checkRemoteId($req);
    return $r unless ( $r == PE_OK );
    $req->user(
      $req->data->{rSessionInfo}->{ $self->conf->{remoteUserField} || 'uid' });
    $req->data->{password} = $req->data->{rSessionInfo}->{'_password'};
    return PE_OK;
}

sub authenticate {
    return PE_OK;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    my $sessionInfo = $req->sessionInfo;

    # Store password (deleted in checkRemoteId() if local policy does not accept
    # stored passwords)
    $sessionInfo->{'_password'} = $req->data->{'password'};
    $sessionInfo->{authenticationLevel} =
      $req->data->{rSessionInfo}->{authenticationLevel};
    $req->sessionInfo($sessionInfo);

    return PE_OK;
}

sub authLogout {
    return PE_OK;
}

sub getDisplayType {
    return "logo";
}

1;
