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

sub getDisplayType {
    my ( $class, $self ) = @_;
    (         -e $self->{conf}->{templateDir}
            . "/../htdocs/static/common/modules/"
            . $self->{conf}->{customAuth}
            . ".png" ) ? return "logo" : return "standardform";
}

1;
