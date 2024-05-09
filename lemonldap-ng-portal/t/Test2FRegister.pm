package t::Test2FRegister;

use strict;
use Mouse;

our $VERSION = '2.19.0';

extends qw(
  Lemonldap::NG::Portal::2F::Register::Base
);

# INITIALIZATION

has logo   => ( is => 'rw', default => 'test.png' );
has prefix => ( is => 'rw', default => 'test' );

sub run {
    my ( $self, $req ) = @_;
    return $self->p->sendError( $req, 'error', 400 );
}

1;
