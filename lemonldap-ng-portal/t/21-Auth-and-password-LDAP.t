use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

SKIP: {
    skip 'LLNGTESTLDAP is not set', 1 unless ( $ENV{LLNGTESTLDAP} );
    require 't/test-ldap.pm';

    my $client = LLNG::Manager::Test->new(
        {
            ini => {
                logLevel        => 'error',
                useSafeJail     => 1,
                authentication  => 'LDAP',
                portal          => 'http://auth.example.com/',
                userDB          => 'Same',
                registerDB      => 'LDAP',
                ldapServer      => 'ldap://127.0.0.1:19389/',
                ldapBase        => 'dc=example,dc=com',
                managerDn       => '',
                managerPassword => '',
            }
        }
    );
    my $postString = 'user='
      . ( $ENV{LDAPACCOUNT} || 'dwho' )
      . '&password='
      . ( $ENV{LDAPPWD} || 'dwho' );

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
count(1);
stopLdapServer();
done_testing( count() );
