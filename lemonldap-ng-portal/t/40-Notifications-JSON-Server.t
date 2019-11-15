use Test::More;
use strict;
use IO::String;

BEGIN {
    require 't/test-lib.pm';
}

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

my $json2 = q%{
"date": "2016-05-30",
"reference": "testref2",
"uid": "dwho",
"title": "Test2 title",
"text": "This is a second test text",
"subtitle": "Application 2",
"check": ["I agree","Yes, I'm sure"]
}%;

my $jsonall = '{
"date": "2016-05-30",
"reference": "testrefall",
"uid": "everyone",
"title": "Testall title",
"text": "This is a test text for all users"
}';

my $notifs = q%[{
 "uid": "dwho",
 "date": "2019-11-15",
 "reference": "ABC1",
 "title": "You have new authorizations",
 "subtitle": "Application 1",
 "text": "You have been granted to access to appli-1",
 "check": "I agree"
 },
 {
 "uid": "rtyler",
 "date": "2019-11-15",
 "reference": "ABC2",
 "title": "You have new authorizations",
 "subtitle": "Application 1",
 "text": "You have been granted to access to appli-1",
 "check": ["I agree", "I am sure"]
 }]%;

my $content = '{"uid":"dwho"}';

my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel              => 'error',
            useSafeJail           => 1,
            notification          => 1,
            notificationServer    => 1,       # POST method enabled if undefined
            notificationServerGET => 1,
            notificationServerDELETE => 1,
            notificationServerSentAttributes =>
              'uid reference  date title text subtitle check',
            notificationWildcard       => 'everyone',
            notificationStorage        => 'File',
            notificationStorageOptions => {
                dirName => $main::tmpDir,
            },
        }
    }
);

my $res;
foreach ( $json, $json2, $jsonall ) {
    ok(
        $res = $client->_post(
            '/notifications', IO::String->new($_),
            type   => 'application/json',
            length => length($_)
        ),
        "POST notification $_"
    );
    ok( $res->[2]->[0] =~ /"result"\s*:\s*1/, 'Notification has been inserted' )
      or print STDERR Dumper( $res->[2]->[0] );
    count(2);
}

ok(
    $res = $client->_get(
        '/notifications', type => 'application/json',
    ),
    'List notifications for "allusers"'
);
ok( $res->[2]->[0] =~ /"result"\s*:\s*/, 'Result found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok(
    $res->[2]->[0] =~ /"reference":"testrefall"/,
    'Notification for all users found'
) or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"uid":"everyone"/, 'Wildcard found' )
  or print STDERR Dumper( $res->[2]->[0] );
count(4);

ok(
    $res = $client->_get(
        '/notifications/dwho', type => 'application/json',
    ),
    'List notifications for "dwho"'
);
ok( $res->[2]->[0] =~ /"result"\s*:\s*/, 'Result found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"reference":"testref"/, 'First notification found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"reference":"testref2"/, 'Second notification found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok(
    $res->[2]->[0] =~ /"reference":"testrefall"/,
    'Third notification found (all users)'
) or print STDERR Dumper( $res->[2]->[0] );
count(5);

ok(
    $res = $client->_get(
        '/notifications/dwho/testref', type => 'application/json',
    ),
    'List notification with reference "testref"'
);
ok( $res->[2]->[0] =~ /"result"\s*:\s*/, 'Result found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"reference"\s*:\s*"testref"/,
    'Notification reference found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"title"\s*:\s*"Test title"/, 'Notification title found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"text"\s*:\s*"This is a test text"/,
    'Notification text found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"date"\s*:\s*"2016-05-30"/, 'Notification date found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"uid"\s*:\s*"dwho"/, 'Notification uid found' )
  or print STDERR Dumper( $res->[2]->[0] );
count(7);

ok(
    $res = $client->_get(
        '/notifications/dwho/testref2',
        type => 'application/json',
    ),
    'List notification with reference "testref2"'
);
ok( $res->[2]->[0] =~ /"result"\s*:\s*/, 'Result found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"reference"\s*:\s*"testref2"/,
    'Notification reference found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"title"\s*:\s*"Test2 title"/,
    'Notification title found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"text"\s*:\s*"This is a second test text"/,
    'Notification text found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"date"\s*:\s*"2016-05-30"/, 'Notification date found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"uid"\s*:\s*"dwho"/, 'Notification uid found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"subtitle"\s*:\s*"Application 2"/,
    'Notification subtitle found' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /"check":\["I agree","Yes, I\'m sure"\]/,
    'Notification check boxes found' )
  or print STDERR Dumper( $res->[2]->[0] );
count(9);

ok(
    $res = $client->_put(
        '/notifications', IO::String->new($content),
        type   => 'application/json',
        length => length($content)
    ),
    'Try to delete notification with bad method'
);
ok( $res->[2]->[0] =~ /"error"\s*:\s*"Bad request"/, 'Bad method is refused' );
count(2);

foreach (qw(testrefall testref2)) {
    my $user = $_ eq 'testrefall' ? 'everyone' : 'dwho';
    ok(
        $res = $client->_delete(
            "/notifications/$user/$_", type => 'application/json',
        ),
        "Delete notification $_"
    );
    ok( $res->[2]->[0] =~ /"result"\s*:\s*1/, 'Notification has been deleted' )
      or print STDERR Dumper( $res->[2]->[0] );
    count(2);
}

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

# Insert combined notifications
ok(
    $res = $client->_post(
        '/notifications', IO::String->new($notifs),
        type   => 'application/json',
        length => length($notifs)
    ),
    "POST combined notifications $notifs"
);
ok( $res->[2]->[0] =~ /"result"\s*:\s*2/, 'Notifications have been inserted' )
  or print STDERR Dumper( $res->[2]->[0] );
count(2);

# Try to authenticate with "dwho"
# -------------------------------
ok(
    $res = $client->_post(
        '/',
        IO::String->new(
            'user=dwho&password=dwho'),
        accept => 'text/html',
        length => 23,
    ),
    'Auth query'
);
expectOK($res);
$id = expectCookie($res);
expectForm( $res, undef, '/notifback', 'reference1x1' );
ok(
    $res->[2]->[0] =~
m%<input type="checkbox" name="check1x2x1" id="1x2x1" value="accepted">I agree</label>%,
    'Checkbox is displayed'
) or print STDERR Dumper( $res->[2]->[0] );
count(3);

# Try to validate notification
my $str = 'reference1x1=testref&check1x2x1=accepted';
ok(
    $res = $client->_post(
        '/notifback',
        IO::String->new($str),
        cookie => "lemonldap=$id",
        accept => 'text/html',
        length => length($str),
    ),
    "Accept notification"
);
expectOK($res);
$client->logout($id);

# Try to authenticate with "rtyler"
# -------------------------------
ok(
    $res = $client->_post(
        '/',
        IO::String->new(
            'user=rtyler&password=rtyler'),
        accept => 'text/html',
        length => 27,
    ),
    'Auth query'
);
expectOK($res);
$id = expectCookie($res);
expectForm( $res, undef, '/notifback', 'reference1x1' );
ok(
    $res->[2]->[0] =~
m%<input type="checkbox" name="check1x1x1" id="1x1x1" value="accepted">I agree</label>%,
    'Checkbox is displayed'
) or print STDERR Dumper( $res->[2]->[0] );
ok(
    $res->[2]->[0] =~
m%<input type="checkbox" name="check1x1x2" id="1x1x2" value="accepted">I am sure</label>%,
    'Checkbox is displayed'
) or print STDERR Dumper( $res->[2]->[0] );
count(4);

# Try to validate notification
$str = 'reference1x1=testref&check1x1x1=accepted&check1x1x2=accepted';
ok(
    $res = $client->_post(
        '/notifback',
        IO::String->new($str),
        cookie => "lemonldap=$id",
        accept => 'text/html',
        length => length($str),
    ),
    "Accept notification"
);
expectOK($res);
$client->logout($id);

clean_sessions();
done_testing( count() );
