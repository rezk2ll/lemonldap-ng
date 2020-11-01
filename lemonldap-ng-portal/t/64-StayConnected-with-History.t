use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel            => 'error',
            useSafeJail         => 1,
            stayConnected       => 1,
            loginHistoryEnabled => 1,
            securedCookie       => 1,
            portalMainLogo      => 'common/logos/logo_llng_old.png',
            accept              => 'text/html',
        }
    }
);

# Try to authenticate
# -------------------
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho&stayconnected=1'),
        length => 39
    ),
    'Auth query'
);
count(1);
my $id = expectCookie($res);
my ( $host, $url, $query ) =
  expectForm( $res, undef, '/registerbrowser', 'fg', 'token' );

# Push fingerprint
$query =~ s/fg=/fg=aaa/;
ok(
    $res = $client->_post(
        '/registerbrowser',
        IO::String->new($query),
        length => length($query),
        cookie => "lemonldap=$id",
        accept => 'text/html',
    ),
    'Post fingerprint'
);
expectRedirection( $res, 'http://auth.example.com/' );
my $cid = expectCookie( $res, 'llngconnexion' );
ok( $res->[1]->[5] =~ /\bsecure\b/, ' Secured cookie found' )
  or print STDERR Dumper( $res->[1]->[5] );
count(2);
$client->logout($id);

# Try to connect with persistent connection cookie
ok(
    $res = $client->_get(
        '/',
        cookie => "llngconnexion=$cid",
        accept => 'text/html',
    ),
    'Try to auth with persistent cookie'
);
count(1);
expectOK($res);
( $host, $url, $query ) = expectForm( $res, '#', undef, 'fg', 'token' );

# Push fingerprint
$query =~ s/fg=/fg=aaa/;
ok(
    $res = $client->_post(
        '/',
        IO::String->new($query),
        cookie => "llngconnexion=$cid",
        length => length($query),
        accept => 'text/html',
    ),
    'Post fingerprint'
);
count(1);
expectRedirection( $res, 'http://auth.example.com/' );
$id = expectCookie($res);

$client->logout($id);

# Try to connect with persistent connection cookie but bad fingerprint
ok(
    $res = $client->_get(
        '/',
        cookie => "llngconnexion=$cid",
        accept => 'text/html',
    ),
    'Try to auth with persistent cookie'
);
count(1);
expectOK($res);
( $host, $url, $query ) = expectForm( $res, '#', undef, 'fg', 'token' );

# Push fingerprint
$query =~ s/fg=/fg=aaaa/;
ok(
    $res = $client->_post(
        '/',
        IO::String->new($query),
        cookie => "llngconnexion=$cid",
        length => length($query),
        accept => 'text/html',
    ),
    'Post bad fingerprint'
);
( $host, $url, $query ) = expectForm($res);
ok( $query =~ /user/, ' Get login form' );
count(2);

# Try to authenticate with history
# --------------------------------
ok(
    $res = $client->_post(
        '/',
        IO::String->new(
            'user=dwho&password=dwho&stayconnected=1&checkLogins=1'),
        length => 53
    ),
    'Auth query'
);
count(1);
$id = expectCookie($res);
( $host, $url, $query ) =
  expectForm( $res, undef, '/registerbrowser', 'fg', 'token' );

# Push fingerprint
$query =~ s/fg=/fg=aaa/;
ok(
    $res = $client->_post(
        '/registerbrowser',
        IO::String->new($query),
        length => length($query),
        cookie => "lemonldap=$id",
        accept => 'text/html',
    ),
    'Post fingerprint'
);
count(1);
$cid = expectCookie( $res, 'llngconnexion' );

ok( $res->[2]->[0] =~ qr%<img src="/static/common/logos/logo_llng_old.png"%,
    'Found custom Main Logo' )
  or print STDERR Dumper( $res->[2]->[0] );
ok( $res->[2]->[0] =~ /trspan="lastLogins"/, 'History found' )
  or explain( $res->[2]->[0], 'trspan="lastLogins"' );
my @c = ( $res->[2]->[0] =~ /<td>127.0.0.1/gs );

# History with 2 successLogins
ok( @c == 2, " -> Two entries found" )
  or explain( $res->[2]->[0], 'Two entries found' );
ok( $res = $client->_get( '/', cookie => "lemonldap=$id" ),
    'Verify connection' );
expectAuthenticatedAs( $res, 'dwho' );
ok(
    $res = $client->_get(
        '/',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Get Menu'
);
ok( $res->[2]->[0] =~ m%<span trspan="yourApps">Your applications</span>%,
    ' Apps menu found' )
  or print STDERR Dumper( $res->[2]->[0] );
count(6);
expectOK($res);

$client->logout($id);
clean_sessions();

done_testing( count() );

