use Test::More;
use strict;
use IO::String;
use JSON;
use Lemonldap::NG::Portal::Main::Constants qw(PE_PP_PASSWORD_TOO_SHORT);

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel                 => 'error',
            passwordDB               => 'Demo',
            portalRequireOldPassword => 1,
            passwordPolicyMinSize    => 6,
        }
    }
);

# Try to authenticate
# -------------------
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23
    ),
    'Auth query'
);
count(1);
expectOK($res);
my $id = expectCookie($res);

# Test min size
ok(
    $res = $client->_post(
        '/',
        IO::String->new(
            'oldpassword=dwho&newpassword=test&confirmpassword=test'),
        cookie => "lemonldap=$id",
        accept => 'application/json',
        length => 54
    ),
    'Password min size not respected'
);
expectBadRequest($res);
my $json;
ok( $json = eval { from_json( $res->[2]->[0] ) }, 'Response is JSON' )
  or print STDERR "$@\n" . Dumper($res);
ok(
    $json->{error} == PE_PP_PASSWORD_TOO_SHORT,
    'Response is PE_PP_PASSWORD_TOO_SHORT'
) or explain( $json, "error => 29" );
count(3);

ok(
    $res = $client->_post(
        '/',
        IO::String->new(
            'oldpassword=dwho&newpassword=testok&confirmpassword=testok'),
        cookie => "lemonldap=$id",
        accept => 'application/json',
        length => 58
    ),
    'Password min size respected'
);
expectOK($res);
count(1);

# Test $client->logout
$client->logout($id);

clean_sessions();

done_testing( count() );
