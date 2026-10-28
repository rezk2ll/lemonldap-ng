use warnings;
use Test::More;
use strict;
use utf8;
use IO::String;

require 't/test-lib.pm';

my $res;
my $maintests = 4;

no warnings 'once';

SKIP: {
    skip 'LLNGTESTLDAP is not set', $maintests unless ( $ENV{LLNGTESTLDAP} );
    require 't/test-ldap.pm';

    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel                 => 'error',
                useSafeJail              => 1,
                authentication           => 'LDAP',
                portal                   => 'http://auth.example.com/',
                userDB                   => 'Same',
                passwordDB               => 'LDAP',
                portalRequireOldPassword => '$uid eq "dwho"',
                ldapServer               => $main::slapd_url,
                ldapBase                 => 'ou=users,dc=example,dc=com',
                managerDn                => 'cn=admin,dc=example,dc=com',
                managerPassword          => 'admin',
            }
        }
    );
    my $postString = 'user='
      . ( $ENV{LDAPACCOUNT} || 'dwho' )
      . '&password='
      . ( $ENV{LDAPPWD} || 'dwho' );

    # Try to authenticate with
    # the server temporarily offline (#2018)
    # --------------------------------------
    stopLdapServer();
    ok(
        $res = $client->_post(
            '/', IO::String->new($postString),
            length => length($postString)
        ),
        'Auth query'
    );

    expectReject( $res, 401, 6 );

    # Try to authenticate with the
    # server back online
    # ----------------------------
    startLdapServer();
    ok(
        $res = $client->_post(
            '/', IO::String->new($postString),
            length => length($postString)
        ),
        'Auth query'
    );
    expectOK($res);
    my $id = expectCookie($res);

    ok(
        $res = $client->_post(
            '/',
            IO::String->new(
                'oldpassword=dwho&newpassword=test&confirmpassword=test'),
            cookie => "lemonldap=$id",
            accept => 'application/json',
            length => 54
        ),
        'Change password'
    );
    expectOK($res);
    $client->logout($id);
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=test'),
            cookie => "lemonldap=$id",
            length => 23
        ),
        'Auth query with new password'
    );
    expectOK($res);
    $id = expectCookie($res);

    $client->logout($id);
}
count($maintests);

# Login values given by a federated provider skip userControl: they must
# only match literally in the LDAP filter
my $ldap = LLNG::Manager::Test->new( {
        ini => {
            logLevel       => 'error',
            authentication => 'LDAP',
            userDB         => 'Same',
            ldapServer     => 'ldap://127.0.0.1:1',
            ldapBase       => 'ou=users,dc=example,dc=com',
            AuthLDAPFilter =>
              '(&(|(uid=$user)(mail=$user))(objectClass=inetOrgPerson))',
            mailLDAPFilter => '(&(mail=$mail)(o=$o))',
        }
    }
)->p->_authentication->userdb_modules->{Default};
subtest 'Values are escaped in LDAP filters' => sub {
    is(
        $ldap->filter->( { user => 'x)(uid=dwho' } ),
        '(&(|(uid=x\29\28uid=dwho)(mail=x\29\28uid=dwho))'
          . '(objectClass=inetOrgPerson))',
        'Parentheses are escaped'
    );
    is(
        $ldap->filter->( { user => 'd*\\' } ),
        '(&(|(uid=d\2a\5c)(mail=d\2a\5c))(objectClass=inetOrgPerson))',
        'Wildcard and backslash are escaped'
    );
    is(
        $ldap->filter->( { user => 'dwho@badwolf.org' } ),
        '(&(|(uid=dwho@badwolf.org)(mail=dwho@badwolf.org))'
          . '(objectClass=inetOrgPerson))',
        'Plain value is unchanged'
    );
    is(
        $ldap->mailFilter->(
            { user => '*', sessionInfo => { o => 'a)(o=*' } }
        ),
        '(&(mail=\2a)(o=a\29\28o=\2a))',
        'Mail and session values are escaped'
    );
};
count(1);

clean_sessions();
done_testing( count() );
