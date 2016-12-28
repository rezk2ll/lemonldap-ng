package Lemonldap::NG::Portal::Auth::SAML;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_CONFIRM
  PE_LOGOUT_OK
  PE_REDIRECT
  PE_OK
  PE_SAML_ART_ERROR
  PE_SAML_CONDITIONS_ERROR
  PE_SAML_DESTINATION_ERROR
  PE_SAML_ERROR
  PM_SAML_IDPCHOOSEN
  PE_SAML_IDPSSOINITIATED_NOTALLOWED
  PE_SAML_SESSION_ERROR
  PE_SAML_SIGNATURE_ERROR
  PE_SAML_SLO_ERROR
  PE_SAML_SSO_ERROR
  PE_SAML_UNKNOWN_ENTITY
  PE_SENDRESPONSE
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base', 'Lemonldap::NG::Portal::Lib::SAML';

# INTERFACE

has sloAssConsumerRe => ( is => 'rw' );
has sloRe            => ( is => 'rw' );
has artRe            => ( is => 'rw' );

sub forAuthUser { 'handleAuthRequests' }

# INITIALIZATION

sub init {
    my ($self) = @_;

    my $saml_acs_art_url = $self->getMetaDataURL(
        "samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact");
    my $saml_acs_post_url = $self->getMetaDataURL(
        "samlSPSSODescriptorAssertionConsumerServiceHTTPPost");
    my $saml_acs_get_url = $self->getMetaDataURL(
        "samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect");
    $self->sloAssConsumerRe(
        qr/^($saml_acs_art_url|$saml_acs_post_url|$saml_acs_get_url)(?:\?.*)?$/i
    );
    my $saml_slo_soap_url =
      $self->getMetaDataURL( "samlSPSSODescriptorSingleLogoutServiceSOAP", 1 );
    my $saml_slo_soap_url_ret =
      $self->getMetaDataURL( "samlSPSSODescriptorSingleLogoutServiceSOAP", 1 );
    my $saml_slo_get_url = $self->getMetaDataURL(
        "samlSPSSODescriptorSingleLogoutServiceHTTPRedirect", 1 );
    my $saml_slo_get_url_ret = $self->getMetaDataURL(
        "samlSPSSODescriptorSingleLogoutServiceHTTPRedirect", 2 );
    my $saml_slo_post_url =
      $self->getMetaDataURL( "samlSPSSODescriptorSingleLogoutServiceHTTPPost",
        1 );
    my $saml_slo_post_url_ret =
      $self->getMetaDataURL( "samlSPSSODescriptorSingleLogoutServiceHTTPPost",
        2 );
    $self->sloRe(
qr/^($saml_slo_soap_url|$saml_slo_soap_url_ret|$saml_slo_get_url|$saml_slo_get_url_ret|$saml_slo_post_url|$saml_slo_post_url_ret)(?:\?.*)?$/i
    );

    my $saml_ars_url = $self->getMetaDataURL(
        "samlSPSSODescriptorArtifactResolutionServiceArtifact");
    $self->artRe(qr/^($saml_ars_url)(?:\?.*)?$/i);

    # Load SAML service and SAML IdP list
    return ( $self->SUPER::init and $self->loadIDPs );
}

# RUNNING METHODS

sub extractFormInfo {
    my ( $self, $req ) = @_;

    # 1. Get HTTP request information to know
    # if we are receving SAML request or response
    my $url            = $req->uri;
    my $request_method = $req->method;
    my $content_type   = $req->contentType;

    # 1.1 SSO assertion consumer
    if ( $url =~ $self->sloAssConsumerRe ) {
        $self->lmLog( "URL $url detected as an SSO assertion consumer URL",
            'debug' );

        # Check SAML Message
        my ( $request, $response, $method, $relaystate, $artifact ) =
          $self->checkMessage( $req, $url, $request_method, $content_type,
            "login" );

        # Create Login object
        my $login = $self->createLogin( $self->lassoServer );

        # Ignore signature verification
        $self->disableSignatureVerification($login);

        if ($response) {

            # Process authentication response
            my $result;
            if ($artifact) {
                $result = $self->processArtResponseMsg( $login, $response );
            }
            else {
                $result = $self->processAuthnResponseMsg( $login, $response );
            }

            unless ($result) {
                $self->lmLog( "SSO: Fail to process authentication response",
                    'error' );
                return PE_SAML_SSO_ERROR;
            }

            $self->lmLog( "SSO: authentication response is valid", 'debug' );

            # Get IDP entityID
            my $idp = $login->remote_providerID();

            $self->lmLog( "Found entityID $idp in SAML message", 'debug' );

            # IDP conf key
            my $idpConfKey = $self->idpList->{$idp}->{confKey};

            unless ($idpConfKey) {
                $self->lmLog( "$idp do not match any IDP in configuration",
                    'error' );
                return PE_SAML_UNKNOWN_ENTITY;
            }

            $self->lmLog( "$idp match $idpConfKey IDP in configuration",
                'debug' );

            # Do we check signature?
            my $checkSSOMessageSignature =
              $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
              ->{samlIDPMetaDataOptionsCheckSSOMessageSignature};

            if ($checkSSOMessageSignature) {

                $self->forceSignatureVerification($login);

                if ($artifact) {
                    $result = $self->processArtResponseMsg( $login, $response );
                }
                else {
                    $result =
                      $self->processAuthnResponseMsg( $login, $response );
                }

                unless ($result) {
                    $self->lmLog( "Signature is not valid", 'error' );
                    return PE_SAML_SIGNATURE_ERROR;
                }
                else {
                    $self->lmLog( "Signature is valid", 'debug' );
                }
            }
            else {
                $self->lmLog( "Message signature will not be checked",
                    'debug' );
            }

            # Get SAML response
            my $saml_response = $login->response();
            unless ($saml_response) {
                $self->lmLog( "No SAML response found", 'error' );
                return PE_SAML_SSO_ERROR;
            }

            # Check Destination
            return PE_SAML_DESTINATION_ERROR
              unless ( $self->checkDestination( $saml_response, $url ) );

            # Replay protection if this is a response to a created authn request
            my $assertion_responded = $saml_response->InResponseTo;
            if ($assertion_responded) {
                unless ( $self->replayProtection($assertion_responded) ) {

                    # Assertion was already consumed or is expired
                    # Force authentication replay
                    $self->lmLog(
"Message $assertion_responded already used or expired, replay authentication",
                        'error'
                    );
                    delete $req->{urldc};
                    $req->mustRedirect(1);
                    $req->steps( [] );
                    return PE_OK;
                }
            }
            else {
                $self->lmLog(
"Assertion is not a response to a created authentication request, do not control replay",
                    'debug'
                );
            }

            # Get SAML assertion
            my $assertion = $self->getAssertion($login);

            unless ($assertion) {
                $self->lmLog( "No assertion found", 'error' );
                return PE_SAML_SSO_ERROR;
            }

            # Do we check conditions?
            my $checkTime =
              $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
              ->{samlIDPMetaDataOptionsCheckTime};
            my $checkAudience =
              $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
              ->{samlIDPMetaDataOptionsCheckAudience};

            # Check conditions - time and audience
            unless (
                $self->validateConditions(
                    $assertion, $self->getMetaDataURL( "samlEntityID", 0, 1 ),
                    $checkTime, $checkAudience
                )
              )
            {
                $self->lmLog( "Conditions not validated", 'error' );
                return PE_SAML_CONDITIONS_ERROR;
            }

            my $relayStateURL =
              $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
              ->{samlIDPMetaDataOptionsRelayStateURL};

            #  Extract RelayState information
            if ( $self->extractRelayState( $relaystate, $relayStateURL ) ) {
                $self->lmLog( "RelayState $relaystate extracted", 'debug' );
            }

            # Check if we accept direct login from IDP
            my $allowLoginFromIDP =
              $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
              ->{samlIDPMetaDataOptionsAllowLoginFromIDP};
            if ( !$assertion_responded and !$allowLoginFromIDP ) {
                $self->lmLog(
                    "Direct login from IDP $idpConfKey is not allowed",
                    'error' );
                return PE_SAML_IDPSSOINITIATED_NOTALLOWED;
            }

            # Check authentication context
            my $responseAuthnContext;
            eval {
                $responseAuthnContext =
                  $assertion->AuthnStatement()->AuthnContext()
                  ->AuthnContextClassRef();
            };
            if ($@) {
                $self->lmLog(
                    "Unable to get authentication context from $idpConfKey",
                    'debug' );
                $responseAuthnContext = $self->getAuthnContext("unspecified");
            }
            else {
                $self->lmLog(
                    "Found authentication context: $responseAuthnContext",
                    'debug' );
            }

            # Map authentication context to authentication level
            $req->sessionInfo->{authenticationLevel} =
              $self->authnContext2authnLevel($responseAuthnContext);

            # Force redirection to portal if no urldc found
            # (avoid displaying the whole SAML URL in user browser URL field)
            $req->mustRedirect(1) unless ( $req->urldc );

            # Get SessionIndex
            my $session_index;

            eval {
                $session_index = $assertion->AuthnStatement()->SessionIndex();
            };
            if ( $@ or !defined($session_index) ) {
                $self->lmLog( "No SessionIndex found", 'debug' );
            }
            else {
                $self->lmLog( "Found SessionIndex $session_index", 'debug' );
            }

            # Get NameID
            my $nameid = $login->nameIdentifier;

            # Set user
            my $user = $nameid->content;

            unless ($user) {
                $self->lmLog( "No NameID value found", 'error' );
                return PE_SAML_SSO_ERROR;
            }

            $self->lmLog( "Found NameID: $user", 'debug' );
            $req->user($user);

            # Store Lasso objects
            $req->datas->{_lassoLogin}   = $login;
            $req->datas->{_idp}          = $idp;
            $req->datas->{_idpConfKey}   = $idpConfKey;
            $req->datas->{_nameID}       = $nameid;
            $req->datas->{_sessionIndex} = $session_index;

            # Store Token
            my $saml_token = $assertion->export_to_xml;

            $self->lmLog( "SAML Token: $saml_token", 'debug' );

            $req->datas->{_samlToken} = $saml_token;

            # Restore initial SAML request in case of proxying
            my $moduleOptions = $self->conf->{samlStorageOptions} || {};
            $moduleOptions->{backend} = $self->conf->{samlStorage};
            my $module = "Lemonldap::NG::Common::Apache::Session";

            my $saml_sessions =
              $module->searchOn( $moduleOptions, "ProxyID",
                $assertion_responded );

            if ( my @saml_sessions_keys = keys %$saml_sessions ) {

                # Warning if more than one session found
                if ( $#saml_sessions_keys > 0 ) {
                    $self->lmLog(
"More than one SAML proxy session found for ID $assertion_responded",
                        'warn'
                    );
                }

                # Take the first session
                my $saml_session = shift @saml_sessions_keys;

                # Get session
                $self->lmLog(
"Retrieve SAML proxy session $saml_session for ID $assertion_responded",
                    'debug'
                );

                my $samlSessionInfo = $self->getSamlSession($saml_session);

                $req->datas->{_proxiedRequest} =
                  $samlSessionInfo->data->{Request};
                $req->datas->{_proxiedMethod} =
                  $samlSessionInfo->data->{Method};
                $req->datas->{_proxiedRelayState} =
                  $samlSessionInfo->data->{RelayState};
                $req->datas->{_proxiedArtifact} =
                  $samlSessionInfo->data->{Artifact};

                # Delete session
                $samlSessionInfo->remove();
            }

            return PE_OK;
        }
        elsif ($request) {

            # Do nothing
            $self->lmLog(
                "This module do not manage SSO request, see IssuerDBSAML",
                'debug' );

            return PE_OK;
        }
        else {

            # This should not happen
            $self->lmLog( "SSO request or response was not found", 'error' );

            return PE_SAML_ERROR;
        }

    }

    # 1.2 SLO
    elsif ( $url =~ $self->sloRe ) {
        $self->lmLog( "URL $url detected as an SLO URL", 'debug' );

        # TODO: call authLogout instead of duplicating SLO
        $req->steps( [ @{ $self->p->beforeLogout }, 'deleteSession' ] );

        # Check SAML Message
        my ( $request, $response, $method, $relaystate, $artifact ) =
          $self->checkMessage( $req, $url, $request_method, $content_type,
            "logout" );

        # Create Logout object
        my $logout = $self->createLogout( $self->lassoServer );

        # Ignore signature verification
        $self->disableSignatureVerification($logout);

        if ($response) {

            # Process logout response
            my $result = $self->processLogoutResponseMsg( $logout, $response );

            unless ($result) {
                $self->lmLog( "Fail to process logout response", 'error' );
                return PE_SAML_SLO_ERROR;
            }

            $self->lmLog( "Logout response is valid", 'debug' );

            # Check Destination
            return PE_SAML_DESTINATION_ERROR
              unless ( $self->checkDestination( $logout->response, $url ) );

            # Get IDP entityID
            my $idp = $logout->remote_providerID();

            $self->lmLog( "Found entityID $idp in SAML message", 'debug' );

            # IDP conf key
            my $idpConfKey = $self->idpList->{$idp}->{confKey};

            unless ($idpConfKey) {
                $self->lmLog( "$idp do not match any IDP in configuration",
                    'error' );
                return PE_SAML_UNKNOWN_ENTITY;
            }

            $self->lmLog( "$idp match $idpConfKey IDP in configuration",
                'debug' );

            # Do we check signature?
            my $checkSLOMessageSignature =
              $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
              ->{samlIDPMetaDataOptionsCheckSLOMessageSignature};

            if ($checkSLOMessageSignature) {

                $self->forceSignatureVerification($logout);

                $result = $self->processLogoutResponseMsg( $logout, $response );

                unless ($result) {
                    $self->lmLog( "Signature is not valid", 'error' );
                    return PE_SAML_SIGNATURE_ERROR;
                }
                else {
                    $self->lmLog( "Signature is valid", 'debug' );
                }
            }
            else {
                $self->lmLog( "Message signature will not be checked",
                    'debug' );
            }

            # Replay protection
            my $samlID = $logout->response()->InResponseTo;

            unless ( $self->replayProtection($samlID) ) {

                # Logout request was already consumed or is expired
                $self->lmLog( "Message $samlID already used or expired",
                    'error' );
                return PE_SAML_SLO_ERROR;
            }

            # If URL in RelayState, different from portal, redirect user
            if ( $self->extractRelayState($relaystate) ) {
                $self->lmLog( "RelayState $relaystate extracted", 'debug' );
                $self->lmLog( "URL " . $req->urldc . " found in RelayState",
                    'debug' );
            }

            if (    $req->urldc
                and $self->conf->{portal} !~ /$req->{urldc}\/?/ )
            {
                $req->steps( [] );
                $req->user('TODO');
                return PE_OK;
            }

            # Else, inform user that logout is OK
            $req->user('TODO');
            return PE_OK;
        }

        elsif ($request) {

            # Logout error
            my $logout_error = 0;

            # Lasso::Session dump
            my $session_dump;

            # Process logout request
            unless ( $self->processLogoutRequestMsg( $logout, $request ) ) {
                $self->lmLog( "Fail to process logout request", 'error' );
                $logout_error = 1;
            }

            $self->lmLog( "Logout request is valid", 'debug' );

            # Check Destination
            return PE_SAML_DESTINATION_ERROR
              unless ( $self->checkDestination( $logout->request, $url ) );

            # Get IDP entityID
            my $idp = $logout->remote_providerID();

            $self->lmLog( "Found entityID $idp in SAML message", 'debug' );

            # IDP conf key
            my $idpConfKey = $self->idpList->{$idp}->{confKey};

            unless ($idpConfKey) {
                $self->lmLog( "$idp do not match any IDP in configuration",
                    'error' );
                return PE_SAML_UNKNOWN_ENTITY;
            }

            $self->lmLog( "$idp match $idpConfKey IDP in configuration",
                'debug' );

            # Do we check signature?
            my $checkSLOMessageSignature =
              $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
              ->{samlIDPMetaDataOptionsCheckSLOMessageSignature};

            if ($checkSLOMessageSignature) {
                unless ( $self->checkSignatureStatus($logout) ) {
                    $self->lmLog( "Signature is not valid", 'error' );
                    return PE_SAML_SIGNATURE_ERROR;
                }
                else {
                    $self->lmLog( "Signature is valid", 'debug' );
                }
            }
            else {
                $self->lmLog( "Message signature will not be checked",
                    'debug' );
            }

            # Get NameID and SessionIndex
            my $name_id       = $logout->request()->NameID;
            my $session_index = $logout->request()->SessionIndex;
            my $user          = $name_id->content;

            unless ($name_id) {
                $self->lmLog( "Fail to get NameID from logout request",
                    'error' );
                $logout_error = 1;
            }

            $self->lmLog( "Logout request NameID content: $user", 'debug' );

            # Get SAML sessions with the same NameID
            my $moduleOptions = $self->conf->{samlStorageOptions} || {};
            $moduleOptions->{backend} = $self->conf->{samlStorage};
            my $module = "Lemonldap::NG::Common::Apache::Session";

            my $local_sessions =
              $module->searchOn( $moduleOptions, "_nameID", $name_id->dump );

            if ( my @local_sessions_keys = keys %$local_sessions ) {

                # At least one session was found
                foreach (@local_sessions_keys) {

                    my $local_session = $_;

                    # Get session
                    $self->lmLog(
                        "Retrieve SAML session $local_session for user $user",
                        'debug' );

                    my $sessionInfo = $self->getSamlSession($local_session);

              # If session index is defined and not equal to SAML session index,
              # jump to next session
                    if ( defined $session_index
                        and $session_index ne
                        $sessionInfo->data->{_sessionIndex} )
                    {
                        $self->lmLog(
"Session $local_session has not the good session index, skipping",
                            'debug'
                        );
                        next;
                    }

                    # Delete session
                    else {

                        # Open real session
                        my $real_session = $sessionInfo->data->{_saml_id};

                        my $ssoSession =
                          $self->p->getApacheSession( $real_session, 1 );

                        # Import SSO session in $req
                        $self->importRealSession( $req, $ssoSession );

                  # Get Lasso::Session dump
                  # This value is erased if a next session match the SLO request
                        if (   $ssoSession
                            && $ssoSession->data->{_lassoSessionDump} )
                        {
                            $self->lmLog(
"Get Lasso::Session dump from session $real_session",
                                'debug'
                            );
                            $session_dump =
                              $ssoSession->data->{_lassoSessionDump};
                        }

                # Real session will be deleted after (see $req->steps... before)

                        # Delete SAML session
                        my $del_saml_result = $sessionInfo->remove();

                        $self->lmLog(
"Delete SAML session $local_session result: $del_saml_result",
                            'debug'
                        );

                        $logout_error = 1 unless $del_saml_result;
                    }
                }

                # Set session from dump
                unless ( $self->setSessionFromDump( $logout, $session_dump ) ) {
                    $self->lmLog( "Cannot set session from dump in logout",
                        'error' );
                    $logout_error = 1;
                }

            }
            else {

                # No corresponding session found
                $self->lmLog( "No SAML session found for user $user", 'debug' );

                $logout_error = 1;

            }

            # Validate request if no previous error
            unless ($logout_error) {
                unless ( $self->validateLogoutRequest($logout) ) {
                    $self->lmLog( "SLO request is not valid", 'error' );
                }
            }

            # Set RelayState
            if ($relaystate) {
                $logout->msg_relayState($relaystate);
                $self->lmLog( "Set $relaystate in RelayState", 'debug' );
            }

            # Do we set signature?
            my $signSLOMessage =
              $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
              ->{samlIDPMetaDataOptionsSignSLOMessage};

            if ( $signSLOMessage == 0 ) {
                $self->lmLog(
                    "SLO message to IDP $idpConfKey will not be signed",
                    'debug' );
                $self->disableSignature($logout);
            }
            elsif ( $signSLOMessage == 1 ) {
                $self->lmLog( "SLO message to IDP $idpConfKey will be signed",
                    'debug' );
                $self->forceSignature($logout);
            }
            else {
                $self->lmLog(
"SLO message to IDP $idpConfKey signature according to metadata",
                    'debug'
                );
            }

            # Logout response
            unless ( $self->buildLogoutResponseMsg($logout) ) {
                $self->lmLog( "Unable to build SLO response", 'error' );
                return PE_SAML_SLO_ERROR;
            }

            # Send response depending on request method
            # HTTP-REDIRECT
            no strict 'subs';
            if ( $method == Lasso::Constants::HTTP_METHOD_REDIRECT ) {

                # Redirect user to response URL
                my $slo_url = $logout->msg_url;
                $self->lmLog( "Redirect user to $slo_url", 'debug' );

                $req->urldc($slo_url);

                return PE_OK;
            }

            # HTTP-POST
            elsif ( $method == Lasso::Constants::HTTP_METHOD_POST ) {

                # Use autosubmit form
                my $slo_url  = $logout->msg_url;
                my $slo_body = $logout->msg_body;

                $req->postUrl($slo_url);
                $req->postFields( { 'SAMLResponse' => $slo_body } );

                # RelayState
                $req->postFields->{'RelayState'} = $relaystate
                  if ($relaystate);

                # TODO: verify this
                push @{ $req->steps }, 'autoPost';
                return PE_OK;
            }

            # HTTP-SOAP
            elsif ( $method == Lasso::Constants::HTTP_METHOD_SOAP ) {

                my $slo_body = $logout->msg_body;

                $self->lmLog( "SOAP response $slo_body", 'debug' );

                $req->response(
                    [
                        200,
                        [
                            'Content-Type'   => 'application/xml',
                            'Content-Length' => length($slo_body)
                        ],
                        [$slo_body]
                    ]
                );
                $req->steps(
                    [
                        @{ $self->p->beforeLogout },
                        sub {
                            my ($req) = @_;
                            my $res = $self->p->deleteSession($req);
                            return (
                                $res eq PE_LOGOUT_OK ? PE_SENDRESPONSE : $res );
                          }
                    ]
                );

                $req->user('SOAP client');
                return PE_OK;
            }

        }
        else {

            # This should not happen
            $self->lmLog( "SLO request or response was not found", 'error' );

            # Redirect user
            $req->mustRedirect(1);
            $req->steps( [] );
            return PE_REDIRECT;
        }
    }

    # 1.3 Artifact
    elsif ( $url =~ $self->artRe ) {

        $self->lmLog( "URL $url detected as an artifact resolution service URL",
            'debug' );

        # Artifact request are sent with SOAP trough POST
        my $art_request = $req->body;
        my $art_response;

        # Create Login object
        my $login = $self->createLogin( $self->lassoServer );

        # Process request message
        unless ( $self->processArtRequestMsg( $login, $art_request ) ) {
            $self->lmLog( "Unable to process artifact request message",
                'error' );
            return PE_SAML_ART_ERROR;
        }

        # Check Destination
        return PE_SAML_DESTINATION_ERROR
          unless ( $self->checkDestination( $login->request, $url ) );

        # Create artifact response
        unless ( $art_response = $self->createArtifactResponse( $req, $login ) )
        {
            $self->lmLog( "Unable to create artifact response message",
                'error' );
            return PE_SAML_ART_ERROR;
        }

        $req->response(
            [
                200,
                [
                    'Content-Type'   => 'application/xml',
                    'Content-Length' => length($art_response)
                ],
                [$art_response]
            ]
        );
        $req->user('SOAP client');
        return PE_SENDRESPONSE;
    }

    # 2. IDP resolution

    # Search a selected IdP
    my ( $idp, $idp_cookie ) = $self->getIDP($req);

    # Get confirmation flag
    my $confirm_flag = $req->param("confirm") // '';

    # If confirmation is -1 from resolved IDP screen,
    # or IDP was not resolve, let the user choose its IDP
    if ( $confirm_flag eq '-1' or !$idp ) {
        $self->lmLog( "Redirecting user to IDP list", 'debug' );

        # Control url parameter
        my $urlcheck = $self->p->controlUrl($req);
        return $urlcheck unless ( $urlcheck == PE_OK );

        # IDP list
        my @list = ();
        foreach ( keys %{ $self->idpList } ) {
            push @list,
              {
                val  => $_,
                name => $self->idpList->{$_}->{name}
              };
        }
        $req->datas->{list}            = \@list;
        $req->datas->{confirmRemember} = 1;

        # Delete existing IDP resolution cookie
        push @{ $req->respHeaders },
          'Set-Cookie' => $self->p->cookie(
            name    => $self->conf->{samlIdPResolveCookie},
            value   => 0,
            domain  => $self->conf->{domain},
            path    => "/",
            secure  => 0,
            expires => '-1d',
          );

        #TODO: check this
        $req->datas->{login} = 1;
        return PE_CONFIRM;
    }

    # If IDP is found but not confirmed, let the user confirm it
    elsif ( $confirm_flag eq '1' ) {
        $self->lmLog( "IDP $idp selected, need user confirmation", 'debug' );

        # Control url parameter
        my $urlcheck = $self->p->controlUrl($req);
        return $urlcheck unless ( $urlcheck == PE_OK );

        # Choosen IDP
        my $html = '<h3>'
          . $self->msg(PM_SAML_IDPCHOOSEN)
          . "</h3>\n" . "<h4>"
          . $self->idpList->{$idp}->{name}
          . "</h4>\n"
          . "<p><i>"
          . $idp
          . "</i></p>\n"
          . "<input type=\"hidden\" name=\"url\" value=\""
          . $req->param("url") . "\" />"
          . "<input type=\"hidden\" name=\"idp\" value=\"$idp\" />\n";

        $self->info( $req, $html );

        $req->datas->{login} = 1;
        return PE_CONFIRM;
    }

    # Here confirmation is OK (confirm_flag == 1), store choosen IDP in cookie
    unless ( $idp_cookie and $idp eq $idp_cookie ) {
        $self->lmLog( "Build cookie to remember $idp as IDP choice", 'debug' );

        # Control url parameter
        my $urlcheck = $self->p->controlUrl($req);
        return $urlcheck unless ( $urlcheck == PE_OK );

        # User can choose temporary (0) or persistent cookie (1)
        my $cookie_type = $req->param("cookie_type") || "0";

        push @{ $req->{respHeaders} },
          'Set-Cookie' => $self->p->cookie(
            name     => $self->conf->{samlIdPResolveCookie},
            value    => $idp,
            domain   => $self->conf->{domain},
            path     => "/",
            secure   => $self->conf->{securedCookie},
            HttpOnly => $self->conf->{httpOnly},
            expires  => $cookie_type ? "+365d" : "",
          );
    }

    # 3. Build authentication request

    # IDP conf key
    my $idpConfKey = $self->idpList->{$idp}->{confKey};

    unless ($idpConfKey) {
        $self->lmLog( "$idp do not match any IDP in configuration", 'error' );
        return PE_SAML_UNKNOWN_ENTITY;
    }

    $self->lmLog( "$idp match $idpConfKey IDP in configuration", 'debug' );

    # IDP ForceAuthn
    my $forceAuthn =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsForceAuthn};

    # IDP IsPassive
    my $isPassive =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsIsPassive};

    # IDP NameIDFormat
    my $nameIDFormat =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsNameIDFormat};
    $nameIDFormat = $self->getNameIDFormat($nameIDFormat) if $nameIDFormat;

    # IDP ProxyRestriction
    my $allowProxiedAuthn =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsAllowProxiedAuthn};

    # IDP HTTP method
    my $method =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsSSOBinding};
    $method = $self->getHttpMethod($method);

    # If no method defined, get first HTTP method
    unless ( defined $method ) {
        no strict 'subs';
        my $protocolType = Lasso::Constants::MD_PROTOCOL_TYPE_SINGLE_SIGN_ON;
        $method =
          $self->getFirstHttpMethod( $self->lassoServer, $idp, $protocolType );
    }

    # Failback to HTTP-REDIRECT
    unless ( defined $method and $method != -1 ) {
        $self->lmLog( "No method found with IDP $idpConfKey for SSO profile",
            'debug' );
        $method = $self->getHttpMethod("redirect");
    }

    $self->lmLog(
        "Use method "
          . $self->getHttpMethodString($method)
          . " with IDP $idpConfKey for SSO profile",
        'debug'
    );

    # Set signature
    my $signSSOMessage =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsSignSSOMessage} // -1;

    # Authentication Context
    my $requestedAuthnContext =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsRequestedAuthnContext} // '';
    $requestedAuthnContext = $self->getAuthnContext($requestedAuthnContext)
      if $requestedAuthnContext;

    # Create SSO request
    my $login = $self->createAuthnRequest(
        $req,          $self->lassoServer, $idp,
        $method,       $forceAuthn,        $isPassive,
        $nameIDFormat, $allowProxiedAuthn, $signSSOMessage,
        $requestedAuthnContext
    );

    unless ($login) {
        $self->lmLog( "Could not create authentication request on $idpConfKey",
            'error' );
        return PE_SAML_SSO_ERROR;
    }

    $self->lmLog( "Authentication request created", 'debug' );

    # Keep assertion ID in memory to prevent replay
    my $samlID = $login->request()->ID;
    unless ( $self->storeReplayProtection($samlID) ) {
        $self->lmLog( "Unable to store assertion ID", 'error' );
        return PE_SAML_SSO_ERROR;
    }

    # Keep initial SAML request data in memory in case of proxing
    if ( $req->datas->{_proxiedSamlRequest} ) {

        my $samlSessionInfo = $self->getSamlSession();

        return PE_SAML_SESSION_ERROR unless $samlSessionInfo;

        my $infos;

        $infos->{type}       = 'proxy';
        $infos->{_utime}     = time;
        $infos->{Request}    = $req->datas->{_proxiedRequest};
        $infos->{Method}     = $req->datas->{_proxiedMethod};
        $infos->{RelayState} = $req->datas->{_proxiedRelayState};
        $infos->{Artifact}   = $req->datas->{_proxiedArtifact};
        $infos->{ProxyID}    = $samlID;

        $samlSessionInfo->update($infos);

        $self->lmLog( "Keep initial SAML request data in memory for ID $samlID",
            'debug' );
    }

    # Send SSO request depending on request method
    # HTTP-REDIRECT
    if (   $method == $self->getHttpMethod('redirect')
        or $method == $self->getHttpMethod('artifact-get') )
    {

        # Redirect user to response URL
        my $sso_url = $login->msg_url;
        $self->lmLog( "Redirect user to $sso_url", 'debug' );

        $req->urldc($sso_url);

        return PE_REDIRECT;
    }

    # HTTP-POST
    elsif ($method == $self->getHttpMethod('post')
        or $method == $self->getHttpMethod('artifact-post') )
    {

        # Use autosubmit form
        my $sso_url  = $login->msg_url;
        my $sso_body = $login->msg_body;

        $req->postUrl($sso_url);

        if ( $method == $self->getHttpMethod("artifact-post") ) {
            $req->{postFields} = { 'SAMLart' => $sso_body };
        }
        else {
            $req->{postFields} = { 'SAMLRequest' => $sso_body };
        }

        # RelayState
        $req->{postFields}->{'RelayState'} = $login->msg_relayState
          if ( $login->msg_relayState );

        # TODO: verify this
        $req->steps( ['autoPost'] );
        $req->continue(1);
        return PE_OK;
    }

    # No SOAP transport for SSO request
    return PE_SAML_SSO_ERROR;
}

sub authenticate {
    PE_OK;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    my $login      = $req->datas->{_lassoLogin};
    my $idp        = $req->datas->{_idp};
    my $idpConfKey = $req->datas->{_idpConfKey};

    # Get SAML assertion
    my $assertion = $self->getAssertion($login);

    unless ($assertion) {
        $self->lmLog( "No assertion found", 'error' );
        return PE_SAML_SSO_ERROR;
    }

    # Force UTF-8
    my $force_utf8 =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsForceUTF8};

    # Try to get attributes if attribute statement is present in assertion
    my $attr_statement = $assertion->AttributeStatement();
    if ($attr_statement) {

        # Get attributes
        my @attributes = $attr_statement->Attribute();

        # Wanted attributes are defined in IDP configuration
        foreach (
            keys
            %{ $self->conf->{samlIDPMetaDataExportedAttributes}->{$idpConfKey} }
          )
        {

            # Extract fields from exportedAttr value
            my ( $mandatory, $name, $format, $friendly_name ) =
              split( /;/,
                $self->conf->{samlIDPMetaDataExportedAttributes}->{$idpConfKey}
                  ->{$_} );

            # Try to get value
            my $value =
              $self->getAttributeValue( $name, $format, $friendly_name,
                \@attributes, $force_utf8 );

            # Store value in sessionInfo
            $req->{sessionInfo}->{$_} = $value if defined $value;
        }
    }

    # Store other information in session
    $req->{sessionInfo}->{_idp}        = $idp;
    $req->{sessionInfo}->{_idpConfKey} = $idpConfKey;

    # Adapt _utime with SessionNotOnOrAfter
    my $sessionNotOnOrAfter;
    eval {
        $sessionNotOnOrAfter =
          $assertion->AuthnStatement()->SessionNotOnOrAfter();
    };

    if ( $@ or !$sessionNotOnOrAfter ) {
        $self->lmLog( "No SessionNotOnOrAfter value found", 'debug' );
    }
    else {

        my $samltime = $self->samldate2timestamp($sessionNotOnOrAfter);
        my $utime    = time();
        my $timeout  = $self->conf->{timeout};
        my $adaptSessionUtime =
          $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
          ->{samlIDPMetaDataOptionsAdaptSessionUtime};

        if ( ( $utime + $timeout > $samltime ) and $adaptSessionUtime ) {

            # Use SAML time to determine the start of the session
            my $new_utime = $samltime - $timeout;
            $req->{sessionInfo}->{_utime} = $new_utime;
            $self->lmLog(
"Adapt _utime with SessionNotOnOrAfter value, new _utime: $new_utime",
                'debug'
            );
        }

    }

    # Establish federation (required for attribute request in UserDBSAML)
    unless ( $self->acceptSSO($login) ) {
        $self->lmLog( "Error while accepting SSO from IDP $idpConfKey",
            'error' );
        return PE_SAML_SSO_ERROR;
    }

    # Get created Lasso::Session and Lasso::Identity
    my $session  = $login->get_session;
    my $identity = $login->get_identity;

    # Dump Lasso objects in session
    $req->{sessionInfo}->{_lassoSessionDump}  = $session->dump()  if $session;
    $req->{sessionInfo}->{_lassoIdentityDump} = $identity->dump() if $identity;

    # Keep SAML Token in session
    my $store_samlToken =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsStoreSAMLToken};
    if ($store_samlToken) {
        $self->lmLog( "Store SAML Token in session", 'debug' );
        $req->{sessionInfo}->{_samlToken} = $req->datas->{_samlToken};
    }
    else {
        $self->lmLog( "SAML Token will not be stored in session", 'debug' );
    }

    $req->datas->{_lassoLogin} = $login;
    push @{ $req->steps }, sub { $self->authFinish(@_) };

    PE_OK;
}

# Inserted in $req->steps by authenticate()
sub authFinish {
    my ( $self, $req ) = @_;
    my %h;

    # Real session was stored, get id and utime
    my $id    = $req->{id};
    my $utime = $req->{sessionInfo}->{_utime};

    # Get saved Lasso objects
    my $nameid        = $req->datas->{_nameID};
    my $session_index = $req->datas->{_sessionIndex};

    $self->lmLog(
        "Store NameID "
          . $nameid->dump
          . " and SessionIndex $session_index for session $id",
        'debug'
    );

    # Save SAML session
    my $samlSessionInfo = $self->getSamlSession();

    return PE_SAML_SESSION_ERROR unless $samlSessionInfo;

    my $infos;
    $infos->{type}          = 'saml';            # Session type
    $infos->{_utime}        = $utime;            # Creation time
    $infos->{_saml_id}      = $id;               # SSO session id
    $infos->{_nameID}       = $nameid->dump;     # SAML NameID
    $infos->{_sessionIndex} = $session_index;    # SAML SessionIndex

    $samlSessionInfo->update($infos);

    my $session_id = $samlSessionInfo->id;

    $self->lmLog( "Link session $id to SAML session $session_id", 'debug' );

    return PE_OK;
}

sub authLogout {
    my ( $self, $req ) = @_;
    my $idp        = $req->sessionInfo->{_idp};
    my $idpConfKey = $req->sessionInfo->{_idpConfKey};
    my $session_id = $req->sessionInfo->{_session_id};
    my $method;

    # Real session was previously deleted,
    # remove corresponding SAML sessions
    $self->deleteSAMLSecondarySessions($session_id);

    # Recover Lasso::Session dump
    my $session_dump = $req->{sessionInfo}->{_lassoSessionDump};

    unless ($session_dump) {
        $self->lmLog( "Could not get session dump from session", 'error' );
        return PE_SAML_SLO_ERROR;
    }

    # IDP HTTP method
    $method =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsSLOBinding};
    $method = $self->getHttpMethod($method);

    # If no method defined, get first HTTP method
    no strict 'subs';
    unless ( defined $method ) {
        my $protocolType = Lasso::Constants::MD_PROTOCOL_TYPE_SINGLE_LOGOUT;
        $method =
          $self->getFirstHttpMethod( $self->lassoServer, $idp, $protocolType );
    }

    # Skip SLO if no method found
    unless ( defined $method and $method != -1 ) {
        $self->lmLog( "No method found with IDP $idpConfKey for SLO profile",
            'debug' );
        return PE_OK;
    }

    $self->lmLog(
        "Use method "
          . $self->getHttpMethodString($method)
          . " with IDP $idpConfKey for SLO profile",
        'debug'
    );

    # Set signature
    my $signSLOMessage =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsSignSLOMessage} // 0;

    # Build Logout Request
    my $logout =
      $self->createLogoutRequest( $req, $self->lassoServer, $session_dump,
        $method, $signSLOMessage );
    unless ($logout) {
        $self->lmLog( "Could not create logout request", 'error' );
        return PE_SAML_SLO_ERROR;
    }

    $self->lmLog( "Logout request created", 'debug' );

    # Keep request ID in memory to prevent replay
    unless ( $self->storeReplayProtection( $logout->request()->ID ) ) {
        $self->lmLog( "Unable to store Logout request ID", 'error' );
        return PE_SAML_SLO_ERROR;
    }

    # Send request depending on request method
    # HTTP-REDIRECT
    if (   $method == Lasso::Constants::HTTP_METHOD_REDIRECT
        or $method == Lasso::Constants::HTTP_METHOD_ARTIFACT_GET )
    {

        # Redirect user to response URL
        my $slo_url = $logout->msg_url;
        $self->lmLog( "Redirect user to $slo_url", 'debug' );

        $req->urldc($slo_url);

        # Redirect done in Portal/Simple.pm
        return PE_OK;
    }

    # HTTP-POST
    elsif ($method == Lasso::Constants::HTTP_METHOD_POST
        or $method == Lasso::Constants::HTTP_METHOD_ARTIFACT_POST )
    {

        # Use autosubmit form
        my $slo_url  = $logout->msg_url;
        my $slo_body = $logout->msg_body;
        $self->lmLog( "Redirect user to $slo_url using autoPost", 'debug' );

        $req->postUrl($slo_url);
        $req->postFields( { 'SAMLRequest' => $slo_body } );

        # RelayState
        $self->postFields->{'RelayState'} = $logout->msg_relayState
          if ( $logout->msg_relayState );

        # Post done in Portal/Simple.pm
        $req->steps( [ 'deleteSession', 'autoPost' ] );
        return PE_OK;
    }

    # HTTP-SOAP
    elsif ( $method == Lasso::Constants::HTTP_METHOD_SOAP ) {

        my $slo_url  = $logout->msg_url;
        my $slo_body = $logout->msg_body;

        # Send SOAP request and manage response
        my $response = $self->sendSOAPMessage( $slo_url, $slo_body );

        unless ($response) {
            $self->lmLog( "No logout response to SOAP request", 'error' );
            return PE_SAML_SLO_ERROR;
        }

        # Create Logout object
        $logout = $self->createLogout( $self->lassoServer );

        # Process logout response
        my $result = $self->processLogoutResponseMsg( $logout, $response );

        unless ($result) {
            $self->lmLog( "Fail to process logout response", 'error' );
            return PE_SAML_SLO_ERROR;
        }

        $self->lmLog( "Logout response is valid", 'debug' );

        # Replay protection
        my $samlID = $logout->response()->InResponseTo;

        unless ( $self->replayProtection($samlID) ) {

            # Logout request was already consumed or is expired
            $self->lmLog( "Message $samlID already used or expired", 'error' );
            return PE_SAML_SLO_ERROR;
        }

        return PE_OK;
    }
    else {
        $self->lmLog("Lasso method $method not implemented here",'error');
        return PE_SAML_SLO_ERROR;
    }
}

sub handleAuthRequests {
    my ( $self, $req ) = @_;
    if ( $req->uri =~ $self->sloRe ) {
        return $self->extractFormInfo($req);
    }
    PE_OK;
}

# TODO: authForce

sub getDisplayType {
    return "logo";
}

# Internal methods

# Try to find an IdP using :
# * HTTP parameter
# * "samlIdPResolveCookie" cookie
# * Rules
# * Common Domain Cookie
#
# @return Array containing :
# * IdP found (or undef)
# * Cookie value if exists
sub getIDP {
    my ( $self, $req ) = @_;
    my $idp;
    my $idpName;

    my $idp_cookie;
    if (   $req->cookies
        && $req->cookies =~ /$self->{conf}->{samlIdPResolveCookie}=([^,; ]+)/o )
    {
        $idp_cookie = $1;
    }

    # Case 1: Recover IDP from idp URL Parameter
    unless ( $idp = $req->param("idp") ) {

        # Case 2: Recover IDP from idpName URL Parameter
        if ( $idpName = $req->param("idpName") ) {
            foreach ( keys %{ $self->idpList } ) {
                my $idpConfKey = $self->idpList->{$_}->{confKey};
                if ( $idpName eq $idpConfKey ) {
                    $idp = $_;
                    $self->lmLog(
                        "IDP $idp found from idpName URL Parameter ($idpName)",
                        'debug'
                    );
                    last;
                }
            }
        }

        # Case 3: Recover IDP from cookie
        if ( !$idp and $idp = $idp_cookie ) {
            $self->lmLog( "IDP $idp found in IDP resolution cookie", 'debug' );
        }

        # Case 4: check all IDP resolution rules
        # The first match win
        else {
            foreach ( keys %{ $self->idpList } ) {
                my $idpConfKey = $self->idpList->{$_}->{confKey};
                my $cond =
                  $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
                  ->{samlIDPMetaDataOptionsResolutionRule};
                next unless defined $cond;
                if ( $self->safe->reval($cond) ) {
                    $self->lmLog( "IDP $idpConfKey resolution rule match",
                        'debug' );
                    $idp = $_;
                    last;
                }
            }
        }

        # Case 5: use Common Domain Cookie
        if (   !$idp
            and $self->conf->{samlCommonDomainCookieActivation}
            and $self->conf->{samlCommonDomainCookieReader} )
        {
            $self->lmLog(
                "Will try to use Common Domain Cookie for IDP resolution",
                'debug' );

            # Add current URL to CDC Reader URL
            my $return_url = encode_base64( $self->self_url(), '' );

            my $cdc_reader_url = $self->conf->{samlCommonDomainCookieReader};

            $cdc_reader_url .= (
                $self->conf->{samlCommonDomainCookieReader} =~ /\?/
                ? '&u->confrl=' . $return_url
                : '?url=' . $return_url
            );

            $self->lmLog( "Redirect user to $cdc_reader_url", 'debug' );

            $req->urldc($cdc_reader_url);

            $req->steps( [] );
            return PE_REDIRECT;
        }

        $self->lmLog( 'No IDP found', 'debug' ) unless ($idp);
    }

    # Alert when selected IDP is unknown
    if ( $idp and !exists $self->idpList->{$idp} ) {
        $self->p->userError("Required IDP $idp does not exists");
        $idp = undef;
    }

    return ( $idp, $idp_cookie );
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::Auth::SAML - SAML Authentication backend

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::Auth::SAML;

=head1 DESCRIPTION

Use SAML to authenticate users

=head1 SEE ALSO

L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Portal::User::SAML>, L<Lemonldap::NG::Portal::Lib::SAML>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Sandro Cazzaniga, E<lt>cazzaniga.sandro@gmail.comE<gt>

=item Thomas Chemineau, E<lt>thomas.chemineau@gmail.comE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2009-2016 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2012 by Sandro Cazzaniga, E<lt>cazzaniga.sandro@gmail.comE<gt>

=item Copyright (C) 2012 by François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Copyright (C) 2010-2015 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item Copyright (C) 2010 by Thomas Chemineau, E<lt>thomas.chemineau@gmail.comE<gt>

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
