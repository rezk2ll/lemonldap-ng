# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Manager-Sessions.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 1;
use strict;
use Cwd 'abs_path';
use File::Basename;

use Env qw($lmTestConfig);
$lmTestConfig = {
    configStorage => {
        type                => 'File',
        dirName             => dirname( abs_path($0) ),
    },
};

use_ok('Lemonldap::NG::Manager::Sessions');

$lmTestConfig = undef;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

__END__

