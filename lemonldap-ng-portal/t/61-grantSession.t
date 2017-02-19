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
            authentication   => 'Demo',
            userdb           => 'Same',
            grantSessionRule => {
                no => '$uid ne "dwho"',
            }
        }
    }
);

ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23
    ),
    'Auth query'
);
count(1);
expectReject($res);

$client = LLNG::Manager::Test->new(
    {
        ini => {
            authentication   => 'Demo',
            userdb           => 'Same',
            grantSessionRule => {
                yes => '$uid eq "dwho"',
            }
        }
    }
);

ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23
    ),
    'auth query'
);
count(1);
expectOK($res);
expectCookie($res);

clean_sessions();

done_testing( count() );
