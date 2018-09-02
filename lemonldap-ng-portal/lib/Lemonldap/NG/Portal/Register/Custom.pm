package Lemonldap::NG::Portal::Register::Custom;

use strict;

sub new {
    my ( $class, $self ) = @_;
    unless ( $self->{conf}->{customRegister} ) {
        die 'Custom register module not defined';
    }

    eval $self->{p}->loadModule( $self->{conf}->{customRegister} );
    ($@)
      ? return $self->{p}->loadModule(
        $self->{conf}->{ customRegister )
        : die 'Unable to load register module '
          . $self->{conf}->{customRegister};
        }

      1;
