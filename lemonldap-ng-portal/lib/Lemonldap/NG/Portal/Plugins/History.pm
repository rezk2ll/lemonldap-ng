package Lemonldap::NG::Portal::Plugins::History;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_INFO PE_OK);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin',
  'Lemonldap::NG::Portal::Lib::OtherSessions';

# INITIALIZATION

sub afterDatas { 'run' }

sub init { 1 }

# RUNNING METHOD

sub run {
    my ( $self, $req ) = @_;
    if ( $req->param('checkLogins') ) {
        $self->logger->debug('History asked');
        $req->info(
            (
                $req->sessionInfo->{_loginHistory}->{successLogin}
                ? $self->mkSessionArray(
                    $req->sessionInfo->{_loginHistory}->{successLogin},
                    'lastLogins', 0, 0 )
                : ""
            )
            . (
                $req->sessionInfo->{_loginHistory}->{failedLogin}
                ? $self->mkSessionArray(
                    $req->sessionInfo->{_loginHistory}->{failedLogin},
                    'lastFailedLogins', 0, 1 )
                : ""
            )
        );
        unless ( $req->info ) {
            $req->info('<p trspan="noHistory"></p>');
        }
        return PE_INFO;
    }
    return PE_OK;
}

1;
