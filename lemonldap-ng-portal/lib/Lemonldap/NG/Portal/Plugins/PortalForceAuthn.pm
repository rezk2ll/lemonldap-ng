package Lemonldap::NG::Portal::Plugins::PortalForceAuthn;

use Data::Dumper;
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
    $self->logger->debug( "********* " . Dumper($req) );
    my $portalURL = $self->conf->{portal} || '';
    my $HTTP_HOST = $req->env->{HTTP_HOST} || '';
    my $referer = $req->env->{HTTP_REFERER} || '';

    $self->logger->debug( "Portal URL -> " . Dumper($portalURL) );
    $self->logger->debug( "HTTP_HOST -> " . Dumper($HTTP_HOST) );

    if ( $req->env->{HTTP_HOST} and $portalURL =~ qr#\Q$HTTP_HOST# ) {
        my $delta = time() - $req->{sessionInfo}->{_utime};
        $self->logger->debug( "Delta with last Authn -> " . $delta );

        $delta <= $self->conf->{portalForceAuthnInterval}
            ? return PE_OK
            : return PE_MUSTAUTHN;
    }
}

1;
