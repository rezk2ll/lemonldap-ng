# Test RSA key generation

use Test::More;
use strict;
use JSON;
use IO::String;
require 't/test-lib.pm';

my $res;
# ok(
#     $res = &client->_get('/api/v1/hello', '')
#     ,
#     "Request succeed"
# );
# ok( $res->[0] == 200, "Result code is 200" );
#
# diag Dumper($res);
my $content = '{"confKey":"dsfsdfsdf","clientId":"sdfsdfsdf", "exportedVars": {"titi":"toto","tata":"tutu"}, "extraClaim": {"titi":"toto","tata":"tutu"}, "options":{"oidcRPMetaDataOptionsClientSecret":"secret","oidcRPMetaDataOptionsDisplayName":"tralala","oidcRPMetaDataOptionsIcon":"web.png"}}';
my $res;
ok(
    $res = &client->_post(
        '/v1/providers/oidc/rp', '', IO::String->new($content),  'application/json', length($content)
    ),
    "Request succeed"
);

use Data::Dumper; print STDERR Dumper($res);

ok( $res->[0] == 200, "Result code is 200" );
my $key;
ok( $key = from_json( $res->[2]->[0] ), 'Response is JSON' );
count(3);

done_testing( );
