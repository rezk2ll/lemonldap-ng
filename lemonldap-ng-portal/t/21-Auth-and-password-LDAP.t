use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

SKIP: {
    skip 'No LDAP server given', 1 unless ( $ENV{LDAPSERVER} );

    my $client = LLNG::Manager::Test->new(
        {
            ini => {
                logLevel        => 'error',
                useSafeJail     => 1,
                authentication  => 'LDAP',
                portal          => 'http://auth.example.com/',
                userDB          => 'Same',
                registerDB      => 'LDAP',
                LDAPFilter      => $ENV{LDAPFILTER} || '(cn=$user)',
                ldapServer      => $ENV{LDAPSERVER},
                ldapBase        => $ENV{LDAPBASE},
                managerDn       => $ENV{MANAGERDN} || '',
                managerPassword => $ENV{MANAGERPASSWORD} || '',
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
done_testing( count() );
