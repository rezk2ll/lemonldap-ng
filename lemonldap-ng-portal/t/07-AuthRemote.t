use Test::More;
use strict;

require 't/test-lib.pm';

my $res;

init(
    {
        logLevel                   => 'debug',
        useSafeJail                => 1,
        authentication             => 'Remote',
        userDB                     => 'Remote',
        remoteUserField            => 'uid',
        remoteGlobalStorage        => 'Apache::Session::File',
        remoteGlobalStorageOptions => {
            Directory     => 't/sessions2',
            LockDirectory => 't/sessions2/lock',
        },
        remotePortal => 'http://auth2.example.com',
    }
);

# Test redirection to remote portal
ok( $res = &client->_get( '/', accept => 'text/html' ), 'First request' );
ok( $res->[0] == 302, 'Response is 302' ) or explain( $res->[0], 302 );
my @tmp = @{ $res->[1] };
while ( @tmp and $tmp[0] ne 'Location' ) {
    shift @tmp;
}
ok(
    (
              $tmp[0]
          and $tmp[1] eq
          'http://auth2.example.com?url=aHR0cDovL2F1dGguZXhhbXBsZS5jb20v'
    ),
    'Get redirection to remote portal'
  )
  or explain(
    $res->[1],
    'Location => http://auth2.example.com?url=aHR0cDovL2F1dGguZXhhbXBsZS5jb20v'
  );
count(3);

ok( $res = &client->_get( '/',query=>'lemonldap=6e30af4ffa5689b3e49a104d1b160d316db2b2161a0f45776994eed19dbdc101'), 'Auth query');
ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
my $cookies = getCookies($res);
my $id;
ok( $id = $cookies->{lemonldap}, 'Get cookie' )
  or explain( $res, 'Set-Cookie: something' );
count(3);
clean_sessions();

done_testing( count() );
