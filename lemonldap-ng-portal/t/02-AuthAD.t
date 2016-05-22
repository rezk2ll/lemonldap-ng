use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

SKIP: {
    skip 'No AD server given', 3 unless ( $ENV{ADSERVER} );

    init(
        {
            logLevel        => 'debug',
            useSafeJail     => 1,
            authentication  => 'AD',
            userDB          => 'AD',
            LDAPFilter      => $ENV{ADFILTER} || '(cn=$user)',
            ldapServer      => $ENV{ADSERVER},
            ldapBase        => $ENV{ADBASE},
            managerDn       => $ENV{MANAGERDN} || '',
            managerPassword => $ENV{MANAGERPASSWORD} || '',
        }
    );
    my $postString = 'user='
      . ( $ENV{ADACCOUNT} || 'dwho' )
      . '&password='
      . ( $ENV{ADPWD} || 'dwho' );

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
    logout($id);

    clean_sessions();
}
count(3);
done_testing( count() );
