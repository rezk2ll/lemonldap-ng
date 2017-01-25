use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel              => 'error',
            useSafeJail           => 1,
            captcha_login_enabled => 1,
        }
    }
);

# Test normal first access
# ------------------------
ok( $res = $client->_get('/'), 'Unauth JSON request' );
count(1);
expectReject($res);

ok( $res = $client->_get( '/', accept => 'text/html' ), 'Unauth request' );
my ( $host, $url, $query ) = expectForm( $res, '#', undef, 'token' );
$query =~ s/.*\btoken=([^&]+).*/token=$1/;
my $token;
ok( $token = $1, ' Token value is defined' );
ok( $res->[2]->[0] =~ m#<img src="data:image/png;base64#,
    ' Captcha image inserted' );
count(3);

# Try to get captcha value

my ( $ts, $captcha );
ok( $ts = $client->p->getApacheSession($token), ' Found token session' );
ok( $captcha = $ts->data->{captcha}, ' Found captcha value' );
count(2);

# Try to authenticate
$query .= "&user=dwho&password=dwho&captcha=$captcha";
ok(
    $res =
      $client->_post( '/', IO::String->new($query), length => length($query) ),
    'Try to auth with captcha value'
);
count(1);
expectOK($res);
my $id = expectCookie($res);

# Verify auth
ok( $res = $client->_get( '/', cookie => "lemonldap=$id" ), 'Verify auth' );
count(1);
expectOK($res);

# New try (with bad captcha)
ok( $res = $client->_get( '/', accept => 'text/html' ), 'New unauth request' );
( $host, $url, $query ) = expectForm( $res, '#', undef, 'token' );
$query =~ s/.*\b(token=[^&]+).*/$1/;
ok( $token = $1, ' Token value is defined' );
count(2);

# Try to auth with bad captcha
$query .= '&user=dwho&password=dwho&captcha=00000';
ok(
    $res = $client->_post(
        '/', IO::String->new($query), length => length($query)
    ),
    'Try to auth with bad captcha value'
);
expectReject($res);
ok(
    $res = $client->_post(
        '/', IO::String->new($query),
        length => length($query),
        accept => 'text/html',
    ),
    'Verify that there is a new captcha image'
);
ok( $res->[2]->[0] =~ m#<img src="data:image/png;base64#,
    ' New captcha image inserted' );
count(3);

clean_sessions();

done_testing( count() );
