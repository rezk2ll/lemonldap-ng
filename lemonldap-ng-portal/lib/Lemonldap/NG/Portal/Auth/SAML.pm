package Lemonldap::NG::Portal::Auth::SAML;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_CONFIRM
  PE_LOGOUT_OK
  PE_OK
  PE_SAML_ART_ERROR
  PE_SAML_CONDITIONS_ERROR
  PE_SAML_DESTINATION_ERROR
  PM_SAML_IDPCHOOSEN
  PE_SAML_IDPSSOINITIATED_NOTALLOWED
  PE_SAML_SESSION_ERROR
  PE_SAML_SIGNATURE_ERROR
  PE_SAML_SLO_ERROR
  PE_SAML_SSO_ERROR
  PE_SAML_UNKNOWN_ENTITY
);
use Lemonldap::NG::Common::Conf::SAML::Metadata;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base', 'Lemonldap::NG::Portal::Lib::SAML';

sub init {
    my ($self) = @_;

    # Load SAML service and SAML IdP list
    return ( $self->SUPER::init and $self->loadIDPs );
}

sub extractFormInfo {
    my ( $self, $req ) = @_;

    # 1. Get HTTP request informations to know
    # if we are receving SAML request or response
    my $url            = $req->uri;
    my $request_method = $req->method;
    my $content_type   = $req->contentType;

    my $saml_acs_art_url = $self->getMetaDataURL(
        "samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact");
    my $saml_acs_post_url = $self->getMetaDataURL(
        "samlSPSSODescriptorAssertionConsumerServiceHTTPPost");
    my $saml_acs_get_url = $self->getMetaDataURL(
        "samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect");
    my $saml_slo_soap_url =
      $self->getMetaDataURL( "samlSPSSODescriptorSingleLogoutServiceSOAP", 1 );
    my $saml_slo_soap_url_ret =
      $self->getMetaDataURL( "samlSPSSODescriptorSingleLogoutServiceSOAP", 2 );
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
    my $saml_ars_url = $self->getMetaDataURL(
        "samlSPSSODescriptorArtifactResolutionServiceArtifact");

    # 1.1 SSO assertion consumer
    if ( $url =~
/^(\Q$saml_acs_art_url\E|\Q$saml_acs_post_url\E|\Q$saml_acs_get_url\E)$/io
      )
    {
        $self->lmLog( "URL $url detected as an SSO assertion consumer URL",
            'debug' );

        # Check SAML Message
        my ( $request, $response, $method, $relaystate, $artifact ) =
          $self->checkMessage( $url, $request_method, $content_type, "login" );

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
                    return $self->_subProcess(qw(autoRedirect));
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
            my $checkConditions =
              $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
              ->{samlIDPMetaDataOptionsCheckConditions};

            # Check conditions - time and audience
            if (
                $checkConditions
                and !$self->validateConditions(
                    $assertion, $self->getMetaDataURL( "samlEntityID", 0, 1 )
                )
              )
            {
                $self->lmLog( "Conditions not validated", 'error' );
                return PE_SAML_CONDITIONS_ERROR;
            }

            #  Extract RelayState information
            if ( $self->extractRelayState($relaystate) ) {
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

               # Save values in hidden fields in case of other user interactions
                $self->setHiddenFormValue( 'SAMLRequest',
                    $req->datas->{_proxiedRequest} );
                $self->setHiddenFormValue( 'Method',
                    $req->datas->{_proxiedMethod} );
                $self->setHiddenFormValue( 'RelayState',
                    $req->datas->{_proxiedRelayState} );
                $self->setHiddenFormValue( 'SAMLart',
                    $req->datas->{_proxiedArtifact} );

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

            # Redirect user
            $req->mustRedirect(1);
            return $self->_subProcess(qw(autoRedirect));
        }

    }

    # 1.2 SLO
    elsif ( $url =~
/^(\Q$saml_slo_soap_url\E|\Q$saml_slo_soap_url_ret\E|\Q$saml_slo_get_url\E|\Q$saml_slo_get_url_ret\E|Q$saml_slo_post_url\E|\Q$saml_slo_post_url_ret\E)$/io
      )
    {
        $self->lmLog( "URL $url detected as an SLO URL", 'debug' );

        # Check SAML Message
        my ( $request, $response, $method, $relaystate, $artifact ) =
          $self->checkMessage( $url, $request_method, $content_type, "logout" );

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

            return $self->_subProcess(qw(autoRedirect))
              if (  $req->urldc
                and $self->conf->{portal} !~ /\Q$req->{urldc}\E\/?/ );

            # Else, inform user that logout is OK
            return PE_LOGOUT_OK;
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
                          $self->getApacheSession( $real_session, 1 );

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

                        # Delete real session
                        my $del_real_result =
                          $self->_deleteSession($ssoSession);

                        $self->lmLog(
"Delete real session $real_session result: $del_real_result",
                            'debug'
                        );

                        $logout_error = 1 unless $del_real_result;

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

                return $self->_subProcess(qw(autoRedirect));
            }

            # HTTP-POST
            elsif ( $method == Lasso::Constants::HTTP_METHOD_POST ) {

                # Use autosubmit form
                my $slo_url  = $logout->msg_url;
                my $slo_body = $logout->msg_body;

                $req->postUrl($slo_url);
                $req->postFields = { 'SAMLResponse' => $slo_body };

                # RelayState
                $req->postFields->{'RelayState'} = $relaystate
                  if ($relaystate);

                return $self->_subProcess(qw(autoPost));
            }

            # HTTP-SOAP
            elsif ( $method == Lasso::Constants::HTTP_METHOD_SOAP ) {

                my $slo_body = $logout->msg_body;

                $self->lmLog( "SOAP response $slo_body", 'debug' );

                $req->datas->{SOAPMessage} = $slo_body;

                $self->_subProcess(qw(returnSOAPMessage));

                # If we are here, there was a problem with SOAP response
                $self->lmLog( "Logout response was not sent trough SOAP",
                    'error' );
                return PE_SAML_SLO_ERROR;
            }

        }
        else {

            # This should not happen
            $self->lmLog( "SLO request or response was not found", 'error' );

            # Redirect user
            $req->mustRedirect(1);
            return $self->_subProcess(qw(autoRedirect));
        }
    }

    # 1.3 Artifact
    elsif ( $url =~ /^(\Q$saml_ars_url\E)$/io ) {

        $self->lmLog( "URL $url detected as an artifact resolution service URL",
            'debug' );

        # Artifact request are sent with SOAP trough POST
        my $art_request = $self->param('POSTDATA');
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
        unless ( $art_response = $self->createArtifactResponse($login) ) {
            $self->lmLog( "Unable to create artifact response message",
                'error' );
            return PE_SAML_ART_ERROR;
        }

        $req->datas->{SOAPMessage} = $art_response;

        $self->lmLog( "Send SOAP Message: " . $req->datas->{SOAPMessage},
            'debug' );

        # Return SOAP message
        $self->returnSOAPMessage();

        # If we are here, there was a problem with SOAP request
        $self->lmLog( "Artifact response was not sent trough SOAP", 'error' );
        return PE_SAML_ART_ERROR;

    }

    # 2. IDP resolution

    # Search a selected IdP
    my ( $idp, $idp_cookie ) = $self->_sub('getIDP');

    # Get confirmation flag
    my $confirm_flag = $self->param("confirm");

    # If confirmation is -1 from resolved IDP screen,
    # or IDP was not resolve, let the user choose its IDP
    if ( $confirm_flag == -1 or !$idp ) {
        $self->lmLog( "Redirecting user to IDP list", 'debug' );

        # Control url parameter
        my $urlcheck = $self->controlUrlOrigin();
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
          'Set-Cookie' => $self->cookie(
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
    elsif ( $confirm_flag != 1 ) {
        $self->lmLog( "IDP $idp selected, need user confirmation", 'debug' );

        # Control url parameter
        my $urlcheck = $self->controlUrlOrigin();
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
          . $self->param("url") . "\" />"
          . "<input type=\"hidden\" name=\"idp\" value=\"$idp\" />\n";

        $self->info($html);

        $req->datas->{login} = 1;
        return PE_CONFIRM;
    }

    # Here confirmation is OK (confirm_flag == 1), store choosen IDP in cookie
    unless ( $idp_cookie and $idp eq $idp_cookie ) {
        $self->lmLog( "Build cookie to remember $idp as IDP choice", 'debug' );

        # Control url parameter
        my $urlcheck = $self->controlUrlOrigin();
        return $urlcheck unless ( $urlcheck == PE_OK );

        # User can choose temporary (0) or persistent cookie (1)
        my $cookie_type = $self->param("cookie_type") || "0";

        push @{ $req->{respHeaders} },
          'Set-Cookie' => $self->cookie(
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
      ->{samlIDPMetaDataOptionsSignSSOMessage};

    # Authentication Context
    my $requestedAuthnContext =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsRequestedAuthnContext};
    $requestedAuthnContext = $self->getAuthnContext($requestedAuthnContext)
      if $requestedAuthnContext;

    # Create SSO request
    my $login = $self->createAuthnRequest(
        $self->lassoServer, $idp,            $method,
        $forceAuthn,        $isPassive,      $nameIDFormat,
        $allowProxiedAuthn, $signSSOMessage, $requestedAuthnContext
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

        return $self->_subProcess(qw(autoRedirect));
    }

    # HTTP-POST
    elsif ($method == $self->getHttpMethod('post')
        or $method == $self->getHttpMethod('artifact-post') )
    {

        # Use autosubmit form
        my $sso_url  = $login->msg_url;
        my $sso_body = $login->msg_body;

        $self->postUrl($sso_url);

        if ( $method == $self->getHttpMethod("artifact-post") ) {
            $req->{postFields} = { 'SAMLart' => $sso_body };
        }
        else {
            $req->{postFields} = { 'SAMLRequest' => $sso_body };
        }

        # RelayState
        $req->{postFields}->{'RelayState'} = $login->msg_relayState
          if ( $login->msg_relayState );

        return $self->_subProcess(qw(autoPost));
    }

    # No SOAP transport for SSO request
}

sub authenticate {
    my ( $self, $req ) = @_;
}

sub authLogout {
    my ( $self, $req ) = @_;
}

sub getDisplayType {
}

1;
