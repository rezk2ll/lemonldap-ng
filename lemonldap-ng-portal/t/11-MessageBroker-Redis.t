use strict;
use Test::More;
use IO::String;
use Lemonldap::NG::Common::MessageBroker::Constants;
use Time::Fake;

BEGIN {
    require 't/test-lib.pm';
    require 't/redis/redis.pm';
}

SKIP: {
    unless ( $ENV{LLNGTESTREDIS} ) {
        skip "LLNGTESTREDIS isn't set", 1;
    }
    startRedis;
    my $client = LLNG::Manager::Test->new(
        {
            ini => {
                messageBroker        => '::Redis',
                messageBrokerOptions => {
                    server => REDISSERVER,
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
                    server => REDISSERVER,
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

eval { stopRedis };

clean_sessions();
done_testing();
