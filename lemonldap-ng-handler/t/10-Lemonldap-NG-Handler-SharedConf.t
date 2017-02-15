# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Handler-SharedConf.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 6;
use Cwd 'abs_path';
use File::Basename;
use File::Temp;
require 't/test.pm';

my $ini = File::Temp->new();
my $dir = dirname( abs_path($0) );
my $tmp = File::Temp::tempdir();

print $ini "[all]

logLevel = warn

[configuration]
type=File
dirName=$dir
localStorage=Cache::FileCache
localStorageOptions={                             \\
    'namespace'          => 'lemonldap-ng-config',\\
    'default_expires_in' => 600,                  \\
    'directory_umask'    => '007',                \\
    'cache_root'         => '$tmp',               \\
    'cache_depth'        => 0,                    \\
}

";

$ini->flush();

use Env qw(LLNG_DEFAULTCONFFILE);
$LLNG_DEFAULTCONFFILE = $ini->filename;

#open STDERR, '>/dev/null';

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use_ok('Lemonldap::NG::Handler::Main');

my $ret;

our $apacheRequest;

my $h = 'Lemonldap::NG::Handler::Test';

ok( $h->init(), 'Initialize handler' );

ok( $h->checkType($apacheRequest) eq 'Main', 'Get Main type' );

ok( $ret = $h->run($apacheRequest),
    'run Handler with basic configuration and no cookie' );

ok( $ret = 302, 'Return code is 302' );

ok(
    $Lemonldap::NG::Handler::Test::header eq
'Location:http://auth.example.com/?url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==',
    'testing redirection URL from previous run'
) or print STDERR "Got: $Lemonldap::NG::Handler::Test::header\n";

