#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 1;

use strict;

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
SKIP: {
    eval { require feature; };
    skip
      "Perl feature non available, so lemonldap-ng-cli will not be useable", 1
      if ($@);
    use_ok('Lemonldap::NG::Manager::Cli');
}
