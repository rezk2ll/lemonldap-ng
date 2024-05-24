package Lemonldap::NG::Common::MessageBroker::Redis;

use strict;
use Redis;
use JSON;

our $VERSION = '2.0.18';

sub new {
    my $self   = bless {}, shift;
    my (%args) = @_;

    # Reconnection parameters
    #  - try to reconnect every 1s up to 60s
    $args{reconnect} //= 60;
    $args{every}     //= 1000000;
    $self->{redis}    = Redis->new(%args);
    $self->{messages} = {};
    return $self;
}

sub publish {
    my ( $self, $channel, $msg ) = @_;
    die 'Not a hash msg' unless ref $msg eq 'HASH';
    my $j = eval { JSON::to_json($msg) };
    die "MessageBroker publish only hashes! $@" if $@;
    $self->{redis}->publish( $channel, $j );
}

sub subscribe {
    my ( $self, $channel ) = @_;
    $self->{messages}{$channel} = [];
    $self->{redis}->subscribe(
        $channel,
        sub {
            my $tmp = eval { JSON::from_json( $_[0] ) };
            if ($@) {
                print STDERR "Bad message from Redis: $@";
            }
            else {
                push @{ $self->{messages}{$channel} }, JSON::from_json( $_[0] );
            }
        }
    );
}

sub checkNextMessage {
    my ( $self, $channel ) = @_;
    return undef
      unless $self->{messages}{$channel};
    return shift( @{ $self->{messages}{$channel} } )
      if @{ $self->{messages}{$channel} };
    $self->{redis}->wait_for_messages(0.1);
    return shift( @{ $self->{messages}{$channel} } )
      if @{ $self->{messages}{$channel} };
    return;
}

sub getNextMessage {
    my ( $self, $channel ) = @_;
    return undef
      unless $self->{messages}{$channel};

    # Infinite loop until one message is seen
    $self->{redis}->wait_for_messages(1)
      while ( !@{ $self->{messages}{$channel} } );
    return shift( @{ $self->{messages}{$channel} } );
}

1;
