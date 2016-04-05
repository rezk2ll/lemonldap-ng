use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

init( { logLevel => 'debug' } );

ok( $res = &client->_get('/'), 'Unauth JSON request' );
ok( $res->[0] == 401, 'Response is 401' ) or explain( $res, 401 );
count(2);

ok( $res = &client->_get('/?url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw=='),
    'Unauth ajax request with good url' );
ok( $res->[0] == 401, 'Response is 401' ) or explain( $res, 401 );
count(2);

ok(
    $res = &client->_post(
        '/', '',
        IO::String->new('user=dwho&password=dwho'),
        'application/x-www-form-urlencoded', 23
    ),
    'Auth query'
);

my $cookies = getCookies($res);
my $id;
ok( $id = $cookies->{lemonldap}, 'Get cookie' );
count(2);

ok(
    $res = &client->_get(
        '/',
        query  => 'url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Auth ajax request with good url'
);
count(1);
print STDERR Dumper($res);

#clean_sessions();

done_testing( count() );
