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
            authentication    => 'Demo',
            userdb            => 'Same',
            grantSessionRules => {
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

my $c = getCookies($res);
ok( not(%$c), 'No cookie' );
count(1);

&Lemonldap::NG::Handler::Main::cfgNum( 0, 0 );
$client = LLNG::Manager::Test->new(
    {
        ini => {
            authentication    => 'Demo',
            userdb            => 'Same',
            grantSessionRules => {
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
