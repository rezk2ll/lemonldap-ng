# Test RSA key generation

use Test::More;
use strict;
use JSON;
use IO::String;
require 't/test-lib.pm';

my $res;
ok(
    $res = &client->_get('/api/v1/hello', '')
    ,
    "Request succeed"
);
ok( $res->[0] == 200, "Result code is 200" );

diag Dumper($res);

done_testing( );
