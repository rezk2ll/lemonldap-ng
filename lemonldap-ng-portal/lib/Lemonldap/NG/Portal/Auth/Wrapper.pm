# Base class for auth modules that call other auth modules (Choice,...)
#
# It fakes portal object to catch entry points and load them only if underlying
# auth module is activated
package Lemonldap::NG::Portal::Auth::Wrapper;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base';

# Current underlying auth module
has current => ( is => 'rw' );

has availableModules => ( is => 'rw', default => sub { {} } );

# loadModule() fakes portal loadModule()
sub loadPlugin {
    my ( $self, $name, $module ) = @_;
    my $obj = $self->p->can('loadPlugin')->( $self, $module );
    return $obj;
}

sub AUTOLOAD {

    # Unknown methods are tried with real portal
    my $self = shift;
    my $sub  = $AUTOLOAD;
    $sub =~ s/.*:://;
    if ( $self->p->can($sub) ) {
        return $self->p->$sub(@_);
    }
    die "Unknown method $sub";
}

1;
