package Lemonldap::NG::Portal::Auth::Custom;

use strict;

# Fake 'new' method here. Return Lemonldap::NG::Portal::Auth::Custom::{CustomAuth}->new
sub new {
    my ( $class, $self ) = @_;
    unless ( $self->{conf}->{customAuth} ) {
        die 'Custom Auth module not defined';
    }

    my $res;
    eval { $res = $self->{p}->loadModule( $self->{conf}->{customAuth} ) };
    die 'Unable to load Auth module ' . $self->{conf}->{customAuth} if ($@);
    return $res;
}

1;
