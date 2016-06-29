use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

init(
    {
        logLevel              => 'error',
        useSafeJail           => 1,
        issuerDBGetActivation => 1,
        issuerDBGetPath       => '^/test/',
        issuerDBGetParameters =>
          { 'test1.example.com' => { ID => '_session_id' } }
    }
);

# Try yo authenticate
# -------------------
ok(
    $res = &client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23
    ),
    'Auth query'
);
ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
my $cookies = getCookies($res);
my $id;
ok( $id = $cookies->{lemonldap}, 'Get cookie' )
  or explain( $res, 'Set-Cookie: something' );
count(3);

# Test GET login
ok(
    $res = &client->_get(
        '/test',
        query  => 'url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'GET request with good url'
);
ok( $res->[0] == 302, 'Get redirection' )
  or explain( [ $res->[0], $res->[1] ], 302 );
my %hdrs = @{ $res->[1] };
ok(
    $hdrs{Location} eq "http://test1.example.com/?ID=$id",
    'Location is http://test1.example.com/<$id>'
) or explain( \%hdrs, "Location => 'http://test1.example.com/$id'" );
count(3);

# Test not logged access
ok(
    $res = &client->_get(
        '/test',
        query  => 'url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==',
    ),
    'Not logged access'
);
ok( $res->[0] == 401, 'Response is 401' ) or explain( $res, 401 );
count(2);

clean_sessions();

done_testing( count() );
