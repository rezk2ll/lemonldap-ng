package Lemonldap::NG::Portal::Auth::Custom;

use strict;

sub new {
    my ( $class, $self ) = @_;
    unless ( $self->{conf}->{customAuth} ) {
        die 'Custom auth module not defined';
    }
    return $self->{p}->loadModule( $self->{conf}->{customAuth} );
}

1;
