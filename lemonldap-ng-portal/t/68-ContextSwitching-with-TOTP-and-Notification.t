use Test::More;
use strict;
use IO::String;

require 't/test-lib.pm';

my $res;
my $file = "$main::tmpDir/20160530_msmith_dGVzdHJlZg==.json";

open F, "> $file" or die($!);
print F '[
{
  "uid": "msmith",
  "date": "2016-05-30",
  "reference": "testref",
  "title": "Test title",
  "subtitle": "Test subtitle",
  "text": "This is a test text",
  "check": ["Accept test","Accept test2"]
}
]';
close F;

my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel                       => 'error',
            authentication                 => 'Demo',
            userDB                         => 'Same',
            loginHistoryEnabled            => 0,
            portalMainLogo                 => 'common/logos/logo_llng_old.png',
            contextSwitchingRule           => 1,
            contextSwitchingIdRule         => 1,
            totp2fSelfRegistration         => 1,
            totp2fActivation               => 1,
            contextSwitchingStopWithLogout => 0,
            notification                   => 1,
            notificationStorage            => 'File',
            notificationStorageOptions     => { dirName => $main::tmpDir },
        }
    }
);

## Try to authenticate
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23,
        accept => 'text/html',
    ),
    'Auth query'
);
count(1);
my $id = expectCookie($res);
expectRedirection( $res, 'http://auth.example.com/' );

# JS query
ok(
    $res = $client->_post(
        '/2fregisters/totp/getkey', IO::String->new(''),
        cookie => "lemonldap=$id",
        length => 0,
    ),
    'Get new key'
);
eval { $res = JSON::from_json( $res->[2]->[0] ) };
ok( not($@), 'Content is JSON' )
  or explain( $res->[2]->[0], 'JSON content' );
my ( $key, $token );
ok( $key   = $res->{secret}, 'Found secret' );
ok( $token = $res->{token},  'Found token' );
$key = Convert::Base32::decode_base32($key);
count(4);

# Post code
my $code;
ok( $code = Lemonldap::NG::Common::TOTP::_code( undef, $key, 0, 30, 6 ),
    'Code' );
ok( $code =~ /^\d{6}$/, 'Code contains 6 digits' );
my $s = "code=$code&token=$token";
ok(
    $res = $client->_post(
        '/2fregisters/totp/verify',
        IO::String->new($s),
        length => length($s),
        cookie => "lemonldap=$id",
    ),
    'Post code'
);
eval { $res = JSON::from_json( $res->[2]->[0] ) };
ok( not($@), 'Content is JSON' )
  or explain( $res->[2]->[0], 'JSON content' );
ok( $res->{result} == 1, 'Key is registered' );
count(5);
$client->logout($id);

## Try to authenticate
ok( $res = $client->_get( '/', accept => 'text/html' ), 'Get Menu', );
my ( $host, $url, $query ) = expectForm( $res, '#', undef, 'user', 'password' );
$query =~ s/user=/user=rtyler/;
$query =~ s/password=/password=rtyler/;
ok(
    $res = $client->_post(
        '/',
        IO::String->new($query),
        length => length($query),
        accept => 'text/html',
    ),
    'Auth query'
);
count(2);
$id = expectCookie($res);
expectRedirection( $res, 'http://auth.example.com/' );

# Get Menu
# ------------------------
ok(
    $res = $client->_get(
        '/',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Get Menu',
);
expectOK($res);
ok(
    $res->[2]->[0] =~ m%<span trspan="connectedAs">Connected as</span> rtyler%,
    'Connected as rtyler'
) or print STDERR Dumper( $res->[2]->[0] );
expectAuthenticatedAs( $res, 'rtyler' );
ok(
    $res->[2]->[0] =~
      m%<span trspan="contextSwitching_ON">contextSwitching_ON</span>%,
    'Connected as rtyler'
) or print STDERR Dumper( $res->[2]->[0] );
count(3);

# JS query
ok(
    $res = $client->_post(
        '/2fregisters/totp/getkey', IO::String->new(''),
        cookie => "lemonldap=$id",
        length => 0,
    ),
    'Get new key'
);
eval { $res = JSON::from_json( $res->[2]->[0] ) };
ok( not($@), 'Content is JSON' )
  or explain( $res->[2]->[0], 'JSON content' );
my ( $key, $token );
ok( $key   = $res->{secret}, 'Found secret' );
ok( $token = $res->{token},  'Found token' );
$key = Convert::Base32::decode_base32($key);
count(4);

# Post code
my $code;
ok( $code = Lemonldap::NG::Common::TOTP::_code( undef, $key, 0, 30, 6 ),
    'Code' );
ok( $code =~ /^\d{6}$/, 'Code contains 6 digits' );
my $s = "code=$code&token=$token";
ok(
    $res = $client->_post(
        '/2fregisters/totp/verify',
        IO::String->new($s),
        length => length($s),
        cookie => "lemonldap=$id",
    ),
    'Post code'
);
eval { $res = JSON::from_json( $res->[2]->[0] ) };
ok( not($@), 'Content is JSON' )
  or explain( $res->[2]->[0], 'JSON content' );
ok( $res->{result} == 1, 'Key is registered' );
count(5);

# ContextSwitching form
# ------------------------
ok(
    $res = $client->_get(
        '/switchcontext',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'ContextSwitching form',
);
( $host, $url, $query ) =
  expectForm( $res, undef, '/switchcontext', 'spoofId' );
ok( $res->[2]->[0] =~ m%<span trspan="contextSwitching_ON">%,
    'Found trspan="contextSwitching_ON"' )
  or explain( $res->[2]->[0], 'trspan="contextSwitching_ON"' );

## POST form
$query =~ s/spoofId=/spoofId=dwho/;
ok(
    $res = $client->_post(
        '/switchcontext',
        IO::String->new($query),
        cookie => "lemonldap=$id",
        length => length($query),
        accept => 'text/html',
    ),
    'POST switchcontext'
);
ok( $res->[2]->[0] =~ m%<span trspan="contextSwitching_OFF">%,
    'Found trspan="contextSwitching_OFF"' )
  or explain( $res->[2]->[0], 'trspan="contextSwitching_OFF"' );
$id = expectCookie($res);
ok(
    $res = $client->_get(
        '/',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Get Menu',
);
expectAuthenticatedAs( $res, 'dwho' );
ok( $res->[2]->[0] =~ m%<span trspan="contextSwitching_OFF">%,
    'Found trspan="contextSwitching_OFF"' )
  or explain( $res->[2]->[0], 'trspan="contextSwitching_OFF"' );
count(6);

# Stop ContextSwitching
# ------------------------
ok(
    $res = $client->_get(
        '/switchcontext',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Stop context switching',
);
$id = expectCookie($res);
ok(
    $res = $client->_get(
        '/',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Get Menu',
);
count(2);
expectAuthenticatedAs( $res, 'rtyler' );

# ContextSwitching form
# ------------------------
ok(
    $res = $client->_get(
        '/switchcontext',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'ContextSwitching form',
);
( $host, $url, $query ) =
  expectForm( $res, undef, '/switchcontext', 'spoofId' );
ok( $res->[2]->[0] =~ m%<span trspan="contextSwitching_ON">%,
    'Found trspan="contextSwitching_ON"' )
  or explain( $res->[2]->[0], 'trspan="contextSwitching_ON"' );

## POST form
$query =~ s/spoofId=/spoofId=msmith/;
ok(
    $res = $client->_post(
        '/switchcontext',
        IO::String->new($query),
        cookie => "lemonldap=$id",
        length => length($query),
        accept => 'text/html',
    ),
    'POST switchcontext'
);
ok( $res->[2]->[0] =~ m%<span trspan="contextSwitching_OFF">%,
    'Found trspan="contextSwitching_OFF"' )
  or explain( $res->[2]->[0], 'trspan="contextSwitching_OFF"' );
$id = expectCookie($res);
ok(
    $res = $client->_get(
        '/',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Get Menu',
);
expectAuthenticatedAs( $res, 'msmith' );
ok( $res->[2]->[0] =~ m%<span trspan="contextSwitching_OFF">%,
    'Found trspan="contextSwitching_OFF"' )
  or explain( $res->[2]->[0], 'trspan="contextSwitching_OFF"' );
count(6);

# Stop ContextSwitching
# ------------------------
ok(
    $res = $client->_get(
        '/switchcontext',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Stop context switching',
);
$id = expectCookie($res);
ok(
    $res = $client->_get(
        '/',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Get Menu',
);
count(2);
expectAuthenticatedAs( $res, 'rtyler' );
$client->logout($id);

clean_sessions();

done_testing( count() );
