use Test::More;
use strict;

require 't/test-lib.pm';

my $res;

init(
    {
        logLevel       => 'error',
        useSafeJail    => 1,
        authentication => 'Null',
        userDB         => 'Null',
    }
);

ok( $res = &client->_get('/'), 'Auth query' );
ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
my $cookies = getCookies($res);
my $id;
ok( $id = $cookies->{lemonldap}, 'Get cookie' )
  or explain( $res, 'Set-Cookie: something' );
clean_sessions();

count(3);
done_testing( count() );
