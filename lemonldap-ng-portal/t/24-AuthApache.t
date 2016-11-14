use Test::More;
use strict;

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel       => 'error',
            useSafeJail    => 1,
            authentication => 'Apache',
            userDB         => 'Null',
        }
    }
);

ok( $res = $client->_get( '/', remote_user => 'dwho' ), 'Auth query' );
ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
my $cookies = $client->getCookies($res);
my $id;
ok( $id = $cookies->{lemonldap}, 'Get cookie' )
  or explain( $res, 'Set-Cookie: something' );
clean_sessions();

count(3);
done_testing( count() );
