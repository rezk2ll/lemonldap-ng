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
        IO::String->new('user=dwho&password=dwho&checkLogins=1'),
        length => 37,
        accept => 'text/html',
    ),
    'Auth query'
);
count(1);
expectOK($res);
my $id1 = expectCookie($res);
ok( $res->[2]->[0] =~ /trspan="lastLogins"/, 'History found' )
  or explain( $res->[2]->[0], 'trspan="noHistory"' );
my @c = ( $res->[2]->[0] =~ /<td>127.0.0.1/gs );

# History with 1 successLogin
ok( @c == 1, " -> One entry found" );
count(2);

ok( $res = $client->_get( '/', cookie => "lemonldap=$id1" ),
    'Verify connection' );
count(1);
expectOK($res);

$client->logout($id1);

## Second successful connection
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho&checkLogins=1'),
        length => 37,
        accept => 'text/html',
    ),
    'Auth query'
);
count(1);
expectOK($res);
$id1 = expectCookie($res);

ok( $res->[2]->[0] =~ /trspan="lastLogins"/, 'History found' );
@c = ( $res->[2]->[0] =~ /<td>127.0.0.1/gs );

# History with 2 success
ok( @c == 2, ' -> Two entries found' );
count(2);

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

## Third successful connection
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho&checkLogins=1'),
        length => 37,
        accept => 'text/html',
    ),
    'Auth query'
);
count(1);
expectOK($res);
$id1 = expectCookie($res);

ok( $res->[2]->[0] =~ /trspan="lastLogins"/, 'History found' );
@c = ( $res->[2]->[0] =~ /<td>127.0.0.1/gs );
my @cf = ( $res->[2]->[0] =~ /PE5<\/td>/gs );

# History with 5 success
ok( @c == 5, ' -> Five entries found' );
ok( @cf == 2, "  -> Two 'failedLogin' entries found" );
count(3);

$client->logout($id1);
clean_sessions();

done_testing( count() );
