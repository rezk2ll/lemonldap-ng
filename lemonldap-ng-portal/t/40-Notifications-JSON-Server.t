use Test::More;
use strict;
use IO::String;

BEGIN {
    require 't/test-lib.pm';
}

eval { unlink 't/20160530_dwho_dGVzdHJlZg==.json' };

my $json = '{
"date": "2016-05-30",
"reference": "testref",
"uid": "dwho",
"title": "Test title",
"text": "This is a test text"
}';

my $jsonbis = '{
"date": "2016-05-31",
"reference": "testref",
"uid": "dwho",
"title": "Test2 title",
"text": "This is a second test text"
}';

my $json2 = '{
"date": "2016-05-30",
"reference": "testref2",
"uid": "dwho",
"title": "Test2 title",
"text": "This is a second test text"
}';

my $deljson = '{"uid":"dwho","reference":"testref2"}';
my $listjson = '{"uid":"dwho"}';

my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel                   => 'error',
            useSafeJail                => 1,
            notification               => 1,
            notificationServer         => 1,
            notificationStorage        => 'File',
            notificationStorageOptions => {
                dirName => 't'
            },
        }
    }
);

my $res;

ok(
    $res = $client->_post(
        '/notifications', IO::String->new($json),
        type   => 'application/json',
        length => length($json)
    ),
    'Create notification'
);
ok( $res->[2]->[0] =~ /"result"\s*:\s*1/, 'Notification has been inserted' )
  or print STDERR Dumper( $res->[2]->[0] );
count(2);

ok(
    $res = $client->_post(
        '/notifications', IO::String->new($json2),
        type   => 'application/json',
        length => length($json2)
    ),
    'Create second notification'
);
ok( $res->[2]->[0] =~ /"result"\s*:\s*1/, 'Second notification has been inserted' )
  or print STDERR Dumper( $res->[2]->[0] );
count(2);

ok(
    $res = $client->_get(
        '/notifications',
        type   => 'application/json',
        length => length($listjson),
        body   => IO::String->new($listjson),
    ),
    'List notifications'
);
ok( $res->[2]->[0] =~ /"result"\s*:\s*/, 'Result found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"reference":"testref"/, 'First notification found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"reference":"testref2"/, 'Second notification found' )
  or print STDERR Dumper( $res->[2]->[0] );
count(4);

ok(
    $res = $client->_put(
        '/notifications', IO::String->new($deljson),
        type   => 'application/json',
        length => length($deljson)
    ),
    'Try to delete notification with bad method'
);
ok( $res->[2]->[0] =~ /"error"\s*:\s*"Bad request"/, 'Bad method is refused' );
count(2);

ok(
    $res = $client->_delete(
        '/notifications',
        type   => 'application/json',
        length => length($deljson),
        body   => IO::String->new($deljson),
    ),
    'Delete notification'
);
ok( $res->[2]->[0] =~ /"result"\s*:\s*1/, 'Notification has been deleted' )
  or print STDERR Dumper( $res->[2]->[0] );
count(2);

ok(
    $res = $client->_post(
        '/notifications', IO::String->new($jsonbis),
        type   => 'application/json',
        length => length($jsonbis)
    ),
    'Try to create the same notification twice'
);
ok(
    $res->[2]->[0] =~
      /"error"\s*:\s*"A notification already exists with reference testref"/,
    'Append the same notification is refused'
);
count(2);

# Try to authenticate
# -------------------
ok(
    $res = $client->_post(
        '/',
        IO::String->new(
            'user=dwho&password=dwho&url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw=='),
        accept => 'text/html',
        length => 64,
    ),
    'Auth query'
);
count(1);
expectOK($res);
my $id = expectCookie($res);
expectForm( $res, undef, '/notifback', 'reference1x1', 'url' );

eval { unlink 't/20160530_dwho_dGVzdHJlZg==.json' };

clean_sessions();
done_testing( count() );
