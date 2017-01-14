use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel              => 'debug',
            useSafeJail           => 1,
            portalDisplayRegister => 1,
            registerDB            => 'Demo',
        }
    }
);

# Test normal first access
# ------------------------
ok( $res = $client->_get('/'), 'Unauth JSON request' );
count(1);
expectReject($res);

clean_sessions();

done_testing( count() );
