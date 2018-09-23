use Test::More;
use strict;
use IO::String;

BEGIN {
    require 't/test-lib.pm';
}

my $res;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel            => 'error',
            authentication      => 'Demo',
            userDB              => 'Same',
            loginHistoryEnabled => 1,
            brutForceProtection => 1,
        }
    }
);

## First successful connection
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23,
        accept => 'text/html',
    ),
    'Auth query'
);
count(1);
my $id1 = expectCookie($res);
expectRedirection( $res, 'http://auth.example.com/' );

$client->logout($id1);

## Second successful connection
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23,
        accept => 'text/html',
    ),
    'Auth query'
);
count(1);
$id1 = expectCookie($res);
expectRedirection( $res, 'http://auth.example.com/' );

$client->logout($id1);


## First failed connection
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=ohwd'),
        length => 23
    ),
    'Auth query'
);
count(1);
expectReject($res);

## Second failed connection
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=ohwd'),
        length => 23
    ),
    'Auth query'
);
count(1);
expectReject($res);

## Third failed connection
my $start = time;
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=ohwd'),
        length => 23,
        accept => 'text/html',
    ),
    'Auth query'
);
my $stop = time;
count(1);

my $wait = $stop - $start;
ok($wait > 29 &&  $wait < 32, "Waiting time = $wait");
count(1);

clean_sessions();

done_testing( count() );
