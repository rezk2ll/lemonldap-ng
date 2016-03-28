package Lemonldap::NG::Portal::Main;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends qw(Lemonldap::NG::Handler::PSGI::Try Lemonldap::NG::Portal::Main::Init);

has stack => ( is => 'rw' );

# ENTRY POINT METHODS
# -------------------

# All methods below have been declared as Lemonldap::NG::Common::PSGI::Router
# routes (see Lemonldap::NG::Portal::Main::Init)

sub issuerForAuthUser {
    my ( $self, $type, $req ) = @_;
}

sub issuerForUnauthUser {
    my ( $self, $type, $req ) = @_;
}

# TODO in run
#  - mustRedirect

1;
