# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Handler-SharedConf.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use Test::More tests => 33;
require 't/test.pm';
BEGIN { use_ok('Lemonldap::NG::Handler::Main::Jail') }

#########################

# Insert your test code below, the Test::More module is used here so read
# its man page ( perldoc Test::More ) for help writing this test script.
my $res;

ok(
    my $jail = Lemonldap::NG::Handler::Main::Jail->new(
        'jail'                 => undef,
        'useSafeJail'          => 1,
        'multiValuesSeparator' => '; ',
    ),
    'new jail object'
);
$jail->build_jail('Lemonldap::NG::Handler::Test');

my $sub   = "sub { return( basic('login','password') ) }";
my $basic = $jail->jail_reval($sub);
ok( ( defined($basic) ), 'basic extended function is defined' );

$sub = "sub { return ( encode_base64('test','') ) }";
my $code = $jail->jail_reval($sub);
ok(
    ( defined($code) and ref($code) eq 'CODE' ),
    'encode_base64 function is defined'
);
ok( $res = &$code,      "Function works" );
ok( $res eq 'dGVzdA==', 'Get good result' );

$sub  = "sub { return ( listMatch('ABC; DEF; GHI','abc',1) ) }";
$code = $jail->jail_reval($sub);
ok( ( defined($code) and ref($code) eq 'CODE' ),
    'listMatch function is defined' );
ok( &$code eq '1', 'Get good result' );

$sub  = "sub { return ( listMatch('ABC; DEF; GHI','ab',1) ) }";
$code = $jail->jail_reval($sub);
ok( ( defined($code) and ref($code) eq 'CODE' ),
    'listMatch function is defined' );
ok( &$code eq '0', 'Get good result' );

$sub  = "sub { return(checkDate('20000101000000','21000101000000')) }";
$code = $jail->jail_reval($sub);
ok(
    ( defined($code) and ref($code) eq 'CODE' ),
    'checkDate extended function is defined'
);
ok( $res = &$code, "Function works" );
ok( $res == 1,     'Get good result' );

$sub = "sub { return(checkDate('20000101000000+0100','21000101000000+0100')) }";
$code = $jail->jail_reval($sub);
ok(
    ( defined($code) and ref($code) eq 'CODE' ),
    'checkDate extended function is defined'
);
ok( $res = &$code, "Function works" );
ok( $res == 1,     'Get good result' );

$sub  = "sub { return(has2f_internal(\$_[0],\$_[1])) }";
$code = $jail->jail_reval($sub);
ok(
    ( defined($code) and ref($code) eq 'CODE' ),
    'checkDate extended function is defined'
);
is(
    $code->( {
            _2fDevices =>
"[{\"name\":\"MyTOTP\",\"_secret\":\"g5fsxwf4d34biemlojsbbvhgtskrssos\",\"epoch\":1602173208,\"type\":\"TOTP\"}]"
        },
        "TOTP"
    ),
    1,
    "Function works"
);
is(
    $code->( {
            _2fDevices =>
"[{\"name\":\"MyTOTP\",\"_secret\":\"g5fsxwf4d34biemlojsbbvhgtskrssos\",\"epoch\":1602173208,\"type\":\"TOTP\"}]"
        },
        "UBK"
    ),
    0,
    "Function works"
);
is(
    $code->( {
            _2fDevices =>
"[{\"name\":\"MyTOTP\",\"_secret\":\"g5fsxwf4d34biemlojsbbvhgtskrssos\",\"epoch\":1602173208,\"type\":\"TOTP\"}]"
        },
    ),
    1,
    "Function works"
);

$sub  = "sub { return()";
$code = $jail->jail_reval($sub);
ok( ( not defined($code) ), 'Syntax error yields undef result' );
like(
    $jail->error,
    qr/(?:Missing right curly or square bracket|Syntax error)/i,
    'Found correct error message'
);

$sub  = "sub { return(subjectid(\@_)) }";
$code = $jail->jail_reval($sub);
ok(
    ( defined($code) and ref($code) eq 'CODE' ),
    'subjectid extended function is defined'
);
is(
    $code->( "abc", "def" ),
    "xj4bnp4pahh6uqkbidpf3lrceoyagyndsylxvhfucd7wd4qacwwq\@def",
    "subjectid works as expected"
);

is(
    $code->( "abc", "def", "salt" ),
    "c2ntukyjo7v64lvr7u4sy2veocrsqhkdt7zs6if25jzqtv7ub3wa\@def",
    "subjectid works as expected"
);

is(
    $code->("abc"),
    "xj4bnp4pahh6uqkbidpf3lrceoyagyndsylxvhfucd7wd4qacwwq",
    "subjectid works as expected"
);

$sub  = "sub { return(bin2guid(\@_)) }";
$code = $jail->jail_reval($sub);
ok(
    ( defined($code) and ref($code) eq 'CODE' ),
    'bin2guid extended function is defined'
);
is(
    $code->( pack( 'H*', 'b82a1f8dc111ac45be3bce4f62767504' ) ),
    "8d1f2ab8-11c1-45ac-be3b-ce4f62767504",
    "bin2guid works as expected"
);
is( $code->( pack( 'H*', 'b82a1f8dc111ac45be3bce4f627675' ) ),
    undef, "bin2guid fails on invalid input" );

$sub  = "sub { return(guid2bin(\@_)) }";
$code = $jail->jail_reval($sub);
ok(
    ( defined($code) and ref($code) eq 'CODE' ),
    'guid2bin extended function is defined'
);
is(
    $code->("8d1f2ab8-11c1-45ac-be3b-ce4f62767504"),
    pack( 'H*', 'b82a1f8dc111ac45be3bce4f62767504' ),
    "guid2bin works as expected"
);
is(
    $code->("8D1F2AB8-11C1-45AC-BE3B-CE4F62767504"),
    pack( 'H*', 'b82a1f8dc111ac45be3bce4f62767504' ),
    "guid2bin works as expected"
);
is( $code->("8d1f2ab8-11c1-45ac-be3b-ce4f627504"),
    undef, "guid2bin fails on invalid input" );
