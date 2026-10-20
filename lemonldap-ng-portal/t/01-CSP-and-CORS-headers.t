use warnings;
use Test::More;
use strict;
use utf8;
use IO::String;
use Lemonldap::NG::Portal::Main::Request;

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel          => 'error',
            useSafeJail       => 1,
            corsAllow_Origin  => '',
            corsAllow_Methods => 'POST',
            cspFormAction     => '*',
            cspFrameAncestors => 'test.example.com',
            cspScript         => "'self' http://myscript",
            customToTrace     => 'mail',
            checkStateSecret  => 'x',
            checkState        => 1,
        }
    }
);

# Test request from alternate vhost to portal
checkCorsAllowed( $client, "http://auth.example.com",    1 );
checkCorsAllowed( $client, "http://auth.example.com:80", 1 );
checkCorsAllowed( $client, "http://auth.example.comm",   0 );
checkCorsAllowed( $client, "http://auth.example.co",     0 );
checkCorsAllowed( $client, "http://example.com",         0 );
checkCorsAllowed( $client, "https://auth.example.com",   0 );

# Test normal first access
# ------------------------
ok( $res = $client->_get('/'), 'Unauth JSON request' );
count(1);
expectReject($res);

ok( $res = $client->_get('/ping'), 'Unauth JSON request' );
count(1);
checkCorsPolicy($res);

# Test "first access" with good url
ok(
    $res =
      $client->_get( '/', query => 'url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==' ),
    'Unauth ajax request with good url'
);
count(1);
expectReject($res);

# sendError (#2380)
ok( $res = $client->_get( '/checkstate', accept => 'text/html' ),
    'Get error page' );
count(1);
checkCorsPolicy($res);

ok( $res = $client->_options( '/', accept => 'text/html' ), 'Get Menu' );
count(1);

checkCorsPolicy($res);

# Test allowCsp and allowCspValue
push @{ $client->p->beforeAuth }, sub {
    my ($req) = @_;
    $req->allowCsp( 'media-src', "http://my.media/url" );
    $req->allowCspValue( 'script-src-attr', 'unsafe-hashes' );
    return 0;
};

ok( $res = $client->_get( '/', accept => 'text/html' ), 'Get Menu' );
ok( $res->[2]->[0] =~ m%<span id="languages"></span>%, ' Language icons found' )
  or print STDERR Dumper( $res->[2]->[0] );
count(2);

checkCorsPolicy($res);

my %headers = @{ $res->[1] };

#CSP
expectCsp(
    $res,
    'default-src'     => "'self'",
    'img-src'         => "'self'",
    'img-src'         => "data:",
    'style-src'       => "'self'",
    'font-src'        => "'self'",
    'connect-src'     => "'self'",
    'script-src'      => "'self'",
    'script-src'      => "http://myscript",
    'form-action'     => '*',
    'frame-ancestors' => "test.example.com",

    # media-src inherits from default-src
    'media-src' => "'self'",
    'media-src' => "http://my.media",

    # script-src-attr inherits from script-src
    'script-src-attr' => "http://myscript",
    'script-src-attr' => "'unsafe-hashes'",
);

ok( $headers{'X-Frame-Options'} eq 'ALLOW-FROM test.example.com;',
    'X-Frame-Options "ALLOW-FROM" found' )
  or print STDERR Dumper( $res->[1] );
count(1);

# Try to authenticate with good password
# --------------------------------------
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23,
    ),
    'Auth query'
);
count(1);
expectOK($res);
my $id        = expectCookie($res);
my $rawCookie = getHeader( $res, 'Set-Cookie' );
ok( $rawCookie =~ /;\s*SameSite=Lax/, 'Found SameSite=Lax (default)' );
count(1);

# Try to get a redirection for an auth user with a valid url
# ----------------------------------------------------------
ok(
    $res = $client->_get(
        '/',
        query  => 'url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Auth ajax request with good url'
);
count(1);
expectRedirection( $res, 'http://test1.example.com/' );
expectAuthenticatedAs( $res, 'dwho' );

ok(
    $res = $client->_get(
        'http://test1.example.com/',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Get test1'
);
count(1);

%headers = @{ $res->[1] };

# Lm-Remote headers
ok( $headers{'Lm-Remote-User'} eq 'dwho', "Lm-Remote-User found" )
  or print STDERR Dumper( $res->[1] );
ok( $headers{'Lm-Remote-Custom'} eq 'dwho@badwolf.org',
    "Lm-Remote-Custom found" )
  or print STDERR Dumper( $res->[1] );
ok( $headers{'X-Frame-Options'} eq 'ALLOW-FROM test.example.com;',
    'X-Frame-Options "ALLOW-FROM" found' )
  or print STDERR Dumper( $res->[1] );
count(3);

checkCorsPolicy($res);

$client->logout($id);

subtest "Test cspGetHost function" => sub {
    my @cases = (
        [ undef                             => undef ],
        [ ""                                => undef ],
        [ "invalid"                         => undef ],
        [ "/relative/url"                   => "'self'" ],
        [ "http://test.com/test"            => "http://test.com" ],
        [ "http://test.com:80/test"         => "http://test.com" ],
        [ "http://test.com:81/test"         => "http://test.com:81" ],
        [ "https://test.com/test"           => "https://test.com" ],
        [ "https://test.com:443/test"       => "https://test.com" ],
        [ "custom.scheme://something?param" => "custom.scheme:" ],
    );
    while ( my $case = shift @cases ) {
        my ( $input, $output ) = @$case;
        is( Lemonldap::NG::Portal::Main::Request->cspGetHost($input),
            $output, "Correct CSP source for $input" );
    }
};
count(1);

clean_sessions();

done_testing( count() );

sub checkCorsAllowed {
    my ( $client, $origin, $result ) = @_;
    ok(
        my $res = $client->_get( '/', custom => { HTTP_ORIGIN => "$origin" } ),
        "Unauth JSON request from $origin"
    );
    my %headers = @{ $res->[1] };
    if ($result) {
        is( $headers{'Access-Control-Allow-Origin'},
            $origin, "$origin is allowed" );
    }
    else {
        ok( !$headers{'Access-Control-Allow-Origin'},
            "$origin is not allowed" );
    }
    count(2);
}

sub checkCorsPolicy {
    my ($res) = @_;
    my %headers = @{ $res->[1] };

    ok( !defined $headers{'Access-Control-Allow-Origin'},
        "CORS origin '' found" )
      or print STDERR Dumper( $res->[1] );
    ok( $headers{'Access-Control-Allow-Credentials'} eq 'true',
        "CORS credentials 'true' found" )
      or print STDERR Dumper( $res->[1] );
    ok( $headers{'Access-Control-Allow-Headers'} eq '*',
        "CORS headers '*' found" )
      or print STDERR Dumper( $res->[1] );
    ok( $headers{'Access-Control-Allow-Methods'} eq 'POST',
        "CORS methods 'POST' found" )
      or print STDERR Dumper( $res->[1] );
    ok( $headers{'Access-Control-Expose-Headers'} eq '*',
        "CORS expose-headers '*' found" )
      or print STDERR Dumper( $res->[1] );
    ok( $headers{'Access-Control-Max-Age'} eq '86400',
        "CORS max-age '86400' found" )
      or print STDERR Dumper( $res->[1] );
    count(6);
}
