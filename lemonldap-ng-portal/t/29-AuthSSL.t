use Test::More;
use strict;

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel       => 'error',
            useSafeJail    => 1,
            authentication => 'SSL',
            userDB         => 'Null',
            SSLVar         => 'SSL_CLIENT_S_DN_Custom',
        }
    }
);

ok(
    $res = $client->_get(
        '/', custom => { SSL_CLIENT_S_DN_Custom => 'dwho' }
    ),
    'Auth query'
);
count(1);
expectOK($res);
my $id = expectCookie($res);
clean_sessions();

done_testing( count() );
