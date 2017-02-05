use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;
my $mainTests = 2;

eval { unlink 't/userdb.db' };

SKIP: {
    eval { require DBI; require DBD::SQLite; };
    if ($@) {
        skip 'DBD::SQLite not found', $mainTests;
    }
    elsif ( !$ENV{LDAPSERVER} ) {
        skip 'No LDAP server given', $mainTests;
    }
    my $dbh = DBI->connect("dbi:SQLite:dbname=t/userdb.db");
    $dbh->do('CREATE TABLE users (user text,password text,name text)');
    $dbh->do("INSERT INTO users VALUES ('dwho','dwho','Doctor who')");

    my $client = LLNG::Manager::Test->new(
        {
            ini => {
                logLevel       => 'error',
                useSafeJail    => 1,
                authentication => 'Choice',
                userDB         => 'Same',

                authChoiceParam   => 'test',
                authChoiceModules => {
                    ldap => 'LDAP;LDAP;LDAP',
                    sql  => 'DBI;DBI;DBI',
                },

                dbiAuthChain        => 'dbi:SQLite:dbname=t/userdb.db',
                dbiAuthUser         => '',
                dbiAuthPassword     => '',
                dbiAuthTable        => 'users',
                dbiAuthLoginCol     => 'user',
                dbiAuthPasswordCol  => 'password',
                dbiAuthPasswordHash => '',

                LDAPFilter      => $ENV{LDAPFILTER}      || '(cn=$user)',
                ldapServer      => $ENV{LDAPSERVER},
                ldapBase        => $ENV{LDAPBASE},
                managerDn       => $ENV{MANAGERDN}       || '',
                managerPassword => $ENV{MANAGERPASSWORD} || '',
            }
        }
    );

    # Test LDAP and SQL
    foreach my $postString (
          'user='
        . ( $ENV{LDAPACCOUNT} || 'dwho' )
        . '&password='
        . ( $ENV{LDAPPWD} || 'dwho' )
        . '&test=ldap',
        'user=dwho&password=dwho&test=sql'
      )
    {

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
    }

    clean_sessions();
}
count($mainTests);
eval { unlink 't/userdb.db' };
done_testing( count() );
