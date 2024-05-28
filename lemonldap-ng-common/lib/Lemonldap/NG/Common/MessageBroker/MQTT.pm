package Lemonldap::NG::Common::MessageBroker::MQTT;

use strict;
use Net::MQTT::Simple;
use Time::HiRes 'usleep';

our $VERSION = '2.20.0';

sub new {
    my $args = $_[1]->{messageBrokerOptions};
    $args //= {};
    $args->{server} ||= 'localhost:1883';
    my $mqtt;
    if ( $args->{ssl} ) {
        require Net::MQTT::Simple::SSL;
        my $h = {};
        $h->{$_} = $args->{$_}
          foreach (qw(SSL_ca_file SSL_cert_file SSL_key_file));
        $mqtt = Net::MQTT::Simple::SSL->new( $args->{server}, $h );
        if ( $args->{user} ) {
            $mqtt->login( $args->{user}, $args->{password} );
        }
    }
    else {
        $mqtt = Net::MQTT::Simple->new( $args->{server} );
    }
    unless ($mqtt) {
        print STDERR "Unalble to connect to MQTT server $@$!";
        return;
    }
    my $self = bless { mqtt => $mqtt, _ch => [] }, shift;
    return $self;
}

sub publish {
    my ( $self, $channel, $msg ) = @_;
    die 'Not a hash msg' unless ref $msg eq 'HASH';
    my $j = eval { JSON::to_json($msg) };
    die "MessageBroker publish only hashes! $@" if $@;
    $self->{mqtt}->publish( "llng/$channel", $j );

    # Wait a little to get the new event in local stack
    usleep 100000;
}

sub subscribe {
    my ( $self, $channel ) = @_;
    $self->{messages}{$channel} = [];
    $self->{mqtt}->subscribe(
        "llng/$channel",
        sub {
            return unless $_[1];
            $_[0] =~ s#llng/##;
            my $tmp = eval { JSON::from_json( $_[1] ) };
            if ($@) {
                print STDERR "Bad message from MQTT server: $@";
            }
            else {
                push @{ $self->{messages}{ $_[0] } }, $tmp;
            }
        }
    );
    push @{ $self->{_ch} }, "llng/$channel";
}

sub DESTROY {
    my ($self) = @_;
    eval {
        ( $self->{mqtt} && $self->{mqtt}->unsubscribe($_) )
          foreach ( @{ $self->{_ch} } );
    };
    print STDERR $@ if $@;
}

sub checkNextMessage {
    my ( $self, $channel, $delay ) = @_;
    return undef unless $self->{messages}{$channel};
    return shift( @{ $self->{messages}{$channel} } )
      if @{ $self->{messages}{$channel} };
    $self->{mqtt}->tick( $delay // 0 );
    return shift( @{ $self->{messages}{$channel} } )
      if @{ $self->{messages}{$channel} };
    return;
}

sub getNextMessage {
    my ( $self, $channel ) = @_;
    return undef
      unless $self->{messages}{$channel};

    # Infinite loop until one message is seen
    my $res;
    while ( !$res ) {
        $res = $self->{redis}->checkNextMessage( $channel, 1 );
    }
    return $res;
}

1;
