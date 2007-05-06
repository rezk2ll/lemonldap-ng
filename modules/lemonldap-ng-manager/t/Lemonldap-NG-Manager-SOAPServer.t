# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Manager-SOAPServer.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 3;

# SOAP::Lite is not required, so Lemonldap::NG::Manager::Conf::SOAP may
# not run.
SKIP: {
    eval { require SOAP::Transport::HTTP };
    skip "SOAP::Transport::HTTP is not installed, so Lemonldap::NG::Manager::SOAPServer will not be useable",
      3
      if ($@);
    use_ok('Lemonldap::NG::Manager::SOAPServer');
    my $s;
    ok ( $s = Lemonldap::NG::Manager::SOAPServer->new (
            type => 'config',
            configStorage => {
                type    => 'File',
                dirName => '.',
            }
      )
    );
    eval { require Apache::Session::File };
    skip "Apache::Session::File is not installed. Lemonldap::NG::Manager::SOAPServer will not be tested in 'sessions' mode",
      1
      if ($@);
    ok ( $s = Lemonldap::NG::Manager::SOAPServer->new (
            type => 'sessions',
            realSessionStorage => 'Apache::Session::File',
      )
    );
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

