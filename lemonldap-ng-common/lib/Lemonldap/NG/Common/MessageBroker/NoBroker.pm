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

sub applyConf {
    my ( $manager, $conf ) = @_;
    my $status;

    my $ua = $manager->ua;

    # Get apply section values
    my %reloadUrls =
      %{ $manager->confAcc->getLocalConf( APPLYSECTION, undef, 0 ) };
    if ( !%reloadUrls && $conf->{reloadUrls} ) {
        %reloadUrls = %{ $conf->{reloadUrls} };
    }
    return {} unless (%reloadUrls);

    $ua->timeout( $conf->{reloadTimeout} );

    # Parse apply values
    while ( my ( $host, $request ) = each %reloadUrls ) {
        my $r = HTTP::Request->new( 'GET', "http://$host$request" );
        $manager->logger->debug("Sending reload request to $host");
        if ( $request =~ /^https?:\/\/[^\/]+.*$/ ) {
            my $url       = URI::URL->new($request);
            my $targetUrl = $url->scheme . "://" . $host;
            $targetUrl .= ":" . $url->port if defined( $url->port );
            $targetUrl .= $url->full_path;
            $r =
              HTTP::Request->new( 'GET', $targetUrl,
                HTTP::Headers->new( Host => $url->host ) );
            if ( defined $url->userinfo
                && $url->userinfo =~ /^([^:]+):(.*)$/ )
            {
                $r->authorization_basic( $1, $2 );
            }
        }

        my $response = $ua->request($r);
        if ( $response->code != 200 ) {
            $status->{$host} =
              "Error " . $response->code . " (" . $response->message . ")";
            $manager->logger->error( "Apply configuration for $host: error "
                  . $response->code . " ("
                  . $response->message
                  . ")" );
        }
        else {
            $status->{$host} = "OK";
            $manager->logger->notice("Apply configuration for $host: ok");
        }
    }

    return $status;
}

1;
