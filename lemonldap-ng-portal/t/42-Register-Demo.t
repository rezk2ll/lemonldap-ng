use Test::More;
use strict;
use IO::String;

BEGIN {
    require MIME::Lite;
    require 't/test-lib.pm';
}

my ( $res, $user, $pwd );
my $mailSend = 0;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel                 => 'error',
            useSafeJail              => 1,
            portalDisplayRegister    => 1,
            authentication           => 'Demo',
            userDB                   => 'Demo',
            registerDB               => 'Demo',
            captcha_register_enabled => 0,
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
    $res = $client->_post(
        '/register',
        IO::String->new('firstname=foo&lastname=bar&mail=foobar%40badwolf.org'),
        length => 52,
        accept => 'text/html'
    ),
    'Ask to create account'
);
count(1);
expectOK($res);

# $query is set by MIME::Lite::send below
ok( $query =~ /register_token=/, 'Found register_token' );
count(1);

ok(
    $res = $client->_get( '/register', query => $query, accept => 'text/html' ),
    'Push register_token'
);
expectOK($res);
count(1);

# $user/$pwd are set by MIME::Lite::send below
ok( $user eq 'fbar', 'Get good login' );
count(1);

ok(
    $res = $client->_post(
        '/', IO::String->new('user=fbar&password=fbar'),
        length => 23,
        accept => 'text/html'
    ),
    'Try to authenticate'
);
count(1);
expectCookie($res);

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

