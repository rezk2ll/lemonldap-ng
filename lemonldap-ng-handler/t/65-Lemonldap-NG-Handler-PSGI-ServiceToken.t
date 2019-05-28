use Test::More;

BEGIN {
    require 't/test-psgi-lib.pm';
}

init(
    'Lemonldap::NG::Handler::Server',
    {
        logLevel               => 'error',
        handlerServiceTokenTTL => 2,
        vhostOptions           => {
            'test1.example.com' => {
                vhostHttps          => 0,
                vhostPort           => 80,
                vhostMaintenance    => 0,
                vhostServiceTokenTTL => 3,
            },
            'test2.example.com' => {
                vhostHttps          => 0,
                vhostPort           => 80,
                vhostMaintenance    => 0,
                vhostServiceTokenTTL => 5,
            }
        },
    }
);

my $res;
my $crypt = Lemonldap::NG::Common::Crypto->new('qwertyui');
my $token = $crypt->encrypt( join ':', time, $sessionId, 'test1.example.com', 'test2.example.com', '*.example.com' );

ok(
    $res = $client->_get(
        '/', undef, 'test1.example.com', undef,
        VHOSTTYPE           => 'ServiceToken',
        'HTTP_X_LLNG_TOKEN' => $token,
    ),
    'Query with token'
);
ok( $res->[0] == 200, 'Code is 200' ) or explain( $res->[0], 200 );
count(2);

diag 'Waiting';
sleep 2;

ok(
    $res = $client->_get(
        '/', undef, 'test1.example.com', undef,
        VHOSTTYPE           => 'ServiceToken',
        'HTTP_X_LLNG_TOKEN' => $token,
    ),
    'Query with token'
);
ok( $res->[0] == 200, 'Code is 200' ) or explain( $res->[0], 200 );
count(2);

diag 'Waiting';
sleep 1;

ok(
    $res = $client->_get(
        '/', undef, 'test1.example.com', undef,
        VHOSTTYPE           => 'ServiceToken',
        'HTTP_X_LLNG_TOKEN' => $token,
    ),
    'Query with token'
);
ok( $res->[0] == 302, 'Code is 200' ) or explain( $res->[0], 302 );
count(2);

diag 'Waiting';
sleep 1;

ok(
    $res = $client->_get(
        '/', undef, 'test2.example.com', undef,
        VHOSTTYPE           => 'ServiceToken',
        'HTTP_X_LLNG_TOKEN' => $token,
    ),
    'Query with token'
);
ok( $res->[0] == 200, 'Code is 200' ) or explain( $res->[0], 200 );
count(2);

diag 'Waiting';
sleep 1;

ok(
    $res = $client->_get(
        '/', undef, 'test2.example.com', undef,
        VHOSTTYPE           => 'ServiceToken',
        'HTTP_X_LLNG_TOKEN' => $token,
    ),
    'Query with token'
);
ok( $res->[0] == 302, 'Code is 302' ) or explain( $res->[0], 302 );
count(2);

ok(
    $res = $client->_get(
        '/', undef, 'test3.example.com', undef,
        VHOSTTYPE           => 'ServiceToken',
        'HTTP_X_LLNG_TOKEN' => $token,
    ),
    'Query with token'
);
ok( $res->[0] == 302, 'Code is 302' ) or explain( $res->[0], 302 );
count(2);

$token = $crypt->encrypt( join ':', time, $sessionId, '' );
ok(
    $res = $client->_get(
        '/', undef, 'test2.example.com', undef,
        VHOSTTYPE           => 'ServiceToken',
        'HTTP_X_LLNG_TOKEN' => $token,
    ),
    'Query with token'
);
ok( $res->[0] == 302, 'Code is 302' ) or explain( $res->[0], 302 );
count(2);

done_testing( count() );

clean();
