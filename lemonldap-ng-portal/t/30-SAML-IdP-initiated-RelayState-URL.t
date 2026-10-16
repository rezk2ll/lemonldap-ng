use warnings;
use Test::More;
use strict;
use IO::String;
use LWP::UserAgent;
use LWP::Protocol::PSGI;
use URI;
use URI::QueryParam;

BEGIN {
    require 't/test-lib.pm';
    require 't/saml-lib.pm';
}

my $debug = 'error';
my ( $issuer, $sp, $res );

# Redefine LWP methods for tests
LWP::Protocol::PSGI->register( denyLwpRequests() );

SKIP: {
    eval "use Lasso";
    if ($@) {
        skip 'Lasso not found';
    }

    # Initialization
    $issuer = register( 'issuer', \&issuer );
    $sp     = register( 'sp',     \&sp );

    # Simple authentication on IdP
    ok(
        $res = $issuer->_post(
            '/', IO::String->new('user=french&password=french'),
            length => 27
        ),
        'Auth query'
    );
    expectOK($res);
    my $idpId = expectCookie($res);

    subtest "Trusted URL in RelayState is followed" => sub {
        my $res = idpInitiated( $idpId, 'http://test1.sp.com/foo?bar=1' );
        expectCookie($res);
        expectRedirection( $res, 'http://test1.sp.com/foo?bar=1' );
    };

    subtest "URL from trustedDomains in RelayState is followed" => sub {
        my $res = idpInitiated( $idpId, 'https://app.trusted.com/' );
        expectCookie($res);
        expectRedirection( $res, 'https://app.trusted.com/' );
    };

    subtest "Untrusted URL in RelayState is ignored" => sub {
        my $res = idpInitiated( $idpId, 'https://www.evil.com/' );
        expectCookie($res);
        expectRedirection( $res, 'http://auth.sp.com/' );
    };

    subtest "Untrusted URL disguised as trusted domain is ignored" => sub {
        my $res = idpInitiated( $idpId, 'http://test1.sp.com@www.evil.com/' );
        expectCookie($res);
        expectRedirection( $res, 'http://auth.sp.com/' );
    };

    subtest "Untrusted URL with trusted domain as suffix is ignored" => sub {
        my $res = idpInitiated( $idpId, 'http://www.evil.com/sp.com/' );
        expectCookie($res);
        expectRedirection( $res, 'http://auth.sp.com/' );
    };

    subtest "URL with XSS in RelayState is ignored" => sub {
        my $res = idpInitiated( $idpId, 'http://test1.sp.com/"><script>' );
        expectCookie($res);
        expectRedirection( $res, 'http://auth.sp.com/' );
    };
}

clean_sessions();
done_testing();

# Run an IdP-initiated SSO, inject RelayState in the SAML response sent to
# the SP (RelayState is not covered by the assertion signature)
sub idpInitiated {
    my ( $idpId, $relayState ) = @_;
    my $res;
    ok(
        $res = $issuer->_get(
            '/saml/singleSignOn',
            query  => 'IDPInitiated=1&spConfKey=sp.com',
            cookie => "lemonldap=$idpId",
            accept => 'test/html'
        ),
        'Query IdP to access to SP'
    );
    my ( $host, $url, $query ) =
      expectAutoPost( $res, 'auth.sp.com', '/saml/proxySingleSignOnPost',
        'SAMLResponse' );

    my $u = URI->new;
    $u->query($query);
    $u->query_param( RelayState => $relayState );
    $query = $u->query;

    ok(
        $res = $sp->_post(
            $url, IO::String->new($query),
            accept => 'text/html',
            length => length($query),
        ),
        'Post SAML response to SP'
    );
    return $res;
}

sub issuer {
    return LLNG::Manager::Test->new( {
            ini => {
                logLevel               => $debug,
                domain                 => 'idp.com',
                portal                 => 'http://auth.idp.com/',
                authentication         => 'Demo',
                userDB                 => 'Same',
                issuerDBSAMLActivation => 1,
                samlSPMetaDataOptions  => {
                    'sp.com' => {
                        samlSPMetaDataOptionsEncryptionMode           => 'none',
                        samlSPMetaDataOptionsEnableIDPInitiatedURL    => 1,
                        samlSPMetaDataOptionsSignSSOMessage           => 1,
                        samlSPMetaDataOptionsSignSLOMessage           => 1,
                        samlSPMetaDataOptionsCheckSSOMessageSignature => 1,
                        samlSPMetaDataOptionsCheckSLOMessageSignature => 1,
                    }
                },
                samlSPMetaDataExportedAttributes => {
                    'sp.com' => {
                        cn =>
'1;cn;urn:oasis:names:tc:SAML:2.0:attrname-format:basic',
                        uid =>
'1;uid;urn:oasis:names:tc:SAML:2.0:attrname-format:basic',
                    }
                },
                samlOrganizationDisplayName => "IDP",
                samlOrganizationName        => "IDP",
                samlOrganizationURL         => "http://www.idp.com/",
                samlServicePrivateKeyEnc    => saml_key_idp_private_enc,
                samlServicePrivateKeySig    => saml_key_idp_private_sig,
                samlServicePublicKeyEnc     => saml_key_idp_public_enc,
                samlServicePublicKeySig     => saml_key_idp_public_sig,
                samlSPMetaDataXML           => {
                    "sp.com" => {
                        samlSPMetaDataXML =>
                          samlSPMetaDataXML( 'sp', 'HTTP-POST' )
                    },
                },
            }
        }
    );
}

sub sp {
    return LLNG::Manager::Test->new( {
            ini => {
                logLevel               => $debug,
                domain                 => 'sp.com',
                portal                 => 'http://auth.sp.com/',
                authentication         => 'SAML',
                userDB                 => 'Same',
                issuerDBSAMLActivation => 0,
                trustedDomains         => 'app.trusted.com',
                locationRules          => {
                    'test1.sp.com' => { default => 'accept' },
                },
                samlIDPMetaDataOptions => {
                    idp => {
                        samlIDPMetaDataOptionsEncryptionMode => 'none',
                        samlIDPMetaDataOptionsSSOBinding     => 'post',
                        samlIDPMetaDataOptionsSLOBinding     => 'post',
                        samlIDPMetaDataOptionsSignSSOMessage => 1,
                        samlIDPMetaDataOptionsSignSLOMessage => 1,
                        samlIDPMetaDataOptionsCheckSSOMessageSignature => 1,
                        samlIDPMetaDataOptionsCheckSLOMessageSignature => 1,
                        samlIDPMetaDataOptionsAllowLoginFromIDP        => 1,
                        samlIDPMetaDataOptionsRelayStateURL            => 1,
                    }
                },
                samlIDPMetaDataExportedAttributes => {
                    idp => {
                        "uid" => "0;uid;;",
                        "cn"  => "1;cn;;",
                    },
                },
                samlIDPMetaDataXML => {
                    idp => {
                        samlIDPMetaDataXML =>
                          samlIDPMetaDataXML( 'idp', 'HTTP-POST' )
                    }
                },
                samlOrganizationDisplayName => "SP",
                samlOrganizationName        => "SP",
                samlOrganizationURL         => "http://www.sp.com",
                samlServicePublicKeySig     => saml_key_sp_public_sig,
                samlServicePrivateKeyEnc    => saml_key_sp_private_enc,
                samlServicePrivateKeySig    => saml_key_sp_private_sig,
                samlServicePublicKeyEnc     => saml_key_sp_public_enc,
                samlSPSSODescriptorAuthnRequestsSigned => 1,
            },
        }
    );
}
