# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Manager.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 1;
use IO::String;
use strict;
use Cwd 'abs_path';
use File::Basename;
use File::Temp;

my $ini = File::Temp->new();
my $dir = dirname( abs_path($0) );

print $ini "[all]

[configuration]
type=File
dirName=$dir
";

$ini->flush();

use Env qw(LLNG_DEFAULTCONFFILE);
$LLNG_DEFAULTCONFFILE = $ini->filename;

use_ok('Lemonldap::NG::Manager');

$LLNG_DEFAULTCONFFILE = undef;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

__END__
$ENV{SCRIPT_NAME}     = "__SCRIPTNAME__";
$ENV{SCRIPT_FILENAME} = $0;
my $h;
our $buf;

tie *STDOUT, 'IO::String', $buf;
our $lastpos = 0;
