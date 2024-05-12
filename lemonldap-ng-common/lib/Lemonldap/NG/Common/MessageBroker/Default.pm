package Lemonldap::NG::Common::MessageBroker::Default;

# The default messages broker simply inserts periodically "checkConf" into
# llng_events.

use strict;

our $lastCheck = time;

sub new {
    my ( $class, $conf ) = @_;
    return bless {
        checkTime => $conf->{checkTime},
        channels  => {
            llng_events => [],
        }
      },
      $class;
}

sub publish {
    my ( $self, $channel, $msg ) = @_;
    $self->{channels}->{$channel} = []
      unless ref( $self->{channels}->{$channel} );
    push @{ $self->{channels}->{$channel} }, $msg;
}

sub subscribe { }

sub checkNextMessage {
    my ( $self, $channel ) = @_;
    my $now = time;
    if ( $now >= $lastCheck + $self->{checkTime} ) {
        $self->publish( 'llng_events', { action => 'checkConf' } );
    }
    if ( ref( $self->{channels}->{$channel} )
        and @{ $self->{channels}->{$channel} } )
    {
        return shift @{ $self->{channels}->{$channel} };
    }
}

sub getNextMessage {
    die __PACKAGE__ . ' is not a real message broker';
}

1;
