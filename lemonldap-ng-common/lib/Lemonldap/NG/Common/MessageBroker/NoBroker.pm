package Lemonldap::NG::Common::MessageBroker::NoBroker;

# The default messages broker simply inserts periodically "newConf" into
# llng_events.

use strict;
use Lemonldap::NG::Common::Conf::Constants;

our $VERSION = '2.20.0';

our $lastCheck = time;

our $channels = {};

sub new {
    my ( $class, $conf ) = @_;
    $channels->{ $conf->{eventQueueName} } //= [];
    return bless {
        checkTime      => $conf->{checkTime},
        eventQueueName => $conf->{eventQueueName},
    }, $class;
}

sub publish {
    my ( $self, $channel, $msg ) = @_;
    die unless $channel and $msg;
    $channels->{$channel} = []
      unless ref( $channels->{$channel} );
    push @{ $channels->{$channel} }, $msg;
}

sub subscribe { }

sub getNextMessage {
    my ( $self, $channel, $delay ) = @_;
    if ( time >= $lastCheck + $self->{checkTime} ) {
        $self->publish( $self->{eventQueueName}, { action => 'newConf' } );
        $lastCheck = time;
    }
    if ( ref( $channels->{$channel} )
        and @{ $channels->{$channel} } )
    {
        return shift @{ $channels->{$channel} };
    }
}

sub waitForNextMessage {
    my ( $self, $channel ) = @_;
    while (1) {
        if ( my $msg = $self->getNextMessage($channel) ) {
            return $msg;
        }
        sleep 1;
    }
}

1;
