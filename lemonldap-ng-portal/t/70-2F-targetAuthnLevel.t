use warnings;
use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';
require Lemonldap::NG::Common::TOTP;

my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel             => 'error',
            totp2fActivation     => "\$targetAuthnLevel <= 10",
            password2fActivation => "\$targetAuthnLevel <= 5",
            authentication       => 'Demo',
            userDB               => 'Same',
            vhostOptions         => {
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

subtest "Check test1 vhost asks TOTP and 2Password" => sub {

    ok(
        $res = $client->_post(
            '/',
            {
                user     => "dwho",
                password => "dwho",
                url      => encodeUrl("http://test1.example.com"),
            }
        ),
        'Auth query'
    );
    expectXpath(
        $res,
        '//button[@name="sf" and @value="totp"]',
        "Found TOTP button"
    );
    expectXpath(
        $res,
        '//button[@name="sf" and @value="password"]',
        "Found password button"
    );
};

subtest "Check test2 vhost asks only TOTP" => sub {

    ok(
        $res = $client->_post(
            '/',
            {
                user     => "dwho",
                password => "dwho",
                url      => encodeUrl("http://test2.example.com"),
            }
        ),
        'Auth query'
    );
    expectXpath( $res, '//span[@trspan="enterTotpCode"]', "Found TOTP prompt" );
};

clean_sessions();
done_testing();
