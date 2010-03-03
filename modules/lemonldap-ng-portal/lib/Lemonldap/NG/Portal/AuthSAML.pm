## @file
# SAML Service Provider - Authentication

## @class
# SAML Service Provider - Authentication
package Lemonldap::NG::Portal::AuthSAML;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_SAML;    #inherits
use Lemonldap::NG::Common::Conf::SAML::Metadata;

our $VERSION = '0.1';
our @ISA     = qw(Lemonldap::NG::Portal::_SAML);

## @apmethod int authInit()
# Load Lasso and metadata
# @return Lemonldap::NG::Portal error code
sub authInit {
    my $self = shift;

    # Load Lasso
    return PE_ERROR unless $self->loadLasso();

    # Activate SOAP
    $self->abort( 'To use SAML, you must activate SOAP (Soap => 1)', 'error' )
      unless ( $self->{Soap} );

    # Check presence of private key in configuration
    unless ( $self->{samlServicePrivateKey} ) {
        $self->lmLog( "SAML private key not found in configuration", 'error' );
        return PE_ERROR;
    }

    # Get metadata from configuration
    $self->lmLog( "Get Metadata for this service", 'debug' );
    my $service_metadata = Lemonldap::NG::Common::Conf::SAML::Metadata->new();

    # Create Lasso server with service metadata
    my $server = $self->createServer(
        $service_metadata->serviceToXML(
            $ENV{DOCUMENT_ROOT} . "/skins/common/saml2-metadata.tpl", $self
        ),
        $self->{samlServicePrivateKey},
    );

    unless ($server) {
        $self->lmLog( 'Unable to create Lasso server', 'error' );
        return PE_ERROR;
    }

    $self->lmLog( "Service created", 'debug' );

    # Check presence of at least one identity provider in configuration
    unless ( $self->{samlIDPMetaDataXML}
        and keys %{ $self->{samlIDPMetaDataXML} } )
    {
        $self->lmLog( "No IDP found in configuration", 'error' );
        return PE_ERROR;
    }

    # Load identity provider metadata
    # IDP metadata are listed in $self->{samlIDPMetaDataXML}
    # Each key is the IDP name
    # Build IDP list for later use in extractFormInfo
    foreach ( keys %{ $self->{samlIDPMetaDataXML} } ) {

        $self->lmLog( "Get Metadata for IDP $_", 'debug' );

        # Get metadata from configuration
        my $idp_metadata = Lemonldap::NG::Common::Conf::SAML::Metadata->new();
        unless (
            $idp_metadata->initializeFromConfHash(
                $self->{samlIDPMetaDataXML}->{$_}->{samlIDPMetaDataXML}
            )
          )
        {
            $self->lmLog( "Fail to read IDP $_ Metadata from configuration",
                'error' );
            return PE_ERROR;
        }

        # Add this IDP to Lasso::Server
        my $result = $self->addIDP( $server, $idp_metadata->toXML() );

        unless ($result) {
            $self->lmLog( "Fail to use IDP $_ Metadata", 'error' );
            return PE_ERROR;
        }

        # Store IDP entityID and Organization Name
        my $entityID = $idp_metadata->{entityID};
        my $name = $self->getOrganizationName( $server, $entityID )
          || ucfirst($_);
        $self->{_idpList}->{$_}->{entityID} = $entityID;
        $self->{_idpList}->{$_}->{name}     = $name;

        $self->lmLog( "IDP $_ added", 'debug' );
    }

    # Store Lasso::Server object
    $self->{_lassoServer} = $server;

    PE_OK;
}

## @apmethod int extractFormInfo()
# Check authentication statement or create authentication request
# @return Lemonldap::NG::Portal error code
sub extractFormInfo {
    my $self   = shift;
    my $server = $self->{_lassoServer};
    my $login;
    my $logout;
    my $idp;
    my $method;
    my $request;
    my $response;
    my $artifact;
    my $relaystate;

    # 1. Get HTTP request informations to know
    # if we are receving SAML request or response
    my $url            = $self->url();
    my $request_method = $self->request_method();
    my $content_type   = $self->content_type();

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
    my $saml_slo_get_url =
      $self->getMetaDataURL( "samlSPSSODescriptorSingleLogoutServiceHTTP", 1 );
    my $saml_slo_get_url_ret =
      $self->getMetaDataURL( "samlSPSSODescriptorSingleLogoutServiceHTTP", 2 );

    # 1.1 SSO assertion consumer
    if ( $url =~ /^($saml_acs_art_url|$saml_acs_post_url|$saml_acs_get_url)$/i )
    {

        $self->lmLog( "URL $url detected as an SSO assertion consumer URL",
            'debug' );

        # Create Login object
        $login = $self->createLogin($server);

        # Get relayState
        $relaystate = $self->param('RelayState');

        # 1.1.1 HTTP REDIRECT
        if ( $request_method =~ /^GET$/ ) {

            $method = Lasso::Constants::HTTP_METHOD_REDIRECT;
            $self->lmLog( "SSO method: HTTP-REDIRECT", 'debug' );

            if ( $self->param('SAMLResponse') ) {

                # Response in query string
                $response = $self->query_string();
                $self->lmLog( "HTTP-REDIRECT: SAML Response $response",
                    'debug' );

            }

            if ( $self->param('SAMLRequest') ) {

                # Request in query string
                $request = $self->query_string();
                $self->lmLog( "HTTP-REDIRECT: SAML Request $request", 'debug' );

            }

            if ( $self->param('SAMLart') ) {

                # Artifcat in query string
                $artifact = $self->query_string();
                $self->lmLog( "HTTP-REDIRECT: SAML Artifact $artifact",
                    'debug' );

                # Resolve Artifact
                $method = Lasso::Constants::HTTP_METHOD_ARTIFACT_GET;
                my $message =
                  $self->resolveArtifact( $login, $artifact, $method );

                # Request or response ?
                if ( $message =~ /samlp:response/i ) {
                    $response = $message;
                }
                else {
                    $request = $message;
                }
            }

        }

        elsif ( $request_method =~ /^POST$/ ) {

            # 1.2.2 POST
            if ( $content_type !~ /xml/ ) {

                $method = Lasso::Constants::HTTP_METHOD_POST;
                $self->lmLog( "SSO method: HTTP-POST", 'debug' );

                if ( $self->param('SAMLResponse') ) {

                    # Response in body part
                    $response = $self->param('SAMLResponse');
                    $self->lmLog( "HTTP-POST: SAML Response $response",
                        'debug' );

                }

                if ( $self->param('SAMLRequest') ) {

                    # Request in body part
                    $request = $self->param('SAMLRequest');
                    $self->lmLog( "HTTP-POST: SAML Request $request", 'debug' );

                }

                if ( $self->param('SAMLart') ) {

                    # Artifcat in SAMLart param
                    $artifact = $self->param('SAMLart');
                    $self->lmLog( "HTTP-REDIRECT: SAML Artifact $artifact",
                        'debug' );

                    # Resolve Artifact
                    $method = Lasso::Constants::HTTP_METHOD_ARTIFACT_POST;
                    my $message =
                      $self->resolveArtifact( $login, $artifact, $method );

                    # Request or response ?
                    if ( $message =~ /samlp:response/i ) {
                        $response = $message;
                    }
                    else {
                        $request = $message;
                    }
                }

            }

            # 1.2.3 SOAP
            else {

                $method = Lasso::Constants::HTTP_METHOD_SOAP;
                $self->lmLog( "SSO method: HTTP-SOAP", 'debug' );

                # SOAP is always a request
                $request = $self->param('POSTDATA');
                $self->lmLog( "HTTP-SOAP: SAML Request $request", 'debug' );

            }
        }

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
                return PE_ERROR;
            }

            $self->lmLog( "SSO: authentication response is valid", 'debug' );

            # Get SAML response
            my $saml_response = $login->response();
            unless ($saml_response) {
                $self->lmLog( "No SAML response found", 'error' );
                return PE_ERROR;
            }

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
                    delete $self->{urldc};
                    $self->{mustRedirect} = 1;
                    $self->{error} = $self->_subProcess(qw(autoRedirect));
                    return $self->{error};
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
                return PE_ERROR;
            }

            # Check conditions - time and audience
            unless (
                $self->validateConditions( $assertion, $self->{samlEntityID} ) )
            {
                $self->lmLog( "Conditions not validated", 'error' );
                return PE_ERROR;
            }

            # Check OneTimeUse flag
            # TODO

            # Check ProxyRestriction flag
            # TODO

            #  Extract RelayState information
            if ( $self->extractRelayState($relaystate) ) {
                $self->lmLog( "RelayState $relaystate extracted", 'debug' );
            }

            # Check IDP from RelayState
            my $idp = $self->{_idp};
            if ($idp) {
                $self->lmLog( "IDP $idp found in RelayState", 'debug' );
            }
            else {

                # Try to recover IDP from IDP cookie
                my %cookies    = fetch CGI::Cookie;
                my $idp_cookie = $cookies{ $self->{samlIdPResolveCookie} };
                if ($idp_cookie) {
                    $idp = $idp_cookie->value;
                    $self->{_idp} = $idp;
                    $self->lmLog( "IDP $idp found in IDP resolution cookie",
                        'debug' );
                }
                else {
                    $self->lmLog(
"IDP was not found in RelayState or in IDP resolution cookie",
                        'error'
                    );
                    return PE_ERROR;
                }
            }

            # Force redirection to portal if no urldc found
            # (avoid displaying the whole SAML URL in user browser URL field)
            $self->{mustRedirect} = 1 unless ( $self->{urldc} );

            # Get NameID
            my $nameid = $login->nameIdentifier;

            # Set user
            my $user = $nameid->content;

            unless ($user) {
                $self->lmLog( "No NameID value found", 'error' );
                return PE_USERNOTFOUND;
            }

            $self->lmLog( "Find NameID: $user", 'debug' );
            $self->{user} = $user;

            # Store Lasso objects
            $self->{_lassoLogin} = $login;

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
            $self->{mustRedirect} = 1;
            $self->{error}        = $self->_subProcess(qw(autoRedirect));
            return $self->{error};
        }

    }

    # 1.2 SLO
    if ( $url =~
/^($saml_slo_soap_url|$saml_slo_soap_url_ret|$saml_slo_get_url|$saml_slo_get_url_ret)$/i
      )
    {
        $self->lmLog( "URL $url detected as an SLO URL", 'debug' );

        # Create Logout object
        $logout = $self->createLogout($server);

        # Get relayState
        $relaystate = $self->param('RelayState');

        # 1.2.1 HTTP-REDIRECT
        if ( $request_method =~ /^GET$/ ) {

            $method = Lasso::Constants::HTTP_METHOD_REDIRECT;
            $self->lmLog( "SLO method: HTTP-REDIRECT", 'debug' );

            if ( $self->param('SAMLResponse') ) {

                # Response in query string
                $response = $self->query_string();
                $self->lmLog( "HTTP-REDIRECT: SAML Response $response",
                    'debug' );

            }

            if ( $self->param('SAMLRequest') ) {

                # Request in query string
                $request = $self->query_string();
                $self->lmLog( "HTTP-REDIRECT: SAML Request $request", 'debug' );

            }

        }

        elsif ( $request_method =~ /^POST$/ ) {

            # 1.2.2 POST
            if ( $content_type !~ /xml/ ) {

                $method = Lasso::Constants::HTTP_METHOD_POST;
                $self->lmLog( "SLO method: HTTP-POST", 'debug' );

                if ( $self->param('SAMLResponse') ) {

                    # Response in body part
                    $response = $self->param('SAMLResponse');
                    $self->lmLog( "HTTP-POST: SAML Response $response",
                        'debug' );

                }

                if ( $self->param('SAMLRequest') ) {

                    # Request in body part
                    $request = $self->param('SAMLRequest');
                    $self->lmLog( "HTTP-POST: SAML Request $request", 'debug' );

                }

            }

            # 1.2.3 SOAP
            else {

                $method = Lasso::Constants::HTTP_METHOD_SOAP;
                $self->lmLog( "SLO method: HTTP-SOAP", 'debug' );

                # SOAP is always a request
                $request = $self->param('POSTDATA');
                $self->lmLog( "HTTP-SOAP: SAML Request $request", 'debug' );

            }
        }

        if ($response) {

            # Process logout response
            my $result = $self->processLogoutResponseMsg( $logout, $response );

            unless ($result) {
                $self->lmLog( "Fail to process logout response", 'error' );
                return PE_ERROR;
            }

            $self->lmLog( "Logout response is valid", 'debug' );

            # Replay protection
            my $samlID = $logout->response()->InResponseTo;

            unless ( $self->replayProtection($samlID) ) {

                # Logout request was already consumed or is expired
                $self->lmLog( "Message $samlID already used or expired",
                    'error' );
                return PE_ERROR;
            }

            # If URL in RelayState, different from portal, redirect user
            if ( $self->extractRelayState($relaystate) ) {
                $self->lmLog( "RelayState $relaystate extracted", 'debug' );
                $self->lmLog( "URL " . $self->{urldc} . " found in RelayState",
                    'debug' );
            }

            $self->_subProcess(qw(autoRedirect))
              if ( $self->{urldc} and $self->{urldc} ne $self->{portal} );

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

            # Get NameID and SessionIndex
            my $name_id       = $logout->request()->NameID;
            my $session_index = $logout->request()->SessionIndex;
            my $user          = $name_id->content;

            unless ($user) {
                $self->lmLog( "Fail to get NameID content from logout request",
                    'error' );
                $logout_error = 1;
            }

            $self->lmLog( "Logout request NameID content: $user", 'debug' );

            # Get corresponding session
            my $local_sessions =
              $self->{globalStorage}
              ->searchOn( $self->{globalStorageOptions}, "_user", $user, );

            if ( my @local_sessions_keys = keys %$local_sessions ) {

                # A session was found
                foreach (@local_sessions_keys) {

                    my $local_session = $_;

                    # Get session
                    $self->lmLog(
                        "Retrieve session $local_session for user $user",
                        'debug' );
                    my $sessionInfo =
                      $self->getApacheSession( $local_session, 1 );

                    # Get Lasso::Session dump
                    $session_dump = $sessionInfo->{_lassoSessionDump}
                      if $sessionInfo->{_lassoSessionDump};

               # TODO test SessionIndex to be sure to select the correct session

                    # Delete Session
                    $self->lmLog(
                        "Delete session $local_session for user $user",
                        'debug' );
                    my $logout_result = $self->_deleteSession($sessionInfo);
                    $self->lmLog( "Local Logout result: $logout_result",
                        'debug' );
                    $logout_error = 1 unless $logout_result;
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
                $self->lmLog( "No local session found for user $user",
                    'debug' );

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

            # Logout response
            unless ( $self->buildLogoutResponseMsg($logout) ) {
                $self->lmLog( "Unable to build SLO response", 'error' );
                return PE_ERROR;
            }

            # Send response depending on request method
            # HTTP-REDIRECT
            if ( $method == Lasso::Constants::HTTP_METHOD_REDIRECT ) {

                # Redirect user to response URL
                my $slo_url = $logout->msg_url;
                $self->lmLog( "Redirect user to $slo_url", 'debug' );

                $self->{urldc} = $slo_url;

                $self->_subProcess(qw(autoRedirect));

                # If we are here, there was a problem with GET request
                $self->lmLog( "Logout response was not sent trough GET",
                    'error' );
                return PE_ERROR;
            }

            # HTTP-POST
            if ( $method == Lasso::Constants::HTTP_METHOD_POST ) {

                # Use autosubmit form
                my $slo_url  = $logout->msg_url;
                my $slo_body = $logout->msg_body;

                $self->{postUrl} = $slo_url;
                $self->{postFields} = { 'SAMLResponse' => $slo_body };

                # RelayState
                $self->{postFields} =
                  { $self->{postFields}, 'RelayState' => $relaystate }
                  if ($relaystate);

                $self->_subProcess(qw(autoPost));

                # If we are here, there was a problem with POST response
                $self->lmLog( "Logout response was not sent trough POST",
                    'error' );
                return PE_ERROR;
            }

            # HTTP-SOAP
            if ( $method == Lasso::Constants::HTTP_METHOD_SOAP ) {

                my $slo_body = $logout->msg_body;

                $self->lmLog( "SOAP response $slo_body", 'debug' );

                $self->{SOAPMessage} = $slo_body;

                $self->_subProcess(qw(returnSOAPMessage));

                # If we are here, there was a problem with SOAP response
                $self->lmLog( "Logout response was not sent trough SOAP",
                    'error' );
                return PE_ERROR;
            }

        }
        else {

            # This should not happen
            $self->lmLog( "SLO request or response was not found", 'error' );

            # Redirect user
            $self->{mustRedirect} = 1;
            $self->{error}        = $self->_subProcess(qw(autoRedirect));
            return $self->{error};
        }
    }

    # 2. IDP resolution

    # Get IDP resolution cookie
    my %cookies    = fetch CGI::Cookie;
    my $idp_cookie = $cookies{ $self->{samlIdPResolveCookie} };
    if ($idp_cookie) {
        $idp = $idp_cookie->value;
        $self->lmLog( "IDP $idp found in IDP resolution cookie", 'debug' );
    }

    # If no IDP resolve cookie, find another way to get it
    # Case 1: IDP was choosen from portal IDP list
    $idp ||= $self->param("idp");

    # TODO - other case (IP resolution, etc.)

    # Get confirmation flag
    my $confirm_flag = $self->param("confirm");

    # If confirmation is -1, or IDP was not resolve, let the user choose its IDP
    if ( $confirm_flag == -1 or !$idp ) {
        $self->lmLog( "No IDP found, redirecting user to IDP list", 'debug' );

        # IDP list
        my $html = "<h3>"
          . &Lemonldap::NG::Portal::_i18n::msg( PM_SAML_IDPSELECT,
            $ENV{HTTP_ACCEPT_LANGUAGE} )
          . "</h3>\n<table>\n";

        foreach ( keys %{ $self->{_idpList} } ) {
            $html .=
              '<tr><td><input type="radio" name="idp" onclick="stop()" value="'
              . $_
              . '" /></td><td>'
              . $self->{_idpList}->{$_}->{name}
              . '</td></tr>';
        }

        $html .=
'<tr><td><input type="checkbox" name="cookie_type" value="1"></td><td>'
          . &Lemonldap::NG::Portal::_i18n::msg( PM_REMEMBERCHOICE,
            $ENV{HTTP_ACCEPT_LANGUAGE} )
          . "</td></tr></table>\n"

          # Script to autoselect first choice
          . '<script>$("[type=radio]:first").attr("checked","checked");</script>';

        $self->info($html);

        # Delete existing IDP resolution cookie
        push @{ $self->{cookie} },
          $self->cookie(
            -name    => $self->{samlIdPResolveCookie},
            -value   => 0,
            -domain  => $self->{domain},
            -path    => "/",
            -secure  => 0,
            -expires => '-1d',
          );

        return PE_CONFIRM;
    }

    # If IDP is found but not confirmed, let the user confirm it
    if ( $confirm_flag != 1 ) {
        $self->lmLog( "IDP $idp selected, need user confirmation", 'debug' );

        # Choosen IDP
        my $html = '<h3>'
          . &Lemonldap::NG::Portal::_i18n::msg( PM_SAML_IDPCHOOSEN,
            $ENV{HTTP_ACCEPT_LANGUAGE} )
          . "</h3>\n"
          . "<h4>$idp</h4>\n" . "<h5>("
          . $self->{_idpList}->{$idp}->{entityID}
          . ")</h5>\n"
          . "<input type=\"hidden\" name=\"idp\" value=\"$idp\" />\n";

        $self->info($html);

        return PE_CONFIRM;
    }

    # Here confirmation is OK (confirm_flag == 1), store choosen IDP in cookie
    unless ( $idp_cookie and ( $idp eq $idp_cookie->value ) ) {
        $self->lmLog( "Build cookie to remember $idp as IDP choice", 'debug' );

        # User can choose temporary (0) or persistent cookie (1)
        my $cookie_type = $self->param("cookie_type") || "0";

        push @{ $self->{cookie} },
          $self->cookie(
            -name     => $self->{samlIdPResolveCookie},
            -value    => $idp,
            -domain   => $self->{domain},
            -path     => "/",
            -secure   => $self->{securedCookie},
            -httponly => $self->{httpOnly},
            -expires  => $cookie_type ? "+365d" : "",
          );
    }

    # 3. Build authentication request

    # Force HTTP-REDIRECT method
    # TODO choose method depending on IDP
    $method = Lasso::Constants::HTTP_METHOD_REDIRECT;

    # IDP entityID
    $self->{_idp} = $idp;
    my $IDPentityID = $self->{_idpList}->{$idp}->{entityID};

    # Create SSO request
    $login = $self->createAuthnRequest( $server, $IDPentityID, $method );

    unless ($login) {
        $self->lmLog( "Could not create authentication request on $IDPentityID",
            'error' );
        return PE_ERROR;
    }

    $self->lmLog( "Authentication request created", 'debug' );

    # Keep assertion ID in memory to prevent replay
    unless ( $self->storeReplayProtection( $login->request()->ID ) ) {
        $self->lmLog( "Unable to store assertion ID", 'error' );
        return PE_ERROR;
    }

    # Send SSO request depending on request method
    # HTTP-REDIRECT
    if ( $method == Lasso::Constants::HTTP_METHOD_REDIRECT ) {

        # Redirect user to response URL
        my $sso_url = $login->msg_url;
        $self->lmLog( "Redirect user to $sso_url", 'debug' );

        $self->{urldc} = $sso_url;

        $self->_subProcess(qw(autoRedirect));

        # If we are here, there was a problem with GET request
        $self->lmLog( "SSO request was not sent trough GET", 'error' );
        return PE_ERROR;
    }

    # HTTP-POST
    if ( $method == Lasso::Constants::HTTP_METHOD_POST ) {

        # Use autosubmit form
        my $sso_url  = $login->msg_url;
        my $sso_body = $login->msg_body;

        $self->{postUrl} = $sso_url;
        $self->{postFields} = { 'SAMLRequest' => $sso_body };

        # RelayState
        $self->{postFields} =
          { $self->{postFields}, 'RelayState' => $login->msg_relayState }
          if ( $login->msg_relayState );

        $self->_subProcess(qw(autoPost));

        # If we are here, there was a problem with POST request
        $self->lmLog( "SSO request was not sent trough POST", 'error' );
        return PE_ERROR;
    }

    # No SOAP transport for SSO request
}

## @apmethod int setAuthSessionInfo()
# Extract attributes sent in authentication statement
# @return Lemonldap::NG::Portal error code
sub setAuthSessionInfo {
    my $self   = shift;
    my $server = $self->{_lassoServer};
    my $login  = $self->{_lassoLogin};
    my $idp    = $self->{_idp};

    # Get SAML assertion
    my $assertion = $self->getAssertion($login);

    unless ($assertion) {
        $self->lmLog( "No assertion found", 'error' );
        return PE_ERROR;
    }

    # Try to get attributes if attribute statement is present in assertion
    my $attr_statement = $assertion->AttributeStatement();
    if ($attr_statement) {

        # Get attributes
        my @attributes = $attr_statement->Attribute();

        # Wanted attributes are defined in IDP configuration
        foreach ( keys %{ $self->{samlIDPMetaDataExportedAttributes}->{$idp} } )
        {

            # Extract fields from exportedAttr value
            my ( $mandatory, $name, $format, $friendly_name ) =
              split( /;/,
                $self->{samlIDPMetaDataExportedAttributes}->{$idp}->{$_} );

            # Try to get value
            my $value =
              $self->getAttributeValue( $name, $format, $friendly_name,
                \@attributes );

            # Store value in sessionInfo
            $self->{sessionInfo}->{$_} = $value if defined $value;
        }
    }

    # Store other informations in session
    $self->{sessionInfo}->{_user} = $self->{user};
    $self->{sessionInfo}->{_idp}  = $idp;

    # TODO adapt _utime with SessionNotOnOrAfter

    # Establish federation (required for attribute request in UserDBSAML)
    unless ( $self->acceptSSO($login) ) {
        $self->lmLog( "Error while accepting SSO from IDP", 'error' );
        return PE_ERROR;
    }

    # Get created Lasso::Session and Lasso::Identity
    my $session  = $login->get_session;
    my $identity = $login->get_identity;

    # Dump Lasso objects in session
    $self->{sessionInfo}->{_lassoSessionDump}  = $session->dump()  if $session;
    $self->{sessionInfo}->{_lassoIdentityDump} = $identity->dump() if $identity;

    $self->{_lassoLogin} = $login;

    PE_OK;
}

## @apmethod int authenticate()
# Set authenticationLevel
# @return PE_OK
sub authenticate {
    my $self = shift;

    # Set authenticationLevel
    $self->{sessionInfo}->{authenticationLevel} = 5;

    PE_OK;
}

## @apmethod void authLogout()
# Logout SP
# @return nothing
sub authLogout {
    my $self = shift;
    my $method;

    # Get Lasso Server
    unless ( $self->{_lassoServer} ) {
        $self->_sub('authInit');
    }

    my $server = $self->{_lassoServer};

    # Recover Lasso::Session dump
    my $session_dump = $self->{sessionInfo}->{_lassoSessionDump};

    unless ($session_dump) {
        $self->lmLog( "Could not get session dump from session", 'error' );
        return PE_ERROR;
    }

    # Force SOAP method
    # TODO choose method depending on IDP
    $method = Lasso::Constants::HTTP_METHOD_SOAP;

    # Build Logout Request
    my $logout = $self->createLogoutRequest( $server, $session_dump, $method );
    unless ($logout) {
        $self->lmLog( "Could not create logout request", 'error' );
        return PE_ERROR;
    }

    $self->lmLog( "Logout request created", 'debug' );

    # Keep request ID in memory to prevent replay
    unless ( $self->storeReplayProtection( $logout->request()->ID ) ) {
        $self->lmLog( "Unable to store Logout request ID", 'error' );
        return PE_ERROR;
    }

    # Send request depending on request method
    # HTTP-REDIRECT
    if ( $method == Lasso::Constants::HTTP_METHOD_REDIRECT ) {

        # Redirect user to response URL
        my $slo_url = $logout->msg_url;
        $self->lmLog( "Redirect user to $slo_url", 'debug' );

        $self->{urldc} = $slo_url;

        # Redirect done in Portal/Simple.pm
        return;
    }

    # HTTP-POST
    if ( $method == Lasso::Constants::HTTP_METHOD_POST ) {

        # Use autosubmit form
        my $slo_url  = $logout->msg_url;
        my $slo_body = $logout->msg_body;

        $self->{postUrl} = $slo_url;
        $self->{postFields} = { 'SAMLRequest' => $slo_body };

        # Post done in Portal/Simple.pm
        return;
    }

    # HTTP-SOAP
    if ( $method == Lasso::Constants::HTTP_METHOD_SOAP ) {

        my $slo_url  = $logout->msg_url;
        my $slo_body = $logout->msg_body;

        # Send SOAP request and manage response
        my $response = $self->sendSOAPMessage( $slo_url, $slo_body );

        unless ($response) {
            $self->lmLog( "No logout response to SOAP request", 'error' );
            return PE_ERROR;
        }

        # Create Logout object
        $logout = $self->createLogout($server);

        # Process logout response
        my $result = $self->processLogoutResponseMsg( $logout, $response );

        unless ($result) {
            $self->lmLog( "Fail to process logout response", 'error' );
            return PE_ERROR;
        }

        $self->lmLog( "Logout response is valid", 'debug' );

        # Replay protection
        my $samlID = $logout->response()->InResponseTo;

        unless ( $self->replayProtection($samlID) ) {

            # Logout request was already consumed or is expired
            $self->lmLog( "Message $samlID already used or expired", 'error' );
            return PE_ERROR;
        }

        return;
    }

}

## @apmethod boolean authForce()
# Check if authentication should be forced
# @return nothing
sub authForce {
    my $self = shift;

    my $url = $self->url();

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
    my $saml_slo_get_url =
      $self->getMetaDataURL( "samlSPSSODescriptorSingleLogoutServiceHTTP", 1 );
    my $saml_slo_get_url_ret =
      $self->getMetaDataURL( "samlSPSSODescriptorSingleLogoutServiceHTTP", 2 );

    return 1
      if ( $url =~
/^($saml_acs_art_url|$saml_acs_post_url|$saml_acs_get_url|$saml_slo_soap_url|$saml_slo_soap_url_ret|$saml_slo_get_url|$saml_slo_get_url_ret)$/
      );

    return 0;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::AuthSAML - SAML Authentication backend

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::AuthSAML;

=head1 DESCRIPTION

Use SAML to authenticate users

=head1 SEE ALSO

L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Portal::UserDBSAML>, L<Lemonldap::NG::Portal::_SAML>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>, Clement Oudot, E<lt>coudot@linagora.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
