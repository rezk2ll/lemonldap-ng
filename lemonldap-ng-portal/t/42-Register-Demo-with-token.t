use Test::More;
use strict;
use IO::String;

BEGIN {
    require 't/test-lib.pm';
    require 't/smtp.pm';
}

my ( $res, $user, $pwd );

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel                 => 'error',
            useSafeJail              => 1,
            portalDisplayRegister    => 1,
            registerDB               => 'Demo',
            captcha_register_enabled => 0,
            requireToken             => 1,
        }
    }
);

# Test normal first access
# ------------------------
ok(
    $res = $client->_get( '/register', accept => 'text/html' ),
    'Unauth request',
);
count(1);
my ( $host, $url, $query ) =
  expectForm( $res, '#', undef, 'firstname', 'lastname', 'mail' );
ok(
    $query =~
s/^.*(token=[^&]+).*$/$1&firstname=foo&lastname=bar&mail=foobar%40badwolf.org/,
    'Token found'
);
count(1);

ok(
    $res = $client->_post(
        '/register',
        IO::String->new($query),
        length => length($query),
        accept => 'text/html'
    ),
    'Ask to create account'
);
count(1);
expectOK($res);

ok( mail() =~ m#a href="http://auth.example.com/register\?(.*?)"#, 'Found register token') or print STDERR Dumper($main::mail);
$query = $1;
ok( $query =~ /register_token=/, 'Found register_token' );
count(2);

ok(
    $res = $client->_get( '/register', query => $query, accept => 'text/html' ),
    'Push register_token'
);
expectOK($res);
count(1);

ok( mail() =~ m#Your login is.+?<b>(\w+)</b>.*?Your password is.+?<b>(.*?)</b>#s, 'Found user and password');
$user = $1;
$pwd = $2;
ok( $user eq 'fbar', 'Get good login' );
count(2);

# Try to authenticate
#  1. get token
ok( $res = $client->_get( '/', accept => 'text/html' ), 'Unauth request' );
count(1);

( $host, $url, $query ) = expectForm( $res, '#', undef, 'token' );
$query =~ s/.*\b(token=[^&]+).*/$1&user=fbar&password=fbar/;

ok(
    $res = $client->_post(
        '/', IO::String->new($query),
        length => length($query),
        accept => 'text/html'
    ),
    'Try to authenticate'
);
count(1);
expectCookie($res);

clean_sessions();

done_testing( count() );

