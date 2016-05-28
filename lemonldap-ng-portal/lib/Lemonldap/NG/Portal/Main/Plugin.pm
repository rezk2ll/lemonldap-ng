package Lemonldap::NG::Portal::Main::Plugin;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Module';

sub addAuthRoute {
    my $self = shift;
    return $self->_addRoute('addAuthRoute',@_);
}

sub addUnauthRoute {
    my $self = shift;
    return $self->_addRoute('addUnauthRoute',@_);
}

sub _addRoute {
    my ( $self, $type, $word, $subName, $methods ) = @_;
    die 'Only simple route are authorizated here. Uses $self->p->addAuthRoute'
      if ( ref $subName );
    $self->can($subName) or die "Unknown sub $subName";
    $self->p->$type(
        $word,
        sub {
            my $p = shift;
            return $self->$subName(@_);
        },
        $methods
    );
}

1;
