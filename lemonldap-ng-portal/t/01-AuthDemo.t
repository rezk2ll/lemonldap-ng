use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new(
    { ini => { logLevel => 'error', useSafeJail => 1 } } );

# Test normal first access
# ------------------------
ok( $res = $client->_get('/'), 'Unauth JSON request' );
ok( $res->[0] == 401, 'Response is 401' ) or explain( $res, 401 );
count(2);

# Test "first access" with good url
ok(
    $res =
      $client->_get( '/', query => 'url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==' ),
    'Unauth ajax request with good url'
);
ok( $res->[0] == 401, 'Response is 401' ) or explain( $res, 401 );
count(2);

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
count(3);

# Try to get a redirection for an auth user with a valid url
# ----------------------------------------------------------
ok(
    $res = $client->_get(
        '/',
        query  => 'url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Auth ajax request with good url'
);
ok( $res->[0] == 302, 'Get redirection' )
  or explain( [ $res->[0], $res->[1] ], 302 );
my %hdrs = @{ $res->[1] };
ok(
    $hdrs{Location} eq 'http://test1.example.com/',
    'Location is http://test1.example.com/'
) or explain( \%hdrs, 'Location => "http://test1.example.com/"' );
ok( $hdrs{'Lm-Remote-User'} eq 'dwho', 'User is set' )
  or explain( \%hdrs, 'Lm-Remote-User => "dwho"' );
count(4);

# Try to get a redirection for an auth user with a bad url (host undeclared
# in manager)
# -------------------------------------------------------------------------
ok(
    $res = $client->_get(
        '/',
        query  => 'url=aHR0cHM6Ly90LmV4YW1wbGUuY29tLw==',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Auth request with bad url'
);
ok( $res->[0] == 200, 'HTTP code is 200' ) or explain( $res, 200 );
%hdrs = @{ $res->[1] };
ok( $hdrs{'Lm-Remote-User'} eq 'dwho', 'User is set' )
  or explain( \%hdrs, 'Lm-Remote-User => "dwho"' );
ok( $hdrs{'Content-Type'} eq 'text/html', 'Reponse is HTML' )
  or explain( \%hdrs, 'Content-Type => "text/html"' );
count(4);

# Test logout
$client->logout($id);

#print STDERR Dumper($res);

clean_sessions();

done_testing( count() );
