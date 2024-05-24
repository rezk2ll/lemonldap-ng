package Lemonldap::NG::Common::MessageBroker::Default;

# The default messages broker simply inserts periodically "checkConf" into
# llng_events.

use strict;
use Lemonldap::NG::Common::MessageBroker::Constants;

our $lastCheck = time;

our $channels = {&EVENT_QUEUE => []};

sub new {
    my ( $class, $conf ) = @_;
    return bless {
        checkTime => $conf->{checkTime},
      },
      $class;
}

sub publish {
    my ( $self, $channel, $msg ) = @_;
    die unless $channel and $msg;
    $channels->{$channel} = []
      unless ref( $channels->{$channel} );
    push @{ $channels->{$channel} }, $msg;
}

sub subscribe { }

sub checkNextMessage {
    my ( $self, $channel, $delay ) = @_;
    if ( time >= $lastCheck + $self->{checkTime} ) {
        $self->publish( EVENT_QUEUE, { action => 'checkConf' } );
    }
    if ( ref( $channels->{$channel} )
        and @{ $channels->{$channel} } )
    {
        return shift @{ $channels->{$channel} };
    }
}

sub getNextMessage {
    my ( $self, $channel ) = @_;
    while(1) {
        if ( my $msg = $self->checkNextMessage($channel) ) {
            return $msg;
        }
        sleep 1;
    }
}

1;
