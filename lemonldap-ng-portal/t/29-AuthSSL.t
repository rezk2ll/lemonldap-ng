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
ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
my $cookies = $client->getCookies($res);
my $id;
ok( $id = $cookies->{lemonldap}, 'Get cookie' )
  or explain( $res, 'Set-Cookie: something' );
clean_sessions();

count(3);
done_testing( count() );
