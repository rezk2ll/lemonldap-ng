use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;
my $file = 't/20160530_dwho_dGVzdHJlZg==.json';

open F, "> $file" or die($!);
print F '[
{
  "uid": "dwho",
  "date": "2016-05-30",
  "reference": "testref",
  "title": "Test title",
  "subtitle": "Test subtitle",
  "text": "This is a test text",
  "check": ["Accept test"]
}
]';
close F;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel                   => 'error',
            useSafeJail                => 1,
            notification               => 1,
            templatesDir               => 'site/templates/',
            notificationStorage        => 'File',
            notificationStorageOptions => {
                dirName => 't'
            },
            oldNotifFormat => 0,
        }
    }
);

# Try yo authenticate
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

# Verify that cookie is ciphered (session unvalid)
ok(
    $res = $client->_get(
        '/',
        query  => 'url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==',
        cookie => "lemonldap=$id",
    ),
    'Test cookie received'
);
count(1);
expectReject($res);

# Try to validate notification without accepting it
my $str = 'reference1x1=testref&url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==';
ok(
    $res = $client->_post(
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
$str =
'reference1x1=testref&check1x1x1=accepted&url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==';
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
expectRedirection( $res, qr/./ );
$file =~ s/json$/done/;
ok( -e $file, 'Notification was deleted' );
count(2);

#print STDERR Dumper($res);

clean_sessions();

unlink $file;

done_testing( count() );
