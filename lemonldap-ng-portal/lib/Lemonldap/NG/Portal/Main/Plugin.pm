# Base package for LLNG portal plugins. It adds somme wrapper to
# Lemonldap::NG::Handler::PSGI::Try (base of portal)
package Lemonldap::NG::Portal::Main::Plugin;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Common::Module';

sub addAuthRoute {
    my $self = shift;
    return $self->_addRoute( 'addAuthRoute', @_ );
}

sub addUnauthRoute {
    my $self = shift;
    return $self->_addRoute( 'addUnauthRoute', @_ );
}

sub _addRoute {
    my ( $self, $type, $word, $subName, $methods, $transform ) = @_;
    $transform //= sub {
        my ($sub) = @_;
        if ( ref $sub ) {
            return sub {
                shift;
                return $sub->( $self, @_ );
              }
        }
        else {
            return sub {
                shift;
                return $self->$sub(@_);
              }
        }
    };
    $self->p->$type( $word, $subName, $methods, $transform );
    return $self;
}

1;
