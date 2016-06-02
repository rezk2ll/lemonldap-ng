package Lemonldap::NG::Common::Module;

use strict;
use Mouse;

our $VERSION = '2.0.0';

# Object that provides lmLog and error methods (typically PSGI object)
has p    => ( is => 'rw', weak_ref => 1 );

# Lemonldap::NG configuration hash ref
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
