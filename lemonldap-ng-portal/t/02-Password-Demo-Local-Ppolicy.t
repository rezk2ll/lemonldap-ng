use Test::More;
use strict;
use IO::String;
use JSON;
use Lemonldap::NG::Portal::Main::Constants
  qw(PE_PP_PASSWORD_TOO_SHORT PE_PP_INSUFFICIENT_PASSWORD_QUALITY);

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel                 => 'error',
            passwordDB               => 'Demo',
            portalRequireOldPassword => 1,
            passwordPolicyMinSize    => 6,
            passwordPolicyMinLower   => 3,
            passwordPolicyMinUpper   => 3,
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
# -------------
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
            'oldpassword=dwho&newpassword=TESTisok&confirmpassword=TESTisok'),
        cookie => "lemonldap=$id",
        accept => 'application/json',
        length => 62
    ),
    'Password min size respected'
);
expectOK($res);
count(1);

# Test min lower
# --------------
ok(
    $res = $client->_post(
        '/',
        IO::String->new(
            'oldpassword=dwho&newpassword=TESTLOWer&confirmpassword=TESTLOWer'),
        cookie => "lemonldap=$id",
        accept => 'application/json',
        length => 64
    ),
    'Password min lower not respected'
);
expectBadRequest($res);
my $json;
ok( $json = eval { from_json( $res->[2]->[0] ) }, 'Response is JSON' )
  or print STDERR "$@\n" . Dumper($res);
ok(
    $json->{error} == PE_PP_INSUFFICIENT_PASSWORD_QUALITY,
    'Response is PE_PP_INSUFFICIENT_PASSWORD_QUALITY'
) or explain( $json, "error => 28" );
count(3);

ok(
    $res = $client->_post(
        '/',
        IO::String->new(
            'oldpassword=dwho&newpassword=TESTlower&confirmpassword=TESTlower'),
        cookie => "lemonldap=$id",
        accept => 'application/json',
        length => 64
    ),
    'Password min lower respected'
);
expectOK($res);
count(1);

# Test min upper
# --------------
ok(
    $res = $client->_post(
        '/',
        IO::String->new(
            'oldpassword=dwho&newpassword=testUPper&confirmpassword=testUPper'),
        cookie => "lemonldap=$id",
        accept => 'application/json',
        length => 64
    ),
    'Password min upper not respected'
);
expectBadRequest($res);
my $json;
ok( $json = eval { from_json( $res->[2]->[0] ) }, 'Response is JSON' )
  or print STDERR "$@\n" . Dumper($res);
ok(
    $json->{error} == PE_PP_INSUFFICIENT_PASSWORD_QUALITY,
    'Response is PE_PP_INSUFFICIENT_PASSWORD_QUALITY'
) or explain( $json, "error => 28" );
count(3);

ok(
    $res = $client->_post(
        '/',
        IO::String->new(
            'oldpassword=dwho&newpassword=testUPPER&confirmpassword=testUPPER'),
        cookie => "lemonldap=$id",
        accept => 'application/json',
        length => 64
    ),
    'Password min upper respected'
);
expectOK($res);
count(1);

# Test $client->logout
$client->logout($id);

clean_sessions();

done_testing( count() );
