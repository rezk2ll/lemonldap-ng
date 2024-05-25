use strict;
use Test::More;
use IO::String;
use Lemonldap::NG::Common::MessageBroker::Constants;
use Time::Fake;

our $noRedis;

BEGIN {
    require 't/test-lib.pm';
    eval 'use Redis';
    if ($@) {
        $noRedis++;
    }
    else {
        require 't/redis/redis.pm';
    }
}

SKIP: {
    skip( "LLNGTESTREDIS isn't set", 1 ) unless $ENV{LLNGTESTREDIS};
    skip( 'Redis is missing',        1 ) if $noRedis;
    &startRedis;
    my $client = LLNG::Manager::Test->new(
        {
            ini => {
                messageBroker        => '::Redis',
                messageBrokerOptions => {
                    server => &REDISSERVER,
                },
            }
        }
    );
    subtest "Simple login/logout" => sub {
        my $id = $client->login('dwho');
        $client->logout($id);
    };
    subtest "External logout" => sub {
        my $id  = $client->login('dwho');
        my $pub = Lemonldap::NG::Common::MessageBroker::Redis->new(
            {
                messageBrokerOptions => {
                    server => &REDISSERVER,
                },
            }
        );
        ok(
            unlink(
                $client->ini->{globalStorageOptions}->{Directory} . "/$id"
            ),
            'Delete session from global storage'
        );
        my $sd = $client->ini->{globalStorageOptions}->{Directory};
        note "Push unlog event";
        $pub->publish( EVENT_QUEUE, { action => 'unlog', id => $id } );
        Time::Fake->offset('+10s');
        my $res;
        ok( $res = $client->_get( '/', cookie => "lemonldap=$id" ),
            'Try / after 6 seconds' );
        expectReject($res);
    };
}

eval { &stopRedis };

clean_sessions();
done_testing();
