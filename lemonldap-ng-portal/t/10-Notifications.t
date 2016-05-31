use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;
my $file = 't/20160530_dwho_dGVzdHJlZg==.xml';

open F, "> $file" or die($!);
print F '<?xml version="1.0" encoding="UTF-8"?>
<root><notification uid="dwho" date="2016-05-30" reference="testref"><root>
<title>Test title</title>
<subtitle>Test subtitle</subtitle>
<text>This is a test text</text>
<check>Accept test</check>
</root></notification></root>';
close F;

init(
    {
        logLevel                   => 'error',
        useSafeJail                => 1,
        notifications              => 1,
        templatesDir               => 'site/templates/',
        notificationStorage        => 'File',
        notificationStorageOptions => {
            dirName => 't'
        },
    }
);

# Try yo authenticate
# -------------------
ok(
    $res = &client->_post(
        '/',
        IO::String->new(
            'user=dwho&password=dwho&url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw=='),
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

#print STDERR Dumper($res);

clean_sessions();

unlink $file;

done_testing( count() );
