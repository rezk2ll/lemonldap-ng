use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;
my $maintests = 2;

eval { unlink 't/userdb.db' };

SKIP: {
    eval { require DBI; require DBD::SQLite; };
    if ($@) {
        skip 'DBD::SQLite not found', $maintests;
    }
    skip 'LLNGTESTLDAP is not set', $maintests unless ( $ENV{LLNGTESTLDAP} );
    require 't/test-ldap.pm';
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

                ldapServer      => 'ldap://127.0.0.1:19389/',
                ldapBase        => 'ou=users,dc=example,dc=com',
                managerDn       => 'cn=admin,dc=example,dc=com',
                managerPassword => 'admin',
            }
        }
    );

    # Test LDAP and SQL
    foreach my $postString (
        'user=dwho&password=dwho&test=ldap',
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
count($maintests);
eval { unlink 't/userdb.db' };
stopLdapServer() if $ENV{LLNGTESTLDAP};
clean_sessions();
done_testing( count() );
