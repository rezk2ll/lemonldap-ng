use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;
my $mainTests = 1;

SKIP: {
    skip 'No AD server given', $mainTests unless ( $ENV{ADSERVER} );

    my $client = LLNG::Manager::Test->new(
        {
            ini => {
                logLevel        => 'error',
                useSafeJail     => 1,
                authentication  => 'AD',
                userDB          => 'Same',
                LDAPFilter      => $ENV{ADFILTER} || '(cn=$user)',
                ldapServer      => $ENV{ADSERVER},
                ldapBase        => $ENV{ADBASE},
                managerDn       => $ENV{MANAGERDN} || '',
                managerPassword => $ENV{MANAGERPASSWORD} || '',
            }
        }
    );
    my $postString = 'user='
      . ( $ENV{ADACCOUNT} || 'dwho' )
      . '&password='
      . ( $ENV{ADPWD} || 'dwho' );

    # Try yo authenticate
    # -------------------
    ok(
        $res = $client->_post(
            '/', IO::String->new($postString),
            length => length($postString)
        ),
        'Auth query'
    );
    expectOK($res);
    my $id = expectCookie($res);
    $client->logout($id);

    clean_sessions();
}
count($mainTests);
done_testing( count() );
