package Lemonldap::NG::Portal::Auth::Remote;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base',
  'Lemonldap::NG::Portal::Lib::Remote';

sub extractFormInfo {
    my ( $self, $req ) = @_;
    my $r    = $self->checkRemoteId($req);
    return $r unless ( $r == PE_OK );
    $req->{user} =
      $req->datas->{rSessionInfo}->{ $self->conf->{remoteUserField} || 'uid' };
    $req->datas->{password} = $req->datas->{rSessionInfo}->{'_password'};
    PE_OK;
}

sub authenticate {
    PE_OK;
}

sub authForce {
    0;
}

sub authLogout {
    PE_OK;
}

sub getDisplayType {
    return "logo";
}

1;
