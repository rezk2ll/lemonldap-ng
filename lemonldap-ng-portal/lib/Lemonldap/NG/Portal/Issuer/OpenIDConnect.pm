package Lemonldap::NG::Portal::Issuer::OpenIDConnect;

use strict;
use JSON;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_CONFIRM
  PE_ERROR
  PE_LOGOUT_OK
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Issuer',
  'Lemonldap::NG::Portal::Lib::OpenIDConnect';

# INITIALIZATION

# OIDC has 7 endpoints managed here as PSGI endpoints or in run() [Main/Issuer.pm
# manage transparent authentication for run()]:
#  - authorize   : in run()
#  - logout      : in run()
#                  => endSessionDone() for unauth users
#  - checksession: => checkSession()   for all
#  - token       : => token()          for unauth users (RP)
#  - userinfo    : => userInfo()       for unauth users (RP)
#  - jwks        : => jwks()           for unauth users (RP)
#  - register    : => registration()   for unauth users (RP)
#
# Other paths will be handle by run() and return PE_ERROR
#
# .well-known/openid-configuration is handled by metadata()

sub init {
    my ($self) = @_;

    # Initialize RP list
    return 0
      unless ( $self->Lemonldap::NG::Portal::Main::Issuer::init()
        and $self->loadRPs );

    # Manage RP requests
    $self->addRouteFromConf(
        'Unauth',
        oidcServiceMetaDataEndSessionURI   => 'endSessionDone',
        oidcServiceMetaDataCheckSessionURI => 'checkSession',
        oidcServiceMetaDataTokenURI        => 'token',
        oidcServiceMetaDataUserInfoURI     => 'userInfo',
        oidcServiceMetaDataJWKSURI         => 'jwks',
        oidcServiceMetaDataRegistrationURI => 'registration',
    );

    # Manage user requests
    $self->addRouteFromConf(
        'Auth',
        oidcServiceMetaDataCheckSessionURI => 'checkSession',
        oidcServiceMetaDataTokenURI        => 'badAuthRequest',
        oidcServiceMetaDataUserInfoURI     => 'badAuthRequest',
        oidcServiceMetaDataJWKSURI         => 'badAuthRequest',
        oidcServiceMetaDataRegistrationURI => 'badAuthRequest',
    );

    # Metadata (.well-known/openid-configuration)
    $self->addUnauthRoute(
        '.well-known' => { 'openid-configuration' => 'metadata' },
        ['GET']
    );
    $self->addAuthRoute(
        '.well-known' => { 'openid-configuration' => 'metadata' },
        ['GET']
    );
    return 1;
}

# PROPERTIES

has '_confAcc' => ( is => 'rw', isa => 'Lemonldap::NG::Common::Conf' );

# Configuration access object
# Return _confAcc property if exists or create it. Used for RP registration
#@return Lemonldap::NG::Common::Conf object
sub confAcc {
    my $self = shift;
    return $self->_confAcc if ( $self->_confAcc );

    # TODO: pass args and remove this
    my $d = `pwd`;
    chomp $d;
    my $tmp;
    unless ( $tmp = Lemonldap::NG::Common::Conf->new( $self->configStorage ) ) {
        die "Unable to build Lemonldap::NG::Common::Conf "
          . $Lemonldap::NG::Common::Conf::msg;
    }
    return $self->_confAcc($tmp);
}

# RUNNING METHODS

# Main method (launched only for authenticated users, see Main/Issuer.pm)
# run() manages only "authorize" and "logout" endpoints.
sub run {
    my ( $self, $req, $path ) = @_;
    if ($path) {

        # AUTHORIZE
        if ( $path eq $self->conf->{oidcServiceMetaDataAuthorizeURI} ) {
            $self->lmLog( "URL  detected as an OpenID Connect AUTHORIZE URL",
                'debug' );

            # Get and save parameters
            my $oidc_request = {};
            foreach my $param (
                qw/response_type scope client_id state redirect_uri nonce
                response_mode display prompt max_age ui_locales id_token_hint
                login_hint acr_valuesi request request_uri/
              )
            {
                if ( $req->param($param) ) {
                    $oidc_request->{$param} = $req->param($param);
                    $self->lmLog(
                        "OIDC request parameter $param: "
                          . $oidc_request->{$param},
                        'debug'
                    );
                }
            }

            # Detect requested flow
            my $response_type = $oidc_request->{'response_type'};
            my $flow          = $self->getFlowType($response_type);

            unless ($flow) {
                $self->lmLog( "Unknown response type: $response_type",
                    'error' );
                return PE_ERROR;
            }
            $self->lmLog(
                "OIDC $flow flow requested (response type: $response_type)",
                'debug' );

            # Extract request_uri/request parameter
            if ( $oidc_request->{'request_uri'} ) {
                my $request =
                  $self->getRequestJWT( $oidc_request->{'request_uri'} );

                if ($request) {
                    $oidc_request->{'request'} = $request;
                }
                else {
                    $self->lmLog( "Error with Request URI resolution",
                        'error' );
                    return PE_ERROR;
                }
            }

            if ( $oidc_request->{'request'} ) {
                my $request =
                  $self->getJWTJSONData( $oidc_request->{'request'} );

                # Override OIDC parameters by request content
                foreach ( keys %$request ) {
                    $self->lmLog(
"Override $_ OIDC param by value present in request parameter",
                        'debug'
                    );
                    $oidc_request->{$_} = $request->{$_};
                    $self->setHiddenFormValue( $_, $request->{$_}, '' );
                }
            }

            # Check all required parameters
            unless ( $oidc_request->{'redirect_uri'} ) {
                $self->lmLog( "Redirect URI is required", 'error' );
                return PE_ERROR;
            }
            unless ( $oidc_request->{'scope'} ) {
                $self->lmLog( "Scope is required", 'error' );
                $self->returnRedirectError(
                    $req,
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
                return $self->returnRedirectError(
                    $req,
                    $oidc_request->{'redirect_uri'},
                    "invalid_request",
                    "client_id required",
                    undef,
                    $oidc_request->{'state'},
                    ( $flow ne "authorizationcode" )
                );
            }
            if ( $flow eq "implicit" and not defined $oidc_request->{'nonce'} )
            {
                $self->lmLog( "Nonce is required for implicit flow", 'error' );
                return $self->returnRedirectError(
                    $req, $oidc_request->{'redirect_uri'},
                    "invalid_request", "nonce required",
                    undef, $oidc_request->{'state'}, 1
                );
            }

            # Check if flow is allowed
            if ( $flow eq "authorizationcode"
                and not $self->conf->{oidcServiceAllowAuthorizationCodeFlow} )
            {
                $self->lmLog( "Authorization code flow is not allowed",
                    'error' );
                return $self->returnRedirectError(
                    $req,           $oidc_request->{'redirect_uri'},
                    "server_error", "Authorization code flow not allowed",
                    undef,          $oidc_request->{'state'},
                    0
                );
            }
            if ( $flow eq "implicit"
                and not $self->conf->{oidcServiceAllowImplicitFlow} )
            {
                $self->lmLog( "Implicit flow is not allowed", 'error' );
                return $self->returnRedirectError(
                    $req,           $oidc_request->{'redirect_uri'},
                    "server_error", "Implicit flow not allowed",
                    undef,          $oidc_request->{'state'},
                    1
                );
            }
            if ( $flow eq "hybrid"
                and not $self->conf->{oidcServiceAllowHybridFlow} )
            {
                $self->lmLog( "Hybrid flow is not allowed", 'error' );
                return $self->returnRedirectError(
                    $req,           $oidc_request->{'redirect_uri'},
                    "server_error", "Hybrid flow not allowed",
                    undef,          $oidc_request->{'state'},
                    1
                );
            }

            # Check if user needs to be reauthenticated
            my $reauthentication = 0;
            my $prompt           = $oidc_request->{'prompt'};
            if ( $prompt and $prompt =~ /\blogin\b/ ) {
                $self->lmLog(
"Reauthentication requested by Relying Party in prompt parameter",
                    'debug'
                );
                $reauthentication = 1;
            }

            my $max_age         = $oidc_request->{'max_age'};
            my $_lastAuthnUTime = $req->{sessionInfo}->{_lastAuthnUTime};
            if ( $max_age && time > $_lastAuthnUTime + $max_age ) {
                $self->lmLog(
"Reauthentication forced cause authentication time ($_lastAuthnUTime) is too old (>$max_age s)",
                    'debug'
                );
                $reauthentication = 1;
            }

            if ($reauthentication) {

                # Set prompt to 0 to avoid loop
                $self->setHiddenFormValue( $req, 'prompt', '', '' );

                # Replay authentication process
                $self->{updateSession} = 1;
                $req->steps(
                    [
                        $self->p->authProcess,
                        @{ $self->p->betweenAuthAndDatas },
                        $self->p->sessionDatas,
                        @{ $self->p->afterDatas }
                    ]
                );

                # Update session_id
                return PE_OK;
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
                    'error'
                );
                return $self->returnRedirectError(
                    $req,
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

            # Check Request JWT signature
            if ( $oidc_request->{'request'} ) {
                unless (
                    $self->verifyJWTSignature(
                        $oidc_request->{'request'},
                        undef, $rp
                    )
                  )
                {
                    $self->lmLog( "Request JWT signature could not be verified",
                        'error' );
                    return PE_ERROR;
                }
                else {
                    $self->lmLog( "Request JWT signature verified", 'debug' );
                }
            }

            # Check redirect_uri
            my $redirect_uri  = $oidc_request->{'redirect_uri'};
            my $redirect_uris = $self->conf->{oidcRPMetaDataOptions}->{$rp}
              ->{oidcRPMetaDataOptionsRedirectUris};

            if ($redirect_uris) {
                my $redirect_uri_allowed = 0;
                foreach ( split( /\s+/, $redirect_uris ) ) {
                    $redirect_uri_allowed = 1 if $redirect_uri eq $_;
                }
                unless ($redirect_uri_allowed) {
                    $self->lmLog( "Redirect URI $redirect_uri not allowed",
                        'error' );
                    return $self->returnRedirectError(
                        $req,
                        $oidc_request->{'redirect_uri'},
                        "invalid_request",
                        "redirect_uri $redirect_uri not allowed",
                        undef,
                        $oidc_request->{'state'},
                        ( $flow ne "authorizationcode" )
                    );
                }
            }

            # Check id_token_hint
            my $id_token_hint = $oidc_request->{'id_token_hint'};
            if ($id_token_hint) {

                $self->lmLog( "Check sub of ID Token $id_token_hint", 'debug' );

                # Check that id_token_hint sub match current user
                my $sub = $self->getIDTokenSub($id_token_hint);
                my $user_id_attribute =
                  $self->conf->{oidcRPMetaDataOptions}->{$rp}
                  ->{oidcRPMetaDataOptionsUserIDAttr} || $self->{whatToTrace};
                my $user_id = $req->{sessionInfo}->{$user_id_attribute};
                unless ( $sub eq $user_id ) {
                    $self->lmLog(
                        "ID Token hint sub $sub do not match user $user_id",
                        'error' );
                    return $self->returnRedirectError(
                        $req,
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
            my $bypassConsent = $self->conf->{oidcRPMetaDataOptions}->{$rp}
              ->{oidcRPMetaDataOptionsBypassConsent};
            if ($bypassConsent) {
                $self->lmLog(
                    "Consent is disabled for RP $rp, user will not be prompted",
                    'debug'
                );
            }
            else {
                my $ask_for_consent = 1;
                if (    $req->{sessionInfo}->{"_oidc_consent_time_$rp"}
                    and $req->{sessionInfo}->{"_oidc_consent_scope_$rp"} )
                {
                    $ask_for_consent = 0;
                    my $consent_time =
                      $req->{sessionInfo}->{"_oidc_consent_time_$rp"};
                    my $consent_scope =
                      $req->{sessionInfo}->{"_oidc_consent_scope_$rp"};

                    $self->lmLog(
"Consent already given for Relying Party $rp (time: $consent_time, scope: $consent_scope)",
                        'debug'
                    );

                    # Check accepted scope
                    foreach my $requested_scope (
                        split( /\s+/, $oidc_request->{'scope'} ) )
                    {
                        if ( $consent_scope =~ /\b$requested_scope\b/ ) {
                            $self->lmLog(
                                "Scope $requested_scope already accepted",
                                'debug' );
                        }
                        else {
                            $self->lmLog(
"Scope $requested_scope was not previously accepted",
                                'debug'
                            );
                            $ask_for_consent = 1;
                            last;
                        }
                    }

                    # Check prompt parameter
                    $ask_for_consent = 1 if ( $prompt =~ /\bconsent\b/ );
                }
                if ($ask_for_consent) {
                    if (    $req->param('confirm')
                        and $req->param('confirm') == 1 )
                    {
                        $self->p->updatePersistentSession(
                            { "_oidc_consent_time_$rp" => time } );
                        $self->p->updatePersistentSession(
                            {
                                "_oidc_consent_scope_$rp" =>
                                  $oidc_request->{'scope'}
                            }
                        );
                        $self->lmLog( "Consent given for Relying Party $rp",
                            'debug' );
                    }
                    elsif ( $req->param('confirm')
                        and $req->param('confirm') == -1 )
                    {
                        $self->lmLog(
                            "User refused consent for Relying party $rp",
                            'debug' );
                        return $self->returnRedirectError(
                            $req,
                            $oidc_request->{'redirect_uri'},
                            "consent_required",
                            "consent not given",
                            undef,
                            $oidc_request->{'state'},
                            ( $flow ne "authorizationcode" )
                        );
                    }
                    else {
                        $self->lmLog(
                            "Obtain user consent for Relying Party $rp",
                            'debug' );

                        # Return error if prompt is none
                        if ( $prompt and $prompt =~ /\bnone\b/ ) {
                            $self->lmLog(
                                "Consent is needed but prompt is none",
                                'debug' );
                            return $self->returnRedirectError(
                                $req,
                                $oidc_request->{'redirect_uri'},
                                "consent_required",
                                "consent required",
                                undef,
                                $oidc_request->{'state'},
                                ( $flow ne "authorizationcode" )
                            );
                        }

                        my $display_name =
                          $self->conf->{oidcRPMetaDataOptions}->{$rp}
                          ->{oidcRPMetaDataOptionsDisplayName};
                        my $icon = $self->conf->{oidcRPMetaDataOptions}->{$rp}
                          ->{oidcRPMetaDataOptionsIcon};
                        my $img_src;

                        if ($icon) {
                            $img_src =
                              ( $icon =~ m#^https?://# )
                              ? $icon
                              : $self->p->staticPrefic . "/common/" . $icon;
                        }

                        # HERE
                        $req->info('<div class="oidc_consent_message">');
                        $req->info( '<img src="' . $img_src . '" />' )
                          if $img_src;
                        $req->info(
qq'<h3 trspan="oidcConsent,$display_name">The application $display_name would like to know:</h3><ul>'
                        );

                        my $scope_messages = {
                            openid  => 'yourIdentity',
                            profile => 'yourProfile',
                            email   => 'yourEmail',
                            address => 'yourAddress',
                            phone   => 'yourPhone',
                        };
                        foreach my $requested_scope (
                            split( /\s/, $oidc_request->{'scope'} ) )
                        {
                            my $message = $scope_messages->{$requested_scope}
                              || 'anotherInformation';
                            $req->info(
                                qq'<li trspan="$message ">$message</li>');
                        }
                        $req->info('</ul></div>');
                        $req->datas->{activeTimer} = 0;
                        return PE_CONFIRM;
                    }
                }
            }

            # Create session_state
            my $session_state =
              $self->createSessionState( $req->id, $client_id );

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
                        user_session_id => $req->id,
                        _utime          => time,
                        nonce           => $oidc_request->{'nonce'},
                    }
                );

                # Build Response
                my $response_url = $self->buildAuthorizationCodeAuthnResponse(
                    $oidc_request->{'redirect_uri'},
                    $code, $oidc_request->{'state'},
                    $session_state
                );

                $self->lmLog( "Redirect user to $response_url", 'debug' );
                $req->urldc($response_url);

                $req->steps( [] );
                return PE_OK;
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
                        $self->returnRedirectError( $req,
                            $oidc_request->{'redirect_uri'},
                            "server_error", undef, undef,
                            $oidc_request->{'state'}, 1 );
                    }

                    # Store data in access token
                    $accessTokenSession->update(
                        {
                            scope           => $oidc_request->{'scope'},
                            rp              => $rp,
                            user_session_id => $req->id,
                            _utime          => time,
                        }
                    );

                    $access_token = $accessTokenSession->id;

                    $self->lmLog( "Generated access token: $access_token",
                        'debug' );

                    # Compute hash to store in at_hash
                    my $alg = $self->conf->{oidcRPMetaDataOptions}->{$rp}
                      ->{oidcRPMetaDataOptionsIDTokenSignAlg};
                    my ($hash_level) = ( $alg =~ /(?:\w{2})(\d{3})/ );
                    $at_hash = $self->createHash( $access_token, $hash_level );
                }

                # ID token payload
                my $id_token_exp = $self->conf->{oidcRPMetaDataOptions}->{$rp}
                  ->{oidcRPMetaDataOptionsIDTokenExpiration};
                $id_token_exp += time;

                my $authenticationLevel =
                  $req->{sessionInfo}->{authenticationLevel};
                my $id_token_acr;
                foreach (
                    keys %{ $self->conf->{oidcServiceMetaDataAuthnContext} } )
                {
                    if ( $self->conf->{oidcServiceMetaDataAuthnContext}->{$_} eq
                        $authenticationLevel )
                    {
                        $id_token_acr = $_;
                        last;
                    }
                }

                my $user_id_attribute =
                  $self->conf->{oidcRPMetaDataOptions}->{$rp}
                  ->{oidcRPMetaDataOptionsUserIDAttr}
                  || $self->conf->{whatToTrace};
                my $user_id = $req->{sessionInfo}->{$user_id_attribute};

                my $id_token_payload_hash = {
                    iss => $self->conf->{oidcServiceMetaDataIssuer}
                    ,    # Issuer Identifier
                    sub => $user_id,         # Subject Identifier
                    aud => [$client_id],     # Audience
                    exp => $id_token_exp,    # expiration
                    iat => time,             # Issued time
                    auth_time => $req->{sessionInfo}->{_lastAuthnUTime}
                    ,                        # Authentication time
                    azp   => $client_id,                 # Authorized party
                                                         # TODO amr
                    nonce => $oidc_request->{'nonce'}    # Nonce
                };

                $id_token_payload_hash->{'at_hash'} = $at_hash if $at_hash;
                $id_token_payload_hash->{'acr'} = $id_token_acr
                  if $id_token_acr;

                # Create ID Token
                my $id_token =
                  $self->createIDToken( $id_token_payload_hash, $rp );

                $self->lmLog( "Generated id token: $id_token", 'debug' );

                # Send token response
                my $expires_in = $self->conf->{oidcRPMetaDataOptions}->{$rp}
                  ->{oidcRPMetaDataOptionsAccessTokenExpiration};

                # Build Response
                my $response_url = $self->buildImplicitAuthnResponse(
                    $oidc_request->{'redirect_uri'},
                    $access_token, $id_token, $expires_in,
                    $oidc_request->{'state'},
                    $session_state
                );

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
                my $alg = $self->conf->{oidcRPMetaDataOptions}->{$rp}
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
                        user_session_id => $req->id,
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
                        return $self->returnRedirectError( $req,
                            $oidc_request->{'redirect_uri'},
                            "server_error", undef, undef,
                            $oidc_request->{'state'}, 1 );
                    }

                    # Store data in access token
                    $accessTokenSession->update(
                        {
                            scope           => $oidc_request->{'scope'},
                            rp              => $rp,
                            user_session_id => $req->id,
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
                    my $id_token_exp =
                      $self->conf->{oidcRPMetaDataOptions}->{$rp}
                      ->{oidcRPMetaDataOptionsIDTokenExpiration};
                    $id_token_exp += time;

                    my $id_token_acr =
                      "loa-" . $req->{sessionInfo}->{authenticationLevel};

                    my $user_id_attribute =
                      $self->conf->{oidcRPMetaDataOptions}->{$rp}
                      ->{oidcRPMetaDataOptionsUserIDAttr}
                      || $self->{whatToTrace};
                    my $user_id = $req->{sessionInfo}->{$user_id_attribute};

                    my $id_token_payload_hash = {
                        iss => $self->conf->{oidcServiceMetaDataIssuer}
                        ,    # Issuer Identifier
                        sub => $user_id,         # Subject Identifier
                        aud => [$client_id],     # Audience
                        exp => $id_token_exp,    # expiration
                        iat => time,             # Issued time
                        auth_time => $req->{sessionInfo}->{_lastAuthnUTime}
                        ,                        # Authentication time
                        acr => $id_token_acr
                        ,    # Authentication Context Class Reference
                        azp   => $client_id,                 # Authorized party
                                                             # TODO amr
                        nonce => $oidc_request->{'nonce'}    # Nonce
                    };

                    $id_token_payload_hash->{'at_hash'} = $at_hash if $at_hash;
                    $id_token_payload_hash->{'c_hash'}  = $c_hash  if $c_hash;

                    # Create ID Token
                    $id_token =
                      $self->createIDToken( $id_token_payload_hash, $rp );

                    $self->lmLog( "Generated id token: $id_token", 'debug' );
                }

                my $expires_in = $self->conf->{oidcRPMetaDataOptions}->{$rp}
                  ->{oidcRPMetaDataOptionsAccessTokenExpiration};

                # Build Response
                my $response_url = $self->buildHybridAuthnResponse(
                    $oidc_request->{'redirect_uri'}, $code,
                    $access_token,                   $id_token,
                    $expires_in,                     $oidc_request->{'state'},
                    $session_state
                );

                $self->lmLog( "Redirect user to $response_url", 'debug' );
                $req->urldc($response_url);
                $req->steps( [] );
                return PE_OK;
            }

            $self->lmLog( "No flow has been selected", 'debug' );
            return PE_OK;
        }

        # LOGOUT
        elsif ( $path eq $self->conf->{oidcServiceMetaDataEndSessionURI} ) {
            $self->lmLog( "URL detected as an OpenID Connect END SESSION URL",
                'debug' );

            # Set hidden fields
            my $oidc_request = {};
            foreach my $param (qw/id_token_hint post_logout_redirect_uri state/)
            {
                $oidc_request->{$param} = $req->param($param);
                $self->lmLog(
                    "OIDC request parameter $param: " . $oidc_request->{$param},
                    'debug'
                );
                $self->setHiddenFormValue( $param, $oidc_request->{$param},
                    '' );
            }

            my $post_logout_redirect_uri =
              $oidc_request->{'post_logout_redirect_uri'};
            my $state = $oidc_request->{'state'};

            # Ask consent for logout
            if ( $req->param('confirm') ) {
                if ( $req->param('confirm') == 1 ) {
                    my $apacheSession = $self->p->getApacheSession( $req->id );
                    $self->p->_deleteSession($apacheSession);
                }

                if ($post_logout_redirect_uri) {

                    # Build Response
                    my $response_url =
                      $self->buildLogoutResponse( $post_logout_redirect_uri,
                        $state );

                    $self->lmLog( "Redirect user to $response_url", 'debug' );
                    $req->urldc($response_url);
                    $req->steps( [] );
                    return PE_OK;
                }
                return $req->param('confirm') == 1 ? PE_LOGOUT_OK : PE_OK;
            }

            $req->info(
'<div class="oidc_logout_message"><h3 trspan="logoutConfirm">Do you want to logout?</h3></div>'
            );
            $req->datas->{activeTimer} = 0;
            return PE_CONFIRM;
        }
    }
    $self->lmLog( "Unknown OIDC endpoint $path, skipping", 'error' );
    return PE_ERROR;
}

# Handle token endpoint
sub token {
    my ( $self, $req ) = @_;
    $req->parseBody if($req->method =~ /^post$/i);
    $self->lmLog( "URL detected as an OpenID Connect TOKEN URL", 'debug' );

    # Check authentication
    my ( $client_id, $client_secret ) =
      $self->getEndPointAuthenticationCredentials($req);

    unless ( $client_id && $client_secret ) {
        $self->lmLog(
"No authentication provided to get token, or authentication type not supported",
            "error"
        );
        return $self->p->sendError( $req, 'unauthorized_client', 401 );
    }

    # Verify that client_id is registered in configuration
    my $rp = $self->getRP($client_id);

    unless ($rp) {
        $self->lmLog(
            "No registered Relying Party found with client_id $client_id",
            'error' );
        return $self->p->sendError( $req, "unauthorized_client", 403 );
    }
    else {
        $self->lmLog( "Client id $client_id match RP $rp", 'debug' );
    }

    # Check client_secret
    unless ( $client_secret eq $self->conf->{oidcRPMetaDataOptions}->{$rp}
        ->{oidcRPMetaDataOptionsClientSecret} )
    {
        $self->lmLog( "Wrong credentials for $rp", "error" );
        return $self->p->sendError( "access_denied", 403 );
    }

    # Get code session
    my $code = $req->param('code');

    $self->lmLog( "OpenID Connect Code: $code", 'debug' );

    my $codeSession = $self->getOpenIDConnectSession($code);

    unless ($codeSession) {
        $self->lmLog( "Unable to find OIDC session $code", "error" );
        $self->p->sendError( $req, "invalid_request", 400 );
    }

    # Check we have the same redirect_uri value
    unless ( $req->param("redirect_uri") eq $codeSession->data->{redirect_uri} )
    {
        $self->lmLog(
            "Provided redirect_uri is different from "
              . $codeSession->{redirect_uri},
            "error"
        );
        $self->p->sendError( $req, "invalid_request", 400 );
    }

    # Get user identifier
    my $apacheSession =
      $self->p->getApacheSession( $codeSession->data->{user_session_id}, 1 );

    unless ($apacheSession) {
        $self->lmLog(
            "Unable to find user session linked to OIDC session $code",
            "error" );
        $codeSession->remove();
        $self->p->sendError( $req, "invalid_request", 400 );
    }

    my $user_id_attribute =
      $self->conf->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsUserIDAttr}
      || $self->conf->{whatToTrace};
    my $user_id = $apacheSession->data->{$user_id_attribute};

    $self->lmLog( "Found corresponding user: $user_id", 'debug' );

    # Generate access_token
    my $accessTokenSession = $self->getOpenIDConnectSession;

    unless ($accessTokenSession) {
        $self->lmLog( "Unable to create OIDC session for access_token",
            "error" );
        $codeSession->remove();
        $self->p->sendError( $req, "invalid_request", 400 );
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
    my $alg = $self->conf->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsIDTokenSignAlg};
    my ($hash_level) = ( $alg =~ /(?:\w{2})(\d{3})/ );
    my $at_hash = $self->createHash( $access_token, $hash_level );

    # ID token payload
    my $id_token_exp = $self->conf->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsIDTokenExpiration};
    $id_token_exp += time;

    my $id_token_acr = "loa-" . $apacheSession->data->{authenticationLevel};

    my $id_token_payload_hash = {
        iss => $self->conf->{oidcServiceMetaDataIssuer},    # Issuer Identifier
        sub => $user_id,                                    # Subject Identifier
        aud => [$client_id],                                # Audience
        exp => $id_token_exp,                               # expiration
        iat => time,                                        # Issued time
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
    my $expires_in = $self->conf->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsAccessTokenExpiration};

    my $token_response = {
        access_token => $access_token,
        token_type   => 'Bearer',
        expires_in   => $expires_in,
        id_token     => $id_token,
    };

    $self->lmLog( "Send token response", 'debug' );

    $codeSession->remove();
    return $self->p->sendJSONresponse( $req, $token_response );
}

# Handle uerinfo endpoint
sub userInfo {
    my ( $self, $req ) = @_;
    $self->lmLog( "URL detected as an OpenID Connect USERINFO URL", 'debug' );
    $req->parseBody if($req->method =~ /^post$/i);

    my $access_token = $self->getEndPointAccessToken($req);

    unless ($access_token) {
        $self->lmLog( "Unable to get access_token", "error" );
        return $self->returnBearerError( "invalid_request",
            "Access token not found in request" );
    }

    $self->lmLog( "Received Access Token $access_token", 'debug' );

    my $accessTokenSession = $self->getOpenIDConnectSession($access_token);

    unless ($accessTokenSession) {
        $self->lmLog( "Unable to get access token session for id $access_token",
            "error" );
        return $self->returnBearerError( "invalid_token",
            "Access Token not found or expired" );
    }

    # Get access token session data
    my $scope           = $accessTokenSession->data->{scope};
    my $rp              = $accessTokenSession->data->{rp};
    my $user_session_id = $accessTokenSession->data->{user_session_id};

    my $userinfo_response =
      $self->buildUserInfoResponse( $scope, $rp, $user_session_id );
    unless ($userinfo_response) {
        return $self->p->sendError( $req, "invalid_request", 400 );
    }

    my $userinfo_sign_alg = $self->conf->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsUserInfoSignAlg};

    unless ($userinfo_sign_alg) {
        return $self->p->sendJSONresponse( $req, $userinfo_response );
    }
    else {
        my $userinfo_jwt =
          $self->createJWT( $userinfo_response, $userinfo_sign_alg, $rp );
        $self->lmLog( "Return UserInfo as JWT: $userinfo_jwt", 'debug' );
        return [
            200,
            [
                'Content-Type'   => 'application/jwt',
                'Content-Length' => length($userinfo_jwt)
            ],
            [$userinfo_jwt]
        ];
    }
}

# Handle jwks endpoint
sub jwks {
    my ( $self, $req ) = @_;
    $self->lmLog( "URL detected as an OpenID Connect JWKS URL", 'debug' );
    $req->parseBody if($req->method =~ /^post$/i);

    my $jwks = { keys => [] };

    my $public_key_sig = $self->conf->{oidcServicePublicKeySig};
    my $key_id_sig     = $self->conf->{oidcServiceKeyIdSig};
    if ($public_key_sig) {
        my $key = $self->key2jwks($public_key_sig);
        $key->{kty} = "RSA";
        $key->{use} = "sig";
        $key->{kid} = $key_id_sig if $key_id_sig;
        push @{ $jwks->{keys} }, $key;
    }
    $self->lmLog( "Send JWKS response sent", 'debug' );
    return $self->p->sendJSONresponse( $req, $jwks );
}

# Handle register endpoint
sub registration {
    my ( $self, $req ) = @_;
    $self->lmLog( "URL detected as an OpenID Connect REGISTRATION URL",
        'debug' );

    # TODO: check Initial Access Token

    # Specific message to allow DOS detection
    my $source_ip = $req->remote_ip;
    $self->lmLog( "OpenID Connect Registration request from $source_ip",
        'warn' );

    # Check dynamic registration is allowed
    unless ( $self->conf->{oidcServiceAllowDynamicRegistration} ) {
        $self->lmLog( "Dynamic registration is not allowed", 'error' );
        $self->p->sendError( $req, 'server_error' );
    }

    # Get client metadata
    my $client_metadata_json = $req->body;
    unless ($client_metadata_json) {
        return $self->p->sendError( $req, 'Missing POST datas', 400 );
    }

    $self->lmLog( "Client metadata received: $client_metadata_json", 'debug' );

    my $client_metadata       = $self->decodeJSON($client_metadata_json);
    my $registration_response = {};

    # Check redirect_uris
    unless ( $client_metadata->{redirect_uris} ) {
        $self->lmLog( "Field redirect_uris is mandatory", 'error' );
        return $self->p->sendError( $req, 'invalid_client_metadata', 400 );
    }

    # RP identifier
    my $registration_time = time;
    my $rp                = "register-$registration_time";

    # Generate Client ID and Client Password
    my $client_id     = random_string("ssssssssssssssssssssssssssssss");
    my $client_secret = random_string("ssssssssssssssssssssssssssssss");

    # Register known parameters
    my $client_name =
      $client_metadata->{client_name} || "Self registered client";
    my $logo_uri = $client_metadata->{logo_uri};
    my $id_token_signed_response_alg =
      $client_metadata->{id_token_signed_response_alg} || "RS256";
    my $userinfo_signed_response_alg =
      $client_metadata->{userinfo_signed_response_alg};
    my $redirect_uris = $client_metadata->{redirect_uris};

    # Register RP in global configuration
    my $conf = $self->confAcc->getConf();

    $conf->{cfgAuthor}   = "OpenID Connect Registration ($client_name)";
    $conf->{cfgAuthorIP} = $source_ip;

    $conf->{oidcRPMetaDataExportedVars}->{$rp} = {};
    $conf->{oidcRPMetaDataOptions}->{$rp}->{oidcRPMetaDataOptionsClientID} =
      $client_id;
    $conf->{oidcRPMetaDataOptions}->{$rp}->{oidcRPMetaDataOptionsClientSecret}
      = $client_secret;
    $conf->{oidcRPMetaDataOptions}->{$rp}->{oidcRPMetaDataOptionsDisplayName} =
      $client_name;
    $conf->{oidcRPMetaDataOptions}->{$rp}->{oidcRPMetaDataOptionsIcon} =
      $logo_uri;
    $conf->{oidcRPMetaDataOptions}->{$rp}->{oidcRPMetaDataOptionsIDTokenSignAlg}
      = $id_token_signed_response_alg;
    $conf->{oidcRPMetaDataOptions}->{$rp}->{oidcRPMetaDataOptionsRedirectUris}
      = join( ' ', @$redirect_uris );
    $conf->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsUserInfoSignAlg} = $userinfo_signed_response_alg
      if defined $userinfo_signed_response_alg;

    if ( $self->confAcc->saveConf($conf) ) {

        # Reload RP list
        $self->loadRPs();

        # Send registration response
        $registration_response->{'client_id'}            = $client_id;
        $registration_response->{'client_secret'}        = $client_secret;
        $registration_response->{'client_id_issued_at'}  = $registration_time;
        $registration_response->{'client_id_expires_at'} = 0;
        $registration_response->{'client_name'}          = $client_name;
        $registration_response->{'logo_uri'}             = $logo_uri;
        $registration_response->{'id_token_signed_response_alg'} =
          $id_token_signed_response_alg;
        $registration_response->{'redirect_uris'} = $redirect_uris;
        $registration_response->{'userinfo_signed_response_alg'} =
          $userinfo_signed_response_alg
          if defined $userinfo_signed_response_alg;
    }
    else {
        $self->lmLog(
            "Configuration not saved: $Lemonldap::NG::Common::Conf::msg",
            'error' );
        return $self->p->sendError( $req, 'server_error', 500 );
    }

    $self->lmLog( "Registration response sent", 'debug' );
    return $self->p->sendJSONresponse( $req, $registration_response,
        code => 201 );
}

# Handle logout endpoint for unauthenticated users
sub endSessionDone {
    my ( $self, $req ) = @_;
    $self->lmLog( "URL  detected as an OpenID Connect END SESSION URL",
        'debug' );
    $req->parseBody if($req->method =~ /^post$/i);
    $self->lmLog( "User is already logged out", 'debug' );

    my $post_logout_redirect_uri = $req->param('post_logout_redirect_uri');
    my $state                    = $req->param('state');

    if ($post_logout_redirect_uri) {

        # Build Response
        my $response_url =
          $self->buildLogoutResponse( $post_logout_redirect_uri, $state );

        $self->lmLog( "Redirect user to $response_url", 'debug' );
        return [ 302, [ Location => $response_url ], [] ];
    }

    # Else, normal login process
    return $self->p->login($req);
}

# Handle checksession endpoint
sub checkSession {
    my ( $self, $req ) = @_;
    $self->lmLog( "URL  detected as an OpenID Connect CHECK SESSION URL",
        'debug' );
    $req->parseBody if($req->method =~ /^post$/i);

    my $portalPath = $self->{portal};
    $portalPath =~ s#^https?://[^/]+/?#/#;
    $portalPath =~ s#[^/]+\.pl$##;

    # TODO: access_control_allow_origin => '*'
    return $self->sendHtml(
        $req, '../common/oidc_checksession',
        JS_CODE   => $self->getSessionManagementOPIFrameJS,
        SKIN_PATH => $portalPath . 'skins'
    );
}

sub badAuthRequest {
    my ( $self, $req ) = @_;
    return $self->p->sendError( $req,
        $req->uri . ' may not be called by an authenticated user', 400 );
}

# Nothing to do here
sub logout {
    my ( $self, $req ) = @_;
    return PE_OK;
}

# Internal methods

sub addRouteFromConf {
    my ( $self, $type, %subs ) = @_;
    my $adder = "add${type}Route";
    foreach ( keys %subs ) {
        my $sub  = $subs{$_};
        my $path = $self->conf->{$_};
        unless ($path) {
            $self->lmLog( "$_ parameter not defined", 'error' );
            next;
        }
        $self->$adder( $self->path => { $path => $sub }, [ 'GET', 'POST' ] );
    }
}

sub metadata {
    my ( $self, $req ) = @_;
    my $issuerDBOpenIDConnectPath = $self->conf->{issuerDBOpenIDConnectPath};
    my $authorize_uri    = $self->conf->{oidcServiceMetaDataAuthorizeURI};
    my $token_uri        = $self->conf->{oidcServiceMetaDataTokenURI};
    my $userinfo_uri     = $self->conf->{oidcServiceMetaDataUserInfoURI};
    my $jwks_uri         = $self->conf->{oidcServiceMetaDataJWKSURI};
    my $registration_uri = $self->conf->{oidcServiceMetaDataRegistrationURI};
    my $endsession_uri   = $self->conf->{oidcServiceMetaDataEndSessionURI};
    my $checksession_uri = $self->conf->{oidcServiceMetaDataCheckSessionURI};

    my $path   = $self->path . '/';
    my $issuer = $self->conf->{oidcServiceMetaDataIssuer};
    $path = "/" . $path unless ( $issuer =~ /\/$/ );
    my $baseUrl = $issuer . $path;

    my @acr = keys %{ $self->conf->{oidcServiceMetaDataAuthnContext} };

    # Add a slash to path value if issuer has no trailing slash

    # Create OpenID configuration hash;
    return $self->p->sendJSONresponse(
        $req,
        {
            issuer => $issuer,

            # Endpoints
            token_endpoint         => $baseUrl . $token_uri,
            userinfo_endpoint      => $baseUrl . $userinfo_uri,
            jwks_uri               => $baseUrl . $jwks_uri,
            authorization_endpoint => $baseUrl . $authorize_uri,
            end_session_endpoint   => $baseUrl . $endsession_uri,
            check_session_iframe   => $baseUrl . $checksession_uri,
            (
                $self->conf->{oidcServiceAllowDynamicRegistration}
                ? ( registration_endpoint => $baseUrl . $registration_uri )
                : ()
            ),

            # Scopes
            scopes_supported => [qw/openid profile email address phone/],
            response_types_supported => [
                "code",
                "id_token",
                "id_token token",
                "code id_token",
                "code token",
                "code id_token token"
            ],
            grant_types_supported   => [qw/authorization_code implicit hybrid/],
            acr_values_supported    => \@acr,
            subject_types_supported => ["public"],
            token_endpoint_auth_methods_supported =>
              [qw/client_secret_post client_secret_basic/],
            request_parameter_supported      => JSON::true,
            request_uri_parameter_supported  => JSON::true,
            require_request_uri_registration => JSON::false,

            # Algorithms
            id_token_signing_alg_values_supported =>
              [qw/none HS256 HS384 HS512 RS256 RS384 RS512/],
            userinfo_signing_alg_values_supported =>
              [qw/none HS256 HS384 HS512 RS256 RS384 RS512/],
        }
    );

    # response_modes_supported}

    # id_token_encryption_alg_values_supported
    # id_token_encryption_enc_values_supported

    # userinfo_encryption_alg_values_supported
    # userinfo_encryption_enc_values_supported
    # request_object_signing_alg_values_supported
    # request_object_encryption_alg_values_supported
    # request_object_encryption_enc_values_supported

    # token_endpoint_auth_signing_alg_values_supported
    # display_values_supported
    # claim_types_supported
    # RECOMMENDED # claims_supported
    # service_documentation
    # claims_locales_supported
    # ui_locales_supported
    # claims_parameter_supported

    # op_policy_uri
    # op_tos_uri
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::Issuer::OpenIDConnect - OpenIDConnect Provider for Lemonldap::NG

=head1 DESCRIPTION

This is an OpenID Connect provider implementation in LemonLDAP::NG

=head1 SEE ALSO

L<http://lemonldap-ng.org>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item Xavier Guimard E<lt>x.guimard@free.frE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2014-2016 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item Copyright (C) 2016 by Xavier Guimard E<lt>x.guimard@free.frE<gt>

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
