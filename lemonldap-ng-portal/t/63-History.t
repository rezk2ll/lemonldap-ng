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
        }
    }
);

# Case "no history"
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
ok( $res->[2]->[0] =~ /trspan="noHistory"/, 'No history found' );
count(1);

ok( $res = $client->_get( '/', cookie => "lemonldap=$id1" ),
    'Verify connection' );
count(1);
expectOK($res);

$client->logout($id1);

# History with 1 success
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
count(1);

clean_sessions();

done_testing( count() );
