package Lemonldap::NG::Portal::Plugins::History;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

extends 'Lemonldap::NG::Portal::Main::Plugin',
  'Lemonldap::NG::Portal::Lib::OtherSessions';

sub afterDatas { 'run' }

sub run {
    my ( $self, $req ) = @_;
    $req->info(
        (
            $req->sessionInfo->{loginHistory}->{successLogin}
            ? $self->mkSessionArray(
                $req->sessionInfo->{loginHistory}->{successLogin},
                'lastLogins', 0, 0 )
            : ""
        )
        . (
            $req->sessionInfo->{loginHistory}->{failedLogin}
            ? $self->mkSessionArray(
                $req->sessionInfo->{loginHistory}->{failedLogin},
                'lastFailedLogins', 0, 1 )
            : ""
        )
    );
    PE_OK;
}

1;
