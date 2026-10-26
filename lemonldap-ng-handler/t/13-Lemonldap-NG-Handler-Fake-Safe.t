# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Handler-SharedConf.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 44;
use Time::Fake;
use Time::Local;
require 't/test.pm';
BEGIN { use_ok('Lemonldap::NG::Handler::Main::Jail') }

#########################

# Insert your test code below, the Test::More module is used here so read
# its man page ( perldoc Test::More ) for help writing this test script.

ok(
    my $jail = Lemonldap::NG::Handler::Main::Jail->new(
        'jail'                 => undef,
        'useSafeJail'          => 0,
        'customFunctions'      => undef,
        'multiValuesSeparator' => '; ',
    ),
    'new fake jail object'
);
$jail->build_jail('Lemonldap::NG::Handler::Test');

my $sub1  = "sub { return( basic('login','password') ) }";
my $basic = $jail->jail_reval($sub1);
like(
    &$basic,
    '/^Basic bG9naW46cGFzc3dvcmQ=$/',
    'basic extended function working without Safe Jail'
);

my $sub2          = "sub { return ( encode_base64('test') ) }";
my $encode_base64 = $jail->jail_reval($sub2);
like( &$encode_base64, '/^dGVzdA==$/',
    'encode_base64 extended function working without Safe Jail' );

my $sub3      = "sub { return(checkDate('20000101000000','21000101000000')) }";
my $checkDate = $jail->jail_reval($sub3);
ok( &$checkDate == "1",
    'checkDate extended function working without Safe Jail' );

my $sub4 =
  "sub { return(checkDate('20000101000000+0100','21000101000000+0100')) }";
$checkDate = $jail->jail_reval($sub4);
ok( &$checkDate == "1",
    'checkDate extended function working without Safe Jail' );

my $sub5      = "sub { return ( listMatch('ABC; DEF; GHI','abc', 1) ) }";
my $listMatch = $jail->jail_reval($sub5);
ok( ( defined($listMatch) and ref($listMatch) eq 'CODE' ),
    'listMatch function is defined' );
ok( &$listMatch eq '1', 'Get good result' );

my $sub6 = "sub { return ( listMatch('ABC; DEF; GHI','ab', 1) ) }";
$listMatch = $jail->jail_reval($sub6);
ok( ( defined($listMatch) and ref($listMatch) eq 'CODE' ),
    'listMatch function is defined' );
ok( &$listMatch eq '0', 'Get good result' );

# Test has2f method
my $sub7  = "sub { return(has2f_internal(\$_[0],\$_[1])) }";
my $has2f = $jail->jail_reval($sub7);
ok(
    ( defined($has2f) and ref($has2f) eq 'CODE' ),
    'checkDate extended function is defined'
);
is(
    $has2f->( {
            _2fDevices =>
"[{\"name\":\"MyTOTP\",\"_secret\":\"g5fsxwf4d34biemlojsbbvhgtskrssos\",\"epoch\":1602173208,\"type\":\"TOTP\"}]"
        },
        "TOTP"
    ),
    1,
    "Function works"
);
is(
    $has2f->( {
            _2fDevices =>
"[{\"name\":\"MyTOTP\",\"_secret\":\"g5fsxwf4d34biemlojsbbvhgtskrssos\",\"epoch\":1602173208,\"type\":\"TOTP\"}]"
        },
    ),
    1,
    "Function works"
);
is(
    $has2f->( {
            _2fDevices =>
"[{\"name\":\"MyTOTP\",\"_secret\":\"g5fsxwf4d34biemlojsbbvhgtskrssos\",\"epoch\":1602173208,\"type\":\"TOTP\"}]"
        },
        "UBK"
    ),
    0,
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

$sub  = "sub { return(checkLogonHours(\@_)) }";
$code = $jail->jail_reval($sub);
ok(
    ( defined($code) and ref($code) eq 'CODE' ),
    'checkLogonHours extended function is defined'
);

sub case_checkLogonHours {
    my ( $args, $hour, $day, $result ) = @_;
    my $test_ts = timegm( 0, 15, $hour, 7 + $day, 5, 126 )
      ;    # June 2026 starts on a monday
    Time::Fake->offset($test_ts);
    is(
        $code->( @{$args} ),
        $result,
        "at "
          . scalar gmtime($test_ts)
          . ", checkLogonHours("
          . join( ', ', @{$args} ) . ") = "
          . ( $result ? "true" : "false" )
    );
    Time::Fake->reset;
}

my @clh_test_cases = (

    # No value, obey default
    [ [undef], 5, 1, 0 ],
    [ [ undef, undef, undef, 0 ], 5, 1, 0 ],
    [ [ undef, undef, undef, 1 ], 5, 1, 1 ],

    # Invalid value, deny
    [ [ "ffffff", undef, undef, 0 ], 5, 1, 0 ],
    [ [ "ffffff", undef, undef, 1 ], 5, 1, 0 ],

    # Workday behavior
    [ ["00000003ffe003ffe003ffe003ffe003ffe0000000"], "5",  "1", 0 ],
    [ ["00000003ffe003ffe003ffe003ffe003ffe0000000"], "6",  "1", 1 ],
    [ ["00000003ffe003ffe003ffe003ffe003ffe0000000"], "13", "1", 1 ],
    [ ["00000003ffe003ffe003ffe003ffe003ffe0000000"], "18", "1", 1 ],
    [ ["00000003ffe003ffe003ffe003ffe003ffe0000000"], "19", "1", 0 ],

    # Timezone offset
    [
        [ "00000003ffe003ffe003ffe003ffe003ffe0000000", undef, "+2" ],
        "3", "1", 0
    ],
    [
        [ "00000003ffe003ffe003ffe003ffe003ffe0000000", undef, "+2" ],
        "4", "1", 1
    ],
    [
        [ "00000003ffe003ffe003ffe003ffe003ffe0000000", undef, "+2" ],
        "11", "1", 1
    ],
    [
        [ "00000003ffe003ffe003ffe003ffe003ffe0000000", undef, "+2" ],
        "16", "1", 1
    ],
    [
        [ "00000003ffe003ffe003ffe003ffe003ffe0000000", undef, "+2" ],
        "17", "1", 0
    ],

    # Weekend
    [ ["00000003ffe003ffe003ffe003ffe003ffe0000000"], "13", "0", 0 ],
);

for my $case (@clh_test_cases) {
    case_checkLogonHours(@$case);
}
