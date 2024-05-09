use warnings;
use Test::More;
use strict;
use IO::String;
use MIME::Base64;
use URI;
use URI::QueryParam;

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new( {
        ini => {
            customPlugins          => "t::Test2FA t::Test2FRegister",
            restSessionServer      => 1,
            test2fSelfRegistration => 1,
            test2fActivation       => 1,
        }
    }
);

ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23,
    ),
    'Auth query'
);
count(1);
expectOK($res);

my ( $host, $url, $query ) = expectForm( $res, undef, '/test2fcheck', 'token' );
ok(
    $res = $client->_post(
        '/test2fcheck', IO::String->new($query),
        length => length($query),
        accept => 'text/html',
    ),
    'Post code'
);
count(1);

my $id = expectCookie($res);
expectSessionAttributes( $client, $id, uid => "dwho", _2f => "test" );

ok(
    $res = $client->_get(
        '/2fregisters',
        cookie => "lemonldap=$id",
        accept => 'text/html',
    ),
    '2FA manager'
);
count(1);
expectRedirection( $res, qr#http://auth\.example\.com/2fregisters/test# );

done_testing( count() );
