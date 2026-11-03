use warnings;
use Test::More;
use strict;
use IO::String;
use LWP::UserAgent;
use LWP::Protocol::PSGI;
use MIME::Base64;

BEGIN {
    require 't/test-lib.pm';
    require 't/saml-lib.pm';
}

my $debug = 'error';
my ( $issuer, $sp, $res );

LWP::Protocol::PSGI->register( denyLwpRequests() );

SKIP: {
    eval "use Lasso";
    if ($@) {
        skip 'Lasso not found', 1;
    }

    $issuer = register( 'issuer', \&issuer );

    # Option off: behaviour unchanged
    $sp = register( 'sp', sub { sp( strict => 0 ) } );

    $res = spGet('');
    expectForm( $res, undef, undef, 'confirm' );
    like( $res->[2]->[0], qr/auth\.idp2\.com/, 'Off: IDP list displayed' );
    count(1);

    $res = spGet('idp=unknown');
    expectForm( $res, undef, undef, 'confirm' );
    like( $res->[2]->[0],
        qr/auth\.idp2\.com/, 'Off: unknown IDP falls back to the IDP list' );
    count(1);

    $sp  = register( 'sp', sub { sp( strict => 0, single => 1 ) } );
    $res = spGet('idp=unknown');
    expectAutoPost( $res, 'auth.idp.com', '/saml/singleSignOn', 'SAMLRequest' );

    $sp  = register( 'sp', sub { sp( strict => 0, rule => 1 ) } );
    $res = spGet('');
    expectAutoPost( $res, 'auth.idp2.com', '/saml/singleSignOn',
        'SAMLRequest' );

    $sp = register( 'sp', sub { sp( strict => 1, rule => 1 ) } );

    expectPortalError( spGet(''),            52, 'On: missing IDP refused' );
    expectPortalError( spGet('idp=unknown'), 52, 'On: unknown idp refused' );
    expectPortalError(
        spGet(
            buildForm(
                { idpEntityId => 'http://auth.unknown.com/saml/metadata' }
            )
        ),
        52,
        'On: unknown idpEntityId refused'
    );

    $res = spGet(
        buildForm( { idpEntityId => 'http://auth.idp.com/saml/metadata' } ) );
    expectAutoPost( $res, 'auth.idp.com', '/saml/singleSignOn', 'SAMLRequest' );

    $res = spGet('idp=idp');
    my $spPdata = 'lemonldappdata=' . expectCookie( $res, 'lemonldappdata' );
    my ( $host, $url, $query ) =
      expectAutoPost( $res, 'auth.idp.com', '/saml/singleSignOn',
        'SAMLRequest' );

    ok(
        $res = $issuer->_post(
            $url, IO::String->new($query),
            accept => 'text/html',
            length => length($query)
        ),
        'Post SAML request to IdP'
    );
    count(1);
    my $pdata = 'lemonldappdata=' . expectCookie( $res, 'lemonldappdata' );
    $query = "user=french&password=french&$query";
    ok(
        $res = $issuer->_post(
            $url, IO::String->new($query),
            accept => 'text/html',
            cookie => $pdata,
            length => length($query),
        ),
        'Authenticate on IdP'
    );
    count(1);
    my $idpId = expectCookie($res);
    ( $host, $url, $query ) =
      expectAutoPost( $res, 'auth.sp.com', '/saml/proxySingleSignOnPost',
        'SAMLResponse' );
    ok(
        $res = $sp->_post(
            $url, IO::String->new($query),
            accept => 'text/html',
            length => length($query),
            cookie => $spPdata,
        ),
        'Post SAML response to SP'
    );
    count(1);
    expectRedirection( $res, 'http://auth.sp.com/' );
    my $spId = expectCookie($res);
    is( getSession($spId)->data->{uid}, 'french', 'On: known IDP accepted' );
    count(1);

    # Option on: session upgrade goes back to the session's IdP
    ok(
        $res = $sp->_get(
            '/upgradesession',
            accept => 'text/html',
            cookie => "lemonldap=$spId",
        ),
        'Ask to upgrade session'
    );
    count(1);
    ( $host, $url, $query ) =
      expectForm( $res, undef, '/upgradesession', 'confirm' );
    ok(
        $res = $sp->_post(
            '/upgradesession', $query,
            accept => 'text/html',
            cookie => "lemonldap=$spId",
        ),
        'Confirm session upgrade'
    );
    count(1);
    expectAutoPost( $res, 'auth.idp.com', '/saml/singleSignOn', 'SAMLRequest' );

    $sp = register( 'sp', sub { sp( strict => 1, single => 1 ) } );
    expectPortalError( spGet(''), 52, 'On: single IDP not auto-selected' );

    ok(
        $res = $issuer->_get(
            '/saml/singleSignOn',
            query  => 'IDPInitiated=1&spConfKey=sp.com',
            cookie => "lemonldap=$idpId",
            accept => 'text/html'
        ),
        'IdP-initiated SSO'
    );
    count(1);
    ( $host, $url, $query ) =
      expectAutoPost( $res, 'auth.sp.com', '/saml/proxySingleSignOnPost',
        'SAMLResponse' );
    ok(
        $res = $sp->_post(
            $url, IO::String->new($query),
            accept => 'text/html',
            length => length($query),
        ),
        'Post IdP-initiated SAML response to SP'
    );
    count(1);
    $spId = expectCookie($res);
    is( getSession($spId)->data->{uid},
        'french', 'On: IdP-initiated response accepted' );
    count(1);
}

clean_sessions();
done_testing( count() );

sub spGet {
    my ($query) = @_;
    my $res;
    ok( $res = $sp->_get( '/', query => $query, accept => 'text/html' ),
        "SP request ($query)" );
    count(1);
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
                        samlSPMetaDataOptionsCheckSSOMessageSignature => 1,
                    }
                },
                samlSPMetaDataExportedAttributes => {
                    'sp.com' => {
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
    my (%args) = @_;
    my @idps   = $args{single} ? ('idp') : ( 'idp', 'idp2' );
    my $common = {
        samlIDPMetaDataOptionsEncryptionMode           => 'none',
        samlIDPMetaDataOptionsSSOBinding               => 'post',
        samlIDPMetaDataOptionsSLOBinding               => 'post',
        samlIDPMetaDataOptionsSignSSOMessage           => 1,
        samlIDPMetaDataOptionsCheckSSOMessageSignature => 1,
        samlIDPMetaDataOptionsAllowLoginFromIDP        => 1,
    };
    return LLNG::Manager::Test->new( {
            ini => {
                logLevel               => $debug,
                domain                 => 'sp.com',
                portal                 => 'http://auth.sp.com/',
                authentication         => 'SAML',
                userDB                 => 'Same',
                issuerDBSAMLActivation => 0,
                samlStrictIDPSelection => $args{strict},
                samlIDPMetaDataOptions => {
                    map {
                        $_ => {
                            %$common,
                            (
                                ( $args{rule} and $_ eq 'idp2' )
                                ? ( samlIDPMetaDataOptionsResolutionRule =>
                                      '1' )
                                : ()
                            )
                        }
                    } @idps
                },
                samlIDPMetaDataExportedAttributes =>
                  { map { $_ => { uid => "1;uid;;" } } @idps },
                samlIDPMetaDataXML => {
                    map {
                        $_ => { samlIDPMetaDataXML =>
                              samlIDPMetaDataXML( $_, 'HTTP-POST' ) }
                    } @idps
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
