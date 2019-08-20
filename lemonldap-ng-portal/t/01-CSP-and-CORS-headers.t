use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel          => 'error',
            useSafeJail       => 1,
            corsAllow_Origin  => '',
            corsAllow_Methods => 'POST',
            cspFormAction     => '*',
            customToTrace     => 'mail'
        }
    }
);

# Test normal first access
# ------------------------
ok( $res = $client->_get('/'), 'Unauth JSON request' );
count(1);
expectReject($res);

# Test "first access" with good url
ok(
    $res =
      $client->_get( '/', query => 'url=aHR0cDovL3Rlc3QxLmV4YW1wbGUuY29tLw==' ),
    'Unauth ajax request with good url'
);
count(1);
expectReject($res);

ok( $res = $client->_get( '/', accept => 'text/html' ), 'Get Menu' );
ok( $res->[2]->[0] =~ m%<span id="languages"></span>%, ' Language icons found' )
  or print STDERR Dumper( $res->[2]->[0] );
count(2);

my %policy = @{ $res->[1] };

# CORS
ok( $policy{'Access-Control-Allow-Origin'} eq '', "CORS origin '' found" )
  or print STDERR Dumper( $res->[1] );
ok( $policy{'Access-Control-Allow-Credentials'} eq 'true',
    "CORS credentials 'true' found" )
  or print STDERR Dumper( $res->[1] );
ok( $policy{'Access-Control-Allow-Headers'} eq '*', "CORS headers '*' found" )
  or print STDERR Dumper( $res->[1] );
ok( $policy{'Access-Control-Allow-Methods'} eq 'POST',
    "CORS methods 'POST' found" )
  or print STDERR Dumper( $res->[1] );
ok( $policy{'Access-Control-Expose-Headers'} eq '*',
    "CORS expose-headers '*' found" )
  or print STDERR Dumper( $res->[1] );
ok( $policy{'Access-Control-Max-Age'} eq '86400', "CORS max-age '86400' found" )
  or print STDERR Dumper( $res->[1] );
count(6);

#CSP
ok(
    $policy{'Content-Security-Policy'} =~
/default-src 'self';img-src 'self' data:;style-src 'self';font-src 'self';connect-src 'self';script-src 'self';form-action \*;frame-ancestors 'none'/,
    'CSP header value found'
) or print STDERR Dumper( $res->[1] );
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
my $id = expectCookie($res);

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

%policy = @{ $res->[1] };

# Lm-Remote headers
ok( $policy{'Lm-Remote-User'} eq 'dwho', "Lm-Remote-User found" )
  or print STDERR Dumper( $res->[1] );
ok( $policy{'Lm-Remote-Custom'} eq 'dwho@badwolf.org',
    "Lm-Remote-Custom found" )
  or print STDERR Dumper( $res->[1] );
count(2);

# CORS
ok( $policy{'Access-Control-Allow-Origin'} eq '', "CORS origin '' found" )
  or print STDERR Dumper( $res->[1] );
ok( $policy{'Access-Control-Allow-Credentials'} eq 'true',
    "CORS credentials 'true' found" )
  or print STDERR Dumper( $res->[1] );
ok( $policy{'Access-Control-Allow-Headers'} eq '*', "CORS headers '*' found" )
  or print STDERR Dumper( $res->[1] );
ok( $policy{'Access-Control-Allow-Methods'} eq 'POST',
    "CORS methods 'POST' found" )
  or print STDERR Dumper( $res->[1] );
ok( $policy{'Access-Control-Expose-Headers'} eq '*',
    "CORS expose-headers '*' found" )
  or print STDERR Dumper( $res->[1] );
ok( $policy{'Access-Control-Max-Age'} eq '86400', "CORS max-age '86400' found" )
  or print STDERR Dumper( $res->[1] );
count(6);

$client->logout($id);

clean_sessions();

done_testing( count() );
