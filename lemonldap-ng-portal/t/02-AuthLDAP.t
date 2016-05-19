use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

SKIP: {
    skip 'No LDAP server given', 3 unless ( $ENV{LDAPSERVER} );

    init(
        {
            logLevel        => 'debug',
            useSafeJail     => 1,
            authentication  => 'LDAP',
            userDB          => 'LDAP',
            LDAPFilter      => $ENV{LDAPFILTER} || '(cn=$user)',
            ldapServer      => $ENV{LDAPSERVER},
            ldapBase        => $ENV{LDAPBASE},
            managerDn       => $ENV{MANAGERDN} || '',
            managerPassword => $ENV{MANAGERPASSWORD} || '',
        }
    );
    my $postString = 'user='
      . ( $ENV{LDAPACCOUNT} || 'dwho' )
      . '&password='
      . ( $ENV{LDAPPWD} || 'dwho' );

    # Try yo authenticate
    # -------------------
    ok(
        $res = &client->_post(
            '/', '',
            IO::String->new($postString),
            'application/x-www-form-urlencoded',
            length($postString)
        ),
        'Auth query'
    );
    ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
    my $cookies = getCookies($res);
    my $id;
    ok( $id = $cookies->{lemonldap}, 'Get cookie' )
      or explain( $res, 'Set-Cookie: something' );

    clean_sessions();
}
count(3);
done_testing( count() );
