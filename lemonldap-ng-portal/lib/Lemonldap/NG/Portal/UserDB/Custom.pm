package Lemonldap::NG::Portal::UserDB::Custom;

use strict;

sub new {
    my ( $class, $self ) = @_;
    unless ( $self->{conf}->{customUserDB} ) {
        die 'Custom user DB module not defined';
    }
    return $self->{p}->loadModule( $self->{conf}->{customUserDB} );
}

1;
