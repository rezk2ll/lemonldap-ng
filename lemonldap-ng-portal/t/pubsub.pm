use strict;
use IPC::Run qw(start finish);

our $pubsubPort  = 62987;
our $pubsubToken = 'aazz';

my $pubsub;

sub startPubsub {
    $pubsub = start [
        '../lemonldap-ng-common/scripts/pubsubWebServer',
        '--token' => $pubsubToken,
        '--port' => $pubsubPort,
        '--debug',
    ];
    print STDERR "# Pubsub server started\n";
    sleep 1;
}

sub stopPubsub {
    $pubsub->kill_kill;
}

1;
