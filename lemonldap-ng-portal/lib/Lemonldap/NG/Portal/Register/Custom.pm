package Lemonldap::NG::Portal::Register::Custom;

use strict;

sub new {
    my ( $class, $self ) = @_;
    unless ( $self->{conf}->{customRegister} ) {
        die 'Custom register module not defined';
    }
    return $self->{p}->loadModule( $self->{conf}->{customRegister} );
}

1;
