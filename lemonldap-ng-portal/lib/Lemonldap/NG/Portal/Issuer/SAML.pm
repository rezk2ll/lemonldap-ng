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
has sloRe    => ( is => 'rw' );

# INITIALIZATION

sub init {
    my ($self) = @_;

    # Get configuration parameter
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
qr/^($saml_sso_soap_url|$saml_sso_soap_url_ret|$saml_sso_get_url|$saml_sso_get_url_ret|$saml_sso_post_url|$saml_sso_post_url_ret|$saml_sso_art_url|$saml_sso_art_url_ret)$/i
    );

    my $saml_slo_soap_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceSOAP", 1 );
    my $saml_slo_soap_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceSOAP", 2 );
    my $saml_slo_get_url = $self->getMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceHTTPRedirect", 1 );
    my $saml_slo_get_url_ret = $self->getMetaDataURL(
        "samlIDPSSODescriptorSingleLogoutServiceHTTPRedirect", 2 );
    my $saml_slo_post_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceHTTPPost",
        1 );
    my $saml_slo_post_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleLogoutServiceHTTPPost",
        2 );
    $self->sloRe(
qr/^($saml_slo_soap_url|$saml_slo_soap_url_ret|$saml_slo_get_url|$saml_slo_get_url_ret|$saml_slo_post_url|$saml_slo_post_url_ret)$/i
    );

    return (
        $self->Lemonldap::NG::Portal::Main::Issuer::init()

          # Load SAML service
          and $self->Lemonldap::NG::Portal::Lib::SAML::init()

          # Load SAML service providers
          and $self->loadSPs()

          # Load SAML identity providers
          # Required to manage SLO in Proxy mode
          and $self->loadIDPs()
    );
}

# RUNNING METHODS

sub run {
    my ( $self, $req ) = @_;
    my $server = $self->lassoServer;
    my $login;
    my $protocolProfile;
    my $artifact_method;
    my $authn_context;

    # Session ID
    my $session_id = $req->{sessionInfo}->{_session_id} || $req->{id};

    # Session creation timestamp
    my $time = $req->{sessionInfo}->{_utime} || time();

    # Get HTTP request informations to know
    # if we are receving SAML request or response
    my $url                     = $req->uri;
    my $request_method          = $req->method();
    my $content_type            = $req->contentType();
    my $idp_initiated           = $req->param('IDPInitiated');
    my $idp_initiated_sp        = $req->param('sp');
    my $idp_initiated_spConfKey = $req->param('spConfKey');

    # 1.1. SSO (SSO URL or Proxy Mode)
    if ( $url =~ $self->ssoUrlRe or $req->datas->{_proxiedRequest} ) {

        $self->lmLog( "URL $url detected as an SSO request URL", 'debug' );

        # Get hidden params for IDP initiated if needed
        $idp_initiated = $self->p->getHiddenFormValue( $req, 'IDPInitiated' )
          unless defined $idp_initiated;
        $idp_initiated_sp = $self->p->getHiddenFormValue( $req, 'sp' )
          unless defined $idp_initiated_sp;
        $idp_initiated_spConfKey =
          $self->p->getHiddenFormValue( $req, 'spConfKey' )
          unless defined $idp_initiated_spConfKey;

        # Check message
        my ( $request, $response, $method, $relaystate, $artifact );

        if ( $req->datas->{_proxiedRequest} ) {
            $request    = $req->datas->{_proxiedRequest};
            $method     = $req->datas->{_proxiedMethod};
            $relaystate = $req->datas->{_proxiedRelayState};
            $artifact   = $req->datas->{_proxiedArtifact};
        }
        else {
            ( $request, $response, $method, $relaystate, $artifact ) =
              $self->checkMessage( $req, $url, $request_method, $content_type );
        }

        # Create Login object
        my $login = $self->createLogin($server);

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
            my $oneTimeUse =
              $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
              ->{samlSPMetaDataOptionsOneTimeUse};

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
              ->{samlSPMetaDataOptionsSignSSOMessage};

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
            my $user = $req->{sessionInfo}->{ $self->conf->{whatToTrace} };
            my $nameIDLog;
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
            no strict 'subs';
            if ( $protocolProfile ==
                Lasso::Constants::LOGIN_PROTOCOL_PROFILE_BRWS_ART )
            {

                # Choose method
                $artifact_method = $self->getHttpMethod("artifact-get")
                  if ( $method == $self->getHttpMethod("redirect")
                    || $method == $self->getHttpMethod("artifact-get") );
                $artifact_method = $self->getHttpMethod("artifact-post")
                  if ( $method == $self->getHttpMethod("post")
                    || $method == $self->getHttpMethod("artifact-post") );

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
                $self->p->updateSession(
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

                # TODO: replace this
                #$self->info( "<h3>" . $self->msg(PM_CDC_WRITER) . "</h3>" );

                $self->info($cdc_iframe);
            }

            # HTTP-REDIRECT
            if ( $protocolProfile eq
                Lasso::Constants::LOGIN_PROTOCOL_PROFILE_REDIRECT
                or $artifact_method == $self->getHttpMethod("artifact-get") )
            {

                # Redirect user to response URL
                my $sso_url = $login->msg_url;
                $self->lmLog( "Redirect user to $sso_url", 'debug' );

                $req->{urldc} = $sso_url;

                return $self->_subProcess(qw(autoRedirect));
            }

            # HTTP-POST
            if ( $protocolProfile eq
                Lasso::Constants::LOGIN_PROTOCOL_PROFILE_BRWS_POST
                or $artifact_method == $self->getHttpMethod("artifact-post") )
            {

                # Use autosubmit form
                my $sso_url  = $login->msg_url;
                my $sso_body = $login->msg_body;

                $req->postUrl($sso_url);

                if ( $artifact_method == $self->getHttpMethod("artifact-post") )
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
    if ( $url =~ $self->sloRe ) {
        $self->lmLog( "URL $url detected as an SLO URL", 'debug' );

        # Check SAML Message
        my ( $request, $response, $method, $relaystate, $artifact ) =
          $self->checkMessage( $req, $url, $request_method, $content_type,
            "logout" );

        # Create Logout object
        my $logout = $self->createLogout($server);

        # Ignore signature verification
        $self->disableSignatureVerification($logout);

        if ($request) {

            # Process logout request
            unless ( $self->processLogoutRequestMsg( $logout, $request ) ) {
                $self->lmLog( "SLO: Fail to process logout request", 'error' );
                return PE_SAML_SLO_ERROR;
            }

            $self->lmLog( "SLO: Logout request is valid", 'debug' );

            # Load Session and Identity if they exist
            my $session  = $req->{sessionInfo}->{_lassoSessionDump};
            my $identity = $req->{sessionInfo}->{_lassoIdentityDump};

            if ($session) {
                unless ( $self->setSessionFromDump( $logout, $session ) ) {
                    $self->lmLog( "Unable to load Lasso Session", 'error' );
                    return $self->sendSLOErrorResponse( $logout, $method );
                }
                $self->lmLog( "Lasso Session loaded", 'debug' );
            }

            if ($identity) {
                unless ( $self->setIdentityFromDump( $logout, $identity ) ) {
                    $self->lmLog( "Unable to load Lasso Identity", 'error' );
                    return $self->sendSLOErrorResponse( $logout, $method );
                }
                $self->lmLog( "Lasso Identity loaded", 'debug' );
            }

            # Get SP entityID
            my $sp = $logout->remote_providerID();

            $self->lmLog( "Found entityID $sp in SAML message", 'debug' );

            # SP conf key
            my $spConfKey = $self->spList->{$sp}->{confKey};

            unless ($spConfKey) {
                $self->lmLog( "$sp do not match any SP in configuration",
                    'error' );
                return $self->sendSLOErrorResponse( $logout, $method );
            }

            $self->lmLog( "$sp match $spConfKey SP in configuration", 'debug' );

            # Do we check signature?
            my $checkSLOMessageSignature =
              $self->conf->{samlSPMetaDataOptions}->{$spConfKey}
              ->{samlSPMetaDataOptionsCheckSLOMessageSignature};

            if ($checkSLOMessageSignature) {

                $self->forceSignatureVerification($logout);

                unless ( $self->processLogoutRequestMsg( $logout, $request ) ) {
                    $self->lmLog( "Signature is not valid", 'error' );
                    return $self->sendSLOErrorResponse( $logout, $method );
                }
                else {
                    $self->lmLog( "Signature is valid", 'debug' );
                }
            }
            else {
                $self->lmLog( "Message signature will not be checked",
                    'debug' );
            }

            # Check Destination
            return $self->sendSLOErrorResponse( $logout, $method )
              unless ( $self->checkDestination( $logout->request, $url ) );

            # Get session index
            my $session_index;
            eval { $session_index = $logout->request()->SessionIndex; };

            # SLO requests without session index are not accepted
            if ( $@ or !defined $session_index ) {
                $self->lmLog(
                    "No session index in SLO request from $spConfKey SP",
                    'error' );
                return $self->sendSLOErrorResponse( $logout, $method );
            }

            # Validate request if no previous error
            unless ( $self->validateLogoutRequest($logout) ) {
                $self->lmLog( "SLO request is not valid", 'error' );
                return $self->sendSLOErrorResponse( $logout, $method );
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
              $self->sendLogoutRequestToProviders( $logout, $relayID );

            # Decrypt session index
            my $local_session_id =
              $self->conf->{cipher}->decrypt($session_index);

            $self->lmLog(
"Get session id $local_session_id (decrypted from $session_index)",
                'debug'
            );

            my $user = $req->{sessionInfo}->{user};
            my $local_session = $self->getApacheSession( $local_session_id, 1 );

            # Close SAML sessions
            unless ( $self->deleteSAMLSecondarySessions($local_session_id) ) {
                $self->lmLog( "Fail to delete SAML sessions", 'error' );
            }

            # Close local session
            unless ( $self->_deleteSession($local_session) ) {
                $self->lmLog(
                    "Fail to delete session $local_session_id for user $user",
                    'error' );
            }

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
                if (
                    my $tmp = $self->sendLogoutResponseToServiceProvider(
                        $logout, $method
                    )
                  )
                {
                    return $tmp;
                }
                else {
                    $self->lmLog( "Fail to send SLO response", 'error' );
                    return $self->sendSLOErrorResponse( $logout, $method );
                }
            }

            # Else build SLO status relay URL and display info
            else {
                $req->{urldc} =
                  $self->conf->{portal} . '/saml/relaySingleLogoutTermination';
                $self->setHiddenFormValue( 'relay', $relayID );
                return PE_INFO;
            }

        }

        elsif ($response) {

            # No SLO response should be here
            # else it means SSO session was not closed
            $self->lmLog(
                "SLO response found on an active SSO session, ignoring it",
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

    return PE_OK;
}

sub logout {
}

# INTERNAL METHODS

1;
