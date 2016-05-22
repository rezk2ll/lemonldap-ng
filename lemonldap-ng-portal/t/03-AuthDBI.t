use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

eval { unlink 't/userdb.db' };

SKIP: {
    eval { require DBI; require DBD::SQLite; };
    if ($@) {
        skip 'DBD::SQLite not found', 3;
    }
    my $dbh = DBI->connect("dbi:SQLite:dbname=t/userdb.db");
    $dbh->do('CREATE TABLE users (user text,password text,name text)');
    $dbh->do("INSERT INTO users VALUES ('dwho','dwho','Doctor who')");
    init(
        {
            logLevel            => 'debug',
            useSafeJail         => 1,
            authentication      => 'DBI',
            userDB              => 'DBI',
            dbiAuthChain        => 'dbi:SQLite:dbname=t/userdb.db',
            dbiAuthUser         => '',
            dbiAuthPassword     => '',
            dbiAuthTable        => 'users',
            dbiAuthLoginCol     => 'user',
            dbiAuthPasswordCol  => 'password',
            dbiAuthPasswordHash => '',
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
            IO::String->new('user=dwho&password=dwho'),
            'application/x-www-form-urlencoded', 23
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
eval { unlink 't/userdb.db' };
done_testing( count() );
