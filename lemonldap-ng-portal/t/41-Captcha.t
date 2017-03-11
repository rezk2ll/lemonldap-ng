use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

my $maintests = 13;
SKIP: {
    eval 'use GD::SecurityImage;use Image::Magick;';
    if ($@) {
        skip 'Lasso not found', $maintests;
    }

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
    expectReject($res);

    ok( $res = $client->_get( '/', accept => 'text/html' ), 'Unauth request' );
    my ( $host, $url, $query ) = expectForm( $res, '#', undef, 'token' );
    $query =~ s/.*\btoken=([^&]+).*/token=$1/;
    my $token;
    ok( $token = $1, ' Token value is defined' );
    ok( $res->[2]->[0] =~ m#<img src="data:image/png;base64#,
        ' Captcha image inserted' );

    # Try to get captcha value

    my ( $ts, $captcha );
    ok( $ts = getCache()->get($token), ' Found token session' );
    $ts = eval { JSON::from_json($ts) };
    ok( $captcha = $ts->{captcha}, ' Found captcha value' );

    # Try to authenticate
    $query .= "&user=dwho&password=dwho&captcha=$captcha";
    ok(
        $res = $client->_post(
            '/',
            IO::String->new($query),
            length => length($query)
        ),
        'Try to auth with captcha value'
    );
    expectOK($res);
    my $id = expectCookie($res);

    # Verify auth
    ok( $res = $client->_get( '/', cookie => "lemonldap=$id" ), 'Verify auth' );
    expectOK($res);

    # New try (with bad captcha)
    ok( $res = $client->_get( '/', accept => 'text/html' ),
        'New unauth request' );
    ( $host, $url, $query ) = expectForm( $res, '#', undef, 'token' );
    $query =~ s/.*\b(token=[^&]+).*/$1/;
    ok( $token = $1, ' Token value is defined' );

    # Try to auth with bad captcha
    $query .= '&user=dwho&password=dwho&captcha=00000';
    ok(
        $res = $client->_post(
            '/',
            IO::String->new($query),
            length => length($query)
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
}
count($maintests);

clean_sessions();

done_testing( count() );
