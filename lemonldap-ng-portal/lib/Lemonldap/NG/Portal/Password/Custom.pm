package Lemonldap::NG::Portal::Password::Custom;

use strict;

sub new {
    my ( $class, $self ) = @_;
    unless ( $self->{conf}->{customPassword} ) {
        die 'Custom password module not defined';
    }
    return $self->{p}->loadModule( $self->{conf}->{customPassword} );
}

1;
