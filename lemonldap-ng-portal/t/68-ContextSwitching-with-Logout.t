use Test::More;
use strict;
use IO::String;

BEGIN {
    require 't/test-lib.pm';
}

my $res;

my $client = LLNG::Manager::Test->new( {
        ini => {
            logLevel                       => 'error',
            authentication                 => 'Demo',
            userDB                         => 'Same',
            loginHistoryEnabled            => 0,
            brutForceProtection            => 0,
            portalMainLogo                 => 'common/logos/logo_llng_old.png',
            requireToken                   => 0,
            checkUser                      => 1,
            impersonationPrefix            => 'testPrefix_',
            securedCookie                  => 0,
            https                          => 0,
            checkUserDisplayPersistentInfo => 0,
            checkUserDisplayEmptyValues    => 0,
            contextSwitchingRule           => '$uid eq "dwho"',
            contextSwitchingIdRule         => '$uid ne "msmith"',
            contextSwitchingStopWithLogout => 1,
        }
    }
);

##
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
count(1);
expectOK($res);
ok( $res->[2]->[0] =~ m%<span trspan="connectedAs">Connected as</span> dwho%,
    'Connected as dwho' )
  or print STDERR Dumper( $res->[2]->[0] );
expectAuthenticatedAs( $res, 'dwho' );
ok( $res->[2]->[0] =~ m%<span trspan="contextSwitching_ON">contextSwitching_ON</span>%,
    'Connected as dwho' )
  or print STDERR Dumper( $res->[2]->[0] );
count(2);

# ContextSwitching form -> PE_OK
# ------------------------
ok(
    $res = $client->_get(
        '/switchcontext',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'ContextSwitching form',
);
count(1);

my ( $host, $url, $query ) =
  expectForm( $res, undef, '/switchcontext', 'spoofId' );
ok( $res->[2]->[0] =~ m%<span trspan="contextSwitching_ON">%, 'Found trspan="contextSwitching_ON"' )
  or explain( $res->[2]->[0], 'trspan="contextSwitching_ON"' );
$query =~ s/spoofId=/spoofId=rtyler/;
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
ok(
    $res = $client->_get(
        '/',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Get Menu',
);
count(3);
expectAuthenticatedAs( $res, 'rtyler' );
ok( $res->[2]->[0] =~ m%<span trspan="contextSwitching_OFF">%, 'Found trspan="contextSwitching_ON"' )
  or explain( $res->[2]->[0], 'trspan="contextSwitching_OFF"' );
ok(
    $res = $client->_get(
        '/switchcontext',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Stop context switching',
);
ok( $res->[2]->[0] =~ /trmsg="47"/, 'Found logout message' );
count(3);

clean_sessions();

done_testing( count() );
