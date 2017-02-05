use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;
my $mainTests = 3;

eval { unlink 't/userdb.db' };

SKIP: {
    eval { require DBI; require DBD::SQLite; };
    if ($@) {
        skip 'DBD::SQLite not found', $mainTests;
    }
    my $dbh = DBI->connect("dbi:SQLite:dbname=t/userdb.db");
    $dbh->do('CREATE TABLE users (user text,password text,name text)');
    $dbh->do("INSERT INTO users VALUES ('dwho','dwho','Doctor who')");
    my $client = LLNG::Manager::Test->new(
        {
            ini => {
                logLevel                 => 'error',
                useSafeJail              => 1,
                authentication           => 'DBI',
                userDB                   => 'Same',
                dbiAuthChain             => 'dbi:SQLite:dbname=t/userdb.db',
                dbiAuthUser              => '',
                dbiAuthPassword          => '',
                dbiAuthTable             => 'users',
                dbiAuthLoginCol          => 'user',
                dbiAuthPasswordCol       => 'password',
                dbiAuthPasswordHash      => '',
                passwordDB               => 'DBI',
                portalRequireOldPassword => 1,
            }
        }
    );

    # Try yo authenticate
    # -------------------
    ok(
        $res = $client->_post(
            '/',
            IO::String->new('user=dwho&password=dwho'),
            length => 23
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
    clean_sessions();
}
eval { unlink 't/userdb.db' };
count($mainTests);
done_testing( count() );
