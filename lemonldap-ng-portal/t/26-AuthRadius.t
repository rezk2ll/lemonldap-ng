use Test::More;
use strict;
use IO::String;
use Test::MockObject;

require 't/test-lib.pm';

my $res;
my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel       => 'error',
            authentication => 'Radius',
            userDB         => 'Demo',
            radiusServer   => 'auth.example.com',
            radiusSecret   => 'test',
            requireToken   => 1
        }
    }
);

# Fake Radius server
my $mock = Test::MockObject->new();
$mock->fake_module( 'Authen::Radius', check_pwd => sub { 1 } );

# Test normal first access
ok( $res = $client->_get( '/', accept => 'text/html' ), 'First request' );
count(1);
my ( $host, $url, $query ) =
  expectForm( $res, '#', undef, 'user', 'password', 'token' );

$query =~ s/user=/user=dwho/;
$query =~ s/password=/password=dwho/;

# Try to authenticate
ok(
    $res = $client->_post(
        '/',
        IO::String->new($query),
        length => length($query)
    ),
    'Auth query'
);
count(1);

expectOK($res);
my $id = expectCookie($res);
$client->logout($id);

clean_sessions();
done_testing( count() );
