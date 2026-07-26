use warnings;
use Test::More;
use strict;
use IO::String;
use MIME::Base64;
use JSON;

BEGIN {
    require 't/test-lib.pm';
    require 't/oidc-lib.pm';
}

my $debug = 'error';

my $op = LLNG::Manager::Test->new( {
        ini => {
            logLevel                        => $debug,
            domain                          => 'op.com',
            portal                          => 'http://auth.op.com/',
            authentication                  => 'Demo',
            userDB                          => 'Same',
            issuerDBOpenIDConnectActivation => 1,
            oidcRPMetaDataExportedVars      => {
                rp => {
                    email       => "mail",
                    family_name => "cn",
                    name        => "cn"
                },
                rp_san => {
                    email       => "mail",
                    family_name => "cn",
                    name        => "cn"
                },
            },
            oidcRPMetaDataOptions => {
                rp => {
                    oidcRPMetaDataOptionsDisplayName           => "mTLS RP",
                    oidcRPMetaDataOptionsIDTokenExpiration     => 3600,
                    oidcRPMetaDataOptionsClientID              => "mtls_client",
                    oidcRPMetaDataOptionsIDTokenSignAlg        => "RS256",
                    oidcRPMetaDataOptionsUserIDAttr            => "",
                    oidcRPMetaDataOptionsAccessTokenExpiration => 3600,
                    oidcRPMetaDataOptionsBypassConsent         => 1,
                    oidcRPMetaDataOptionsRedirectUris       => 'http://rp.com/',
                    oidcRPMetaDataOptionsAuthMethod         => 'tls_client_auth',
                    oidcRPMetaDataOptionsMtlsCertIdentifierType => 'DN',
                    oidcRPMetaDataOptionsMtlsCertIdentifier =>
                      'CN=mtls_client,O=Example,C=FR',
                },
                rp_san => {
                    oidcRPMetaDataOptionsDisplayName       => "mTLS RP SAN",
                    oidcRPMetaDataOptionsIDTokenExpiration => 3600,
                    oidcRPMetaDataOptionsClientID          => "mtls_client_san",
                    oidcRPMetaDataOptionsIDTokenSignAlg    => "RS256",
                    oidcRPMetaDataOptionsUserIDAttr        => "",
                    oidcRPMetaDataOptionsAccessTokenExpiration => 3600,
                    oidcRPMetaDataOptionsBypassConsent         => 1,
                    oidcRPMetaDataOptionsRedirectUris          => 'http://rp.com/',
                    oidcRPMetaDataOptionsAuthMethod            => 'tls_client_auth',
                    oidcRPMetaDataOptionsMtlsCertIdentifierType => 'DNS',
                    oidcRPMetaDataOptionsMtlsCertIdentifier => 'client.example.com',
                },
                rp_noid => {
                    oidcRPMetaDataOptionsDisplayName       => "mTLS RP no id",
                    oidcRPMetaDataOptionsIDTokenExpiration => 3600,
                    oidcRPMetaDataOptionsClientID          => "mtls_client_noid",
                    oidcRPMetaDataOptionsIDTokenSignAlg    => "RS256",
                    oidcRPMetaDataOptionsUserIDAttr        => "",
                    oidcRPMetaDataOptionsAccessTokenExpiration => 3600,
                    oidcRPMetaDataOptionsBypassConsent         => 1,
                    oidcRPMetaDataOptionsRedirectUris          => 'http://rp.com/',
                    oidcRPMetaDataOptionsAuthMethod            => 'tls_client_auth',

                    # No oidcRPMetaDataOptionsMtlsCertIdentifier: RFC 8705
                    # forbids accepting any PKI-validated certificate
                },
            },
            oidcServicePrivateKeySig => oidc_key_op_private_sig,
            oidcServicePublicKeySig  => oidc_cert_op_public_sig,
        }
    }
);

subtest "Discovery metadata includes mTLS auth methods" => sub {
    my $res = $op->_get( '/.well-known/openid-configuration',
        accept => 'application/json', );
    expectOK($res);
    my $json = expectJSON($res);

    my $auth_methods = $json->{token_endpoint_auth_methods_supported};
    ok( $auth_methods, 'token_endpoint_auth_methods_supported present' );
    ok(
        grep( /^tls_client_auth$/, @$auth_methods ),
        'tls_client_auth in supported methods'
    );
};

subtest "mTLS authentication with Subject DN match" => sub {
    my $idpId = login( $op, "french" );

    my $code = codeAuthorize(
        $op, $idpId,
        {
            response_type => "code",
            scope         => "openid profile email",
            client_id     => "mtls_client",
            state         => "af0ifjsldkj",
            redirect_uri  => "http://rp.com/"
        }
    );
    ok( $code, 'Got authorization code' );

    # Token request with valid client certificate
    my $query = buildForm( {
            grant_type   => 'authorization_code',
            code         => $code,
            redirect_uri => 'http://rp.com/',
            client_id    => 'mtls_client',
        }
    );
    my $res = $op->_post(
        '/oauth2/token',
        IO::String->new($query),
        accept => 'application/json',
        length => length($query),
        custom => {
            SSL_CLIENT_S_DN => 'CN=mtls_client,O=Example,C=FR',
        },
    );
    expectOK($res);
    my $json = expectJSON($res);
    ok( $json->{access_token}, 'Got access token with mTLS auth' );

    $op->logout($idpId);
};

subtest "mTLS authentication fails with wrong Subject DN" => sub {
    my $idpId = login( $op, "french" );

    my $code = codeAuthorize(
        $op, $idpId,
        {
            response_type => "code",
            scope         => "openid profile email",
            client_id     => "mtls_client",
            state         => "af0ifjsldkj",
            redirect_uri  => "http://rp.com/"
        }
    );
    ok( $code, 'Got authorization code' );

    # Token request with invalid client certificate
    my $query = buildForm( {
            grant_type   => 'authorization_code',
            code         => $code,
            redirect_uri => 'http://rp.com/',
            client_id    => 'mtls_client',
        }
    );
    my $res = $op->_post(
        '/oauth2/token',
        IO::String->new($query),
        accept => 'application/json',
        length => length($query),
        custom => {
            SSL_CLIENT_S_DN => 'CN=wrong_client,O=Evil,C=XX',
        },
    );
    is( $res->[0], 400,
        'Token request rejected with wrong certificate (invalid_client)' );

    $op->logout($idpId);
};

subtest "mTLS authentication fails without certificate" => sub {
    my $idpId = login( $op, "french" );

    my $code = codeAuthorize(
        $op, $idpId,
        {
            response_type => "code",
            scope         => "openid profile email",
            client_id     => "mtls_client",
            state         => "af0ifjsldkj",
            redirect_uri  => "http://rp.com/"
        }
    );
    ok( $code, 'Got authorization code' );

    # Token request without client certificate
    my $query = buildForm( {
            grant_type   => 'authorization_code',
            code         => $code,
            redirect_uri => 'http://rp.com/',
            client_id    => 'mtls_client',
        }
    );
    my $res = $op->_post(
        '/oauth2/token',
        IO::String->new($query),
        accept => 'application/json',
        length => length($query),
    );
    is( $res->[0], 400,
        'Token request rejected without certificate (invalid_client)' );

    $op->logout($idpId);
};

subtest "mTLS authentication with SAN DNS match" => sub {
    my $idpId = login( $op, "french" );

    my $code = codeAuthorize(
        $op, $idpId,
        {
            response_type => "code",
            scope         => "openid profile email",
            client_id     => "mtls_client_san",
            state         => "af0ifjsldkj",
            redirect_uri  => "http://rp.com/"
        }
    );
    ok( $code, 'Got authorization code' );

    # Token request with valid SAN DNS
    my $query = buildForm( {
            grant_type   => 'authorization_code',
            code         => $code,
            redirect_uri => 'http://rp.com/',
            client_id    => 'mtls_client_san',
        }
    );
    my $res = $op->_post(
        '/oauth2/token',
        IO::String->new($query),
        accept => 'application/json',
        length => length($query),
        custom => {
            SSL_CLIENT_S_DN      => 'CN=something,O=Example,C=FR',
            SSL_CLIENT_SAN_DNS_0 => 'client.example.com',
        },
    );
    expectOK($res);
    my $json = expectJSON($res);
    ok( $json->{access_token}, 'Got access token with mTLS SAN DNS auth' );

    $op->logout($idpId);
};

subtest "mTLS authentication refused when no identifier configured" => sub {
    my $idpId = login( $op, "french" );

    my $code = codeAuthorize(
        $op, $idpId,
        {
            response_type => "code",
            scope         => "openid profile email",
            client_id     => "mtls_client_noid",
            state         => "af0ifjsldkj",
            redirect_uri  => "http://rp.com/"
        }
    );
    ok( $code, 'Got authorization code' );

    # Token request with a valid PKI certificate but no expected identifier
    # configured on the RP: RFC 8705 forbids accepting it
    my $query = buildForm( {
            grant_type   => 'authorization_code',
            code         => $code,
            redirect_uri => 'http://rp.com/',
            client_id    => 'mtls_client_noid',
        }
    );
    my $res = $op->_post(
        '/oauth2/token',
        IO::String->new($query),
        accept => 'application/json',
        length => length($query),
        custom => {
            SSL_CLIENT_S_DN => 'CN=anything,O=Example,C=FR',
        },
    );
    is( $res->[0], 400,
        'Token request rejected when no identifier configured (invalid_client)'
    );

    $op->logout($idpId);
};

subtest "mTLS authentication fails with wrong SAN DNS" => sub {
    my $idpId = login( $op, "french" );

    my $code = codeAuthorize(
        $op, $idpId,
        {
            response_type => "code",
            scope         => "openid profile email",
            client_id     => "mtls_client_san",
            state         => "af0ifjsldkj",
            redirect_uri  => "http://rp.com/"
        }
    );
    ok( $code, 'Got authorization code' );

    # Token request with wrong SAN DNS
    my $query = buildForm( {
            grant_type   => 'authorization_code',
            code         => $code,
            redirect_uri => 'http://rp.com/',
            client_id    => 'mtls_client_san',
        }
    );
    my $res = $op->_post(
        '/oauth2/token',
        IO::String->new($query),
        accept => 'application/json',
        length => length($query),
        custom => {
            SSL_CLIENT_S_DN      => 'CN=something,O=Example,C=FR',
            SSL_CLIENT_SAN_DNS_0 => 'wrong.example.com',
        },
    );
    is( $res->[0], 400,
        'Token request rejected with wrong SAN DNS (invalid_client)' );

    $op->logout($idpId);
};

done_testing();
