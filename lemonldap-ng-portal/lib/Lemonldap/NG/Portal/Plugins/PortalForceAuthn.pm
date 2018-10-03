package Lemonldap::NG::Portal::Plugins::PortalForceAuthn;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_MUSTAUTHN);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

use constant forAuthUser => 'run';

sub init {1}

# RUNNING METHOD

sub run {
    my ( $self, $req ) = @_;
    my $portalURL = $self->conf->{portal} || '';
    my $HTTP_HOST = $req->env->{HTTP_HOST} || '';

    if ( $req->env->{HTTP_HOST} and $portalURL =~ qr#\Q$HTTP_HOST# ) {
        my $delta = time() - $req->{sessionInfo}->{_utime};
        $self->logger->debug( "Delta with last Authn -> " . $delta );

        $delta <= $self->conf->{portalForceAuthnInterval}
            ? return PE_OK
            : return PE_MUSTAUTHN;
    }
}

1;
