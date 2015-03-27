## @file
# OpenIDConnect Issuer file

## @class
# OpenIDConnect Issuer class
package Lemonldap::NG::Portal::IssuerDBOpenIDConnect;

use strict;
use Lemonldap::NG::Portal::Simple;
use base qw(Lemonldap::NG::Portal::_OpenIDConnect);

our $VERSION = '2.00';

## @method void issuerDBInit()
# Get configuration data
# @return Lemonldap::NG::Portal error code
sub issuerDBInit {
    my $self = shift;

    return PE_ERROR unless $self->loadRPs;

    return PE_OK;
}

## @apmethod int issuerForUnAuthUser()
# Get OIDC request
# @return Lemonldap::NG::Portal error code
sub issuerForUnAuthUser {

    my $self = shift;

    my $issuerDBOpenIDConnectPath = $self->{issuerDBOpenIDConnectPath};
    my $authorize_uri             = $self->{oidcServiceMetaDataAuthorizeURI};
    my $token_uri                 = $self->{oidcServiceMetaDataTokenURI};
    my $userinfo_uri              = $self->{oidcServiceMetaDataUserInfoURI};
    my $jwks_uri                  = $self->{oidcServiceMetaDataJWKSURI};
    my $issuer                    = $self->{oidcServiceMetaDataIssuer};

    # Called URL
    my $url = $self->url();
    my $url_path = $self->url( -absolute => 1 );
    $url_path =~ s#^//#/#;

    # AUTHORIZE
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${authorize_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect AUTHORIZE URL",
            'debug' );

        # Get and save parameters
        my $oidc_request = {};
        foreach my $param (
            qw/response_type scope client_id state redirect_uri nonce response_mode display prompt max_age ui_locales id_token_hint login_hint acr_values/
          )
        {
            $oidc_request->{$param} = $self->getHiddenFormValue($param)
              || $self->param($param);
            $self->lmLog(
                "OIDC request parameter $param: " . $oidc_request->{$param},
                'debug' );
            $self->setHiddenFormValue( $param, $oidc_request->{$param} );
        }

        # Detect requested flow
        my $response_type = $oidc_request->{'response_type'};
        my $flow          = $self->getFlowType($response_type);

        unless ($flow) {
            $self->lmLog( "Unknown response type: $response_type", 'error' );
            return PE_ERROR;
        }
        $self->lmLog(
            "OIDC $flow flow requested (response type: $response_type)",
            'debug' );

        # State
        my $state = $oidc_request->{'state'};

        # Check redirect_uri
        my $redirect_uri = $oidc_request->{'redirect_uri'};
        unless ($redirect_uri) {
            $self->lmLog( "Redirect URI is required", 'error' );
            return PE_ERROR;
        }

        # Check display
        my $display = $oidc_request->{'display'};
        if ( $display eq "page" ) {
            $self->lmLog( "Display type page will be used", 'debug' );
        }
        else {
            $self->lmLog(
"Display type $display not supported, display type page will be used",
                'debug'
            );
        }

        # Check prompt
        my $prompt = $oidc_request->{'prompt'};
        if ( $prompt =~ /\bnone\b/ ) {
            $self->lmLog(
                "Prompt type none requested, but user needs to authenticate",
                'error' );
            $self->returnRedirectError( $redirect_uri, "login_required",
                "Prompt type none requested",
                undef, $state, ( $flow ne "authorizationcode" ) );
        }

        # Check ui_locales
        my $ui_locales = $oidc_request->{'ui_locales'};
        if ( defined $ui_locales ) {
            my $lang = join( ',', split( /\s+/, $ui_locales ) );
            $self->{lang} = $self->extract_lang($lang);
        }

        # Check login_hint
        my $login_hint = $oidc_request->{'login_hint'};
        if ( defined $login_hint ) {
            $self->{user} ||= $login_hint;
        }

    }

    # TOKEN
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${token_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect TOKEN URL",
            'debug' );

        # Check authentication
        my ( $client_id, $client_secret ) =
          $self->getEndPointAuthenticationCredentials();

        unless ( $client_id && $client_secret ) {
            $self->lmLog(
"No authentication provided to get token, or authentication type not supported",
                "error"
            );
            $self->returnJSONError("unauthorized_client");
            $self->quit;
        }

        # Verify that client_id is registered in configuration
        my $rp = $self->getRP($client_id);

        unless ($rp) {
            $self->lmLog(
                "No registered Relying Party found with client_id $client_id",
                'error' );
            $self->returnJSONError("unauthorized_client");
            $self->quit;
        }
        else {
            $self->lmLog( "Client id $client_id match RP $rp", 'debug' );
        }

        # Check client_secret
        unless ( $client_secret eq $self->{oidcRPMetaDataOptions}->{$rp}
            ->{oidcRPMetaDataOptionsClientSecret} )
        {
            $self->lmLog( "Wrong credentials", "error" );
            $self->returnJSONError("access_denied");
            $self->quit;
        }

        # Get code session
        my $code = $self->param('code');

        $self->lmLog( "OpenID Connect Code: $code", 'debug' );

        my $codeSession = $self->getOpenIDConnectSession($code);

        unless ($codeSession) {
            $self->lmLog( "Unable to find OIDC session $code", "error" );
            $self->returnJSONError("invalid_request");
            $self->quit;
        }

        # Check we have the same redirect_uri value
        unless (
            $self->param("redirect_uri") eq $codeSession->data->{redirect_uri} )
        {
            $self->lmLog(
                "Provided redirect_uri is different from "
                  . $codeSession->{redirect_uri},
                "error"
            );
            $self->returnJSONError("invalid_request");
            $codeSession->remove();
            $self->quit;
        }

        # Get user identifier
        my $apacheSession =
          $self->getApacheSession( $codeSession->data->{user_session_id}, 1 );

        unless ($apacheSession) {
            $self->lmLog(
                "Unable to find user session linked to OIDC session $code",
                "error" );
            $self->returnJSONError("invalid_request");
            $codeSession->remove();
            $self->quit;
        }

        my $user_id_attribute = $self->{oidcRPMetaDataOptions}->{$rp}
          ->{oidcRPMetaDataOptionsUserIDAttr} || $self->{whatToTrace};
        my $user_id = $apacheSession->data->{$user_id_attribute};

        $self->lmLog( "Found corresponding user: $user_id", 'debug' );

        # Generate access_token
        my $accessTokenSession = $self->getOpenIDConnectSession;

        unless ($accessTokenSession) {
            $self->lmLog( "Unable to create OIDC session for access_token",
                "error" );
            $self->returnJSONError("invalid_request");
            $codeSession->remove();
            $self->quit;
        }

        # Store data in access token
        $accessTokenSession->update(
            {
                scope           => $codeSession->data->{scope},
                rp              => $rp,
                user_session_id => $apacheSession->id,
                _utime          => time,
            }
        );

        my $access_token = $accessTokenSession->id;

        $self->lmLog( "Generated access token: $access_token", 'debug' );

        # Compute hash to store in at_hash
        my $alg = $self->{oidcRPMetaDataOptions}->{$rp}
          ->{oidcRPMetaDataOptionsIDTokenSignAlg};
        my ($hash_level) = ( $alg =~ /(?:\w{2})(\d{3})/ );
        my $at_hash = $self->createHash( $access_token, $hash_level );

        # ID token payload
        my $id_token_exp = $self->{oidcRPMetaDataOptions}->{$rp}
          ->{oidcRPMetaDataOptionsIDTokenExpiration};

        my $id_token_acr = "loa-" . $apacheSession->data->{authenticationLevel};

        my $id_token_payload_hash = {
            iss => $issuer,          # Issuer Identifier
            sub => $user_id,         # Subject Identifier
            aud => [$client_id],     # Audience
            exp => $id_token_exp,    # expiration
            iat => time,             # Issued time
            auth_time =>
              $apacheSession->data->{_lastAuthnUTime},    # Authentication time
            acr => $id_token_acr,    # Authentication Context Class Reference
            azp => $client_id,       # Authorized party
                                     # TODO amr
        };

        my $nonce = $codeSession->data->{nonce};
        $id_token_payload_hash->{nonce} = $nonce if defined $nonce;
        $id_token_payload_hash->{'at_hash'} = $at_hash if $at_hash;

        # Create ID Token
        my $id_token = $self->createIDToken( $id_token_payload_hash, $rp );

        $self->lmLog( "Generated id token: $id_token", 'debug' );

        # Send token response
        my $expires_in = $self->{oidcRPMetaDataOptions}->{$rp}
          ->{oidcRPMetaDataOptionsAccessTokenExpiration};

        my $token_response = {
            access_token => $access_token,
            token_type   => 'Bearer',
            expires_in   => $expires_in,
            id_token     => $id_token,
        };

        $self->returnJSON($token_response);

        $self->lmLog( "Token response sent", 'debug' );

        $codeSession->remove();
        $self->quit;

    }

    # USERINFO
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${userinfo_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect USERINFO URL",
            'debug' );

        my $access_token = $self->getEndPointAccessToken();

        unless ($access_token) {
            $self->lmLog( "Unable to get access_token", "error" );
            $self->returnBearerError( "invalid_request",
                "Access token not found in request" );
            $self->quit;
        }

        $self->lmLog( "Received Access Token $access_token", 'debug' );

        my $accessTokenSession = $self->getOpenIDConnectSession($access_token);

        unless ($accessTokenSession) {
            $self->lmLog(
                "Unable to get access token session for id $access_token",
                "error" );
            $self->returnBearerError( "invalid_token",
                "Access Token not found or expired" );
            $self->quit;
        }

        # Get access token session data
        my $scope           = $accessTokenSession->data->{scope};
        my $rp              = $accessTokenSession->data->{rp};
        my $user_session_id = $accessTokenSession->data->{user_session_id};

        my $userinfo_response =
          $self->buildUserInfoResponse( $scope, $rp, $user_session_id );

        $self->returnJSON($userinfo_response);

        $self->lmLog( "UserInfo response sent", 'debug' );

        $self->quit;

    }

    # JWKS
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${jwks_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect JWKS URL",
            'debug' );

        my $jwks = { keys => [] };

        my $public_key_sig = $self->{oidcServicePublicKeySig};
        if ($public_key_sig) {
            my $key = $self->key2jwks($public_key_sig);
            $key->{kty} = "RSA";
            $key->{use} = "sig";
            push @{ $jwks->{keys} }, $key;
        }

        $self->returnJSON($jwks);

        $self->lmLog( "JWKS response sent", 'debug' );

        $self->quit;

    }

    PE_OK;
}

## @apmethod int issuerForAuthUser()
# Do nothing
# @return Lemonldap::NG::Portal error code
sub issuerForAuthUser {

    my $self = shift;

    my $issuerDBOpenIDConnectPath = $self->{issuerDBOpenIDConnectPath};
    my $authorize_uri             = $self->{issuerDBOpenIDConnectAuthorizeURI};
    my $token_uri                 = $self->{issuerDBOpenIDConnectTokenURI};
    my $userinfo_uri              = $self->{issuerDBOpenIDConnectUserInfoURI};
    my $jwks_uri                  = $self->{oidcServiceMetaDataJWKSURI};
    my $issuer                    = $self->{oidcServiceMetaDataIssuer};

    # Session ID
    my $session_id = $self->{sessionInfo}->{_session_id} || $self->{id};

    # Called URL
    my $url = $self->url();
    my $url_path = $self->url( -absolute => 1 );
    $url_path =~ s#^//#/#;

    # AUTHORIZE
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${authorize_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect AUTHORIZE URL",
            'debug' );

        # Get and save parameters
        my $oidc_request = {};
        foreach my $param (
            qw/response_type scope client_id state redirect_uri nonce response_mode display prompt max_age ui_locales id_token_hint login_hint acr_values/
          )
        {
            $oidc_request->{$param} = $self->getHiddenFormValue($param)
              || $self->param($param);
            $self->lmLog(
                "OIDC request parameter $param: " . $oidc_request->{$param},
                'debug' );
            $self->setHiddenFormValue( $param, $oidc_request->{$param} );
        }

        # Detect requested flow
        my $response_type = $oidc_request->{'response_type'};
        my $flow          = $self->getFlowType($response_type);

        unless ($flow) {
            $self->lmLog( "Unknown response type: $response_type", 'error' );
            return PE_ERROR;
        }
        $self->lmLog(
            "OIDC $flow flow requested (response type: $response_type)",
            'debug' );

        # Check all required parameters
        unless ( $oidc_request->{'redirect_uri'} ) {
            $self->lmLog( "Redirect URI is required", 'error' );
            return PE_ERROR;
        }
        unless ( $oidc_request->{'scope'} ) {
            $self->lmLog( "Scope is required", 'error' );
            $self->returnRedirectError(
                $oidc_request->{'redirect_uri'},
                "invalid_request",
                "scope required",
                undef,
                $oidc_request->{'state'},
                ( $flow ne "authorizationcode" )
            );
        }
        unless ( $oidc_request->{'client_id'} ) {
            $self->lmLog( "Client ID is required", 'error' );
            $self->returnRedirectError(
                $oidc_request->{'redirect_uri'},
                "invalid_request",
                "client_id required",
                undef,
                $oidc_request->{'state'},
                ( $flow ne "authorizationcode" )
            );
        }
        if ( $flow eq "implicit" and not defined $oidc_request->{'nonce'} ) {
            $self->lmLog( "Nonce is required for implicit flow", 'error' );
            $self->returnRedirectError(
                $oidc_request->{'redirect_uri'},
                "invalid_request", "nonce required",
                undef, $oidc_request->{'state'}, 1
            );
        }

        # Check if user needs to be reauthenticated
        my $reauthentication = 0;
        my $prompt           = $oidc_request->{'prompt'};
        if ( $prompt =~ /\blogin\b/ ) {
            $self->lmLog(
"Reauthentication requested by Relying Party in prompt parameter",
                'debug'
            );
            $reauthentication = 1;
        }

        my $max_age         = $oidc_request->{'max_age'};
        my $_lastAuthnUTime = $self->{sessionInfo}->{_lastAuthnUTime};
        if ( $max_age && time > $_lastAuthnUTime + $max_age ) {
            $self->lmLog(
"Reauthentication forced cause authentication time ($_lastAuthnUTime) is too old (>$max_age s)",
                'debug'
            );
            $reauthentication = 1;
        }

        if ($reauthentication) {

            # Replay authentication process
            $self->{updateSession} = 1;
            $self->{error}         = $self->_subProcess(
                qw(issuerDBInit authInit issuerForUnAuthUser extractFormInfo
                  userDBInit getUser setAuthSessionInfo setSessionInfo
                  setMacros setGroups setPersistentSessionInfo
                  setLocalGroups authenticate store authFinish)
            );

            # Return error if any
            return $self->{error} if ( $self->{error} > 0 );

            # Disable further reauthentication
            $prompt =~ s/\blogin\b//;
            $self->setHiddenFormValue( 'prompt', $prompt );
        }

        # Check openid scope
        unless ( $oidc_request->{'scope'} =~ /\bopenid\b/ ) {
            $self->lmLog( "No openid scope found", 'debug' );

            #TODO manage standard OAuth request
            return PE_OK;
        }

        # Check client_id
        my $client_id = $oidc_request->{'client_id'};
        $self->lmLog( "Request from client id $client_id", 'debug' );

        # Verify that client_id is registered in configuration
        my $rp = $self->getRP($client_id);

        unless ($rp) {
            $self->lmLog(
                "No registered Relying Party found with client_id $client_id",
                'error' );
            $self->returnRedirectError(
                $oidc_request->{'redirect_uri'},
                "invalid_request",
                "client_id $client_id unknown",
                undef,
                $oidc_request->{'state'},
                ( $flow ne "authorizationcode" )
            );
        }
        else {
            $self->lmLog( "Client id $client_id match RP $rp", 'debug' );
        }

        # Check id_token_hint
        my $id_token_hint = $oidc_request->{'id_token_hint'};
        if ($id_token_hint) {

            $self->lmLog( "Check sub of ID Token $id_token_hint", 'debug' );

            # Check that id_token_hint sub match current user
            my $sub               = $self->getIDTokenSub($id_token_hint);
            my $user_id_attribute = $self->{oidcRPMetaDataOptions}->{$rp}
              ->{oidcRPMetaDataOptionsUserIDAttr} || $self->{whatToTrace};
            my $user_id = $self->{sessionInfo}->{$user_id_attribute};
            unless ( $sub eq $user_id ) {
                $self->lmLog(
                    "ID Token hint sub $sub do not match user $user_id",
                    'error' );
                $self->returnRedirectError(
                    $oidc_request->{'redirect_uri'},
                    "invalid_request",
                    "current user do not match id_token_hint sub",
                    undef,
                    $oidc_request->{'state'},
                    ( $flow ne "authorizationcode" )
                );
            }
            else {
                $self->lmLog( "ID Token hint sub $sub match current user",
                    'debug' );
            }
        }

        # Obtain consent
        my $ask_for_consent = 1;
        if (    $self->{sessionInfo}->{"_oidc_consent_time_$rp"}
            and $self->{sessionInfo}->{"_oidc_consent_scope_$rp"} )
        {
            $ask_for_consent = 0;
            my $consent_time = $self->{sessionInfo}->{"_oidc_consent_time_$rp"};
            my $consent_scope =
              $self->{sessionInfo}->{"_oidc_consent_scope_$rp"};

            $self->lmLog(
"Consent already given for Relying Party $rp (time: $consent_time, scope: $consent_scope)",
                'debug'
            );

            # Check accepted scope
            foreach
              my $requested_scope ( split( /\s+/, $oidc_request->{'scope'} ) )
            {
                if ( $consent_scope =~ /\b$requested_scope\b/ ) {
                    $self->lmLog( "Scope $requested_scope already accepted",
                        'debug' );
                }
                else {
                    $self->lmLog(
                        "Scope $requested_scope was not previously accepted",
                        'debug' );
                    $ask_for_consent = 1;
                    last;
                }
            }

            # Check prompt parameter
            $ask_for_consent = 1 if ( $prompt =~ /\bconsent\b/ );
        }
        if ($ask_for_consent) {
            if ( $self->param('confirm') == 1 ) {
                $self->updatePersistentSession(
                    { "_oidc_consent_time_$rp" => time } );
                $self->updatePersistentSession(
                    {
                        "_oidc_consent_scope_$rp" => $oidc_request->{'scope'}
                    }
                );
                $self->lmLog( "Consent given for Relying Party $rp", 'debug' );
            }
            elsif ( $self->param('confirm') == -1 ) {
                $self->lmLog( "User refused consent for Relying party $rp",
                    'debug' );
                $self->returnRedirectError(
                    $oidc_request->{'redirect_uri'},
                    "consent_required",
                    "consent not given",
                    undef,
                    $oidc_request->{'state'},
                    ( $flow ne "authorizationcode" )
                );
            }
            else {
                $self->lmLog( "Obtain user consent for Relying Party $rp",
                    'debug' );

                # Return error if prompt is none
                if ( $prompt =~ /\bnone\b/ ) {
                    $self->lmLog( "Consent is needed but prompt is none",
                        'debug' );
                    $self->returnRedirectError(
                        $oidc_request->{'redirect_uri'},
                        "consent_required",
                        "consent required",
                        undef,
                        $oidc_request->{'state'},
                        ( $flow ne "authorizationcode" )
                    );
                }

                my $display_name = $self->{oidcRPMetaDataOptions}->{$rp}
                  ->{oidcRPMetaDataOptionsDisplayName};
                my $icon = $self->{oidcRPMetaDataOptions}->{$rp}
                  ->{oidcRPMetaDataOptionsIcon};
                my $portalPath = $self->{portal};
                $portalPath =~ s#^https?://[^/]+/?#/#;
                $portalPath =~ s#[^/]+\.pl$##;

                $self->info('<div class="oidc_consent_message">');
                $self->info( '<img src="'
                      . $portalPath
                      . "skins/common/"
                      . $icon
                      . '" />' )
                  if $icon;
                $self->info( '<h3>'
                      . sprintf( $self->msg(PM_OIDC_CONSENT), $display_name )
                      . '</h3>' );
                $self->info('<ul>');

                foreach my $requested_scope (
                    split( /\s/, $oidc_request->{'scope'} ) )
                {
                    my $message;
                    my $scope_messages = {
                        openid  => PM_OIDC_SCOPE_OPENID,
                        profile => PM_OIDC_SCOPE_PROFILE,
                        email   => PM_OIDC_SCOPE_EMAIL,
                        address => PM_OIDC_SCOPE_ADDRESS,
                        phone   => PM_OIDC_SCOPE_PHONE,
                    };
                    if ( $scope_messages->{$requested_scope} ) {
                        $message =
                          $self->msg( $scope_messages->{$requested_scope} );
                    }
                    else {
                        $message = $self->msg(PM_OIDC_SCOPE_OTHER) . " "
                          . $requested_scope;
                    }
                    $self->info("<li>$message</li>");
                }
                $self->info('</ul>');
                $self->info('</div>');
                $self->{activeTimer} = 0;
                return PE_CONFIRM;
            }
        }

        # Authorization Code Flow
        if ( $flow eq "authorizationcode" ) {

            # Generate code
            my $codeSession = $self->getOpenIDConnectSession();
            my $code        = $codeSession->id();

            $self->lmLog( "Generated code: $code", 'debug' );

            # Store data in session
            $codeSession->update(
                {
                    redirect_uri    => $oidc_request->{'redirect_uri'},
                    scope           => $oidc_request->{'scope'},
                    user_session_id => $session_id,
                    _utime          => time,
                    nonce           => $oidc_request->{'nonce'},
                }
            );

            # Build Response
            my $response_url =
              $self->buildAuthorizationCodeAuthnResponse(
                $oidc_request->{'redirect_uri'},
                $code, $oidc_request->{'state'} );

            $self->lmLog( "Redirect user to $response_url", 'debug' );
            $self->{'urldc'} = $response_url;

            $self->_sub('autoRedirect');
        }

        # Implicit Flow
        if ( $flow eq "implicit" ) {

            my $access_token;
            my $at_hash;

            if ( $response_type =~ /\btoken\b/ ) {

                # Generate access_token
                my $accessTokenSession = $self->getOpenIDConnectSession;

                unless ($accessTokenSession) {
                    $self->lmLog(
                        "Unable to create OIDC session for access_token",
                        "error" );
                    $self->returnRedirectError( $oidc_request->{'redirect_uri'},
                        "server_error", undef,
                        undef, $oidc_request->{'state'}, 1 );
                }

                # Store data in access token
                $accessTokenSession->update(
                    {
                        scope           => $oidc_request->{'scope'},
                        rp              => $rp,
                        user_session_id => $session_id,
                        _utime          => time,
                    }
                );

                $access_token = $accessTokenSession->id;

                $self->lmLog( "Generated access token: $access_token",
                    'debug' );

                # Compute hash to store in at_hash
                my $alg = $self->{oidcRPMetaDataOptions}->{$rp}
                  ->{oidcRPMetaDataOptionsIDTokenSignAlg};
                my ($hash_level) = ( $alg =~ /(?:\w{2})(\d{3})/ );
                $at_hash = $self->createHash( $access_token, $hash_level );
            }

            # ID token payload
            my $id_token_exp = $self->{oidcRPMetaDataOptions}->{$rp}
              ->{oidcRPMetaDataOptionsIDTokenExpiration};

            my $id_token_acr =
              "loa-" . $self->{sessionInfo}->{authenticationLevel};

            my $user_id_attribute = $self->{oidcRPMetaDataOptions}->{$rp}
              ->{oidcRPMetaDataOptionsUserIDAttr} || $self->{whatToTrace};
            my $user_id = $self->{sessionInfo}->{$user_id_attribute};

            my $id_token_payload_hash = {
                iss => $issuer,          # Issuer Identifier
                sub => $user_id,         # Subject Identifier
                aud => [$client_id],     # Audience
                exp => $id_token_exp,    # expiration
                iat => time,             # Issued time
                auth_time =>
                  $self->{sessionInfo}->{_lastAuthnUTime}, # Authentication time
                acr => $id_token_acr,   # Authentication Context Class Reference
                azp => $client_id,      # Authorized party
                                        # TODO amr
                nonce => $oidc_request->{'nonce'}    # Nonce
            };

            $id_token_payload_hash->{'at_hash'} = $at_hash if $at_hash;

            # Create ID Token
            my $id_token = $self->createIDToken( $id_token_payload_hash, $rp );

            $self->lmLog( "Generated id token: $id_token", 'debug' );

            # Send token response
            my $expires_in = $self->{oidcRPMetaDataOptions}->{$rp}
              ->{oidcRPMetaDataOptionsAccessTokenExpiration};

            # Build Response
            my $response_url =
              $self->buildImplicitAuthnResponse(
                $oidc_request->{'redirect_uri'},
                $access_token, $id_token, $expires_in,
                $oidc_request->{'state'} );

            $self->lmLog( "Redirect user to $response_url", 'debug' );
            $self->{'urldc'} = $response_url;

            $self->_sub('autoRedirect');
        }

        # Hybrid Flow
        if ( $flow eq "hybrid" ) {

            my $access_token;
            my $id_token;
            my $at_hash;
            my $c_hash;

            # Hash level
            my $alg = $self->{oidcRPMetaDataOptions}->{$rp}
              ->{oidcRPMetaDataOptionsIDTokenSignAlg};
            my ($hash_level) = ( $alg =~ /(?:\w{2})(\d{3})/ );

            # Generate code
            my $codeSession = $self->getOpenIDConnectSession();
            my $code        = $codeSession->id();

            $self->lmLog( "Generated code: $code", 'debug' );

            # Store data in session
            $codeSession->update(
                {
                    redirect_uri    => $oidc_request->{'redirect_uri'},
                    scope           => $oidc_request->{'scope'},
                    user_session_id => $session_id,
                    _utime          => time,
                    nonce           => $oidc_request->{'nonce'},
                }
            );

            # Compute hash to store in c_hash
            $c_hash = $self->createHash( $code, $hash_level );

            if ( $response_type =~ /\btoken\b/ ) {

                # Generate access_token
                my $accessTokenSession = $self->getOpenIDConnectSession;

                unless ($accessTokenSession) {
                    $self->lmLog(
                        "Unable to create OIDC session for access_token",
                        "error" );
                    $self->returnRedirectError( $oidc_request->{'redirect_uri'},
                        "server_error", undef,
                        undef, $oidc_request->{'state'}, 1 );
                }

                # Store data in access token
                $accessTokenSession->update(
                    {
                        scope           => $oidc_request->{'scope'},
                        rp              => $rp,
                        user_session_id => $session_id,
                        _utime          => time,
                    }
                );

                $access_token = $accessTokenSession->id;

                $self->lmLog( "Generated access token: $access_token",
                    'debug' );

                # Compute hash to store in at_hash
                $at_hash = $self->createHash( $access_token, $hash_level );
            }

            if ( $response_type =~ /\bid_token\b/ ) {

                # ID token payload
                my $id_token_exp = $self->{oidcRPMetaDataOptions}->{$rp}
                  ->{oidcRPMetaDataOptionsIDTokenExpiration};

                my $id_token_acr =
                  "loa-" . $self->{sessionInfo}->{authenticationLevel};

                my $user_id_attribute = $self->{oidcRPMetaDataOptions}->{$rp}
                  ->{oidcRPMetaDataOptionsUserIDAttr} || $self->{whatToTrace};
                my $user_id = $self->{sessionInfo}->{$user_id_attribute};

                my $id_token_payload_hash = {
                    iss => $issuer,          # Issuer Identifier
                    sub => $user_id,         # Subject Identifier
                    aud => [$client_id],     # Audience
                    exp => $id_token_exp,    # expiration
                    iat => time,             # Issued time
                    auth_time => $self->{sessionInfo}->{_lastAuthnUTime}
                    ,                        # Authentication time
                    acr =>
                      $id_token_acr,    # Authentication Context Class Reference
                    azp   => $client_id,                 # Authorized party
                                                         # TODO amr
                    nonce => $oidc_request->{'nonce'}    # Nonce
                };

                $id_token_payload_hash->{'at_hash'} = $at_hash if $at_hash;
                $id_token_payload_hash->{'c_hash'}  = $c_hash  if $c_hash;

                # Create ID Token
                $id_token = $self->createIDToken( $id_token_payload_hash, $rp );

                $self->lmLog( "Generated id token: $id_token", 'debug' );
            }

            my $expires_in = $self->{oidcRPMetaDataOptions}->{$rp}
              ->{oidcRPMetaDataOptionsAccessTokenExpiration};

            # Build Response
            my $response_url =
              $self->buildHybridAuthnResponse( $oidc_request->{'redirect_uri'},
                $code, $access_token, $id_token, $expires_in,
                $oidc_request->{'state'} );

            $self->lmLog( "Redirect user to $response_url", 'debug' );
            $self->{'urldc'} = $response_url;

            $self->_sub('autoRedirect');
        }

        $self->lmLog( "No flow has been selected", 'debug' );
        return PE_OK;
    }

    # TOKEN
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${token_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect TOKEN URL",
            'debug' );

        # This should not happen
        $self->lmLog(
            "Token request found on an active SSO session, ignoring it",
            'error' );
        $self->returnJSONError("invalid_request");

        $self->quit;
    }

    # USERINFO
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${userinfo_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect USERINFO URL",
            'debug' );

        # This should not happen
        $self->lmLog(
            "UserInfo request found on an active SSO session, ignoring it",
            'error' );
        $self->returnJSONError("invalid_request");

        $self->quit;
    }

    # JWKS
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${jwks_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect JWKS URL",
            'debug' );

        # This should not happen
        $self->lmLog(
            "JWKS request found on an active SSO session, ignoring it",
            'error' );
        $self->returnJSONError("invalid_request");

        $self->quit;
    }

    PE_OK;
}

## @apmethod int issuerLogout()
# Do nothing
# @return Lemonldap::NG::Portal error code
sub issuerLogout {
    PE_OK;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::IssuerDBOpenIDConnect - OpenIDConnect Provider for Lemonldap::NG

=head1 DESCRIPTION

This is an OpenID Connect provider implementation in LemonLDAP::NG

=head1 SEE ALSO

L<Lemonldap::NG::Portal>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2014 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=back

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.

=cut
