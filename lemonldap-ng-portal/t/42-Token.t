use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new(
    { ini => { logLevel => 'debug', useSafeJail => 1, requireToken => 1, } } );

# Test normal first access
# ------------------------
ok( $res = $client->_get('/'), 'Unauth JSON request' );
count(1);
expectReject($res);

ok( $res = $client->_get( '/', accept => 'text/html' ), 'Unauth request' );
count(1);

my ( $host, $url, $query ) = expectForm( $res, '#', undef, 'token' );

clean_sessions();

done_testing( count() );
