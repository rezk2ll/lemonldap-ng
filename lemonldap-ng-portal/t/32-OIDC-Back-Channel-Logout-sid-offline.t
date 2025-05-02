use Test::More;
use strict;
use IO::String;
use LWP::UserAgent;
use LWP::Protocol::PSGI;
use MIME::Base64;

BEGIN {
    require 't/test-lib.pm';
    require 't/oidc-lib.pm';
}

my $debug = 'error';
my ( $op, $rp, $res );

my $refresh_token;

my $op2rpRequestCount = 0;
my $lastRpRequest     = '';

LWP::Protocol::PSGI->register(
    sub {
        my $req = Plack::Request->new(@_);
        ok( $req->uri =~ m#http://auth.((?:o|r)p).com(.*)#, ' REST request' );
        my $host = $1;
        my $url  = $2;
        my ( $res, $client );
        if ( $host eq 'op' ) {
            pass("  Request from RP to OP,     endpoint $url");
            $client = $op;
        }
        elsif ( $host eq 'rp' ) {
            pass('  Request from OP to RP');
            $client = $rp;
            $op2rpRequestCount++;
            $lastRpRequest = $req->uri;
        }
        else {
            fail('  Aborting REST request (external)');
            return [ 500, [], [] ];
        }
        if ( $req->method =~ /^post$/i ) {
            my $s = $req->content || '';
            ok(
                $res = $client->_post(
                    $url,
                    IO::String->new($s),
                    length => length($s),
                    type   => $req->header('Content-Type'),
                    (
                        $req->header('Authorization')
                        ? (
                            custom => {
                                HTTP_AUTHORIZATION =>
                                  $req->header('Authorization'),
                            }
                          )
                        : ()
                    ),
                ),
                '  Execute request'
            );
        }
        else {
            ok(
                $res = $client->_get(
                    $url,
                    custom => {
                        HTTP_AUTHORIZATION => $req->header('Authorization')
                          || '',
                        HTTP_COOKIE => $req->header('Cookie') || '',
                    }
                ),
                '  Execute request'
            );
        }
        ok( $res->[0] == 200, '  Response is 200' );
        if ( $url !~ /(?:blogout|oidcTokenRevoke)/ ) {
            ok( getHeader( $res, 'Content-Type' ) =~ m#^application/json#,
                '  Content is JSON' )
              or explain( $res->[1], 'Content-Type => application/json' );
        }
        if ( $url =~ m#/token# ) {
            my $json = eval { JSON::from_json( $res->[2]->[0] ) };
            if ($json) {
                $refresh_token = $json->{refresh_token};
            }
            else {
                fail "Bad response" if $@;
            }
        }
        return $res;
    }
);

# Initialization
ok( $op = register( 'op', sub { op() } ), 'OP portal' );

ok( $res = $op->_get('/oauth2/jwks'), 'Get JWKS,     endpoint /oauth2/jwks' );
expectOK($res);
my $jwks = $res->[2]->[0];

ok(
    $res = $op->_get('/.well-known/openid-configuration'),
    'Get metadata, endpoint /.well-known/openid-configuration'
);
expectOK($res);
my $metadata = $res->[2]->[0];

&Lemonldap::NG::Handler::Main::cfgNum( 0, 0 );
ok( $rp = register( 'rp', sub { rp( $jwks, $metadata ) } ), 'RP portal' );

sub runTest {

    my ( $adminLogout, $useRT ) = @_;

    # Query RP for auth
    ok( $res = $rp->_get( '/', accept => 'text/html' ), 'Unauth RP request' );
    my ( $url, $query ) =
      expectRedirection( $res,
        qr#http://auth.op.com(/oauth2/authorize)\?(.*)$# );

    # Push request to OP
    ok( $res = $op->_get( $url, query => $query, accept => 'text/html' ),
        "Push request to OP,         endpoint $url" );
    expectOK($res);

    # Try to authenticate to OP
    $query = "user=french&password=french&$query";
    ok(
        $res = $op->_post(
            $url,
            IO::String->new($query),
            accept => 'text/html',
            length => length($query),
        ),
        "Post authentication,        endpoint $url"
    );
    my $idpId = expectCookie($res);
    ($query) = expectRedirection( $res, qr#^http://auth.rp.com/?\?(.*)$# );

    # Push OP response to RP

    ok( $res = $rp->_get( '/', query => $query, accept => 'text/html' ),
        'Call openidconnectcallback on RP' );
    my $spId = expectCookie($res);

    # Logout initiated by OP

    # Reset conf to make sure lazy loading works during logout (#3014)
    withHandler( 'op', sub { $op->p->HANDLER->checkConf(1) } );

    ok(
        $res = $op->_get(
            '/',
            query  => 'logout',
            cookie => "lemonldap=$idpId",
            accept => 'text/html'
        ),
        'Query OP for logout'
    );
    expectOK($res);

    # Test if logout is done
    ok(
        $res = $op->_get(
            '/', cookie => "lemonldap=$idpId",
        ),
        'Test if user is reject on OP'
    );
    expectReject($res);

    ok(
        $res = $rp->_get(
            '/',
            cookie => "lemonldap=$spId",
            accept => 'text/html'
        ),
        'Test if user is reject on RP'
    );
    expectRedirection( $res, qr#http://auth.op.com(/oauth2/authorize)\?(.*)$# );

    my $json = expectJSON( refreshGrant( $op, 'rpid', $refresh_token ) );

    my $i = $op2rpRequestCount;
    if ($adminLogout) {
        my $anotherId = $op->login('french');
        require t::SessionExplorer;
        my $se;
        ok( $se = t::SessionExplorer->new( $op->p->conf ),
            'Create SessionExplorer object' );
        expectOK(
            $se->adminLogout(
                query => (
                    $useRT
                    ? "sessionType=offline&sessionId=$refresh_token"
                    : "sessionType=global&sessionId=$anotherId"
                ),
            )
        );
        expectReject( $op->_get( '/', cookie => "lemonldap=$anotherId" ) );
    }
    else {
        $query = "token=$refresh_token&token_hint=refresh_token";
        ok(
            $op->_post(
                '/oauth2/revoke',
                IO::String->new($query),
                length => length($query),
                query  => 'logout=1',
                custom => { HTTP_AUTHORIZATION => "Basic cnBpZDpycGlk" }
            ),
            'Refresh_token logout'
        );
    }
    ok( $op2rpRequestCount == $i + 1, 'One request sent ro RP' );
    is(
        $lastRpRequest,
        'http://auth.rp.com/oauth2/blogout',
        'Last RP request is /oauth2/blogout'
    );

    ok( $res = refreshGrant( $op, 'rpid', $refresh_token ) );
    expectReject( $res, 400, 'invalid_request' );
}

subtest "Offline Back-Channel-Logout using revoke endpoint" => sub {
    runTest();
};

subtest "Offline Back-Channel-Logout using admin logout and SSO session" =>
  sub {
  SKIP: {
        eval { require Lemonldap::NG::Manager::Sessions };
        skip 'No manager found', 1 if $@;
        runTest( 1, 0 );
    }
  };

subtest "Offline Back-Channel-Logout using admin logout and refresh_token" =>
  sub {
  SKIP: {
        eval { require Lemonldap::NG::Manager::Sessions };
        skip 'No manager found', 1 if $@;
        runTest( 1, 1 );
    }
  };

clean_sessions();
done_testing();

sub op {
    return LLNG::Manager::Test->new( {
            ini => {
                logLevel                        => $debug,
                domain                          => 'idp.com',
                portal                          => 'http://auth.op.com/',
                authentication                  => 'Demo',
                userDB                          => 'Same',
                issuerDBOpenIDConnectActivation => "1",
                oidcRPMetaDataExportedVars      => {
                    rp => {
                        email       => "mail",
                        family_name => "cn",
                        name        => "cn"
                    }
                },
                oidcServiceAllowHybridFlow            => 1,
                restOidcRevokeSecret                  => 'qwertyui',
                oidcServiceAllowImplicitFlow          => 1,
                oidcServiceAllowAuthorizationCodeFlow => 1,
                oidcRPMetaDataOptions                 => {
                    rp => {
                        oidcRPMetaDataOptionsDisplayName           => "RP",
                        oidcRPMetaDataOptionsIDTokenExpiration     => 3600,
                        oidcRPMetaDataOptionsClientID              => "rpid",
                        oidcRPMetaDataOptionsAllowOffline          => 1,
                        oidcRPMetaDataOptionsIDTokenSignAlg        => "HS512",
                        oidcRPMetaDataOptionsBypassConsent         => 0,
                        oidcRPMetaDataOptionsClientSecret          => "rpid",
                        oidcRPMetaDataOptionsUserIDAttr            => "",
                        oidcRPMetaDataOptionsBypassConsent         => 1,
                        oidcRPMetaDataOptionsAccessTokenExpiration => 3600,
                        oidcRPMetaDataOptionsLogoutUrl             =>
                          'http://auth.rp.com/oauth2/blogout',
                        oidcRPMetaDataOptionsLogoutType            => 'back',
                        oidcRPMetaDataOptionsLogoutSessionRequired => 1,
                        oidcRPMetaDataOptionsRedirectUris          =>
                          'http://auth.rp.com/?openidconnectcallback=1',
                    }
                },
                oidcOPMetaDataOptions           => {},
                oidcOPMetaDataJSON              => {},
                oidcOPMetaDataJWKS              => {},
                oidcServiceMetaDataAuthnContext => {
                    'loa-4' => 4,
                    'loa-1' => 1,
                    'loa-5' => 5,
                    'loa-2' => 2,
                    'loa-3' => 3
                },
                oidcServicePrivateKeySig => oidc_key_op_private_sig,
                oidcServicePublicKeySig  => oidc_cert_op_public_sig,
            }
        }
    );
}

sub rp {
    my ( $jwks, $metadata ) = @_;
    return LLNG::Manager::Test->new( {
            ini => {
                logLevel                   => $debug,
                domain                     => 'rp.com',
                portal                     => 'http://auth.rp.com/',
                authentication             => 'OpenIDConnect',
                userDB                     => 'Same',
                restSessionServer          => 1,
                oidcOPMetaDataExportedVars => {
                    op => {
                        cn   => "name",
                        uid  => "sub",
                        sn   => "family_name",
                        mail => "email"
                    }
                },
                oidcServiceMetaDataBackChannelURI => 'blogout',
                oidcOPMetaDataOptions             => {
                    op => {
                        oidcOPMetaDataOptionsCheckJWTSignature => 1,
                        oidcOPMetaDataOptionsJWKSTimeout       => 0,
                        oidcOPMetaDataOptionsClientSecret      => "rpid",
                        oidcOPMetaDataOptionsScope             =>
                          "openid profile offline_access",
                        oidcOPMetaDataOptionsStoreIDToken     => 0,
                        oidcOPMetaDataOptionsDisplay          => "",
                        oidcOPMetaDataOptionsClientID         => "rpid",
                        oidcOPMetaDataOptionsConfigurationURI =>
                          "https://auth.op.com/.well-known/openid-configuration"
                    }
                },
                globalStorageOptions => {
                    Directory      => "$main::tmpDir/saml",
                    LockDirectory  => "$main::tmpDir/saml/lock",
                    generateModule =>
                      'Lemonldap::NG::Common::Apache::Session::Generate::SHA256',
                },
                oidcOPMetaDataJWKS => {
                    op => $jwks,
                },
                oidcOPMetaDataJSON => {
                    op => $metadata,
                }
            }
        }
    );
}
