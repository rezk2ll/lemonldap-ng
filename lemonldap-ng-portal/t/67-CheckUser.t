use Test::More;
use strict;
use IO::String;

BEGIN {
    require 't/test-lib.pm';
}

my $res;

my $client = LLNG::Manager::Test->new(
    {   ini => {
            logLevel            => 'error',
            authentication      => 'Demo',
            userDB              => 'Same',
            loginHistoryEnabled => 0,
            brutForceProtection => 0,
            portalMainLogo      => 'common/logos/logo_llng_old.png',
            checkUser           => 1,
            requireToken        => 0,
            checkUserDisplayPersistentInfo => 1,
            checkUserDisplayEmptyValues    => 1,
        }
    }
);

## Try to authenticate
ok( $res = $client->_post(
        '/',
        IO::String->new('user=rtyler&password=rtyler'),
        length => 27,
        accept => 'text/html',
    ),
    'Auth query'
);
count(1);

my $id = expectCookie($res);
expectRedirection( $res, 'http://auth.example.com/' );

ok( $res = $client->_get(
        '/checkuser',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'Try to access /checkuser'
);
count(1);

ok( $res->[2]->[0] =~ m%<img src="/static/common/logos/logo_llng_old.png"%,
    'Found custom Main Logo' )
    or explain( $res->[2]->[0], 'custom Main logo not found"' );
ok( $res->[2]->[0] =~ m%<span trspan="accessDenied">%,
    'Found trspan="accessDenied"' )
    or explain( $res->[2]->[0], 'trspan="accessDenied"' );
count(2);
$client->logout($id);

## Try to authenticate
ok( $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23,
        accept => 'text/html',
    ),
    'Auth query'
);
count(1);

$id = expectCookie($res);
expectRedirection( $res, 'http://auth.example.com/' );

# CheckUser form -> granted
# ------------------------
ok( $res = $client->_get(
        '/checkuser',
        cookie => "lemonldap=$id",
        accept => 'text/html'
    ),
    'CheckUser form',
);
count(1);
my ( $host, $url, $query )
    = expectForm( $res, undef, '/checkuser', 'user', 'url' );
ok( $res->[2]->[0] =~ m%<span trspan="checkUser">%,
    'Found trspan="checkUser"' )
    or explain( $res->[2]->[0], 'trspan="checkUser"' );
count(1);

$query =~ s/user=dwho/user=rtyler/;
$query =~ s/url=/url=http%3A%2F%2Ftest1.example.com/;

ok( $res = $client->_post(
        '/checkuser',
        IO::String->new($query),
        cookie => "lemonldap=$id",
        length => length($query),
        accept => 'text/html',
    ),
    'POST checkuser'
);
count(1);

( $host, $url, $query )
    = expectForm( $res, undef, '/checkuser', 'user', 'url' );
ok( $res->[2]->[0] =~ m%<span trspan="checkUser">%,
    'Found trspan="checkUser"' )
    or explain( $res->[2]->[0], 'trspan="checkUser"' );
count(1);

ok( $res->[2]->[0] =~ m%<span trspan="checkUser">%,
    'Found trspan="checkUser"' )
    or explain( $res->[2]->[0], 'trspan="checkUser"' );
ok( $res->[2]->[0]
        =~ m%<div class="alert alert-success"><span trspan="allowed"></span></div>%,
    'Found trspan="allowed"'
) or explain( $res->[2]->[0], 'trspan="allowed"' );
ok( $res->[2]->[0] =~ m%<span trspan="headers">%, 'Found trspan="headers"' )
    or explain( $res->[2]->[0], 'trspan="headers"' );
ok( $res->[2]->[0] =~ m%<span trspan="groups_sso">%,
    'Found trspan="groups_sso"' )
    or explain( $res->[2]->[0], 'trspan="groups_sso"' );
ok( $res->[2]->[0] =~ m%<span trspan="macros">%, 'Found trspan="macros"' )
    or explain( $res->[2]->[0], 'trspan="macros"' );
ok( $res->[2]->[0] =~ m%<span trspan="attributes">%,
    'Found trspan="attributes"' )
    or explain( $res->[2]->[0], 'trspan="attributes"' );
ok( $res->[2]->[0] =~ m%<td class="align-middle">Auth-User</td>%,
    'Found Auth-User' )
    or explain( $res->[2]->[0], 'Header Key: Auth-User' );
ok( $res->[2]->[0] =~ m%<td class="align-middle">rtyler</td>%,
    'Found rtyler' )
    or explain( $res->[2]->[0], 'Header Value: rtyler' );
ok( $res->[2]->[0] =~ m%<td class="align-middle">su</td>%, 'Found su' )
    or explain( $res->[2]->[0], 'SSO Groups: su' );
ok( $res->[2]->[0] =~ m%<td class="align-middle">_whatToTrace</td>%,
    'Found _whatToTrace' )
    or explain( $res->[2]->[0], 'Macro Key _whatToTrace' );
ok( $res->[2]->[0] =~ m%<td class="align-middle">uid</td>%, 'Found uid' )
    or explain( $res->[2]->[0], 'Macro Value uid' );
count(11);

$query =~ s/user=dwho/user=msmith/;
$query
    =~ s/url=http%3A%2F%2Ftest1.example.com/url=http%3A%2F%2Fmanager.example.com%2Fmanager.html/;

ok( $res = $client->_post(
        '/checkuser',
        IO::String->new($query),
        cookie => "lemonldap=$id",
        length => length($query),
        accept => 'text/html',
    ),
    'POST checkuser'
);
ok( $res->[2]->[0]
        =~ m%<div class="alert alert-danger"><span trspan="forbidden"></span></div>%,
    'Found trspan="forbidden"'
) or explain( $res->[2]->[0], 'trspan="forbidden"' );
count(2);

$client->logout($id);
clean_sessions();

done_testing( count() );