use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

ok( $res = &client->_get('/'), 'Unauth JSON request' );
ok( $res->[0] == 401, 'Response is 401' ) or explain( $res, 401 );
count(2);

#ok( $res = &client->jsonPostResponse('/','',IO::String->new('user=dwho&password=dwho'),'application/x-www-form-urlencoded',23), 'Auth query');
#count(1);

done_testing( count() );
