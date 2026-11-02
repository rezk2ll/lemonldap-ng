# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Handler-SharedConf.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use Test::More tests => 3;
use Time::Fake;
use Time::Local;
use utf8;
require 't/test.pm';
BEGIN { use_ok('Lemonldap::NG::Handler::Main::Jail') }

sub doTest {
    my ($jail) = @_;

    # How many tests does this function perform
    plan tests => 56;

    my $res;
    my $sub  = "sub { return( basic(\@_) ) }";
    my $code = $jail->jail_reval($sub);
    ok( ( defined($code) ), 'basic extended function is defined' );
    is(
        $code->( 'login', 'pàssword' ),
        'Basic bG9naW46cMOgc3N3b3Jk',
        'basic() function returns correct result, UTF8'
    );
    is(
        $code->( 'login', 'pàssword', 1 ),
        'Basic bG9naW46cOBzc3dvcmQ=',
        'basic() function returns correct result, UTF8'
    );

    is( eval { $code->( 'login', "password\x{1f511}", 1 ) },
        undef, 'Character that cant be represented in ISO returns an error' );

    $sub  = "sub { return ( encode_base64(\@_) ) }";
    $code = $jail->jail_reval($sub);
    ok(
        ( defined($code) and ref($code) eq 'CODE' ),
        'encode_base64 function is defined'
    );
    ok( $res = $code->('test'), "Function works" );
    is( $res, 'dGVzdA==', 'Get good result' );

    is( $code->("Lemon\x{1f34b}"),
        'TGVtb27wn42L', '4bytes characters correctly encoded' );
    is( eval { $code->( "Lemon\x{1f34b}", 1 ) },
        undef, '4bytes characters cannot be encoded as ISO' );
    is( $code->("Test accentué"),
        'VGVzdCBhY2NlbnR1w6k=', 'Accents encoded as UTF-8' );
    is(
        $code->( "Test accentué", 1 ),
        'VGVzdCBhY2NlbnR16Q==',
        'Accents encoded as ISO8859-1'
    );

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

    $sub =
      "sub { return(checkDate('20000101000000+0100','21000101000000+0100')) }";
    $code = $jail->jail_reval($sub);
    ok(
        ( defined($code) and ref($code) eq 'CODE' ),
        'checkDate extended function is defined'
    );
    ok( $res = &$code, "Function works" );
    ok( $res == 1,     'Get good result' );

    # Test has2f method
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

    $sub  = "sub { return(checkLogonHours(\@_)) }";
    $code = $jail->jail_reval($sub);
    ok(
        ( defined($code) and ref($code) eq 'CODE' ),
        'checkLogonHours extended function is defined'
    );

    sub case_checkLogonHours {
        my ( $args, $hour, $day, $result ) = @_;
        my $test_ts =
          timegm( 0, 15, $hour, 7 + $day, 5, 126 )
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
}

subtest "Regular jail" => sub {
    ok(
        my $jail = Lemonldap::NG::Handler::Main::Jail->new(
            'jail'                 => undef,
            'useSafeJail'          => 1,
            'multiValuesSeparator' => '; ',
        ),
        'new jail object'
    );
    $jail->build_jail('Lemonldap::NG::Handler::Test');
    doTest($jail);
};

subtest "Fake jail" => sub {
    ok(
        my $jail = Lemonldap::NG::Handler::Main::Jail->new(
            'jail'                 => undef,
            'useSafeJail'          => 0,
            'multiValuesSeparator' => '; ',
        ),
        'new jail object'
    );
    $jail->build_jail('Lemonldap::NG::Handler::Test');
    doTest($jail);
};
