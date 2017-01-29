use Test::More;
use strict;
use IO::String;

BEGIN {
    require MIME::Lite;
    require 't/test-lib.pm';
}

my $maintests = 11;
my ( $res, $user, $pwd, $host, $url, $query ) = my $mailSend = 0;

SKIP: {
    eval 'use GD::SecurityImage;use Image::Magick;';
    if ($@) {
        skip 'Lasso not found', $maintests;
    }

    my $client = LLNG::Manager::Test->new(
        {
            ini => {
                logLevel                 => 'error',
                useSafeJail              => 1,
                portalDisplayRegister    => 1,
                registerDB               => 'Demo',
                captcha_register_enabled => 1,
            }
        }
    );

    # Test normal first access
    # ------------------------
    ok(
        $res = $client->_get( '/register', accept => 'text/html' ),
        'Unauth request',
    );
    ( $host, $url, $query ) =
      expectForm( $res, '#', undef, 'firstname', 'lastname', 'mail' );
    ok(
        $query =~
s/^.*token=([^&]+).*$/token=$1&firstname=foo&lastname=bar&mail=foobar%40badwolf.org/,
        'Token found'
    );
    my $token;
    ok( $token = $1, ' Token value is defined' );
    ok( $res->[2]->[0] =~ m#<img src="data:image/png;base64#,
        ' Captcha image inserted' );

    # Try to get captcha value

    my ( $ts, $captcha );
    ok( $ts = $client->p->getApacheSession($token), ' Found token session' );
    ok( $captcha = $ts->data->{captcha}, ' Found captcha value' );

    $query .= "&captcha=$captcha";

    ok(
        $res = $client->_post(
            '/register',
            IO::String->new($query),
            length => length($query),
            accept => 'text/html'
        ),
        'Ask to create account'
    );
    expectOK($res);

    # $query is set by MIME::Lite::send below
    ok( $query =~ /register_token=/, 'Found register_token' );

    ok(
        $res =
          $client->_get( '/register', query => $query, accept => 'text/html' ),
        'Push register_token'
    );
    expectOK($res);

    # $user/$pwd are set by MIME::Lite::send below
    ok( $user eq 'fbar', 'Get good login' );

    # Try to authenticate
    $query = '&user=fbar&password=fbar';

    ok(
        $res = $client->_post(
            '/', IO::String->new($query),
            length => length($query),
            accept => 'text/html'
        ),
        'Try to authenticate'
    );
    expectCookie($res);
}
count($maintests);

clean_sessions();

done_testing( count() );

no warnings 'redefine';

my $mail2 = 0;

sub MIME::Lite::send {
    my ($mail) = @_;
    pass('Mail sent');
    ok( $mail->header_as_string =~ /foobar\@badwolf.org/s, 'Found dest' )
      or explain( $mail->header_as_string, 'To: foobar@badwolf.org' );
    count(2);
    unless ($mail2) {
        $mailSend = 1;
        ok(
            $mail->body_as_string =~
              m#a href="http://auth.example.com/register\?(.*?)"#,
            'Found link'
        );
        count(1);
        $query = $1;
        $mail2++;
    }
    else {
        $mailSend = 2;
        ok(
            $mail->body_as_string =~
              m#yourLoginIs.+?<b>(\w+)</b>.*?pwdIs.+?<b>(.*?)</b>#s,
            'Get login/pwd'
        );
        ( $user, $pwd ) = ( $1, $2 );
        count(1);
    }
}

