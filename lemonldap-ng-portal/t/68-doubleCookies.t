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
            checkUser                      => 0,
            impersonationRule              => 0,
            impersonationIdRule            => '$uid ne "msmith"',
            impersonationPrefix            => 'testPrefix_',
            securedCookie                  => 3,
            https                          => 0,
            impersonationMergeSSOgroups    => 0,
            macros                         => {
                test_impersonation => '"$testPrefix__user/$_user"',
                _whatToTrace =>
                  '$_auth eq "SAML" ? "$_user@$_idpConfKey" : $_user',
            },
        }
    }
);

## Try to impersonate with a bad spoofed user
ok( $res = $client->_get( '/', accept => 'text/html' ), 'Get Menu', );
count(1);
my ( $host, $url, $query ) =
  expectForm( $res, '#', undef, 'user', 'password');#, 'spoofId' );

$query =~ s/user=/user=rtyler/;
$query =~ s/password=/password=rtyler/;
#$query =~ s/spoofId=/spoofId=dwho/;
ok(
    $res = $client->_post(
        '/',
        IO::String->new($query),
        length => length($query),
        accept => 'text/html',
    ),
    'Auth query'
);
count(1);

my $id1 = expectCookie($res);
ok( $id1 =~ /\w+/, " -> Get cookie : lemonldap=something" )
  or explain( $res, "Set-Cookie: lemonldap=$id1" );
my $id2 = expectCookie( $res, 'lemonldaphttp' );
ok( $id2 =~ /\w+/, " -> Get cookie lemonldaphttp=something" )
  or explain( $res, "Set-Cookie: lemonldaphttp=$id2" );
expectRedirection( $res, 'http://auth.example.com/' );
count(2);

# # CheckUser form
# # ------------------------
# ok(
#     $res = $client->_get(
#         '/checkuser',
#         cookie => "lemonldap=$id1",
#         accept => 'text/html'
#     ),
#     'CheckUser form',
# );
# count(1);
# ( $host, $url, $query ) =
#   expectForm( $res, undef, '/checkuser', 'user', 'url' );
# ok( $res->[2]->[0] =~ m%<span trspan="checkUser">%, 'Found trspan="checkUser"' )
#   or explain( $res->[2]->[0], 'trspan="checkUser"' );
# count(1);

# ok(
#     $res = $client->_post(
#         '/checkuser',
#         IO::String->new($query),
#         cookie => "lemonldap=$id1",
#         length => length($query),
#         accept => 'text/html',
#     ),
#     'POST checkuser'
# );
# count(1);

$client->logout($id1);
clean_sessions();

done_testing( count() );
