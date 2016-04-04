use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

ok( $res = &client->_get('/'), 'Unauth JSON request' );
ok( $res->[0] == 401, 'Response is 401' ) or explain( $res, 401 );
count(2);

ok(
    $res = eval {
        &client->jsonPostResponse(
            '/', '',
            IO::String->new('user=dwho&password=dwho'),
            'application/x-www-form-urlencoded', 23
        );
    },
    'Auth query'
  )
  or explain(
    &client->_post(
        '/', '',
        IO::String->new('user=dwho&password=dwho'),
        'application/x-www-form-urlencoded', 23
    ),
    200
  );
count(1);

done_testing( count() );
