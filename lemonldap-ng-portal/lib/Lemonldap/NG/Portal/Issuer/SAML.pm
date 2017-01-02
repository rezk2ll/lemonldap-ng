package Lemonldap::NG::Portal::Issuer::SAML;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_INFO
  PE_OK
  PE_SAML_ART_ERROR
  PE_SAML_DESTINATION_ERROR
  PE_SAML_SESSION_ERROR
  PE_SAML_SIGNATURE_ERROR
  PE_SAML_SLO_ERROR
  PE_SAML_SSO_ERROR
  PE_SAML_UNKNOWN_ENTITY
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Issuer',
  'Lemonldap::NG::Portal::Lib::SAML';

has ssoUrlRe => ( is => 'rw' );

# INITIALIZATION

sub init {
    my ($self) = @_;

    # Prepare SSO URL catching
    my $saml_sso_soap_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceSOAP", 1 );
    my $saml_sso_soap_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceSOAP", 2 );
    my $saml_sso_get_url = $self->getMetaDataURL(
        "samlIDPSSODescriptorSingleSignOnServiceHTTPRedirect", 1 );
    my $saml_sso_get_url_ret = $self->getMetaDataURL(
        "samlIDPSSODescriptorSingleSignOnServiceHTTPRedirect", 2 );
    my $saml_sso_post_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceHTTPPost",
        1 );
    my $saml_sso_post_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceHTTPPost",
        2 );
    my $saml_sso_art_url = $self->getMetaDataURL(
        "samlIDPSSODescriptorSingleSignOnServiceHTTPArtifact", 1 );
    my $saml_sso_art_url_ret = $self->getMetaDataURL(
        "samlIDPSSODescriptorSingleSignOnServiceHTTPArtifact", 2 );
    $self->ssoUrlRe(
qr/^($saml_sso_soap_url|$saml_sso_soap_url_ret|$saml_sso_get_url|$saml_sso_get_url_ret|$saml_sso_post_url|$saml_sso_post_url_ret|$saml_sso_art_url|$saml_sso_art_url_ret)(?:\?.*)?$/i
    );

    # Launch parents initialization subroutines, then launch IdP en SP lists
    my $res = (
        $self->Lemonldap::NG::Portal::Main::Issuer::init()

          # Load SAML service
          and $self->Lemonldap::NG::Portal::Lib::SAML::init()

          # Load SAML service providers
          and $self->loadSPs()

          # Load SAML identity providers
          # Required to manage SLO in Proxy mode
          and $self->loadIDPs()
    );

    # Single logout routes
    $self->addUnauthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceSOAP",
        1, 'sloServer', ['POST'] );
    $self->addUnauthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceSOAP",
        2, 'sloServer', ['POST'] );
    $self->addUnauthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceHTTPRedirect",
        1, 'sloServer', ['GET'] );
    $self->addUnauthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceHTTPRedirect",
        2, 'sloServer', ['GET'] );
    $self->addUnauthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceHTTPPost",
        1, 'sloServer', ['POST'] );
    $self->addUnauthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceHTTPPost",
        2, 'sloServer', ['POST'] );

    $self->addAuthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceSOAP",
        1, 'authSloServer', ['POST'] );
    $self->addAuthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceSOAP",
        2, 'authSloServer', ['POST'] );
    $self->addAuthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceHTTPRedirect",
        1, 'authSloServer', ['GET'] );
    $self->addAuthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceHTTPRedirect",
        2, 'authSloServer', ['GET'] );
    $self->addAuthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceHTTPPost",
        1, 'authSloServer', ['POST'] );
    $self->addAuthRouteFromMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceHTTPPost",
        2, 'authSloServer', ['POST'] );

    # SOAP routes (access without authentication)
    $self->addRouteFromMetaDataURL(
        'samlIDPSSODescriptorArtifactResolutionServiceArtifact',
        3, 'artifactServer', ['POST'] );
    $self->addRouteFromMetaDataURL(
        'samlAttributeAuthorityDescriptorAttributeServiceSOAP',
        1, 'attributeServer', ['POST'] );

    # TODO: @coudot, why this URL isn't managed with a conf param ?
    $self->addUnauthRoute(
        $self->path => { relaySingleLogoutSOAP => 'sloRelaySoap' },
        [ 'GET', 'POST' ]
    );
    $self->addAuthRoute(
        $self->path => { relaySingleLogoutPOST => 'sloRelayPost' },
        [ 'GET', 'POST' ]
    );
    $self->addUnauthRoute(
        $self->path => { relaySingleLogoutPOST => 'sloRelayPost' },
        [ 'GET', 'POST' ]
    );
    return $res;
}

# RUNNING METHODS

# Main method (launched only for authenticated users, see Main/Issuer)
sub run {
    my ( $self, $req ) = @_;
    my $login;
    my $protocolProfile;
    my $artifact_method;
    my $authn_context;

    # Session ID
    my $session_id = $req->{sessionInfo}->{_session_id} || $req->{id};

    # Session creation timestamp
    my $time = $req->{sessionInfo}->{_utime} || time();

    # Get HTTP request information to know
    # if we are receving SAML request or response
    my $url                     = $req->uri;
    my $request_method          = $req->param('issuerMethod') || $req->method;
    my $content_type            = $req->contentType();
    my $idp_initiated           = $req->param('IDPInitiated');
    my $idp_initiated_sp        = $req->param('sp');
    my $idp_initiated_spConfKey = $req->param('spConfKey');

    # 1.1. SSO (SSO URL or Proxy Mode)
    if ( $url =~ $self->ssoUrlRe or $req->datas->{_proxiedRequest} ) {

        $self->lmLog( "URL $url detected as an SSO request URL", 'debug' );

        # Check message
        my ( $request, $response, $method, $relaystate, $artifact ) =
          $self->checkMessage( $req, $url, $request_method, $content_type );

        # Create Login object
        my $login = $self->createLogin( $self->lassoServer );

        # Ignore signature verification
        $self->disableSignatureVerification($login);

        # Process the request or use IDP initiated mode
        if ( $request or $idp_initiated ) {

            # Load Session and Identity if they exist
            my $session  = $req->{sessionInfo}->{_lassoSessionDump};
            my $identity = $req->{sessionInfo}->{_lassoIdentityDump};

            if ($session) {
                unless ( $self->setSessionFromDump( $login, $session ) ) {
                    $self->lmLog( "Unable to load Lasso Session", 'error' );
                    return PE_SAML_SSO_ERROR;
                }
                $self->lmLog( "Lasso Session loaded", 'debug' );
            }

            if ($identity) {
                unless ( $self->setIdentityFromDump( $login, $identity ) ) {
                    $self->lmLog( "Unable to load Lasso Identity", 'error' );
                    return PE_SAML_SSO_ERROR;
                }
                $self->lmLog( "Lasso Identity loaded", 'debug' );
            }

            my $result;

            # Create fake request if IDP initiated mode
            if ($idp_initiated) {

                # Need sp or spConfKey parameter
                unless ( $idp_initiated_sp or $idp_initiated_spConfKey ) {
                    $self->lmLog(
"sp or spConfKey parameter needed to make IDP initiated SSO",
                        'error'
                    );
                    return PE_SAML_SSO_ERROR;
                }

                unless ($idp_initiated_sp) {

                    # Get SP from spConfKey
                    foreach ( keys %{ $self->spList } ) {
                        if ( $self->spList->{$_}->{confKey} eq
                            $idp_initiated_spConfKey )
                        {
                            $idp_initiated_sp = $_;
                            last;
                        }
                    }
                }
                else {
                    unless ( defined $self->spList->{$idp_initiated_sp} ) {
                        $self->lmLog( "SP $idp_initiated_sp not known",
                            'error' );
                        return PE_SAML_UNKNOWN_ENTITY;
                    }
                    $idp_initiated_spConfKey =
                      $self->spList->{$idp_initiated_sp}->{confKey};
                }

                # Check if IDP Initiated SSO is allowed
                unless ( $self->conf->{samlSPMetaDataOptions}
                    ->{$idp_initiated_spConfKey}
                    ->{samlSPMetaDataOptionsEnableIDPInitiatedURL} )
                {
                    $self->lmLog(
"IDP Initiated SSO not allowed for SP $idp_initiated_spConfKey",
                        'error'
                    );
                    return PE_SAML_SSO_ERROR;
                }

                $result =
                  $self->initIdpInitiatedAuthnRequest( $login,
                    $idp_initiated_sp );
                unless ($result) {
                    $self->lmLog(
"SSO: Fail to init IDP Initiated authentication request",
                        'error'
                    );
                    return PE_SAML_SSO_ERROR;
                }

                # Force NameID Format
                my $nameIDFormatKey =
                  $self->conf->{samlSPMetaDataOptions}
                  ->{$idp_initiated_spConfKey}
                  ->{samlSPMetaDataOptionsNameIDFormat} || "email";
                eval {
                    $login->request()->NameIDPolicy()
                      ->Format( $self->getNameIDFormat($nameIDFormatKey) );
                };

                # Force AllowCreate to TRUE
                eval { $login->request()->NameIDPolicy()->AllowCreate(1); };
            }

            # Process authentication request
            if ($artifact) {
                $result = $self->processArtResponseMsg( $login, $request );
            }
            else {
                $result = $self->processAuthnRequestMsg( $login, $request );
            }

            unless ($result) {
                $self->lmLog( "SSO: Fail to process authentication request",
                    'error' );
                return PE_SAML_SSO_ERROR;
            }

            # Get SP entityID
            my $sp = $request ? $login->remote_providerID() : $idp_initiated_sp;

            $self->lmLog( "Found entityID $sp in SAML message", 'debug' );

            # SP conf key
            my $spConfKey = $self->spList->{$sp}->{confKey};

            unless ($spConfKey) {
                $self->lmLog( "$sp do not match any SP in configuration",
                    'error' );
                return PE_SAML_UNKNOWN_ENTITY;
            }

            $self->lmLog( "$sp match $spConfKey SP in configuration", 'debug' );

            # Do we check signature?
            my $checkSSOMessageSignature =
              $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
              ->{samlSPMetaDataOptionsCheckSSOMessageSignature};

            if ($checkSSOMessageSignature) {

                $self->forceSignatureVerification($login);

                if ($artifact) {
                    $result = $self->processArtResponseMsg( $login, $request );
                }
                else {
                    $result = $self->processAuthnRequestMsg( $login, $request );
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

            # Validate request
            unless ( $self->validateRequestMsg( $login, 1, 1 ) ) {
                $self->lmLog( "Unable to validate SSO request message",
                    'error' );
                return PE_SAML_SSO_ERROR;
            }

            $self->lmLog( "SSO: authentication request is valid", 'debug' );

            # Get ForceAuthn flag
            my $force_authn;

            eval { $force_authn = $login->request()->ForceAuthn(); };
            if ($@) {
                $self->lmLog( "Unable to get ForceAuthn flag, set it to false",
                    'warn' );
                $force_authn = 0;
            }

            $self->lmLog( "Found ForceAuthn flag with value $force_authn",
                'debug' );

            # Get ForceAuthn sessions for this session_id
            my $moduleOptions = $self->conf->{samlStorageOptions} || {};
            $moduleOptions->{backend} = $self->conf->{samlStorage};
            my $module = "Lemonldap::NG::Common::Apache::Session";

            my $forceAuthn_sessions =
              $module->searchOn( $moduleOptions, "_saml_id", $session_id );

            my $forceAuthn_session;
            my $forceAuthnSessionInfo;

            if (
                my @forceAuthn_sessions_keys =
                keys %$forceAuthn_sessions
              )
            {

                # Warning if more than one session found
                if ( $#forceAuthn_sessions_keys > 0 ) {
                    $self->lmLog(
"More than one ForceAuthn session found for session $session_id",
                        'warn'
                    );
                }

                # Take the first session
                $forceAuthn_session = shift @forceAuthn_sessions_keys;

                # Get session
                $self->lmLog(
"Retrieve ForceAuthn session $forceAuthn_session for session $session_id",
                    'debug'
                );

                $forceAuthnSessionInfo =
                  $self->getSamlSession($forceAuthn_session);

                # Check forceAuthn flag for current SP
                if ( $forceAuthnSessionInfo->data->{$spConfKey} ) {

                    $self->lmLog(
"User was already forced to reauthenticate for SP $spConfKey",
                        'debug'
                    );
                    $force_authn = 1;
                }
            }
            else {
                $self->lmLog(
                    "No ForceAuthn session found for session $session_id",
                    'debug' );
            }

            # Force authentication if flag is on, or previous flag still active
            if ($force_authn) {

                # Store flag for further requests
                $forceAuthnSessionInfo =
                  $self->getSamlSession($forceAuthn_session);
                $forceAuthnSessionInfo->update( { $spConfKey => 1 } );

                unless ($forceAuthn_session) {
                    my $forceInfos;
                    $forceInfos->{'_type'}    = "forceAuthn";
                    $forceInfos->{'_saml_id'} = $session_id;
                    $forceInfos->{'_utime'}   = $time;
                    $forceAuthnSessionInfo->update($forceInfos);
                    $forceAuthn_session = $forceAuthnSessionInfo->id;
                    $self->lmLog(
                        "Create ForceAuthn session $forceAuthn_session",
                        'debug' );
                }

                $self->lmLog(
"Set ForceAuthn flag for SP $spConfKey in ForceAuthn session $forceAuthn_session",
                    'debug'
                );

                # Replay authentication process
                $req->{updateSession} = 1;
                die 'TODO: recall';

               #$self->{error}         = $self->_subProcess(
               #    qw(issuerDBInit authInit issuerForUnAuthUser extractFormInfo
               #      userDBInit getUser setAuthSessionInfo setSessionInfo
               #      setMacros setGroups setPersistentSessionInfo
               #      setLocalGroups authenticate store authFinish)
               #);

                # Return error if any
                #return $self->{error} if $self->{error} > 0;

                # Else remove flag
                $forceAuthnSessionInfo =
                  $self->getSamlSession($forceAuthn_session);
                $forceAuthnSessionInfo->update( { $spConfKey => 0 } );

                $self->lmLog(
"Unset ForceAuthn flag for SP $spConfKey in ForceAuthn session $forceAuthn_session",
                    'debug'
                );
            }

            # Check Destination (only in non proxy mode)
            unless ( $req->datas->{_proxiedRequest} ) {
                return PE_SAML_DESTINATION_ERROR
                  unless ( $self->checkDestination( $login->request, $url ) );
            }

            # Map authenticationLevel with SAML2 authentication context
            my $authenticationLevel =
              $req->{sessionInfo}->{authenticationLevel};

            $authn_context =
              $self->authnLevel2authnContext($authenticationLevel);

            $self->lmLog( "Authentication context is $authn_context", 'debug' );

            # Get SP options notOnOrAfterTimeout
            my $notOnOrAfterTimeout =
              $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
              ->{samlSPMetaDataOptionsNotOnOrAfterTimeout};

            # Build Assertion
            unless (
                $self->buildAssertion(
                    $req, $login, $authn_context, $notOnOrAfterTimeout
                )
              )
            {
                $self->lmLog( "Unable to build assertion", 'error' );
                return PE_SAML_SSO_ERROR;
            }

            $self->lmLog( "SSO: assertion is built", 'debug' );

            # Get default NameID Format from configuration
            # Set to "email" if no value in configuration
            my $nameIDFormatKey =
              $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
              ->{samlSPMetaDataOptionsNameIDFormat} || "email";
            my $nameIDFormat;

            # Check NameID Policy in request
            if ( $login->request()->NameIDPolicy ) {
                $nameIDFormat = $login->request()->NameIDPolicy->Format();
                $self->lmLog( "Get NameID format $nameIDFormat from request",
                    'debug' );
            }

            # NameID unspecified is forced to default NameID format
            if (  !$nameIDFormat
                or $nameIDFormat eq $self->getNameIDFormat("unspecified") )
            {
                $nameIDFormat = $self->getNameIDFormat($nameIDFormatKey);
            }

            # Get session key associated with NameIDFormat
            # Not for unspecified, transient, persistent, entity, encrypted
            my $nameIDFormatConfiguration = {
                $self->getNameIDFormat("email") => 'samlNameIDFormatMapEmail',
                $self->getNameIDFormat("x509")  => 'samlNameIDFormatMapX509',
                $self->getNameIDFormat("windows") =>
                  'samlNameIDFormatMapWindows',
                $self->getNameIDFormat("kerberos") =>
                  'samlNameIDFormatMapKerberos',
            };

            my $nameIDSessionKey =
              $self->conf->{ $nameIDFormatConfiguration->{$nameIDFormat} };

            # Override default NameID Mapping
            if ( $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
                ->{samlSPMetaDataOptionsNameIDSessionKey} )
            {
                $nameIDSessionKey =
                  $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
                  ->{samlSPMetaDataOptionsNameIDSessionKey};
            }

            my $nameIDContent;
            if ( defined $req->{sessionInfo}->{$nameIDSessionKey} ) {
                $nameIDContent =
                  $self->p->getFirstValue(
                    $req->{sessionInfo}->{$nameIDSessionKey} );
            }

            # Manage Entity NameID format
            if ( $nameIDFormat eq $self->getNameIDFormat("entity") ) {
                $nameIDContent = $self->getMetaDataURL( "samlEntityID", 0, 1 );
            }

            # Manage Transient NameID format
            if ( $nameIDFormat eq $self->getNameIDFormat("transient") ) {
                eval {
                    my @assert = $login->response->Assertion;
                    $nameIDContent = $assert[0]->Subject->NameID->content;
                };
            }

            if ( $login->nameIdentifier ) {
                $login->nameIdentifier->Format($nameIDFormat);
                $login->nameIdentifier->content($nameIDContent)
                  if $nameIDContent;
            }
            else {
                my $nameIdentifier = Lasso::Saml2NameID->new();
                $nameIdentifier->Format($nameIDFormat);
                $nameIdentifier->content($nameIDContent)
                  if $nameIDContent;
                $login->nameIdentifier($nameIdentifier);
            }

            $self->lmLog( "NameID Format is " . $login->nameIdentifier->Format,
                'debug' );
            $self->lmLog(
                "NameID Content is " . $login->nameIdentifier->content,
                'debug' );

            # Push mandatory attributes
            my @attributes;

            foreach (
                keys %{
                    $self->conf->{samlSPMetaDataExportedAttributes}
                      ->{$spConfKey}
                }
              )
            {

                # Extract fields from exportedAttr value
                my ( $mandatory, $name, $format, $friendly_name ) =
                  split( /;/,
                    $self->conf->{samlSPMetaDataExportedAttributes}
                      ->{$spConfKey}->{$_} );

                # Name is required
                next unless $name;

                # Do not send attribute if not mandatory
                unless ($mandatory) {
                    $self->lmLog( "SAML2 attribute $name is not mandatory",
                        'debug' );
                    next;
                }

                # Error if corresponding attribute is not in user session
                my $value = $req->{sessionInfo}->{$_};
                unless ( defined $value ) {
                    $self->lmLog(
"Session key $_ is required to set SAML $name attribute",
                        'error'
                    );
                    return PE_SAML_SSO_ERROR;
                }

                $self->lmLog(
                    "SAML2 attribute $name will be set with $_ session key",
                    'debug' );

                # SAML2 attribute
                my $attribute =
                  $self->createAttribute( $name, $format, $friendly_name );

                unless ($attribute) {
                    $self->lmLog( "Unable to create a new SAML attribute",
                        'error' );
                    return PE_SAML_SSO_ERROR;
                }

                # Set attribute value(s)
                my @values = split $self->conf->{multiValuesSeparator}, $value;
                my @saml2values;

                foreach (@values) {

                    # SAML2 attribute value
                    my $saml2value = $self->createAttributeValue( $_,
                        $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
                          ->{samlSPMetaDataOptionsForceUTF8} );

                    unless ($saml2value) {
                        $self->lmLog(
                            "Unable to create a new SAML attribute value",
                            'error' );
                        $self->checkLassoError($@);
                        return PE_SAML_SSO_ERROR;
                    }

                    push @saml2values, $saml2value;

                    $self->lmLog( "Push $_ in SAML attribute $name", 'debug' );

                }

                $attribute->AttributeValue(@saml2values);

                # Push attribute in attribute list
                push @attributes, $attribute;

            }

            # Get response assertion
            my @response_assertions = $login->response->Assertion;

            unless ( $response_assertions[0] ) {
                $self->lmLog( "Unable to get response assertion", 'error' );
                return PE_SAML_SSO_ERROR;
            }

            # Set subject NameID
            $response_assertions[0]
              ->set_subject_name_id( $login->nameIdentifier );

            # Set basic conditions
            my $oneTimeUse = $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
              ->{samlSPMetaDataOptionsOneTimeUse} // 0;

            my $conditionNotOnOrAfter = $notOnOrAfterTimeout || "86400";
            eval {
                $response_assertions[0]
                  ->set_basic_conditions( 60, $conditionNotOnOrAfter,
                    $oneTimeUse );
            };
            if ($@) {
                $self->lmLog( "Basic conditions not set: $@", 'debug' );
            }

            # Create attribute statement
            if ( scalar @attributes ) {

                my $attribute_statement;

                eval {
                    $attribute_statement =
                      Lasso::Saml2AttributeStatement->new();
                };
                if ($@) {
                    $self->checkLassoError($@);
                    return PE_SAML_SSO_ERROR;
                }

                # Register attributes in attribute statement
                $attribute_statement->Attribute(@attributes);

                # Add attribute statement in response assertion
                my @attributes_statement = ($attribute_statement);
                $response_assertions[0]
                  ->AttributeStatement(@attributes_statement);
            }

            # Get AuthnStatement
            my @authn_statements = $response_assertions[0]->AuthnStatement();

            # Set sessionIndex
            # sessionIndex is the encrypted session_id
            my $sessionIndex = $self->conf->{cipher}->encrypt($session_id);
            $authn_statements[0]->SessionIndex($sessionIndex);

            $self->lmLog(
                "Set sessionIndex $sessionIndex (encrypted from $session_id)",
                'debug' );

            # Set SessionNotOnOrAfter
            my $sessionNotOnOrAfterTimeout =
              $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
              ->{samlSPMetaDataOptionsSessionNotOnOrAfterTimeout};
            $sessionNotOnOrAfterTimeout ||= $self->conf->{timeout};
            my $timeout             = $time + $sessionNotOnOrAfterTimeout;
            my $sessionNotOnOrAfter = $self->timestamp2samldate($timeout);
            $authn_statements[0]->SessionNotOnOrAfter($sessionNotOnOrAfter);

            $self->lmLog( "Set sessionNotOnOrAfter $sessionNotOnOrAfter",
                'debug' );

            # Register AuthnStatement in assertion
            $response_assertions[0]->AuthnStatement(@authn_statements);

            # Set response assertion
            $login->response->Assertion(@response_assertions);

            # Signature
            my $signSSOMessage =
              $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
              ->{samlSPMetaDataOptionsSignSSOMessage} // -1;

            if ( $signSSOMessage == 0 ) {
                $self->lmLog( "SSO response will not be signed", 'debug' );
                $self->disableSignature($login);
            }
            elsif ( $signSSOMessage == 1 ) {
                $self->lmLog( "SSO response will be signed", 'debug' );
                $self->forceSignature($login);
            }
            else {
                $self->lmLog( "SSO response signature according to metadata",
                    'debug' );
            }

            # log that a SAML authn response is build
            my $user      = $req->{sessionInfo}->{ $self->conf->{whatToTrace} };
            my $nameIDLog = '';
            foreach my $format (qw(persistent transient)) {
                if ( $login->nameIdentifier->Format eq
                    $self->getNameIDFormat($format) )
                {
                    $nameIDLog =
                      " with $format NameID " . $login->nameIdentifier->content;
                    last;
                }
            }
            $self->p->userNotice(
"SAML authentication response sent to SAML SP $spConfKey for $user$nameIDLog"
            );

            # Build SAML response
            $protocolProfile = $login->protocolProfile();

            # Artifact
            # Choose method
            if (   $artifact
                or $protocolProfile ==
                Lasso::Constants::LOGIN_PROTOCOL_PROFILE_BRWS_ART )
            {
                $artifact = 1;
                if (   $method == $self->getHttpMethod("post")
                    || $method == $self->getHttpMethod("artifact-post") )
                {
                    $artifact_method = $self->getHttpMethod("artifact-post")

                }
                else {
                    $artifact_method = $self->getHttpMethod("artifact-get");
                }
            }

            no strict 'subs';
            if ( $protocolProfile ==
                Lasso::Constants::LOGIN_PROTOCOL_PROFILE_BRWS_ART )
            {

                # Build artifact message
                unless ( $self->buildArtifactMsg( $login, $artifact_method ) ) {
                    $self->lmLog(
                        "Unable to build SSO artifact response message",
                        'error' );
                    return PE_SAML_ART_ERROR;
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
                    return PE_SAML_SSO_ERROR;
                }

                $self->lmLog( "SSO: authentication response is built",
                    'debug' );

            }

            # Save Identity and Session
            if ( $login->is_identity_dirty ) {

                # Update session
                $self->lmLog( "Save Lasso identity in session", 'debug' );
                $self->updatePersistentSession(
                    { _lassoIdentityDump => $login->get_identity->dump },
                    undef, $session_id );
            }

            if ( $login->is_session_dirty ) {
                $self->lmLog( "Save Lasso session in session", 'debug' );
                $self->p->updateSession( $req,
                    { _lassoSessionDump => $login->get_session->dump },
                    $session_id );
            }

            # Keep SAML elements for later queries
            my $nameid = $login->nameIdentifier;

            $self->lmLog(
                "Store NameID "
                  . $nameid->dump
                  . " and SessionIndex $sessionIndex for session $session_id",
                'debug'
            );

            my $samlSessionInfo = $self->getSamlSession();

            return PE_SAML_SESSION_ERROR unless $samlSessionInfo;

            my $infos;

            $infos->{type}          = 'saml';           # Session type
            $infos->{_utime}        = $time;            # Creation time
            $infos->{_saml_id}      = $session_id;      # SSO session id
            $infos->{_nameID}       = $nameid->dump;    # SAML NameID
            $infos->{_sessionIndex} = $sessionIndex;    # SAML SessionIndex

            $samlSessionInfo->update($infos);

            my $saml_session_id = $samlSessionInfo->id;

            $self->lmLog(
                "Link session $session_id to SAML session $saml_session_id",
                'debug' );

            # Send SSO Response

            # Register IDP in Common Domain Cookie if needed
            if (    $self->conf->{samlCommonDomainCookieActivation}
                and $self->conf->{samlCommonDomainCookieWriter} )
            {
                my $cdc_idp = $self->getMetaDataURL( "samlEntityID", 0, 1 );

                $self->lmLog(
                    "Will register IDP $cdc_idp in Common Domain Cookie",
                    'debug' );

                # Redirection to CDC Writer page in a hidden iframe
                my $cdc_writer_url =
                  $self->conf->{samlCommonDomainCookieWriter};
                $cdc_writer_url .= (
                    $self->conf->{samlCommonDomainCookieWriter} =~ /\?/
                    ? '&idp=' . $cdc_idp
                    : '?url=' . $cdc_idp
                );

                my $cdc_iframe =
                    "<iframe src=\"$cdc_writer_url\""
                  . " alt=\"Common Dommain Cookie\" marginwidth=\"0\""
                  . " marginheight=\"0\" scrolling=\"no\" style=\"border: none;display: hidden;margin: 0\""
                  . " width=\"0\" height=\"0\" frameborder=\"0\">"
                  . "</iframe>";

                $self->info( $req,
                    '<h3 trspan="updateCdc">Update Common Domain Cookie</h3>'
                      . $cdc_iframe );
            }

            # HTTP-POST
            if (
                (
                       !$artifact
                    and $protocolProfile eq
                    Lasso::Constants::LOGIN_PROTOCOL_PROFILE_BRWS_POST
                )
                or (    $artifact
                    and $artifact_method ==
                    $self->getHttpMethod("artifact-post") )
              )
            {

                # Use autosubmit form
                my $sso_url  = $login->msg_url;
                my $sso_body = $login->msg_body;

                $req->postUrl($sso_url);

                if (    $artifact_method
                    and $artifact_method ==
                    $self->getHttpMethod("artifact-post") )
                {
                    $req->{postFields} = { 'SAMLart' => $sso_body };
                }
                else {
                    $req->{postFields} = { 'SAMLResponse' => $sso_body };
                }

                # RelayState
                $req->{postFields}->{'RelayState'} = $relaystate
                  if ($relaystate);

                $req->steps( ['autoPost'] );
                return PE_OK;
            }

            # HTTP-REDIRECT
            if ( $protocolProfile eq
                Lasso::Constants::LOGIN_PROTOCOL_PROFILE_REDIRECT or $artifact )
            {

                # Redirect user to response URL
                my $sso_url = $login->msg_url;
                $self->lmLog( "Redirect user to $sso_url", 'debug' );

                $req->{urldc} = $sso_url;
                $req->mustRedirect(1);
                $req->steps( [] );

                return PE_OK;
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

    return PE_OK;
}

sub artifactServer {
    my ( $self, $req ) = @_;
    $self->lmLog(
        "URL $req->uri detected as an artifact resolution service URL",
        'debug' );

    # Artifact request are sent with SOAP trough POST
    my $art_request = $req->body;
    my $art_response;

    # Create Login object
    my $login = $self->createLogin( $self->lassoServer );

    # Process request message
    unless ( $self->processArtRequestMsg( $login, $art_request ) ) {
        return $self->p->sendError( $req,
            'Unable to process artifact request message', 400 );
    }

    # Check Destination
    unless ( $self->checkDestination( $login->request, $req->uri ) ) {
        return $self->p->sendError( $req, 'Bad request', 400 );
    }

    # Create artifact response
    unless ( $art_response = $self->createArtifactResponse( $req, $login ) ) {
        return $self->p->sendError( $req,
            "Unable to create artifact response message", 400 );
    }

    $self->{SOAPMessage} = $art_response;

    # Return SOAP message
    $self->lmLog( "Send SOAP Message: $art_response", 'debug' );
    return [
        200,
        [
            'Content-Type'   => 'application/xml',
            'Content-Length' => length($art_response)
        ],
        [$art_response]
    ];
}

sub soapSloServer {
    my ( $self, $req ) = @_;
    my $url            = $req->uri;
    my $request_method = $req->param('issuerMethod') || $req->method;
    my $content_type   = $req->contentType();

    $self->lmLog( "URL $url detected as an SLO URL", 'debug' );

    # Check SAML Message
    my ( $request, $response, $method, $relaystate, $artifact ) =
      $self->checkMessage( $req, $url, $request_method, $content_type,
        "logout" );

    # Create Logout object
    my $logout = $self->createLogout( $self->lassoServer );

    # Ignore signature verification
    $self->disableSignatureVerification($logout);

    if ($request) {

        # Process logout request
        unless ( $self->processLogoutRequestMsg( $logout, $request ) ) {
            return $self->p->sendError( $req,
                "SLO: Fail to process logout request", 400 );
        }

        $self->lmLog( "SLO: Logout request is valid", 'debug' );

        # We accept only SOAP here
        unless ( $method eq $self->getHttpMethod('soap') ) {
            return $self->p->sendError( $req,
                "Only SOAP requests allowed here", 400 );
        }

        # Get SP entityID
        my $sp = $logout->remote_providerID();

        $self->lmLog( "Found entityID $sp in SAML message", 'debug' );

        # SP conf key
        my $spConfKey = $self->spList->{$sp}->{confKey};

        unless ($spConfKey) {
            return $self->p->sendError( $req,
                "$sp do not match any SP in configuration", 400 );
        }

        $self->lmLog( "$sp match $spConfKey SP in configuration", 'debug' );

        # Do we check signature?
        my $checkSLOMessageSignature =
          $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
          ->{samlSPMetaDataOptionsCheckSLOMessageSignature};

        if ($checkSLOMessageSignature) {

            $self->forceSignatureVerification($logout);

            unless ( $self->processLogoutRequestMsg( $logout, $request ) ) {
                return $self->p->sendError( $req, "Signature is not valid",
                    400 );
            }
            else {
                $self->lmLog( "Signature is valid", 'debug' );
            }
        }
        else {
            $self->lmLog( "Message signature will not be checked", 'debug' );
        }

        # Get SAML request
        my $saml_request = $logout->request();
        unless ($saml_request) {
            return $self->p->sendError( $req, "No SAML request found", 400 );
        }

        # Check Destination
        return $self->sendSLOSoapErrorResponse( $req, $logout, $method )
          unless ( $self->checkDestination( $saml_request, $url ) );

        # Get session index
        my $session_index;
        eval { $session_index = $logout->request()->SessionIndex; };

        # SLO requests without session index are not accepted
        unless ( defined $session_index ) {
            $self->p->sendError( $req,
                "No session index in SLO request from $spConfKey SP", 400 );
        }

        # Decrypt session index
        my $local_session_id = $self->conf->{cipher}->decrypt($session_index);

        $self->lmLog(
            "Get session id $local_session_id (decrypted from $session_index)",
            'debug'
        );

        # Open local session
        my $local_session = $self->p->getApacheSession( $local_session_id, 1 );

        unless ($local_session) {
            return $self->p->sendError( $req, "No local session found", 400 );
        }

        # Load Session and Identity if they exist
        my $session  = $local_session->data->{_lassoSessionDump};
        my $identity = $local_session->data->{_lassoIdentityDump};

        if ($session) {
            unless ( $self->setSessionFromDump( $logout, $session ) ) {
                return $self->p->sendError( $req,
                    "Unable to load Lasso Session", 400 );
            }
            $self->lmLog( "Lasso Session loaded", 'debug' );
        }

        if ($identity) {
            unless ( $self->setIdentityFromDump( $logout, $identity ) ) {
                return $self->p->sendError( $req,
                    "Unable to load Lasso Identity", 400 );
            }
            $self->lmLog( "Lasso Identity loaded", 'debug' );
        }

        # Close SAML sessions
        unless ( $self->deleteSAMLSecondarySessions($local_session_id) ) {
            return $self->p->sendError( $req, "Fail to delete SAML sessions",
                400 );
        }

        # Close local session
        unless ( $self->p->_deleteSession( $req, $local_session ) ) {
            return $self->p->sendError( $req,
                "Fail to delete session $local_session_id", 400 );
        }

        # Validate request if no previous error
        unless ( $self->validateLogoutRequest($logout) ) {
            return $self->p->sendError( $req, "SLO request is not valid", 400 );
        }

        # Try to send SLO request trough SOAP
        $self->resetProviderIdIndex($logout);
        while ( my $providerID = $self->getNextProviderId($logout) ) {

            # Send logout request
            my ( $rstatus, $rmethod, $rinfo ) =
              $self->sendLogoutRequestToProvider( $logout, $providerID,
                $self->getHttpMethod('soap'), 0 );

            if ($rstatus) {
                $self->lmLog( "SOAP SLO successful on $providerID", 'debug' );
            }
            else {
                $self->lmLog( "SOAP SLO error on $providerID", 'debug' );
            }
        }

        # Set RelayState
        if ($relaystate) {
            $logout->msg_relayState($relaystate);
            $self->lmLog( "Set $relaystate in RelayState", 'debug' );
        }

        # Signature
        my $signSLOMessage =
          $self->{samlSPMetaDataOptions}->{$spConfKey}
          ->{samlSPMetaDataOptionsSignSLOMessage} // 0;

        if ( $signSLOMessage == 0 ) {
            $self->lmLog( "SLO response will not be signed", 'debug' );
            $self->disableSignature($logout);
        }
        elsif ( $signSLOMessage == 1 ) {
            $self->lmLog( "SLO response will be signed", 'debug' );
            $self->forceSignature($logout);
        }
        else {
            $self->lmLog( "SLO response signature according to metadata",
                'debug' );
        }

        # Send logout response
        unless ( $self->buildLogoutResponseMsg($logout) ) {
            $self->lmLog( "Unable to build SLO response", 'error' );
            return $self->p->sendError( $req, 'Unable to build SLO response',
                400 );
        }
        my $slo_body = $logout->msg_body;
        return [
            200,
            [
                'Content-Type'   => 'application/xml',
                'Content-Length' => length($slo_body)
            ],
            [$slo_body]
        ];
    }

}

sub logout {
    my ( $self, $req ) = @_;
    return PE_OK if ( $req->datas->{samlSLOCalled} );

    # Session ID
    my $session_id = $req->{sessionInfo}->{_session_id} || $req->{id};

    # Close SAML sessions
    unless ( $self->deleteSAMLSecondarySessions($session_id) ) {
        $self->lmLog( "Fail to delete SAML sessions", 'error' );
    }

    # Create Logout object
    my $logout = $self->createLogout( $self->lassoServer );

    # Load Session and Identity if they exist
    my $session  = $req->{sessionInfo}->{_lassoSessionDump};
    my $identity = $req->{sessionInfo}->{_lassoIdentityDump};

    if ($session) {
        unless ( $self->setSessionFromDump( $logout, $session ) ) {
            $self->lmLog( "Unable to load Lasso Session", 'error' );
            return PE_SAML_SLO_ERROR;
        }
        $self->lmLog( "Lasso Session loaded", 'debug' );
    }

    # No need to initiate logout requests on SP, if no SAML session is
    # available into the session.
    else {
        $self->lmLog( 'No SAML session available into this session', 'debug' );
        return PE_OK;
    }

    if ($identity) {
        unless ( $self->setIdentityFromDump( $logout, $identity ) ) {
            $self->lmLog( "Unable to load Lasso Identity", 'error' );
            return PE_SAML_SLO_ERROR;
        }
        $self->lmLog( "Lasso Identity loaded", 'debug' );
    }

    # Proceed to logout on all others SP.
    # Verify that logout response is correctly sent. If we have to wait for
    # providers during HTTP-REDIRECT process, return PE_INFO to notify to wait
    # for them.
    # Redirect on logout page when all is done.
    if ( $self->sendLogoutRequestToProviders( $req, $logout ) ) {
        $self->{urldc} = $req->scriptname . "?logout=1";
        return PE_OK;
    }

    return PE_OK;
}

sub sloRelaySoap {
    my ( $self, $req ) = @_;
    $self->lmLog( "URL " . $req->uri . " detected as a SOAP relay service URL",
        'debug' );

    # Check if relay parameter is present (mandatory)
    my $relayID;
    unless ( $relayID = $req->param('relay') ) {
        $self->lmLog( "No relayID detected", 'error' );
        return $self->imgnok($req);
    }

    # Retrieve the corresponding data from samlStorage
    my $relayInfos = $self->getSamlSession($relayID);
    unless ($relayInfos) {
        $self->lmLog( "Could not get relay session $relayID", 'error' );
        return $self->imgnok($req);
    }

    $self->lmLog( "Found relay session $relayID", 'debug' );

    # Rebuild the logout object
    my $logout;
    unless ( $logout = $self->createLogout( $self->lassoServer ) ) {
        $self->lmLog( "Could not rebuild logout object", 'error' );
        return $self->imgnok($req);
    }

    # Load Session and Identity if they exist
    my $session    = $relayInfos->data->{_lassoSessionDump};
    my $identity   = $relayInfos->data->{_lassoIdentityDump};
    my $providerID = $relayInfos->data->{_providerID};
    my $relayState = $relayInfos->data->{_relayState} // '';
    my $spConfKey  = $self->spList->{$providerID}->{confKey};

    if ($session) {
        unless ( $self->setSessionFromDump( $logout, $session ) ) {
            $self->lmLog( "Unable to load Lasso Session", 'error' );
            return $self->imgnok($req);
        }
        $self->lmLog( "Lasso Session loaded", 'debug' );
    }

    if ($identity) {
        unless ( $self->setIdentityFromDump( $logout, $identity ) ) {
            $self->lmLog( "Unable to load Lasso Identity", 'error' );
            return $self->imgnok($req);
        }
        $self->lmLog( "Lasso Identity loaded", 'debug' );
    }

    # Send the logout request
    my ( $rstatus, $rmethod, $rinfo ) =
      $self->sendLogoutRequestToProvider( $req, $logout, $providerID,
        Lasso::Constants::HTTP_METHOD_SOAP,
        undef, $relayState );
    unless ($rstatus) {
        $self->lmLog( "Fail to process SOAP logout request to $providerID",
            'error' );
        return $self->imgnok($req);
    }

    # Store success status for this SLO request
    my $sloStatusSessionInfos = $self->getSamlSession($relayState);

    if ($sloStatusSessionInfos) {
        $sloStatusSessionInfos->update( { $spConfKey => 1 } );
        $self->lmLog( "Store SLO status for $spConfKey in session $relayState",
            'debug' );
    }
    else {
        $self->lmLog(
            "Unable to store SLO status for $spConfKey in session $relayState",
            'warn'
        );
    }

    # Delete relay session
    $relayInfos->remove();

    # SLO response is OK
    $self->lmLog( "Display OK status for SLO on $spConfKey", 'debug' );
    return $self->imgok($req);
}

sub sloRelayPost {
    my ( $self, $req ) = @_;
    $self->lmLog( "URL " . $req->uri . " detected as a POST relay service URL",
        'debug' );

    # Check if relay parameter is present (mandatory)
    my $relayID;
    unless ( $relayID = $req->param('relay') ) {
        return $self->p->sendError( $req, 'No relayID detected' );
    }

    # Retrieve the corresponding data from samlStorage
    my $relayInfos = $self->getSamlSession($relayID);
    unless ($relayInfos) {
        return $self->p->sendError( $req,
            "Could not get relay session $relayID" );
    }

    $self->lmLog( "Found relay session $relayID", 'debug' );

    # Get data to build POST form
    $req->{postUrl}                     = $relayInfos->data->{url};
    $req->{postFields}->{'SAMLRequest'} = $relayInfos->data->{body};
    $req->{postFields}->{'RelayState'}  = $relayInfos->data->{relayState};

    # Delete relay session
    $relayInfos->remove();
    return $self->p->do( $req, ['autoPost'] );
}

sub authSloServer {
    my ( $self, $req ) = @_;
    $self->p->importHandlerDatas($req);
    return $self->sloServer($req);
}

sub sloServer {
    my ( $self, $req ) = @_;
    my $url            = $req->uri;
    my $request_method = $req->param('issuerMethod') || $req->method;
    my $content_type   = $req->contentType();
    $self->lmLog( "URL $url detected as an SLO URL", 'debug' );

    # Check SAML Message
    my ( $request, $response, $method, $relaystate, $artifact ) =
      $self->checkMessage( $req, $url, $request_method, $content_type,
        "logout" );

    # Create Logout object
    my $logout = $self->createLogout( $self->lassoServer );

    # Ignore signature verification
    $self->disableSignatureVerification($logout);

    if ($request) {

        # Process logout request
        unless ( $self->processLogoutRequestMsg( $logout, $request ) ) {
            return $self->p->sendError( $req,
                "SLO: Fail to process logout request", 400 );
        }

        $self->lmLog( "SLO: Logout request is valid", 'debug' );

        # Get SP entityID
        my $sp = $logout->remote_providerID();

        $self->lmLog( "Found entityID $sp in SAML message", 'debug' );

        # SP conf key
        my $spConfKey = $self->spList->{$sp}->{confKey};

        unless ($spConfKey) {
            return $self->p->sendError( $req,
                "$sp do not match any SP in configuration", 400 );
        }

        $self->lmLog( "$sp match $spConfKey SP in configuration", 'debug' );

        # Load Session and Identity if they exist
        my ( $session, $session_index, $identity, $local_session_id );

        eval { $session_index = $logout->request()->SessionIndex; };

        # SLO requests without session index are not accepted
        unless ( defined $session_index ) {
            $self->lmLog( "No session index in SLO request from $spConfKey SP",
                'error' );
            return $self->sendSLOErrorResponse( $logout, $method );
        }
        $local_session_id = $self->conf->{cipher}->decrypt($session_index);
        $self->lmLog(
            "Get session id $local_session_id (decrypted from $session_index)",
            'debug'
        );

        if ( $req->{sessionInfo} ) {
            $session  = $req->{sessionInfo}->{_lassoSessionDump};
            $identity = $req->{sessionInfo}->{_lassoIdentityDump};
        }
        unless ($session) {

            # Open local session
            my $local_session =
              $self->p->getApacheSession( $local_session_id, 1 );

            unless ($local_session) {
                $self->lmLog( "No local session found", 'error' );
                return $self->sendSLOErrorResponse( $logout, $method );
            }

            # Load Session and Identity if they exist
            $session  = $local_session->data->{_lassoSessionDump};
            $identity = $local_session->data->{_lassoIdentityDump};

            # Import user datas in $req (for other "logout" subs)
            $req->id( $local_session->data->{_session_id} );
            $req->sessionInfo( $local_session->data );
            $req->user( $local_session->data->{ $self->conf->{whatToTrace} } );
        }

        if ($session) {
            unless ( $self->setSessionFromDump( $logout, $session ) ) {
                return $self->p->sendError( $req,
                    "Unable to load Lasso Session", 400 );
            }
            $self->lmLog( "Lasso Session loaded", 'debug' );
        }

        if ($identity) {
            unless ( $self->setIdentityFromDump( $logout, $identity ) ) {
                return $self->p->sendError( $req,
                    "Unable to load Lasso Identity", 400 );
            }
            $self->lmLog( "Lasso Identity loaded", 'debug' );
        }

        # Do we check signature?
        my $checkSLOMessageSignature =
          $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
          ->{samlSPMetaDataOptionsCheckSLOMessageSignature};

        if ($checkSLOMessageSignature) {

            $self->forceSignatureVerification($logout);

            unless ( $self->processLogoutRequestMsg( $logout, $request ) ) {
                return $self->p->sendError( $req, "Signature is not valid",
                    400 );
            }
            else {
                $self->lmLog( "Signature is valid", 'debug' );
            }
        }
        else {
            $self->lmLog( "Message signature will not be checked", 'debug' );
        }

        # Check Destination
        return $self->sendSLOErrorResponse( $logout, $method )
          unless ( $self->checkDestination( $logout->request, $url ) );

        # Validate request if no previous error
        unless ( $self->validateLogoutRequest($logout) ) {
            return $self->p->sendError( $req, "SLO request is not valid", 400 );
        }

        # Set RelayState
        if ($relaystate) {
            $logout->msg_relayState($relaystate);
            $self->lmLog( "Set $relaystate in RelayState", 'debug' );
        }

        # Create SLO status session and get ID
        my $sloStatusSessionInfo = $self->getSamlSession();

        my $sloInfos;
        $sloInfos->{type}    = 'sloStatus';
        $sloInfos->{_utime}  = time;
        $sloInfos->{_logout} = $logout->dump;
        $sloInfos->{_session} =
          $logout->get_session() ? $logout->get_session()->dump : "";
        $sloInfos->{_method} = $method;
        $sloStatusSessionInfo->update($sloInfos);
        my $relayID = $sloStatusSessionInfo->id;

        # Prepare logout on all others SP
        my $provider_nb =
          $self->sendLogoutRequestToProviders( $req, $logout, $relayID );

        # Close SAML sessions
        unless ( $self->deleteSAMLSecondarySessions($local_session_id) ) {
            $self->lmLog( "Fail to delete SAML sessions", 'error' );
        }

        # Close local session
        # This flag is for logout() to say that SAML logout is already done
        $req->datas->{samlSLOCalled} = 1;

        # Launch normal logout and ignore errors
        $self->p->do( $req, [ @{ $self->p->beforeLogout }, 'deleteSession' ] );

        # Signature
        my $signSLOMessage =
          $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
          ->{samlSPMetaDataOptionsSignSLOMessage};

        unless ($signSLOMessage) {
            $self->lmLog( "Do not sign this SLO response", 'debug' );
            return $self->sendSLOErrorResponse( $logout, $method )
              unless ( $self->disableSignature($logout) );
        }

        # If no waiting SP, return directly SLO response
        unless ($provider_nb) {
            return $self->sendLogoutResponseToServiceProvider( $req,
                $logout, $method );
        }

        # Else build SLO status relay URL and display info
        else {
            $req->{urldc} =
              $self->conf->{portal} . '/saml/relaySingleLogoutTermination';
            $self->p->setHiddenFormValue( 'relay', $relayID );
            return $self->do( $req, [] );
        }

    }

    elsif ($response) {

        # No SLO response should be here
        # else it means SSO session was not closed: launching it
        $self->lmLog(
            "SLO response found on an active SSO session, ignoring it",
            'debug' );
        $req->datas->{samlSLOCalled} = 1;
        return $self->p->do( $req,
            [ @{ $self->p->beforeLogout }, 'deleteSession' ] );
    }

    else {

        # No request or response
        # This should not happen
        return $self->p->sendError( $req, "No request or response found", 400 );
    }
}

sub attributeServer {
    my ( $self, $req, ) = @_;
    my $url = $req->uri;
    $self->lmLog( "URL $url detected as an attribute service URL", 'debug' );

    # Attribute request are sent with SOAP trough POST
    my $att_request = $req->body;
    my $att_response;

    # Process request
    my $query =
      $self->processAttributeRequest( $self->lassoServer, $att_request );
    unless ($query) {
        return $self->p->sendError( $req,
            "Unable to process attribute request", 400 );
    }

    # Get SP entityID
    my $sp = $query->remote_providerID();

    $self->lmLog( "Found entityID $sp in SAML message", 'debug' );

    # SP conf key
    my $spConfKey = $self->spList->{$sp}->{confKey};

    unless ($spConfKey) {
        return $self->p->sendError( $req,
            "$sp do not match any SP in configuration", 400 );
    }

    $self->lmLog( "$sp match $spConfKey SP in configuration", 'debug' );

    # Check Destination
    unless ( $self->checkDestination( $query->request, $url ) ) {
        return $self->p->sendError( $req, "Bad destination $url", 400 );
    }

    # Validate request
    unless ( $self->validateAttributeRequest($query) ) {
        return $self->p->sendError( $req, "Attribute request not valid", 400 );
    }

    # Get NameID
    my $name_id = $query->nameIdentifier();

    unless ($name_id) {
        $self->p->sendError( $req, "Fail to get NameID from attribute request",
            400 );
    }

    my $user = $name_id->content();

    # Get sessionInfo for the given NameID
    my $sessionInfo;
    my $moduleOptions = $self->conf->{samlStorageOptions} || {};
    $moduleOptions->{backend} = $self->conf->{samlStorage};
    my $module = "Lemonldap::NG::Common::Apache::Session";

    my $saml_sessions =
      $module->searchOn( $moduleOptions, "_nameID", $name_id->dump );

    if ( my @saml_sessions_keys = keys %$saml_sessions ) {

        # Warning if more than one session found
        if ( $#saml_sessions_keys > 0 ) {
            $self->lmLog( "More than one SAML session found for user $user",
                'warn' );
        }

        # Take the first session
        my $saml_session = shift @saml_sessions_keys;

        # Get session
        $self->lmLog( "Retrieve SAML session $saml_session for user $user",
            'debug' );

        my $samlSessionInfo = $self->getSamlSession($saml_session);

        # Get real session
        my $real_session = $samlSessionInfo->data->{_saml_id};

        $self->lmLog( "Retrieve real session $real_session for user $user",
            'debug' );

        $sessionInfo = $self->p->getApacheSession( $real_session, 1 );

        unless ($sessionInfo) {
            return $self->p->sendError( $req,
                "Cannot get session $real_session", 500 );
        }

    }
    else {
        return $self->p->sendError( $req,
            "No SAML session found for user $user", 400 );
    }

    # Get requested attributes
    my @requested_attributes;
    eval { @requested_attributes = $query->request()->Attribute(); };
    if ($@) {
        $self->checkLassoError($@);
        return $self->p->sendError( $req, "Unable to get requested attributes",
            400 );
    }

    # Returned attributes
    my @returned_attributes;

    # Browse SP authorized attributes
    foreach (
        keys %{ $self->conf->{samlSPMetaDataExportedAttributes}->{$spConfKey} }
      )
    {
        my $sp_attr = $_;

        # Extract fields from exportedAttr value
        my ( $mandatory, $name, $format, $friendly_name ) =
          split( /;/,
            $self->conf->{samlSPMetaDataExportedAttributes}->{$spConfKey}
              ->{$sp_attr} );

        foreach (@requested_attributes) {
            my $req_attr       = $_;
            my $rname          = $req_attr->Name();
            my $rformat        = $req_attr->NameFormat();
            my $rfriendly_name = $req_attr->FriendlyName();

            # Skip if name does not match
            next unless ( $rname =~ /^$name$/ );

            # Check format and friendly name
            next if ( $rformat and $rformat !~ /^$format$/ );
            next
              if (  $rfriendly_name
                and $rfriendly_name !~ /^$friendly_name$/ );

            $self->lmLog(
                "SP $spConfKey is authorized to access attribute $rname",
                'debug' );

            $self->lmLog( "Attribute $rname is linked to $sp_attr session key",
                'debug' );

            # Check if values are given
            my $rvalue =
              $self->getAttributeValue( $rname, $rformat, $rfriendly_name,
                [$req_attr] );

            $self->lmLog( "Some values are explicitely requested: $rvalue",
                'debug' )
              if defined $rvalue;

            # Get session value
            if ( $sessionInfo->data->{$sp_attr} ) {

                my @values = split $self->conf->{multiValuesSeparator},
                  $sessionInfo->data->{$sp_attr};
                my @saml2values;

                # SAML2 attribute
                my $ret_attr =
                  $self->createAttribute( $rname, $rformat, $rfriendly_name );

                unless ($ret_attr) {
                    return $self->p->sendError( $req,
                        "Unable to create a new SAML attribute", 500 );
                }

                foreach (@values) {

                    my $local_value = $_;

                    # Check if values were set in requested attribute
                    # In this case, only requested values can be returned
                    if (
                        $rvalue
                        and !map( /^$local_value$/,
                            split(
                                $self->conf->{multiValuesSeparator}, $rvalue
                            ) )
                      )
                    {
                        $self->lmLog(
"$local_value value is not in requested values, it will not be sent",
                            'warn'
                        );
                        next;
                    }

                    # SAML2 attribute value
                    my $saml2value = $self->createAttributeValue( $local_value,
                        $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
                          ->{samlSPMetaDataOptionsForceUTF8} );

                    unless ($saml2value) {
                        return $self->p->sendError( $req,
                            "Unable to create a new SAML attribute value",
                            400 );
                    }

                    push @saml2values, $saml2value;

                    $self->lmLog( "Push $local_value in SAML attribute $name",
                        'debug' );

                }

                $ret_attr->AttributeValue(@saml2values);

                # Push attribute in attribute list
                push @returned_attributes, $ret_attr;

            }
            else {
                $self->lmLog( "No session value for $sp_attr", 'debug' );
            }

        }

    }

    # Create attribute statement
    if ( scalar @returned_attributes ) {
        my $attribute_statement;

        eval { $attribute_statement = Lasso::Saml2AttributeStatement->new(); };
        if ($@) {
            $self->checkLassoError($@);
            return $self->p->sendError( $req, 'An error occurs, see IdP logs',
                500 );
        }

        # Register attributes in attribute statement
        $attribute_statement->Attribute(@returned_attributes);

        # Create assetion
        my $assertion;

        eval { $assertion = Lasso::Saml2Assertion->new(); };
        if ($@) {
            $self->checkLassoError($@);
            return $self->p->sendError( $req, 'An error occurs, see IdP logs',
                500 );
        }

        # Add attribute statement in response assertion
        my @attributes_statement = ($attribute_statement);
        $assertion->AttributeStatement(@attributes_statement);

        # Set response assertion
        $query->response->Assertion( ($assertion) );
    }

    # Build response
    $att_response = $self->buildAttributeResponse($query);

    unless ($att_response) {
        $self->p->sendError( $req, "Unable to build attribute response", 500 );
    }

    return [
        200,
        [
            'Content-Type'   => 'application/xml',
            'Content-Length' => length($att_response)
        ],
        [$att_response]
    ];
}

# INTERNAL METHODS

sub imgok {
    my ( $self, $req, ) = @_;
    return $self->sendImage( $req, 'ok.png' );
}

sub imgnok {
    my ( $self, $req, ) = @_;
    return $self->sendImage( $req, 'warning.png' );
}

sub sendImage {
    my ( $self, $req,, $img ) = @_;
    return $self->p->staticFile( $req, "common/$img", 'image/png' );
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::Issuer::SAML - SAML Issuer for LemonLDAP::NG

=head1 DESCRIPTION

SAML Issuer for LemonLDAP::NG

=head1 SEE ALSO

L<Lemonldap::NG::Portal>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

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

=item Copyright (C) 2009-2017 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2012 by François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Copyright (C) 2009-2016 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

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
