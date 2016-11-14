use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

eval { unlink 't/userdb.db' };

SKIP: {
    eval { require DBI; require DBD::SQLite; };
    if ($@) {
        skip 'DBD::SQLite not found', 8;
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
                userDB                   => 'DBI',
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
    ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
    my $cookies = $client->getCookies($res);
    my $id;
    ok( $id = $cookies->{lemonldap}, 'Get cookie' )
      or explain( $res, 'Set-Cookie: something' );

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
    ok( $res->[0] == 200, 'Response is 200' ) or explain( $res, 200 );
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
    ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
    $cookies = $client->getCookies($res);
    ok( $id = $cookies->{lemonldap}, 'Get cookie' )
      or explain( $res, 'Set-Cookie: something' );

    $client->logout($id);
    clean_sessions();
}
eval { unlink 't/userdb.db' };
count(8);
done_testing( count() );
