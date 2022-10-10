# Base package for 2F Register modules
package Lemonldap::NG::Portal::2F::Register::Base;

use strict;
use Mouse;

our $VERSION = '2.0.15';

extends 'Lemonldap::NG::Portal::Main::Plugin';

has logo          => ( is => 'rw', default => '2f.png' );
has label         => ( is => 'rw' );
has authnLevel    => ( is => 'rw' );
has userCanRemove => ( is => 'rw' );

sub init {
    my ($self) = @_;

    # Set logo if overridden
    $self->logo( $self->conf->{ $self->prefix . "2fLogo" } )
      if ( $self->conf->{ $self->prefix . "2fLogo" } );

    # Set label if provided, translation files will be used otherwise
    $self->label( $self->conf->{ $self->prefix . "2fLabel" } )
      if ( $self->conf->{ $self->prefix . "2fLabel" } );

    $self->authnLevel( $self->conf->{ $self->prefix . "2fAuthnLevel" } )
      if ( $self->conf->{ $self->prefix . "2fAuthnLevel" } );

    # Set whether the user can remove this registration
    $self->userCanRemove(
        $self->conf->{ $self->prefix . '2fUserCanRemoveKey' } )
      if ( $self->conf->{ $self->prefix . '2fUserCanRemoveKey' } );

    return 1;
}

1;
