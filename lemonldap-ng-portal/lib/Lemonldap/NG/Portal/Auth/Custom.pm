package Lemonldap::NG::Portal::Auth::Custom;

use strict;

sub new {
    my ( $class, $self ) = @_;
    unless ( $self->{conf}->{customAuth} ) {
        die 'Custom Auth module not defined';
    }

    eval $self->{p}->loadModule( $self->{conf}->{customAuth} );
    ($@)
      ? return $self->{p}->loadModule( $self->{conf}->{customAuth} )
      : die 'Unable to load Auth module ' . $self->{conf}->{customAuth};
}

1;
