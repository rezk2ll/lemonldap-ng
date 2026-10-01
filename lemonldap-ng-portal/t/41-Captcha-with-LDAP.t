use strict;
use warnings;
use Test::More;
use IO::String;

require 't/test-lib.pm';

my $res;
my $maintests = 11;
SKIP: {
    eval 'use GD; use Net::LDAP;';
    if ($@) {
        skip "Prerequisites not found: $@", $maintests;
    }

    my $client = LLNG::Manager::Test->new( {
            ini => {
                logLevel              => 'error',
                authentication        => 'LDAP',
                ldapServer            => 'ldap://ldap.failed.com',
                captcha_login_enabled => 1
            }
        }
    );

    # Test normal first access
    # ------------------------
    ok( $res = $client->_get( '/', accept => 'text/html' ), 'Unauth request' );
    my ( $host, $url, $query ) = expectForm( $res, '#', undef, 'token' );
    ok( $res->[2]->[0] =~ m%<input[^>]*name="password"%,
        'Password: Found text input' );

    my ($token) = $query =~ /\btoken=([^&]*)/;
    ok( $token = $1, ' Token value is defined' );
    ok( $res->[2]->[0] =~ m#<img id="captcha" src="data:image/png;base64#,
        ' Captcha image inserted' )
      or
      explain( $res->[2]->[0], '<img id="captcha" src="data:image/png;base64' );

    # Try to get captcha value
    my ( $ts, $captcha );
    ok( $ts = getCache()->get($token), ' Found token session' );
    $ts = eval { from_json($ts) };
    ok( $captcha = from_json($ts->{stored_data})->{captcha}, ' Found captcha value' );

    # Try to authenticate
    $query = "token=$token&user=dwho&password=dwho&captcha=$captcha";
    ok(
        $res = $client->_post(
            '/',
            IO::String->new($query),
            length => length($query),
            accept => 'text/html',
        ),
        'Try to auth with captcha value'
    );

    ( $host, $url, $query ) = expectForm( $res, '#', undef, 'user', 'token' );
    ok( $res->[2]->[0] =~ m%<input[^>]*name="password"%,
        'Password: Found text input' );

    $query =~ s/.*\btoken=([^&]+).*/token=$1/;
    ok( $token = $1, ' Token value is defined' );

    expectXpath(
        $res,
        '//input[@id="userfield" and @value="dwho"]',
        "Found name in form"
    );
    expectXpath(
        $res,
        '//span[@trmsg="6" or @trmsg="7"]',
        "Error message found"
    );
    expectXpath(
        $res,
        '//img[@id="captcha" and starts-with(@src,"data:image/png;base64")]',
        "Captcha image found"
    );

    # Try to get captcha value
    ok( $ts = getCache()->get($token), ' Found token session' );
    $ts = eval { from_json($ts) };
    ok( $captcha = from_json($ts->{stored_data})->{captcha}, ' Found captcha value' );
}
count($maintests);

clean_sessions();

done_testing( count() );

{
    no warnings 'redefine';
    use Lemonldap::NG::Portal::Lib::Net::LDAP;

    sub Lemonldap::NG::Portal::Lib::Net::LDAP::new {
        my ($self) = @_;
        note "Mocking LDAP failure";
        return 0;
    }
}
