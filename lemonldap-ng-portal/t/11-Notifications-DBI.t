use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;
my $file = 't/notifications.db';
eval { unlink $file };

SKIP: {
    eval { require DBI; require DBD::SQLite; };
    if ($@) {
        skip 'DBD::SQLite not found', 1;
    }
    my $dbh = DBI->connect("dbi:SQLite:dbname=$file");
    $dbh->do(
'CREATE TABLE notifications (uid text,ref text,date datetime,xml text,cond text,done datetime)'
    );
    $dbh->do(
qq{INSERT INTO notifications VALUES ('dwho','testref','2016-05-30 00:00:00','<?xml version="1.0" encoding="UTF-8"?>
<root><notification uid="dwho" date="2016-05-30" reference="testref">
<title>Test title</title>
<subtitle>Test subtitle</subtitle>
<text>This is a test text</text>
<check>Accept test</check>
</notification></root>',null,null)}
    );

    init(
        {
            logLevel                   => 'error',
            useSafeJail                => 1,
            notifications              => 1,
            templatesDir               => 'site/templates/',
            notificationStorage        => 'DBI',
            notificationStorageOptions => {
                dbiChain => "dbi:SQLite:dbname=$file",
            },
        }
    );

    # Try yo authenticate
    # -------------------
    ok(
        $res = &client->_post(
            '/',
            IO::String->new(
'user=dwho&password=dwho&url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw=='
            ),
            accept => 'text/html',
            length => 64,
        ),
        'Auth query'
    );
    ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
    my $cookies = getCookies($res);
    my $id;
    ok( $id = $cookies->{lemonldap}, 'Get cookie' )
      or explain( $res, 'Set-Cookie: something' );
    count(3);

    # Verify that cookie is ciphered (session unvalid)
    ok(
        $res = &client->_get(
            '/',
            query  => 'url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==',
            cookie => "lemonldap=$id",
        ),
        'Test cookie received'
    );
    ok( $res->[0] == 401, "Session isn't valid" )
      or explain( [ $res->[0], $res->[1] ], 401 );
    count(2);

    # Try to validate notification without accepting it
    my $str = 'reference1x1=testref&url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==';
    ok(
        $res = &client->_post(
            '/notifback',
            IO::String->new($str),
            cookie => "lemonldap=$id",
            accept => 'text/html',
            length => length($str),
        ),
        "Don't accept notification"
    );
    ok( $res->[0] == 200, "Don't receive redirection" )
      or explain( [ $res->[0], $res->[1] ], 200 );
    count(2);

    # Try to validate notification
    my $str =
'reference1x1=testref&check1x1x1=accepted&url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==';
    ok(
        $res = &client->_post(
            '/notifback',
            IO::String->new($str),
            cookie => "lemonldap=$id",
            accept => 'text/html',
            length => length($str),
        ),
        "Accept notification"
    );
    ok( $res->[0] == 302, "Get redirection" )
      or explain( [ $res->[0], $res->[1] ], 302 );

    # Verify that notification was tagged as 'done'
    my $sth =
      $dbh->prepare('SELECT * FROM notifications WHERE done IS NOT NULL');
    $sth->execute;
    my $i = 0;
    while ( $sth->fetchrow_hashref ) { $i++ }
    ok( $i == 1, 'Notification was deleted' );
    count(3);

    clean_sessions();

}

eval { unlink $file };

done_testing( count() );
