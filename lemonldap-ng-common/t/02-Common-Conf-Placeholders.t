use warnings;
use strict;
use Test::More tests => 21;
use Data::Dumper;

BEGIN { use_ok('Lemonldap::NG::Common::Conf') }

use File::Temp;
my $dir = File::Temp::tempdir( CLEANUP => 1 );
my $h;

ok(
    $h = new Lemonldap::NG::Common::Conf( {
            type    => 'File',
            dirName => $dir,
        }
    ),
    'type => file',
);
my $conf = {
    cfgNum              => 1,
    test                => '%SERVERENV:A%',
    test2               => '%SERVERENV:B% %SERVERENV:C%',
    '%SERVERENV:MYKEY%' => {
        test  => 'Test: %SERVERENV:A%',
        array => [ 'a', '%SERVERENV:B% %SERVERENV:C%', ],
    },
};

$ENV{A}     = 'Aa';
$ENV{B}     = 'Bb';
$ENV{C}     = 'Cc';
$ENV{MYKEY} = 'MyKey';

ok( $h->store($conf) == 1, "Conf is stored" )
  or print STDERR "$Lemonldap::NG::Common::Conf::msg $!";
my $cfg;
ok( $cfg = $h->getConf( { cfgNum => 1 } ), "Conf can be read" )
  or print STDERR $Lemonldap::NG::Common::Conf::msg;
ok( $cfg->{test} eq '%SERVERENV:A%',
    '%SERVERENV:A% is not substitued into Aa without useServerEnv' )
  or print STDERR "Expect $cfg->{test} eq %SERVERENV:A%\n";

ok(
    $h = new Lemonldap::NG::Common::Conf( {
            type         => 'File',
            dirName      => "t/",
            useServerEnv => 1,
        }
    ),
    'type => file',
);
ok( $h->store($conf) == 1, "Conf is stored" )
  or print STDERR "$Lemonldap::NG::Common::Conf::msg $!";

ok( $cfg = $h->getConf( { cfgNum => 1 } ), "Conf can be read" )
  or print STDERR $Lemonldap::NG::Common::Conf::msg;
ok( $cfg->{test} eq 'Aa', '%SERVERENV:A% is substitued into Aa' )
  or print STDERR "Expect $cfg->{test} eq Aa\n";
ok( $cfg->{test2} eq 'Bb Cc',
    '%SERVERENV:B% %SERVERENV:C% is substitued into Bb Cc' )
  or print STDERR "Expect $cfg->{test} eq Aa\n";

ok( ( !$cfg->{'%SERVERENV:MYKEY%'} and $cfg->{MyKey} ),
    'Keyname is transformed' );
ok( (
              $cfg->{MyKey}->{array}->[0] eq 'a'
          and $cfg->{MyKey}->{array}->[1] eq 'Bb Cc'
    ),
    'Values are substitued into arrays'
);

ok( $cfg = $h->getConf( { cfgNum => 1, raw => 1 } ), 'Get raw conf' );
ok( $cfg->{test} eq '%SERVERENV:A%',
    '%SERVERENV:A% is not substitued into Aa in raw mode' )
  or print STDERR "Expect $cfg->{test} eq %SERVERENV:A%\n";

subtest "Check useServerEnv in config file in localConf" => sub {

    my ( $fh, $filename ) =
      File::Temp::tempfile( "lemonldap-ng.ini.XXXXXX", DIR => $dir );
    print $fh <<\EOF;
[all]
useSafeJail = 1
logLevel     = notice
checkTime = 1
myA = %SERVERENV:A%
myS = %SECRET:myS%

[configuration]
useServerEnv=1
configPlaceHolderModules=SECRET=t::Secrets
secretPlaceholderConfig=1
type=t::TestConfBackend
accessoption=%SERVERENV:MYKEY%

EOF
    close($fh);

    my $h = Lemonldap::NG::Common::Conf->new( {
            confFile => $filename,
        }
    );
    is( $h->{accessoption}, "MyKey",
        'configuration access option correctly replaced' );
    my $localConf = $h->getLocalConf();
    {
        is( $localConf->{myA}, "Aa", 'configuration variable replaced' );
        is( $localConf->{myS}, "secret-myS",
            'configuration variable replaced' );
    }
};

subtest "Check useServerEnv in build option in localConf" => sub {

    my ( $fh, $filename ) =
      File::Temp::tempfile( "lemonldap-ng.ini.XXXXXX", DIR => $dir );
    print $fh <<\EOF;
[all]
useSafeJail = 1
logLevel     = notice
checkTime = 1
myA = %SERVERENV:A%
myS = %SECRET:myS%

[configuration]
type=t::TestConfBackend
accessoption=%SERVERENV:MYKEY%

EOF
    close($fh);

    my $h = Lemonldap::NG::Common::Conf->new( {
            confFile     => $filename,
            useServerEnv => 1,
        }
    );
    is( $h->{accessoption}, "MyKey",
        'configuration access option correctly replaced' );
    my $localConf = $h->getLocalConf();
    {
        is( $localConf->{myA}, "Aa", 'configuration variable replaced' );
    }
};

subtest "No useServerEnv in localConf" => sub {

    my ( $fh, $filename ) =
      File::Temp::tempfile( "lemonldap-ng.ini.XXXXXX", DIR => $dir );
    print $fh <<\EOF;
[all]
useSafeJail = 1
logLevel     = notice
checkTime = 1
myA = %SERVERENV:A%
myS = %SECRET:myS%

[configuration]
type=t::TestConfBackend
accessoption=%SERVERENV:MYKEY%

EOF
    close($fh);

    my $h = Lemonldap::NG::Common::Conf->new( {
            confFile => $filename,
        }
    );
    is( $h->{accessoption}, "%SERVERENV:MYKEY%",
        'configuration access option not replaced' );
    my $localConf = $h->getLocalConf();
    {
        is( $localConf->{myA}, "%SERVERENV:A%",
            'configuration variable not replaced' );
        is( $localConf->{myS}, "%SECRET:myS%",
            'configuration variable not replaced' );
    }
};

require t::Placeholders;
my $phDir = File::Temp::tempdir( CLEANUP => 1 );

# Build a configuration access declaring t::Placeholders on the PH prefix
sub phAccess {
    return Lemonldap::NG::Common::Conf->new( {
            type                     => 'File',
            dirName                  => $phDir,
            configPlaceHolderModules => 'PH=t::Placeholders',
            @_,
        }
    );
}

subtest 'Fail-closed: a module which dies' => sub {
    my $h = phAccess();
    ok( $h->store( { cfgNum => 1, globalStorage => '%PH:die%' } ) == 1,
        'Conf is stored' )
      or print STDERR $Lemonldap::NG::Common::Conf::msg;

    $Lemonldap::NG::Common::Conf::msg = '';
    is( $h->getConf( { cfgNum => 1 } ), undef, 'Configuration is refused' );
    like(
        $Lemonldap::NG::Common::Conf::msg,
        qr/Error: placeholder %PH:die% could not be resolved: no such secret/,
        'Error is reported'
    );

    my $conf = { globalStorage => '%PH:die%' };
    ok( !$h->replacePlaceholders($conf), 'replacePlaceholders() fails' );
    is( $conf->{globalStorage}, '%PH:die%', 'Placeholder is left as is' );
};

subtest 'Fail-closed: a module which returns undef' => sub {
    my $h = phAccess();
    ok( $h->store( { cfgNum => 1, globalStorage => '%PH:undef%' } ) == 1,
        'Conf is stored' )
      or print STDERR $Lemonldap::NG::Common::Conf::msg;

    $Lemonldap::NG::Common::Conf::msg = '';
    is( $h->getConf( { cfgNum => 1 } ), undef, 'Configuration is refused' );
    like(
        $Lemonldap::NG::Common::Conf::msg,
qr/Error: placeholder %PH:undef% could not be resolved: module returned an undefined value/,
        'Error is reported'
    );

    my $conf = { globalStorage => 'a %PH:undef% b' };
    ok( !$h->replacePlaceholders($conf), 'replacePlaceholders() fails' );
    is( $conf->{globalStorage}, 'a %PH:undef% b', 'Placeholder is left as is' );
};

subtest 'An undefined environment variable is still an empty string' => sub {
    delete $ENV{LLNG_UNDEFINED_VARIABLE};
    my $h = phAccess( useServerEnv => 1 );
    ok(
        $h->store( {
                cfgNum        => 1,
                globalStorage => '%SERVERENV:LLNG_UNDEFINED_VARIABLE%',
                whatToTrace   => 'a %SERVERENV:LLNG_UNDEFINED_VARIABLE% b',
            }
        ) == 1,
        'Conf is stored'
    ) or print STDERR $Lemonldap::NG::Common::Conf::msg;

    $Lemonldap::NG::Common::Conf::msg = '';
    my $cfg = $h->getConf( { cfgNum => 1 } );
    ok( $cfg, 'Configuration is accepted' )
      or print STDERR $Lemonldap::NG::Common::Conf::msg;
    is( $cfg->{globalStorage}, '',
        'Whole value is replaced by an empty string' );
    is( $cfg->{whatToTrace}, 'a  b',
        'Nested value is replaced by an empty string' );
    unlike( $Lemonldap::NG::Common::Conf::msg, qr/Error:/, 'No error' );
};

subtest 'A reference is refused' => sub {
    my $h = phAccess();

    my $conf = { globalStorageOptions => '%PH:hash%' };
    $Lemonldap::NG::Common::Conf::msg = '';
    ok( !$h->replacePlaceholders($conf), 'replacePlaceholders() fails' );
    is( $conf->{globalStorageOptions},
        '%PH:hash%', 'Placeholder is left as is' );
    like(
        $Lemonldap::NG::Common::Conf::msg,
qr/Error: placeholder %PH:hash% could not be resolved: module returned a reference/,
        'Error is reported'
    );

    my $conf2 = { '%PH:hash%' => 'x' };
    $Lemonldap::NG::Common::Conf::msg = '';
    ok(
        !$h->replacePlaceholders($conf2),
        'replacePlaceholders() fails on a key'
    );
    ok( exists $conf2->{'%PH:hash%'}, 'Key is left as is' );
};

unlink 't/lmConf-1.json';
