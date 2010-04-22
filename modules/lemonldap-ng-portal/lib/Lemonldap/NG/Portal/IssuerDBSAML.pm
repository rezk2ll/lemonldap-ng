## @file
# SAML Issuer file

## @class
# SAML Issuer class
package Lemonldap::NG::Portal::IssuerDBSAML;

use strict;
use Lemonldap::NG::Common::Conf::SAML::Metadata;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_SAML;
our @ISA = qw(Lemonldap::NG::Portal::_SAML);

our $VERSION = '0.01';

## @method void issuerDBInit()
# Load and check SAML configuration
# @return Lemonldap::NG::Portal error code
sub issuerDBInit {
    my $self = shift;

    # Load SAML service
    return PE_ERROR unless $self->loadService();

    # Load SAML identity providers
    return PE_ERROR unless $self->loadSPs();

    PE_OK;
}

## @apmethod int issuerForUnAuthUser()
# Check if there is an SAML authentication request
# Called only for unauthenticated users, check isPassive flag
# @return Lemonldap::NG::Portal error code
sub issuerForUnAuthUser {
    my $self   = shift;
    my $server = $self->{_lassoServer};

    # Get configuration parameter
    my $saml_sso_soap_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceSOAP", 1 );
    my $saml_sso_soap_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceSOAP", 2 );
    my $saml_sso_get_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceHTTP", 1 );
    my $saml_sso_get_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceHTTP", 2 );
    my $saml_slo_soap_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceSOAP", 1 );
    my $saml_slo_soap_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceSOAP", 2 );
    my $saml_slo_get_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceHTTP", 1 );
    my $saml_slo_get_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceHTTP", 2 );
    my $saml_ars_url = $self->getMetaDataURL(
        "samlIDPSSODescriptorArtifactResolutionServiceArtifact");

    # Get HTTP request informations to know
    # if we are receving SAML request or response
    my $url            = $self->url();
    my $request_method = $self->request_method();
    my $content_type   = $self->content_type();

    # 1.1. SSO
    if ( $url =~ /^(\Q$saml_sso_soap_url\E|\Q$saml_sso_get_url\E)$/i ) {

        $self->lmLog( "URL $url detected as an SSO request URL", 'debug' );

        # Check message
        my ( $request, $response, $method, $relaystate, $artifact ) =
          $self->checkMessage( $url, $request_method, $content_type );

        # Process the request
        if ($request) {

            # Create Login object
            my $login = $self->createLogin($server);

            # Process authentication request
            my $result;
            if ($artifact) {
                $result = $self->processArtRequestMsg( $login, $request );
            }
            else {
                $result = $self->processAuthnRequestMsg( $login, $request );
            }

            unless ($result) {
                $self->lmLog( "SSO: Fail to process authentication request",
                    'error' );
                return PE_ERROR;
            }

            $self->lmLog( "SSO: authentication request is valid", 'debug' );

            # Get SAML request
            my $saml_request = $login->request();
            unless ($saml_request) {
                $self->lmLog( "No SAML request found", 'error' );
                return PE_ERROR;
            }

            # Check isPassive flag
            my $isPassive = $saml_request->IsPassive();

            if ($isPassive) {
                $self->lmLog(
"Found isPassive flag in SAML request, not compatible with unauthenticated user",
                    'error'
                );
                return PE_ERROR;
            }

        }

    }

    # 1.2. SLO
    if ( $url =~
/^(\Q$saml_slo_soap_url\E|\Q$saml_slo_soap_url_ret\E|\Q$saml_slo_get_url\E|\Q$saml_slo_get_url_ret\E)$/i
      )
    {

        $self->lmLog( "URL $url detected as an SLO URL", 'debug' );

        # Create Logout object
        my $logout = $self->createLogout($server);

        # Check SAML Message
        my ( $request, $response, $method, $relaystate, $artifact ) =
          $self->checkMessage( $url, $request_method, $content_type, "logout" );

        if ($request) {

            # Process logout request
            unless ( $self->processLogoutRequestMsg( $logout, $request ) ) {
                $self->lmLog( "SLO: Fail to process logout request", 'error' );
                return PE_ERROR;
            }

            $self->lmLog( "SLO: Logout request is valid", 'debug' );

            # Get SAML request
            my $saml_request = $logout->request();
            unless ($saml_request) {
                $self->lmLog( "No SAML request found", 'error' );
                return PE_ERROR;
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

            # Send logout response
            return PE_ERROR
              unless ($self->sendLogoutResponseAfterLogoutRequest(
                $logout, $method, $relaystate));

        }

    }

    # 1.3. Artifacts
    if ( $url =~ /^(\Q$saml_ars_url\E)$/i ) {

        $self->lmLog( "URL $url detected as an artifact resolution service URL",
            'debug' );

        # Artifact request are sent with SOAP trough POST
        my $art_request = $self->param('POSTDATA');
        my $art_response;

        # Create Login object
        my $login = $self->createLogin($server);

        # Create artifact response
        unless ( $art_response =
            $self->createArtifactResponse( $login, $art_request ) )
        {
            $self->lmLog( "Unable to create artifact response message",
                'error' );
            return PE_ERROR;
        }

        $self->{SOAPMessage} = $art_response;

        $self->lmLog( "Send SOAP Message: " . $self->{SOAPMessage}, 'debug' );

        # Return SOAP message
        $self->returnSOAPMessage();

        # If we are here, there was a problem with SOAP request
        $self->lmLog( "Artifact response was not sent trough SOAP", 'error' );
        return PE_ERROR;

    }

    PE_OK;
}

## @apmethod int issuerForAuthUser()
# Check if there is an SAML authentication request for an authenticated user
# Build assertions and redirect user
# @return Lemonldap::NG::Portal error code
sub issuerForAuthUser {
    my $self   = shift;
    my $server = $self->{_lassoServer};
    my $login;
    my $protocolProfile;
    my $artifact_method;
    my $authn_context;

    # Session ID
    my $session_id = $self->{sessionInfo}->{_session_id} || $self->{id};

    # Get configuration parameter
    my $saml_sso_soap_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceSOAP", 1 );
    my $saml_sso_soap_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceSOAP", 2 );
    my $saml_sso_get_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceHTTP", 1 );
    my $saml_sso_get_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceHTTP", 2 );
    my $saml_slo_soap_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceSOAP", 1 );
    my $saml_slo_soap_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceSOAP", 2 );
    my $saml_slo_get_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceHTTP", 1 );
    my $saml_slo_get_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceHTTP", 2 );

    # Get HTTP request informations to know
    # if we are receving SAML request or response
    my $url            = $self->url();
    my $request_method = $self->request_method();
    my $content_type   = $self->content_type();

    # 1.1. SSO
    if ( $url =~ /^(\Q$saml_sso_soap_url\E|\Q$saml_sso_get_url\E)$/i ) {

        $self->lmLog( "URL $url detected as an SSO request URL", 'debug' );

        # Check message
        my ( $request, $response, $method, $relaystate, $artifact ) =
          $self->checkMessage( $url, $request_method, $content_type );

        # Process the request
        if ($request) {

            # Create Login object
            $login = $self->createLogin($server);

            # Load Session and Identity if they exist
            my $session  = $self->{sessionInfo}->{_lassoSessionDump};
            my $identity = $self->{sessionInfo}->{_lassoIdentityDump};

            if ($session) {
                unless ( $self->setSessionFromDump( $login, $session ) ) {
                    $self->lmLog( "Unable to load Lasso Session", 'error' );
                    return PE_ERROR;
                }
                $self->lmLog( "Lasso Session loaded", 'debug' );
            }

            if ($identity) {
                unless ( $self->setIdentityFromDump( $login, $identity ) ) {
                    $self->lmLog( "Unable to load Lasso Identity", 'error' );
                    return PE_ERROR;
                }
                $self->lmLog( "Lasso Identity loaded", 'debug' );
            }

            # Process authentication request
            my $result;
            if ($artifact) {
                $result = $self->processArtRequestMsg( $login, $request );
            }
            else {
                $result = $self->processAuthnRequestMsg( $login, $request );
            }

            unless ($result) {
                $self->lmLog( "SSO: Fail to process authentication request",
                    'error' );
                return PE_ERROR;
            }

            # Get EntityID
            my $entityID = $login->request->Issuer->content;

            $self->lmLog( "Request issued from $entityID", 'debug' );

            # Find EntityID in SPList
            unless ( defined $self->{_spList}->{$entityID} ) {
                $self->lmLog( "$entityID do not match any known SP", 'error' );
                return PE_ERROR;
            }

            # Get SP Name from EntityID
            my $sp = $self->{_spList}->{$entityID}->{name};

            $self->lmLog( "Using SP $sp configuration", 'debug' );

            # Validate request
            unless ( $self->validateRequestMsg( $login, 1, 1 ) ) {
                $self->lmLog( "Unable to validate SSO request message",
                    'error' );
                return PE_ERROR;
            }

            $self->lmLog( "SSO: authentication request is valid", 'debug' );

            # TODO Check AuthnRequest conditions

            # Map authenticationLevel with SAML2 authentication context
            my $authenticationLevel =
              $self->{sessionInfo}->{authenticationLevel};

            $authn_context = $self->getAuthnContext("unspecified");
            $authn_context = $self->getAuthnContext("password")
              if ( $authenticationLevel == "2" );
            $authn_context =
              $self->getAuthnContext("password-protected-transport")
              if ( $authenticationLevel == "3" );
            $authn_context = $self->getAuthnContext("tls-client")
              if ( $authenticationLevel == "5" );

            $self->lmLog( "Authentication context is $authn_context", 'debug' );

            # Build Assertion
            unless ( $self->buildAssertion( $login, $authn_context ) ) {
                $self->lmLog( "Unable to build assertion", 'error' );
                return PE_ERROR;
            }

            $self->lmLog( "SSO: assertion is built", 'debug' );

            # Build NameID
            # Default NameID Format
            my $nameIDFormat = $self->getNameIDFormat("email");
            my $nameIDContent;

            # Check NameID Policy in request
            if ( $login->request()->NameIDPolicy ) {
                $nameIDFormat = $login->request()->NameIDPolicy->Format();
            }

            # TODO use options to map format with session vars
            # TODO Take the first value of a multivaluated var ( split ;)
            # TODO support other formats
            $nameIDContent = $self->{sessionInfo}->{mail}
              if ( $nameIDFormat eq $self->getNameIDFormat("email") );

            $login->nameIdentifier->Format($nameIDFormat);
            $login->nameIdentifier->content($nameIDContent) if $nameIDContent;

            $self->lmLog( "NameID Format is $nameIDFormat",   'debug' );
            $self->lmLog( "NameID Content is $nameIDContent", 'debug' );

            # Push mandatory attributes
            my @attributes;

            foreach (
                keys %{ $self->{samlSPMetaDataExportedAttributes}->{$sp} } )
            {

                # Extract fields from exportedAttr value
                my ( $mandatory, $name, $format, $friendly_name ) =
                  split( /;/,
                    $self->{samlSPMetaDataExportedAttributes}->{$sp}->{$_} );

                # Name is required
                next unless $name;

                # Do not send attribute if not mandatory
                unless ($mandatory) {
                    $self->lmLog( "SAML2 attribute $name is not mandatory",
                        'debug' );
                    next;
                }

                # Error if corresponding attribute is not in user session
                my $value = $self->{sessionInfo}->{$_};
                unless ( defined $value ) {
                    $self->lmLog(
"Session key $_ is required to set SAML $name attribute",
                        'error'
                    );
                    return PE_ERROR;
                }

                $self->lmLog(
                    "SAML2 attribute $name will be set with $_ session key",
                    'debug' );

                # SAML2 attribute
                my $attribute;

                eval { $attribute = Lasso::Saml2Attribute->new(); };
                if ($@) {
                    $self->checkLassoError($@);
                    return PE_ERROR;
                }

                # Default values
                $friendly_name ||= $name;
                $format ||= Lasso::Constants::SAML2_ATTRIBUTE_NAME_FORMAT_BASIC;

                # Set attribute properties
                $attribute->Name($name);
                $attribute->NameFormat($format);
                $attribute->FriendlyName($friendly_name);

                # Set attribute value(s)
                my @values = split $self->{multiValuesSeparator}, $value;
                my @saml2values;

                foreach (@values) {

                    # SAML2 attribute value
                    my $saml2value;

                    eval { $saml2value = Lasso::Saml2AttributeValue->new(); };
                    if ($@) {
                        $self->checkLassoError($@);
                        return PE_ERROR;
                    }

                    my @any;

                    my $textNode;
                    eval { $textNode = Lasso::MiscTextNode->new(); };
                    if ($@) {
                        $self->checkLassoError($@);
                        return PE_ERROR;
                    }

                    $textNode->text_child(1);
                    $textNode->content($_);

                    push @any, $textNode;

                    $saml2value->any(@any);

                    push @saml2values, $saml2value;

                    $self->lmLog( "Push $_ in SAML attribute $name", 'debug' );

                }

                $attribute->AttributeValue(@saml2values);

                # Push attribute in attribute list
                push @attributes, $attribute;

            }

            # Create attribute statement
            my $attribute_statement;

            eval {
                $attribute_statement = Lasso::Saml2AttributeStatement->new();
            };
            if ($@) {
                $self->checkLassoError($@);
                return PE_ERROR;
            }

            # Register attributes in attribute statement
            $attribute_statement->Attribute(@attributes);

            # Get response assertion
            my @response_assertions = $login->response->Assertion;

            unless ( $response_assertions[0] ) {
                $self->lmLog( "Unable to get response assertion", 'error' );
                return PE_ERROR;
            }

            # Set subject NameID
            $response_assertions[0]
              ->set_subject_name_id( $login->nameIdentifier );

            # Add attribute statement in response assertion
            my @attributes_statement = ($attribute_statement);
            $response_assertions[0]->AttributeStatement(@attributes_statement);

            # Set response assertion
            $login->response->Assertion(@response_assertions);

            # Build SAML response
            $protocolProfile = $login->protocolProfile();

            # Artifact
            if ( $protocolProfile ==
                Lasso::Constants::LOGIN_PROTOCOL_PROFILE_BRWS_ART )
            {

                # Choose method
                $artifact_method = $self->getHttpMethod("artifact-get")
                  if ( $method == $self->getHttpMethod("redirect") );
                $artifact_method = $self->getHttpMethod("artifact-post")
                  if ( $method == $self->getHttpMethod("post") );

                # Build artifact message
                unless ( $self->buildArtifactMsg( $login, $artifact_method ) ) {
                    $self->lmLog(
                        "Unable to build SSO artifact response message",
                        'error' );
                    return PE_ERROR;
                }

                $self->lmLog( "SSO: artifact response is built", 'debug' );

                # Get artifact ID and Content, and store them
                my $artifact_id      = $login->get_artifact;
                my $artifact_message = $login->get_artifact_message;

                $self->storeArtifact( $artifact_id, $artifact_message,
                    $session_id );
            }

            # No artifact
            else {

                unless ( $self->buildAuthnResponseMsg($login) ) {
                    $self->lmLog( "Unable to build SSO response message",
                        'error' );
                    return PE_ERROR;
                }

                $self->lmLog( "SSO: authentication response is built",
                    'debug' );

            }

            # Save Identity and Session
            if ( $login->is_identity_dirty ) {
                $self->lmLog( "Save Lasso identity in session", 'debug' );
                $self->updateSession(
                    { _lassoIdentityDump => $login->get_identity->dump },
                    $session_id );
            }

            if ( $login->is_session_dirty ) {
                $self->lmLog( "Save Lasso session in session", 'debug' );
                $self->updateSession(
                    { _lassoSessionDump => $login->get_session->dump },
                    $session_id );
            }

            # Send SSO Response

            # HTTP-REDIRECT
            if ( $protocolProfile eq
                Lasso::Constants::LOGIN_PROTOCOL_PROFILE_REDIRECT
                or $artifact_method == $self->getHttpMethod("artifact-get") )
            {

                # Redirect user to response URL
                my $sso_url = $login->msg_url;
                $self->lmLog( "Redirect user to $sso_url", 'debug' );

                $self->{urldc} = $sso_url;

                $self->_subProcess(qw(autoRedirect));

                # If we are here, there was a problem with GET request
                $self->lmLog( "SSO response was not sent trough GET", 'error' );
                return PE_ERROR;
            }

            # HTTP-POST
            if ( $protocolProfile eq
                Lasso::Constants::LOGIN_PROTOCOL_PROFILE_BRWS_POST
                or $artifact_method == $self->getHttpMethod("artifact-post") )
            {

                # Use autosubmit form
                my $sso_url  = $login->msg_url;
                my $sso_body = $login->msg_body;

                $self->{postUrl} = $sso_url;
                $self->{postFields} = { 'SAMLResponse' => $sso_body };

                # RelayState
                $self->{postFields}->{'RelayState'} = $login->msg_relayState
                  if ( $login->msg_relayState );

                $self->_subProcess(qw(autoPost));

                # If we are here, there was a problem with POST request
                $self->lmLog( "SSO response was not sent trough POST",
                    'error' );
                return PE_ERROR;
            }

        }

        elsif ($response) {
            $self->lmLog(
                "Authentication responses are not managed by this module",
                'debug' );
            return PE_OK;
        }

        else {

            # No request or response
            # This should not happen
            $self->lmLog( "No request or response found", 'debug' );
            return PE_OK;
        }

    }

    # 1.2. SLO
    if ( $url =~
/^(\Q$saml_slo_soap_url\E|\Q$saml_slo_soap_url_ret\E|\Q$saml_slo_get_url\E|\Q$saml_slo_get_url_ret\E)$/i
      )
    {

        $self->lmLog( "URL $url detected as an SLO URL", 'debug' );

        # Create Logout object
        my $logout = $self->createLogout($server);

        # Check SAML Message
        my ( $request, $response, $method, $relaystate, $artifact ) =
          $self->checkMessage( $url, $request_method, $content_type, "logout" );

        if ($request) {

            my $logout_error = 0;

            # Load Session and Identity if they exist
            my $session  = $self->{sessionInfo}->{_lassoSessionDump};
            my $identity = $self->{sessionInfo}->{_lassoIdentityDump};

            if ($session) {
                unless ( $self->setSessionFromDump( $logout, $session ) ) {
                    $self->lmLog( "Unable to load Lasso Session", 'error' );
                    return PE_ERROR;
                }
                $self->lmLog( "Lasso Session loaded", 'debug' );
            }

            if ($identity) {
                unless ( $self->setIdentityFromDump( $logout, $identity ) ) {
                    $self->lmLog( "Unable to load Lasso Identity", 'error' );
                    return PE_ERROR;
                }
                $self->lmLog( "Lasso Identity loaded", 'debug' );
            }

            # Process logout request
            unless ( $self->processLogoutRequestMsg( $logout, $request ) ) {
                $self->lmLog( "SLO: Fail to process logout request", 'error' );
                return PE_ERROR;
            }

            $self->lmLog( "SLO: Logout request is valid", 'debug' );

            $self->sendLogoutRequestToServiceProviders($logout);

            # Validate request if no previous error
            unless ( $self->validateLogoutRequest($logout) ) {
                $self->lmLog( "SLO request is not valid", 'error' );
                $logout_error = 1;
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

            # Delete Session
            if (!$logout_error) {
            my $user = $self->{sessionInfo}->{user};
                my $local_session =  $self->getApacheSession($session_id, 1);
                unless ( $self->_deleteSession($local_session) ) {
                $self->lmLog( "Fail to delete session $session_id for user $user",
                  'debug' );
            }
            }

            $self->lmLog( "Send logout response", 'debug' );

            # Send logout response
            return PE_ERROR
              unless ($self->sendLogoutResponseAfterLogoutRequest(
                $logout, $method, $relaystate));

        }

    }

    return PE_OK;
}

## @apmethod int issuerLogout()
# TODO
# @return Lemonldap::NG::Portal error code
sub issuerLogout {
    my $self = shift;

    print STDERR "IssuerDBSAML: issuerLogout\n";

    PE_OK;
}

## @pmethod int sendLogoutResponseAfterLogoutRequest(Lasso::Logout $logout,
#  int $method string $relaystate)
# Send logout response issue from a logout request.
# @param $logout Lasso Logout object
# @param $method Method to use
# @param $relaystate The relay state
# @return boolean False if failed.
sub sendLogoutResponseAfterLogoutRequest {
    my $self = shift;
    my $logout = shift;
    my $method = shift;
    my $relaystate = shift;

    # Send response depending on request method
    # HTTP-REDIRECT
    if ( $method == Lasso::Constants::HTTP_METHOD_REDIRECT ) {

        # Redirect user to response URL
        my $slo_url = $logout->msg_url;
        $self->lmLog( "Redirect user to $slo_url", 'debug' );

        $self->{urldc} = $slo_url;

        $self->_subProcess(qw(autoRedirect));

        # If we are here, there was a problem with GET request
        $self->lmLog( "Logout response was not sent trough GET", 'error' );

        return 0;
    }

    # HTTP-POST
    if ( $method == Lasso::Constants::HTTP_METHOD_POST ) {

        # Use autosubmit form
        my $slo_url  = $logout->msg_url;
        my $slo_body = $logout->msg_body;

        $self->{postUrl} = $slo_url;
        $self->{postFields} = { 'SAMLResponse' => $slo_body };

        # RelayState
        $self->{postFields}->{'RelayState'} = $relaystate
          if ($relaystate);

        $self->_subProcess(qw(autoPost));

        # If we are here, there was a problem with POST response
        $self->lmLog( "Logout response was not sent trough POST", 'error' );

        return 0;
    }

    # HTTP-SOAP
    if ( $method == Lasso::Constants::HTTP_METHOD_SOAP ) {

        my $slo_body = $logout->msg_body;

        $self->lmLog( "SOAP response $slo_body", 'debug' );

        $self->{SOAPMessage} = $slo_body;

        $self->_subProcess(qw(returnSOAPMessage));

        # If we are here, there was a problem with SOAP response
        $self->lmLog( "Logout response was not sent trough SOAP",  'error' );

        return 0;
    }

    return 1;
}

sub sendLogoutRequestToServiceProviders {
    my $self = shift;
    my $logout = shift;
    my $server = $self->{_lassoServer};

    # Get EntityID
    my $entityID = $logout->request->Issuer->content;

    # Reset providerID into Lasso::Logout object
    $self->resetProviderIdIndex($logout);

    # Page header
    print $self->header();
    print $self->start_html();
    print '<ul>';

    # Foreach SP found in session, get it from configuration, and send the
    # appropriate logout request (HTTP,POST,SOAP).
    while ( my $providerID = $self->getNextProviderId($logout) ) {

        # Do not process logout on SP that initiate the logout request
        next if ($entityID =~ /^$providerID$/);

        # Find EntityID in SPList
        unless ( defined $self->{_spList}->{$providerID} ) {
            $self->lmLog( "$entityID does not match any known SP", 'error' );
            return PE_ERROR;
        }

        # Get first HTTP method
        my $protocolType = Lasso::Constants::MD_PROTOCOL_TYPE_SINGLE_LOGOUT;
        my $method =
          $self->getFirstHttpMethod( $server, $providerID, $protocolType );

        # Initiate the logout request
        unless ( $self->initLogoutRequest( $logout, $providerID, $method ) )
        {
            $self->lmLog( "Initiate logout request failed for $providerID",
              'error' );
            next;
        }

        # Build request message
        unless ( $self->buildLogoutRequestMsg( $logout ) )
        {
            $self->lmLog( "Build logout request failed for $providerID",
              'error' );
            next;
        }

        # Send logout request to the provider depending of the request method
        # HTTP-REDIRECT
        if ( $method == Lasso::Constants::HTTP_METHOD_REDIRECT ) {

            # Redirect user to response URL
            my $slo_url = $logout->msg_url;

            print '<li>' . $providerID . '...'
                . '<iframe src="' . $slo_url . '" alt="" marginwidth="0"'
                . 'marginheight="0" scrolling="no" style="border: none"'
                . ' width="12" height="12">'
                . '<img src="' . $slo_url . '" width="12" height="12"></img>'
                . '</iframe></li>';
        }

        # HTTP-POST
        if ( $method == Lasso::Constants::HTTP_METHOD_POST ) {

            # Use autosubmit form
            my $slo_url  = $logout->msg_url;
            my $slo_body = $logout->msg_body;

            #$self->{postUrl} = $slo_url;
            #$self->{postFields} = { 'SAMLResponse' => $slo_body };

            # RelayState
            #$self->{postFields}->{'RelayState'} = $relaystate
              #if ($relaystate);

            $self->lmLog( "POST method not yet available", 'debug' );

        }

        # HTTP-SOAP
        if ( $method == Lasso::Constants::HTTP_METHOD_SOAP ) {

            my $slo_url  = $logout->msg_url;
            my $slo_body = $logout->msg_body;

            # Send SOAP request and manage response
            my $sp_response = $self->sendSOAPMessage( $slo_url, $slo_body );

            unless ($sp_response) {
                $self->lmLog( "No logout response to SOAP request", 'error' );
                next;
            }

            # Create Logout object
            my $sp_logout = $self->createLogout($server);

            # Process logout response
            my $sp_result =
              $self->processLogoutResponseMsg( $sp_logout, $sp_response );

            unless ($sp_result) {
                $self->lmLog( "Fail to process logout response", 'error' );
                next;
            }

            $self->lmLog( "Logout response is valid", 'debug' );

            # Replay protection
            my $samlID = $sp_logout->response()->InResponseTo;

            unless ( $self->replayProtection($samlID) ) {

                # Logout request was already consumed or is expired
                $self->lmLog( "Message $samlID already used or expired", 'error' );
                next;
            }

        }

    }

    # End page
    print '</ul>';
    print $self->end_html();

}    

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::IssuerDBSAML - SAML IssuerDB for LemonLDAP::NG

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::SharedConf;

  my $portal = Lemonldap::NG::Portal::SharedConf->new({
      issuerDB => SAML,
  });

=head1 DESCRIPTION

SAML IssuerDB for LemonLDAP::NG

=head1 SEE ALSO

L<Lemonldap::NG::Portal>

=head1 AUTHOR

Clément Oudot, E<lt>coudot@linagora.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Clément Oudot

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
