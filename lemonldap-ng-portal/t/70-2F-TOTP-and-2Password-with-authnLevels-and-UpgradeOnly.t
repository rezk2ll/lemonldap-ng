use warnings;
use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';
require Lemonldap::NG::Common::TOTP;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel                   => 'error',
            checkUser                  => 1,
            sfOnlyUpgrade              => 1,
            totp2fSelfRegistration     => 1,
            totp2fActivation           => "\$targetAuthnLevel <= 10",
            totp2fAuthnLevel           => 10,
            handlerInternalCache       => 5,
            password2fSelfRegistration => 1,
            password2fActivation       => "\$targetAuthnLevel <= 5",
            password2fAuthnLevel       => 5,
            authentication             => 'Demo',
            userDB                     => 'Same',
            restSessionServer          => 1,
            vhostOptions               => {
                "test1.example.com" => {
                    vhostAuthnLevel => 5
                },
                "test2.example.com" => {
                    vhostAuthnLevel => 10
                }
            }

        }
    }
);
my $res;
my $id;
my $key;
my $keySecret;
my $token;
my $code;
subtest "Authenticate" => sub {

    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=dwho'),
            length => 23
        ),
        'Auth query'
    );
    $id = expectCookie($res);
    $client->logout($id);
};

subtest "Registering TOTP" => sub {

    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=dwho'),
            length => 23
        ),
        'Auth query'
    );
    $id = expectCookie($res);
    ok(
        $res = $client->_get(
            '/2fregisters/totp',
            cookie => "lemonldap=$id",
            accept => 'text/html'
        ),
        'Form registration'
    );
    ok( $res->[2]->[0] =~ /totpregistration\.(?:min\.)?js/, 'Found TOTP js' );

    # JS query
    ok(
        $res = $client->_post(
            '/2fregisters/totp/getkey', IO::String->new(''),
            cookie => "lemonldap=$id",
            length => 0,
        ),
        'Get new key'
    );
    eval { $res = JSON::from_json( $res->[2]->[0] ) };
    ok( not($@), 'Content is JSON' )
      or explain( $res->[2]->[0], 'JSON content' );
    ok( $keySecret = $res->{secret}, 'Found secret' );
    ok( $token     = $res->{token},  'Found token' );
    $key = Convert::Base32::decode_base32($keySecret);

    # Post code
    ok( $code = Lemonldap::NG::Common::TOTP::_code( undef, $key, 0, 30, 6 ),
        'Code' );
    ok( $code =~ /^\d{6}$/, 'Code contains 6 digits' );
    my $s = "code=$code&token=$token&TOTPName=MyTOTP";
    ok(
        $res = $client->_post(
            '/2fregisters/totp/verify',
            IO::String->new($s),
            length => length($s),
            cookie => "lemonldap=$id",
        ),
        'Post code'
    );
    eval { $res = JSON::from_json( $res->[2]->[0] ) };
    ok( not($@), 'Content is JSON' )
      or explain( $res->[2]->[0], 'JSON content' );
    ok( $res->{result} == 1, 'TOTP is registered' );

    Time::Fake->offset("+10s");
    $client->logout($id);
};

subtest 'Register Password 2FA' => sub {

    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=dwho'),
            length => 23
        ),
        'Auth query'
    );
    $id = expectCookie($res);
    ok( $res = $client->_get( '/', accept => 'text/html' ), 'Get Menu', );
    my ( $host, $url, $query ) =
      expectForm( $res, '#', undef, 'user', 'password' );

    $query =~ s/user=/user=dwho/;
    $query =~ s/password=/password=dwho/;
    ok(
        $res = $client->_post(
            '/',
            IO::String->new($query),
            length => length($query),
            accept => 'text/html',
        ),
        'Auth query'
    );
    my $id = expectCookie($res);
    expectRedirection( $res, 'http://auth.example.com/' );

    # Password form
    ok(
        $res = $client->_get(
            '/2fregisters',
            cookie => "lemonldap=$id",
            accept => 'text/html',
        ),
        'Form registration'
    );

    ok(
        $res = $client->_get(
            '/2fregisters/password',
            cookie => "lemonldap=$id",
            accept => 'text/html',
        ),
        'Form registration'
    );

    ok( $res->[2]->[0] =~ /password2fregistration\.(?:min\.)?js/,
        'Found password js' );

    my $s = "password=somethingyouknow&passwordverify=somethingyouknow";
    ok(
        $client->_post(
            '/2fregisters/password/verify',
            IO::String->new($s),
            length => length($s),
            cookie => "lemonldap=$id",
        )
    );
    $client->logout($id);
};

subtest "Check test1 vhost asks TOTP and 2Password" => sub {

    my $requestParams =
      'user=dwho&password=dwho&url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29t';
    ok(
        $res = $client->_post(
            '/',
            IO::String->new($requestParams),
            length => length($requestParams),
        ),
        'Auth query'
    );
    $key = Convert::Base32::decode_base32($keySecret);

    # Post code
    my ( $host, $url, $query ) =
      expectForm( $res, undef, '/2fchoice', 'token' );
};

subtest "Check test2 vhost asks only TOTP" => sub {

    my $requestParams =
      'user=dwho&password=dwho&url=aHR0cDovL3Rlc3QyLmV4YW1wbGUuY29t';
    ok(
        $res = $client->_post(
            '/',
            IO::String->new($requestParams),
            length => length($requestParams),
        ),
        'Auth query'
    );
    $key = Convert::Base32::decode_base32($keySecret);

    # Post code
    my ( $host, $url, $query ) =
      expectForm( $res, undef, '/totp2fcheck', 'token' );
    ok( $code = Lemonldap::NG::Common::TOTP::_code( undef, $key, 0, 30, 6 ),
        'Code' );
    $query =~ s/code=/code=$code/;
    ok(
        $res = $client->_post(
            '/totp2fcheck', IO::String->new($query),
            length => length($query),
        ),
        'Post code'
    );
    $id = expectCookie($res);
    $client->logout($id);
};

clean_sessions();
done_testing();
