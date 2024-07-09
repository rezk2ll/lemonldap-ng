use warnings;
use Test::More;
use strict;
use IO::String;
use MIME::Base64;
use URI;
use URI::QueryParam;
use JSON;

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new( {
        ini => {
            customPlugins     => "t::Test2FA t::Test2FRegister t::sfHookPlugin",
            restSessionServer => 1,
            test2fSelfRegistration => 1,
            test2fActivation       => 'has2f("test")',
            sfRequired             => '$uid eq "dwho"',
        }
    }
);

subtest "Register 2FA on first login" => sub {
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=dwho'),
            length => 23,
        ),
        'Auth query'
    );
    my $pdata = expectCookie( $res, 'lemonldappdata' );
    expectRedirection( $res, "http://auth.example.com/2fregisters" );

    ok(
        $res = $client->_get(
            '/2fregisters',
            cookie => "lemonldappdata=$pdata",
            length => 23,
        ),
        'Auth query'
    );
    expectXpath( $res, '//a[@href="/2fregisters/test"]' );
    expectXpath( $res, '//span[@trspan="2fRegRequired"]' );
    $pdata = expectCookie( $res, 'lemonldappdata' );

    ok(
        $res = $client->_get(
            '/2fregisters/test',
            cookie => "lemonldappdata=$pdata",
            length => 23,
        ),
        'Auth query'
    );
    expectXpath( $res, '//span[@trspan="generic2fwelcome"]' );
    $pdata = expectCookie( $res, 'lemonldappdata' );

    ok(
        $res = $client->_post(
            '/2fregisters/test/register',
            {
                private => "myprivateinfo",
            },
            cookie => "lemonldappdata=$pdata",
        ),
        'Post code'
    );
    is( expectJSON($res)->{result}, 1, "Correct response" );

    ok(
        $res = $client->_get(
            '/2fregisters',
            accept => "text/html",
            query  => "continue=1",
            cookie => "lemonldappdata=$pdata",
        ),
        "Continue login"
    );

    expectRedirection( $res, "http://auth.example.com/" );
    my $id = expectCookie($res);
    expectSessionAttributes(
        $client, $id,
        uid                 => "dwho",
        _2f                 => "test",
        authenticationLevel => 7
    );
    my $devices = from_json( getPSession("dwho")->data->{_2fDevices} );
    is( $devices->[0]->{_private}, "myprivateinfo", "Correct private info" );
    is( $devices->[0]->{_hooked_attr},
        "1", "Hook can modify registered device" );
    is( $devices->[0]->{_hooked_type}, "test", "Hook can read device info" );
    is( $devices->[0]->{_hooked_uid},  "dwho", "Hook can read session info" );
    is( $devices->[0]->{type},         "test", "Correct type" );
};

subtest "Login with 2FA" => sub {
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=dwho'),
            length => 23,
        ),
        'Auth query'
    );

    my ( $host, $url, $query ) =
      expectForm( $res, undef, '/test2fcheck', 'token' );
    ok(
        $res = $client->_post(
            '/test2fcheck', IO::String->new($query),
            length => length($query),
            accept => 'text/html',
        ),
        'Post code'
    );
    my $id = expectCookie($res);
    expectSessionAttributes( $client, $id, uid => "dwho", _2f => "test" );
};

subtest "Register 2FA from logged in session" => sub {

    my $id = $client->login("rtyler");
    ok(
        $res = $client->_get(
            '/2fregisters',
            cookie => "lemonldap=$id",
            accept => 'text/html',
        ),
        '2FA manager'
    );
    expectRedirection( $res, qr#http://auth\.example\.com/2fregisters/test# );

    ok(
        $res = $client->_post(
            '/2fregisters/test/register',
            {
                private => "myprivateinfo",
            },
            cookie => "lemonldap=$id",
        ),
        'Post code'
    );
    is( expectJSON($res)->{result}, 1, "Correct response" );

    my $devices = from_json( getPSession("rtyler")->data->{_2fDevices} );
    is( $devices->[0]->{_private}, "myprivateinfo", "Correct private info" );
    is( $devices->[0]->{_hooked_attr}, "1",      "Private info added by hook" );
    is( $devices->[0]->{_hooked_type}, "test",   "Hook can read device info" );
    is( $devices->[0]->{_hooked_uid},  "rtyler", "Hook can read session info" );
    is( $devices->[0]->{type},         "test",   "Correct type" );
};

done_testing();
