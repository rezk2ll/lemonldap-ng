use Test::More;
use strict;
use IO::String;

BEGIN {
    require MIME::Lite;
    require 't/test-lib.pm';
}

my ( $res, $host, $url, $query );
my $maintests = 8;
my $mailSend  = 0;
my $mail2     = 0;

SKIP: {
    eval 'use GD::SecurityImage;use Image::Magick;';
    if ($@) {
        skip 'Lasso not found', $maintests;
    }

    my $client = LLNG::Manager::Test->new(
        {
            ini => {
                logLevel                   => 'error',
                useSafeJail                => 1,
                portalDisplayRegister      => 1,
                authentication             => 'Demo',
                userDB                     => 'Same',
                passwordDB                 => 'Demo',
                captcha_mail_enabled       => 1,
                requireToken               => 1,
                portalDisplayResetPassword => 1,
            }
        }
    );

    # Test form
    # ------------------------
    ok( $res = $client->_get( '/resetpwd', accept => 'text/html' ),
        'Reset form', );
    ( $host, $url, $query ) = expectForm( $res, '#', undef, 'mail', 'token' );

    $query =~ s/mail=&//;
    $query .= '&mail=dwho%40badwolf.org';

    # Check captcha
    my ($token) = ( $query =~ /token=([^&]+)/ );
    ok( $res->[2]->[0] =~ m#<img src="data:image/png;base64#,
        ' Captcha image inserted' );

    # Try to get captcha value

    my ( $ts, $captcha );
    ok( $ts = $client->p->getApacheSession($token), ' Found token session' );
    ok( $captcha = $ts->data->{captcha}, ' Found captcha value' );

    $query .= "&captcha=$captcha";

    # Post email
    ok(
        $res = $client->_post(
            '/resetpwd', IO::String->new($query),
            length => length($query),
            accept => 'text/html'
        ),
        'Post mail'
    );

    # $query has been set by MIME::Lite::send
    ok(
        $res =
          $client->_get( '/resetpwd', query => $query, accept => 'text/html' ),
        'Post mail token received by mail'
    );
    ( $host, $url, $query ) = expectForm( $res, '#', undef, 'token' );
    ok( $res->[2]->[0] =~ /newpassword/s, ' Ask for a new password' );

    $query .= '&newpassword=zz&confirmpassword=zz';

    # Post new password
    ok(
        $res = $client->_post(
            '/resetpwd', IO::String->new($query),
            length => length($query),
            accept => 'text/html'
        ),
        'Post new password'
    );

    #print STDERR Dumper($query);
}
count($maintests);

clean_sessions();

done_testing( count() );

no warnings 'redefine';

sub MIME::Lite::send {
    my ($mail) = @_;
    pass('----- Mail given to MIME::Lite -----');
    ok( $mail->header_as_string =~ /dwho\@badwolf.org/s, ' Found dest' )
      or explain( $mail->header_as_string, 'To: dwho@badwolf.org' );
    count(2);
    unless ($mail2) {
        $mailSend = 1;
        ok(
            $mail->body_as_string =~
              m#a href="http://auth.example.com/resetpwd\?(.*?)"#,
            ' Found link'
        );
        count(1);
        $query = $1;
        $mail2++;
    }
    else {
        $mailSend = 2;
        ok( $mail->body_as_string =~ /pwdChanged/, ' Password was changed' );
        count(1);
    }
    pass('----- Mail sent -----');
    count(1);
}

