use Test::More;
use strict;
use IO::String;

BEGIN {
    require 't/test-lib.pm';
    require 't/smtp.pm';
}

my ( $res, $user, $pwd );
my $mailSend = 0;

my $mail2 = 0;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel                   => 'error',
            useSafeJail                => 1,
            portalDisplayRegister      => 1,
            authentication             => 'Demo',
            userDB                     => 'Same',
            passwordDB                 => 'Demo',
            captcha_mail_enabled       => 0,
            portalDisplayResetPassword => 1,
        }
    }
);

# Test form
# ------------------------
ok( $res = $client->_get( '/resetpwd', accept => 'text/html' ), 'Reset form', );
count(1);
my ( $host, $url, $query ) = expectForm( $res, '#', undef, 'mail' );

$query = 'mail=dwho%40badwolf.org';

# Post email
ok(
    $res = $client->_post(
        '/resetpwd', IO::String->new($query),
        length => length($query),
        accept => 'text/html'
    ),
    'Post mail'
);
count(1);

ok( mail() =~ m#a href="http://auth.example.com/resetpwd\?(.*?)"#,
    'Found link in mail' );
$query = $1;
count(1);

ok(
    $res = $client->_get( '/resetpwd', query => $query, accept => 'text/html' ),
    'Post mail token received by mail'
);
count(1);
( $host, $url, $query ) = expectForm( $res, '#', undef, 'token' );
ok( $res->[2]->[0] =~ /newpassword/s, ' Ask for a new password' );
count(1);

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
count(1);

ok( mail() =~ /Your password was changed/, 'Password was changed' );
count(1);

#print STDERR Dumper($query);

clean_sessions();

done_testing( count() );
