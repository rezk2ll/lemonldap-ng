package Lemonldap::NG::Portal::Main::Module;

use strict;
use Mouse;

our $VERSION = '2.0.0';

has p    => ( is => 'rw', weak_ref => 1 );
has conf => ( is => 'rw', weak_ref => 1 );

sub lmLog {
    my $self = shift;
    return $self->p->lmLog(@_);
}

sub error {
    my $self = shift;
    return $self->p->error(@_);
}

1;
