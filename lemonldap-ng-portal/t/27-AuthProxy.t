use Test::More;
use strict;
use IO::String;

my $res;

SKIP: {
    skip 'REMOTELLNG is not set', 10 unless ( $ENV{REMOTELLNG} );
    require 't/test-lib.pm';
    init(
        {
            logLevel        => 'error',
            useSafeJail     => 1,
            authentication  => 'Proxy',
            userDB          => 'Proxy',
            soapAuthService => $ENV{REMOTELLNG},
        }
    );
    ok(
        $res = &client->_post(
            '/',
            IO::String->new('user=dwho&password=dwho'),
            length => 23
        ),
        'Auth query'
    );
    ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
    my $cookies = getCookies($res);
    my $id;
    ok( $id = $cookies->{lemonldap}, 'Get cookie' )
      or explain( $res, 'Set-Cookie: something' );

    logout($id);
    clean_sessions();
}
done_testing(10);
