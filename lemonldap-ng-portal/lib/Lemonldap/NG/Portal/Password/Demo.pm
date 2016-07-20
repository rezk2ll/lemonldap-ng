package Lemonldap::NG::Portal::Password::Demo;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR);

extends 'Lemonldap::NG::Portal::Password::Base';

our $VERSION = '2.0.0';

sub init {
    my ($self) = @_;
    if ( $self->p->getModule( undef, 'auth' ) eq 'Demo' ) {
        return $self->SUPER::init;
    }
    else {
        $self->lmLog( "Use PasswordDBDemo only with AuthDemo", 'error' );
        return 0;
    }
}

sub confirm {
    my ( $self, $req, $pwd ) = @_;
    return ( $pwd eq $req->{sessionInfo}->{uid} );
}

sub modifyPassword {
    my ( $self, $req, $pwd ) = @_;

    # Nothing to do here, all new passwords are accepted
    PE_OK;
}

1;
