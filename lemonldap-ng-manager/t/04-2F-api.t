# Test RSA key generation

use Test::More;
use strict;
use JSON;
use IO::String;
use Lemonldap::NG::Common::Session;

eval { mkdir 't/sessions' };
`rm -rf t/sessions/*`;

require 't/test-lib.pm';

our $_json = JSON->new->allow_nonref;

my $res;
ok(
    $res = &client->_get('/api/v1/secondFactor/dwho', '')
    ,
    "Request succeed"
);
ok( $res->[0] == 200, "Result code is 200" );

diag Dumper($res);

done_testing( );
