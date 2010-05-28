## @file
# Common SAML functions

## @class
# Common SAML functions
package Lemonldap::NG::Portal::_SAML;

use strict;
use Lemonldap::NG::Common::Conf::SAML::Metadata;
use XML::Simple;
use MIME::Base64;
use String::Random;
use LWP::UserAgent;    # SOAP call
use HTTP::Request;     # SOAP call
use POSIX;             # Convert SAML2 date into timestamp
use Time::Local;       # Convert SAML2 date into timestamp
use Encode;            # Encode attribute values

our $VERSION = '0.01';
our $_samlCache;

BEGIN {

    # Load Glib if available
    eval 'use Glib;';
    if ($@) {
        print STDERR
          "Glib Lasso messages will not be catched (require Glib module)\n";
        eval "use constant GLIB => 0";
    }
    else {
        eval "use constant GLIB => 1";
    }

    # Load Lasso.pm
    eval 'use Lasso;';
    if ($@) {
        print STDERR "Lasso.pm not loaded :$@";
        eval 'use constant LASSO => 0;use constant BADLASSO => 0;';
    }
    else {
        no strict 'subs';
        eval 'use constant LASSO => 1';

        # Check Lasso version >= 2.2.91
        my $lasso_check_version_mode = Lasso::Constants::CHECK_VERSION_NUMERIC;
        my $check_version =
          Lasso::check_version( 2, 2, 91, $lasso_check_version_mode );
        unless ($check_version) {
            eval 'use constant BADLASSO => 1';
        }
        else {
            eval 'use constant BADLASSO => 0';
        }
    }

}

## @method boolean loadLasso()
# Load Lasso module
# @return boolean result
sub loadLasso {
    my $self = shift;

    # Catch GLib Lasso messages (require Glib)
    if (GLIB) {
        Glib::Log->set_handler(
            "Lasso",
            [qw/ error critical warning message info debug /],
            sub {
                $self->lmLog( $_[0] . " error " . $_[1] . ": " . $_[2],
                    'debug' );
            }
        );
    }

    unless (LASSO) {
        $self->lmLog( "Module Lasso not loaded (see bellow)", 'error' );
        return 0;
    }

    if (BADLASSO) {
        $self->lmLog( 'Lasso version >= 2.2.91 required', 'error' );
        return 0;
    }

    return 1;
}

## @method boolean loadService()
# Load SAML service by creating a Lasso::Server
# @return boolean result
sub loadService {
    my $self = shift;

    # Load Lasso
    return 0 unless $self->loadLasso();

    # Activate SOAP
    $self->abort('To use SAML, you must activate SOAP (Soap => 1)')
      unless ( $self->{Soap} );

    # Check presence of private key in configuration
    unless ( $self->{samlServicePrivateKey} ) {
        $self->lmLog( "SAML private key not found in configuration", 'error' );
        return 0;
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

    # Log
    unless ($server) {
        $self->lmLog( 'Unable to create Lasso server', 'error' );
        return 0;
    }
    $self->lmLog( "Service created", 'debug' );

    # Store Lasso::Server object
    $self->{_lassoServer} = $server;

    return 1;
}

## @method boolean loadIDPs()
# Load SAML identity providers
# @return boolean result
sub loadIDPs {
    my $self = shift;

    # Check if SAML service is loaded
    return 0 unless $self->{_lassoServer};

    # Check presence of at least one identity provider in configuration
    unless ( $self->{samlIDPMetaDataXML}
        and keys %{ $self->{samlIDPMetaDataXML} } )
    {
        $self->lmLog( "No IDP found in configuration", 'warn' );
    }

    # Load identity provider metadata
    # IDP metadata are listed in $self->{samlIDPMetaDataXML}
    # Each key is the IDP name
    # Build IDP list for later use in extractFormInfo
    $self->{_idpList} = ();
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
            return 0;
        }

        # Add this IDP to Lasso::Server
        my $result =
          $self->addIDP( $self->{_lassoServer}, $idp_metadata->toXML() );

        unless ($result) {
            $self->lmLog( "Fail to use IDP $_ Metadata", 'error' );
            return 0;
        }

        # Store IDP entityID and Organization Name
        my $entityID = $idp_metadata->{entityID};
        my $name =
          $self->getOrganizationName( $self->{_lassoServer}, $entityID )
          || ucfirst($_);
        $self->{_idpList}->{$entityID}->{confKey} = $_;
        $self->{_idpList}->{$entityID}->{name}    = $name;

        $self->lmLog( "IDP $_ added", 'debug' );
    }

    return 1;
}

## @method boolean loadSPs()
# Load SAML service providers
# @return boolean result
sub loadSPs {
    my $self = shift;

    # Check if SAML service is loaded
    return 0 unless $self->{_lassoServer};

    # Check presence of at least one service provider in configuration
    unless ( $self->{samlSPMetaDataXML}
        and keys %{ $self->{samlSPMetaDataXML} } )
    {
        $self->lmLog( "No SP found in configuration", 'warn' );
    }

    # Load service provider metadata
    # SP metadata are listed in $self->{samlSPMetaDataXML}
    # Each key is the SP name
    # Build SP list for later use in extractFormInfo
    $self->{_spList} = ();
    foreach ( keys %{ $self->{samlSPMetaDataXML} } ) {

        $self->lmLog( "Get Metadata for SP $_", 'debug' );

        # Get metadata from configuration
        my $sp_metadata = Lemonldap::NG::Common::Conf::SAML::Metadata->new();
        unless (
            $sp_metadata->initializeFromConfHash(
                $self->{samlSPMetaDataXML}->{$_}->{samlSPMetaDataXML}
            )
          )
        {
            $self->lmLog( "Fail to read SP $_ Metadata from configuration",
                'error' );
            return 0;
        }

        # Add this SP to Lasso::Server
        my $result =
          $self->addSP( $self->{_lassoServer}, $sp_metadata->toXML() );

        unless ($result) {
            $self->lmLog( "Fail to use SP $_ Metadata", 'error' );
            return 0;
        }

        # Store SP entityID and Organization Name
        my $entityID = $sp_metadata->{entityID};
        my $name =
          $self->getOrganizationName( $self->{_lassoServer}, $entityID )
          || ucfirst($_);
        $self->{_spList}->{$entityID}->{confKey} = $_;
        $self->{_spList}->{$entityID}->{name}    = $name;

        $self->lmLog( "SP $_ added", 'debug' );
    }

    return 1;
}

## @method array checkMessage(string url, string request_method, string content_type, string profile_type)
# Check SAML requests and responses
# @param url
# @param request_method
# @param content_type
# @param profile_type login or logout
# @return ( $request, $response, $method, $relaystate, $artifact )
sub checkMessage {
    my ( $self, $url, $request_method, $content_type, $profile_type ) =
      splice @_;
    $profile_type ||= "login";
    my ( $request, $response, $message, $method, $relaystate, $artifact );

    # Check if SAML service is loaded
    return ( $request, $response, $method, $relaystate, $artifact )
      unless $self->{_lassoServer};

    # 1. Get hidden fields
    $request    = $self->getHiddenFormValue('SAMLRequest');
    $response   = $self->getHiddenFormValue('SAMLResponse');
    $method     = $self->getHiddenFormValue('Method');
    $relaystate = $self->getHiddenFormValue('RelayState');
    $artifact   = $self->getHiddenFormValue('SAMLart');

    # 2. If no hidden fields, check HTTP request contents
    unless ( $request or $response ) {

        # Create Profile object
        my $profile;
        $profile = $self->createLogin( $self->{_lassoServer} )
          if ( $profile_type eq "login" );
        $profile = $self->createLogout( $self->{_lassoServer} )
          if ( $profile_type eq "logout" );

        # Get relayState
        $relaystate = $self->param('RelayState');

        # 2.1. HTTP REDIRECT
        if ( $request_method =~ /^GET$/ ) {

            $method = Lasso::Constants::HTTP_METHOD_REDIRECT;
            $self->lmLog( "SAML method: HTTP-REDIRECT", 'debug' );

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

                # Artifact in query string
                $artifact = $self->query_string();
                $self->lmLog( "HTTP-REDIRECT: SAML Artifact $artifact",
                    'debug' );

                # Resolve Artifact
                $method = Lasso::Constants::HTTP_METHOD_ARTIFACT_GET;
                $message =
                  $self->resolveArtifact( $profile, $artifact, $method );

                # Request or response ?
                if ( $message =~ /samlp:response/i ) {
                    $response = $message;
                }
                else {
                    $request = $message;
                }
            }

        }

        # 2.2. HTTP POST AND SOAP
        elsif ( $request_method =~ /^POST$/ ) {

            # 2.2.1. POST
            if ( $content_type !~ /xml/ ) {

                $method = Lasso::Constants::HTTP_METHOD_POST;
                $self->lmLog( "SAML method: HTTP-POST", 'debug' );

                if ( $self->param('SAMLResponse') ) {

                    # Response in body part
                    $response = $self->param('SAMLResponse');
                    $self->lmLog( "HTTP-POST: SAML Response $response",
                        'debug' );

                }

                elsif ( $self->param('SAMLRequest') ) {

                    # Request in body part
                    $request = $self->param('SAMLRequest');
                    $self->lmLog( "HTTP-POST: SAML Request $request", 'debug' );

                }

                elsif ( $self->param('SAMLart') ) {

                    # Artifact in SAMLart param
                    $artifact = $self->param('SAMLart');
                    $self->lmLog( "HTTP-REDIRECT: SAML Artifact $artifact",
                        'debug' );

                    # Resolve Artifact
                    $method = Lasso::Constants::HTTP_METHOD_ARTIFACT_POST;
                    $message =
                      $self->resolveArtifact( $profile, $artifact, $method );

                    # Request or response ?
                    if ( $message =~ /samlp:response/i ) {
                        $response = $message;
                    }
                    else {
                        $request = $message;
                    }

                }

            }

            # 2.2.2. SOAP
            else {

                $method = Lasso::Constants::HTTP_METHOD_SOAP;
                $self->lmLog( "SAML method: HTTP-SOAP", 'debug' );

                # SOAP is always a request
                $request = $self->param('POSTDATA');
                $self->lmLog( "HTTP-SOAP: SAML Request $request", 'debug' );

            }

        }

    }
    else {
        $self->lmLog( "Keep values from hidden fields", 'debug' );
    }

    # 3. Backup values into hidden form values, if process is interrupted
    # later in LemonLDAP::NG

    $self->setHiddenFormValue( 'SAMLRequest',  $request );
    $self->setHiddenFormValue( 'SAMLResponse', $response );
    $self->setHiddenFormValue( 'Method',       $method );
    $self->setHiddenFormValue( 'RelayState',   $relaystate );
    $self->setHiddenFormValue( 'SAMLart',      $artifact );

    # 4. Return values
    return ( $request, $response, $method, $relaystate, $artifact ? 1 : 0 );
}

## @method boolean checkLassoError(Lasso::Error error, string level)
# Log Lasso error code and message if this is actually a Lasso::Error with code > 0
# @param Lasso::Error Lasso error object
# @param string optional log level (debug by default)
# @return 1 if no error
sub checkLassoError {
    my ( $self, $error, $level ) = splice @_;
    $level ||= 'debug';

    # If $error is not a Lasso::Error object, display error string
    unless ( ref($error) and $error->isa("Lasso::Error") ) {
        return 1 unless $error;
        $self->lmLog( "Lasso error: $error", $level );
        return 0;
    }

    # Else check error code and error message
    if ( $error->{code} ) {
        $self->lmLog(
            "Lasso error code " . $error->{code} . ": " . $error->{message},
            $level );
        return 0;
    }

    return 1;
}

## @method Lasso::Server createServer(string metadata, string private_key, string private_key_password, string certificate)
# Load service metadata and create Lasso::Server object
# @param string metadata
# @param string private key
# @param string optional private key password
# @param string optional certificate
# @return Lasso::Server object
sub createServer {
    my ( $self, $metadata, $private_key, $private_key_password, $certificate ) =
      splice @_;
    my $server = $_samlCache->{$metadata};
    return $server if ($server);

    eval {
        $server = Lasso::Server::new_from_buffers( $metadata, $private_key,
            $private_key_password, $certificate );
    };

    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    return $server;
}

## @method boolean addIDP(Lasso::Server server, string metadata, string public_key, string ca_cert_chain)
# Add IDP to an existing Lasso::Server
# @param Lasso::Server Lasso::Server object
# @param string metadata IDP metadata
# @param string optional public key
# @param string optional ca cert chain
# @return boolean result
sub addIDP {
    my ( $self, $server, $metadata, $public_key, $ca_cert_chain ) = splice @_;

    return 0 unless ( $server->isa("Lasso::Server") and defined $metadata );

    return $self->addProvider( $server, Lasso::Constants::PROVIDER_ROLE_IDP,
        $metadata, $public_key, $ca_cert_chain );
}

## @method boolean addSP(Lasso::Server server, string metadata, string public_key, string ca_cert_chain)
# Add SP to an existing Lasso::Server
# @param Lasso::Server Lasso::Server object
# @param string metadata SP metadata
# @param string optional public key
# @param string optional ca cert chain
# @return boolean result
sub addSP {
    my ( $self, $server, $metadata, $public_key, $ca_cert_chain ) = splice @_;

    return 0 unless ( $server->isa("Lasso::Server") and defined $metadata );

    return $self->addProvider( $server, Lasso::Constants::PROVIDER_ROLE_SP,
        $metadata, $public_key, $ca_cert_chain );
}

## @method boolean addProvider(Lasso::Server server, int role, string metadata, string public_key, string ca_cert_chain)
# Add provider to an existing Lasso::Server
# @param Lasso::Server Lasso::Server object
# @param int role (IDP, SP or Both)
# @param string metadata IDP metadata
# @param string optional public key
# @param string optional ca cert chain
# @return boolean result
sub addProvider {
    my ( $self, $server, $role, $metadata, $public_key, $ca_cert_chain ) =
      splice @_;

    return 0
      unless ( $server->isa("Lasso::Server")
        and defined $role
        and defined $metadata );

    eval {
        Lasso::Server::add_provider_from_buffer( $server, $role, $metadata,
            $public_key, $ca_cert_chain );
    };

    return $self->checkLassoError($@);

}

## @method string getOrganizationName(Lasso::Server server, string idp)
# Return name of organization picked up from metadata
#@param server Lasso::Server object
#@param string entityID
#@return string organization name
sub getOrganizationName {
    my ( $self, $server, $idp ) = splice @_;
    my ( $provider, $node );

    # Get provider from server
    eval { $provider = Lasso::Server::get_provider( $server, $idp ); };

    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    # Get organization node
    eval { $node = Lasso::Provider::get_organization($provider); };

    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    # Return if node is empty
    return unless $node;

    # Extract organization name
    my $xs   = XML::Simple->new();
    my $data = $xs->XMLin($node);
    return $data->{OrganizationName}->{content};
}

## @method string getNextProviderId(Lasso::Logout logout)
# Returns the provider id from providerID_index in list of providerIDs in
# principal session with the exception of initial service provider ID.
# @param logout Lasso::Logout object
# @return string
sub getNextProviderId {
    my $self   = shift;
    my $logout = shift;
    my $providerId;

    eval { $providerId = Lasso::Logout::get_next_providerID($logout); };
    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    return $providerId;
}

## @method boolean resetProviderIdIndex(Lasso::Logout logout)
# Reset the providerID_index attribute in Lasso::Logout object
# @param logout Lasso::Logout object
# @return boolean
sub resetProviderIdIndex {
    my $self   = shift;
    my $logout = shift;

    eval { Lasso::Logout::reset_providerID_index($logout); };
    return $self->checkLassoError($@);
}

## @method Lasso::Login createAuthnRequest(Lasso::Server server, string idp, int method, boolean forceAuthn, boolean isPassive, string nameIDFormat, boolean allowProxiedAuthn, boolean signSSOMessage, string requestedAuthnContext)
# Create authentication request for selected IDP
# @param server Lasso::Server object
# @param entityID IDP entityID
# @param method HTTP method
# @param forceAuthn force authentication on IDP
# @param isPassive require passive authentication
# @param nameIDFormat SAML2 NameIDFormat
# @param allowProxiedAuthn allow proxy on IDP
# @param signSSOMessage sign request
# @param requestedAuthnContext authentication context
# @return Lasso::Login object
sub createAuthnRequest {
    my (
        $self,         $server,            $idp,
        $method,       $forceAuthn,        $isPassive,
        $nameIDFormat, $allowProxiedAuthn, $signSSOMessage,
        $requestedAuthnContext
    ) = splice @_;

    # Create Lasso Login
    my $login = $self->createLogin($server);

    unless ($login) {
        $self->lmLog( 'Unable to create Lasso login', 'error' );
        return;
    }

    # Init authentication request
    unless ( $self->initAuthnRequest( $login, $idp, $method ) ) {
        $self->lmLog( "Could not initiate authentication request on $idp",
            'error' );
        return;
    }

    # Set RelayState
    my $infos;
    foreach (qw /urldc/) {
        $infos->{$_} = $self->{$_} if $self->{$_};
    }
    my $relaystate = $self->storeRelayState($infos);
    $login->msg_relayState($relaystate);
    $self->lmLog( "Set $relaystate in RelayState", 'debug' );

    # Customize request
    my $request = $login->request();

    # NameIDFormat
    if ($nameIDFormat) {
        $self->lmLog( "Use NameIDFormat $nameIDFormat", 'debug' );
        $request->NameIDPolicy()->Format($nameIDFormat);
    }

    # Always allow NameID creation
    $request->NameIDPolicy()->AllowCreate(1);

    # Force authentication
    if ($forceAuthn) {
        $self->lmLog( "Force authentication on IDP", 'debug' );
        $request->ForceAuthn(1);
    }

    # Passive authentication
    if ($isPassive) {
        $self->lmLog( "Passive authentication on IDP", 'debug' );
        $request->IsPassive(1);
    }

    # Allow proxy
    unless ($allowProxiedAuthn) {
        $self->lmLog( "Do not allow this request to be proxied", 'debug' );
        eval {
            my $proxyRestriction = Lasso::Saml2ProxyRestriction->new();
            $proxyRestriction->Audience($idp);
            $proxyRestriction->Count(0);
            my $conditions = $request->Conditions()
              || Lasso::Saml2Conditions->new();
            $conditions->ProxyRestriction($proxyRestriction);
            $request->Conditions($conditions);
        };
        if ($@) {
            $self->checkLassoError($@);
            return;
        }
    }

    # Signature
    unless ($signSSOMessage) {
        $self->lmLog( "Do not sign this SSO request", 'debug' );
        return unless ( $self->disableSignature($login) );
    }

    # Requested authentication context
    if ($requestedAuthnContext) {
        $self->lmLog( "Request $requestedAuthnContext context", 'debug' );
        eval {
            my $context = Lasso::Samlp2RequestedAuthnContext->new();
            $context->AuthnContextClassRef($requestedAuthnContext);
            $context->Comparison("minimum");
            $request->RequestedAuthnContext($context);
        };
        if ($@) {
            $self->checkLassoError($@);
            return;
        }
    }

    # Build authentication request
    unless ( $self->buildAuthnRequestMsg($login) ) {
        $self->lmLog( "Could not build authentication request on $idp",
            'error' );
        return;
    }

    return $login;
}

## @method Lasso::Login createLogin(Lasso::Server server, string dump)
# Create Lasso::Login object
# @param server Lasso::Server object
# @param dump optional XML dump
# @return Lasso::Login object
sub createLogin {
    my ( $self, $server, $dump ) = splice @_;
    my $login;

    if ($dump) {
        eval { $login = Lasso::Login::new_from_dump( $server, $dump ); };
    }
    else {
        eval { $login = Lasso::Login->new($server); };
    }

    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    return $login;
}

## @method boolean initAuthnRequest(Lasso::Login login, string idp, int method)
# Init authentication request
# @param Lasso::Login login
# @param string entityID
# @param int HTTP method
# @return boolean result
sub initAuthnRequest {
    my ( $self, $login, $idp, $method ) = splice @_;

    eval { Lasso::Login::init_authn_request( $login, $idp, $method ); };

    return $self->checkLassoError($@);
}

## @method boolean buildAuthnRequestMsg(Lasso::Login login)
# Build authentication request message
# @param Lasso::Login login
# @return boolean result
sub buildAuthnRequestMsg {
    my ( $self, $login ) = splice @_;

    eval { Lasso::Login::build_authn_request_msg($login); };

    return $self->checkLassoError($@);
}

## @method boolean processAuthnRequestMsg(Lasso::Login login, string request)
# Process authentication request message
# @param login Lasso::Login object
# @param response SAML request
# @return result
sub processAuthnRequestMsg {
    my ( $self, $login, $request ) = splice @_;

    eval { Lasso::Login::process_authn_request_msg( $login, $request ); };

    return $self->checkLassoError($@);
}

## @method boolean validateRequestMsg(Lasso::Login login, boolean auth, boolean consent)
# Validate request message
# @param login Lasso::Login object
# @param auth is user authenticated?
# @param consent is consent obtained?
# @return result
sub validateRequestMsg {
    my ( $self, $login, $auth, $consent ) = splice @_;

    eval { Lasso::Login::validate_request_msg( $login, $auth, $consent ); };

    return $self->checkLassoError($@);
}

## @method boolean buildAuthnResponseMsg(Lasso::Login login)
# Build authentication response message
# @param login Lasso::Login object
# @return boolean result
sub buildAuthnResponseMsg {
    my ( $self, $login ) = splice @_;

    eval { Lasso::Login::build_authn_response_msg($login); };

    return $self->checkLassoError($@);
}

## @method boolean buildArtifactMsg(Lasso::Login login, int method)
# Build artifact message
# @param login Lasso::Login object
# @param method HTTP method
# @return boolean result
sub buildArtifactMsg {
    my ( $self, $login, $method ) = splice @_;

    eval { Lasso::Login::build_artifact_msg( $login, $method ); };

    return $self->checkLassoError($@);
}

## @method boolean buildAssertion(Lasso::Login login, string authn_context)
# Build assertion
# @param login Lasso::Login object
# @param authn_context SAML2 authentication context
# @return boolean result
sub buildAssertion {
    my ( $self, $login, $authn_context ) = splice @_;

    # Dates
    my $time                    = $self->{sessionInfo}->{_utime} || time();
    my $timeout                 = $time + $self->{timeout};
    my $authenticationInstant   = $self->timestamp2samldate($time);
    my $reauthenticateOnOrAfter = $self->timestamp2samldate($timeout);
    my $notBefore               = $authenticationInstant;
    my $notOnOrAfter            = $reauthenticateOnOrAfter;

    eval {
        Lasso::Login::build_assertion( $login, $authn_context,
            $authenticationInstant, $reauthenticateOnOrAfter, $notBefore,
            $notOnOrAfter );
    };

    return $self->checkLassoError($@);
}

## @method boolean processAuthnResponseMsg(Lasso::Login login, string response)
# Process authentication response message
# @param login Lasso::Login object
# @param response SAML response
# @return result
sub processAuthnResponseMsg {
    my ( $self, $login, $response ) = splice @_;

    eval { Lasso::Login::process_authn_response_msg( $login, $response ); };

    return $self->checkLassoError($@);
}

## @method Lasso::Saml2NameID getNameIdentifer(Lasso::Profile profile)
# Get NameID from Lasso Profile
# @param profile Lasso::Profile object
# @return result or NULL if error
sub getNameIdentifier {
    my ( $self, $profile ) = splice @_;
    my $nameid;

    eval { $nameid = Lasso::Profile::get_nameIdentifier($profile); };

    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    return $nameid;
}

## @method Lasso::Identity createIdentity(string dump)
# Create Lasso::Identity object
# @param dump optional Identity dump
# @return Lasso::Identity object
sub createIdentity {
    my ( $self, $dump ) = splice @_;
    my $identity;

    if ($dump) {
        eval { $identity = Lasso::Identity::new_from_dump($dump); };
    }
    else {
        eval { $identity = Lasso::Identity->new(); };
    }

    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    return $identity;
}

## @method Lasso::Session createSession(string dump)
# Create Lasso::Session object
# @param dump optional Session dump
# @return Lasso::Session object
sub createSession {
    my ( $self, $dump ) = splice @_;
    my $session;

    if ($dump) {
        eval { $session = Lasso::Session::new_from_dump($dump); };
    }
    else {
        eval { $session = Lasso::Session->new(); };
    }

    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    return $session;
}

## @method boolean acceptSSO(Lasso::Login login)
# Accept SSO from IDP
# @param login Lasso::Login object
# @return result
sub acceptSSO {
    my ( $self, $login ) = splice @_;

    eval { Lasso::Login::accept_sso($login); };

    return $self->checkLassoError($@);
}

## @method string storeRelayState(hashref infos)
# Store information in relayState database and return
# corresponding session_id
# @param infos HASH reference of information
sub storeRelayState {
    my ( $self, $infos ) = splice @_;
    my %h;

    # Create relaystate session
    eval { tie %h, $self->{samlStorage}, undef, $self->{samlStorageOptions}; };
    if ($@) {
        $self->lmLog( "Unable to create relaystate session: $@", 'error' );
        return;
    }

    # Session type
    $h{_type} = "relaystate";

    # UNIX time
    $h{_utime} = time();

    # Store infos in relaystate session
    foreach ( keys %$infos ) {
        $h{$_} = $infos->{$_};
    }

    # Session ID
    my $relaystate_id = $h{_session_id};

    # Close session
    untie %h;

    # Return session ID
    return $relaystate_id;

}

## @method boolean extractRelayState(string relaystate)
# Extract RelayState information into $self
# @param relayState relayState value
# @return result
sub extractRelayState {
    my ( $self, $relaystate ) = splice @_;
    my %h;

    return 0 unless $relaystate;

    # Open relaystate session
    eval {
        tie %h, $self->{samlStorage}, $relaystate, $self->{samlStorageOptions};
    };
    if ($@) {
        $self->lmLog( "Unable to open relaystate session: $@", 'error' );
        return 0;
    }

    # Push values in $self
    foreach ( keys %h ) {
        next if $_ =~ /(type|_session_id|_utime)/;
        $self->{$_} = $h{$_};
    }

    return 1;
}

## @method Lasso::Node getAssertion(Lasso::Login login)
# Get assertion in Lasso::Login object
# @param login Lasso::Login object
# @return assertion Lasso::Node object
sub getAssertion {
    my ( $self, $login ) = splice @_;
    my $assertion;

    eval { $assertion = Lasso::Login::get_assertion($login); };

    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    return $assertion;
}

## @method string getAttributeValue(string name, string format, string friendly_name, array_ref attributes, boolean force_utf8)
# Get SAML attribute value corresponding to name, format and friendly_name
# Multivaluated values are separated by multiValuesSeparator
# If force_utf8 flag is set, value is encoded in UTF-8
# @param name SAML attribute name
# @param format optional SAML attribute format
# @param friendly_name optional SAML attribute friendly name
# @param force_utf8 optional flag to force value in UTF-8
# @return attribute value
sub getAttributeValue {
    my ( $self, $name, $format, $friendly_name, $attributes, $force_utf8 ) =
      splice @_;
    my $value;

    # Loop on attributes
    foreach (@$attributes) {
        my $attr_name   = $_->Name();
        my $attr_format = $_->NameFormat();
        my $attr_fname  = $_->FriendlyName();

        # Skip if name does not correspond to attribute name
        next if ( $name ne $attr_name );

        # Verify format and friendly name if given
        next if ( $format        and $format        ne $attr_format );
        next if ( $friendly_name and $friendly_name ne $attr_fname );

        # Attribute is found, return its content
        my @attr_values = $_->AttributeValue();

        foreach (@attr_values) {
            my $xs      = XML::Simple->new();
            my $data    = $xs->XMLin( $_->dump() );
            my $content = $data->{content};
            $value .= $content . $self->{multiValuesSeparator} if $content;
        }
        $value =~ s/\Q$self->{multiValuesSeparator}\E$//;

        # Encode UTF-8 if force_utf8 flag
        $value = encode( "utf8", $value ) if $force_utf8;

    }

    return $value;
}

## @method boolean validateConditions(Lasso::Saml2::Assertion assertion, string entityID)
# Validate conditions
# @param assertion SAML2 assertion
# @param entityID relaying party entity ID
# @return result
sub validateConditions {
    my ( $self, $assertion, $entityID ) = splice @_;
    my $tolerance = 10;
    my $status;

    # Time
    eval {
        $status =
          Lasso::Saml2Assertion::validate_time_checks( $assertion, $tolerance );
    };

    if ($@) {
        $self->checkLassoError($@);
        return 0;
    }

    unless ( $status eq Lasso::Constants::SAML2_ASSERTION_VALID ) {
        $self->lmLog( "Time conditions validations result: $status", 'error' );
        return 0;
    }

    $self->lmLog( "Time conditions validated", 'debug' );

    # Audience
    eval {
        $status =
          Lasso::Saml2Assertion::validate_audience( $assertion, $entityID );
    };

    if ($@) {
        $self->checkLassoError($@);
        return 0;
    }

    unless ( $status eq Lasso::Constants::SAML2_ASSERTION_VALID ) {
        $self->lmLog( "Audience conditions validations result: $status",
            'error' );
        return 0;
    }

    $self->lmLog( "Audience conditions validated", 'debug' );

    return 1;
}

## @method Lasso::Logout createLogoutRequest(Lasso::Server server, string session_dump, int method, boolean signSLOMessage)
# Create logout request for selected entity
# @param server Lasso::Server object
# @param session_dump Lasso::Session dump
# @param method HTTP method
# @param signSLOMessage sign request
# @return Lasso::Login object
sub createLogoutRequest {
    my ( $self, $server, $session_dump, $method, $signSLOMessage ) = splice @_;
    my $session;

    # Create Lasso Logout
    my $logout = $self->createLogout($server);

    unless ( $self->setSessionFromDump( $logout, $session_dump ) ) {
        $self->lmLog( "Could not fill Lasso::Logout with session dump",
            'error' );
        return;
    }

    # Init logout request
    unless ( $self->initLogoutRequest( $logout, undef, $method ) ) {
        $self->lmLog( "Could not initiate logout request", 'error' );
        return;
    }

    # Set RelayState
    my $infos;
    foreach (qw /urldc/) {
        $infos->{$_} = $self->{$_} if $self->{$_};
    }
    my $relaystate = $self->storeRelayState($infos);
    $logout->msg_relayState($relaystate);
    $self->lmLog( "Set $relaystate in RelayState", 'debug' );

    # Signature
    unless ($signSLOMessage) {
        $self->lmLog( "Do not sign this SLO request", 'debug' );
        return unless ( $self->disableSignature($logout) );
    }

    # Build logout request
    unless ( $self->buildLogoutRequestMsg($logout) ) {
        $self->lmLog( "Could not build logout request", 'error' );
        return;
    }

    return $logout;

}

## @method Lasso::Logout createLogout(Lasso::Server server)
# Create Lasso::Logout object
# @param server Lasso::Server object
# @return Lasso::Logout object
sub createLogout {
    my ( $self, $server ) = splice @_;
    my $logout;

    eval { $logout = Lasso::Logout->new($server); };

    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    return $logout;
}

## @method boolean initLogoutRequest(Lasso::Logout logout, string entityID, int method)
# Init logout request
# @param logout Lasso::Logout object
# @param entityID
# @param HTTP method
# @return result
sub initLogoutRequest {
    my ( $self, $logout, $entityID, $method ) = splice @_;

    eval { Lasso::Logout::init_request( $logout, $entityID, $method ); };

    return $self->checkLassoError($@);
}

## @method boolean buildLogoutRequestMsg(Lasso::Logout logout)
# Build logout request message
# @param logout Lasso::Logout object
# @return result
sub buildLogoutRequestMsg {
    my ( $self, $logout ) = splice @_;

    eval { Lasso::Logout::build_request_msg($logout); };

    return $self->checkLassoError($@);
}

## @method boolean setSessionFromDump(Lasso::Profile profile, string dump)
# Set session from dump in Lasso::Profile object
# @param profile Lasso::Profile object
# @param dump Lasso::Session XML dump
# @return result
sub setSessionFromDump {
    my ( $self, $profile, $dump ) = splice @_;

    eval { Lasso::Profile::set_session_from_dump( $profile, $dump ); };

    return $self->checkLassoError($@);
}

## @method boolean setIdentityFromDump(Lasso::Profile profile, string dump)
# Set identity from dump in Lasso::Profile object
# @param profile Lasso::Profile object
# @param dump Lasso::Identity XML dump
# @return result
sub setIdentityFromDump {
    my ( $self, $profile, $dump ) = splice @_;

    eval { Lasso::Profile::set_identity_from_dump( $profile, $dump ); };

    return $self->checkLassoError($@);
}

## @method string getMetaDataURL(string key, int index)
# Get URL stored in a service metadata configuration key
# @param key Metadata configuration key
# @param index field index containing URL
# @return url
sub getMetaDataURL {
    my ( $self, $key, $index ) = splice @_;
    $index = 3 unless defined $index;

    return unless defined $self->{$key};

    return ( split( /;/, $self->{$key} ) )[$index];
}

## @method boolean processLogoutResponseMsg(Lasso::Logout logout, string response)
# Process logout response message
# @param logout Lasso::Logout object
# @param response SAML response
# @return result
sub processLogoutResponseMsg {
    my ( $self, $logout, $response ) = splice @_;

    eval { Lasso::Logout::process_response_msg( $logout, $response ); };

    return $self->checkLassoError($@);
}

## @method boolean processLogoutRequestMsg(Lasso::Logout logout, string request)
# Process logout request message
# @param logout Lasso::Logout object
# @param request SAML request
# @return result
sub processLogoutRequestMsg {
    my ( $self, $logout, $request ) = splice @_;

    eval { Lasso::Logout::process_request_msg( $logout, $request ); };

    return $self->checkLassoError($@);
}

## @method boolean validateLogoutRequest(Lasso::Logout logout)
# Validate logout request
# @param logout Lasso::Logout object
# @return result
sub validateLogoutRequest {
    my ( $self, $logout ) = splice @_;

    eval { Lasso::Logout::validate_request($logout); };

    return $self->checkLassoError($@);
}

## @method boolean buildLogoutResponseMsg(Lasso::Logout logout)
# Build logout response message
# @param Lasso::Logout logout
# @return boolean result
sub buildLogoutResponseMsg {
    my ( $self, $logout ) = splice @_;

    eval { Lasso::Logout::build_response_msg($logout); };

    return $self->checkLassoError($@);
}

## @method boolean storeReplayProtection(string samlID)
# Store ID of an SAML message in Replay Protection base
# @param samlID ID of SAML message
# @param samlData Optional data to store
# @return result
sub storeReplayProtection {
    my ( $self, $samlID, $samlData ) = splice @_;
    my %h;

    eval { tie %h, $self->{samlStorage}, undef, $self->{samlStorageOptions}; };
    if ( $@ or !$samlID ) {
        $self->lmLog( "Unable to create replay protection session: $@",
            'error' );
        return 0;
    }

    $h{type}   = 'assertion';    # Session type
    $h{_utime} = time();         # Creation time
    $h{ID}     = $samlID;

    if ( defined $samlData && $samlData ) {
        $h{data} = $samlData;
    }

    my $session_id = $h{_session_id};

    untie %h;

    $self->lmLog( "Keep request ID $samlID in assertion session $session_id",
        'debug' );

    return 1;
}

## @method boolean replayProtection(string samlID)
# Check if SAML message do not correspond to a previously responded message
# @param samlID ID of initial SAML message
# @return result
sub replayProtection {
    my ( $self, $samlID ) = splice @_;
    my %h;

    unless ($samlID) {
        $self->lmLog( "Cannot verify replay because no SAML ID given",
            'error' );
        return 0;
    }

    my $sessions =
      $self->{samlStorage}
      ->searchOn( $self->{samlStorageOptions}, "ID", $samlID );

    if ( my @keys = keys %$sessions ) {

        # A session was found
        foreach (@keys) {
            my $session = $_;
            my $result  = 1;

            # Delete it
            eval {
                tie %h, $self->{samlStorage}, $_, $self->{samlStorageOptions};
            };
            if ($@) {
                $self->lmLog(
"Unable to recover assertion session $session (Message ID $samlID)",
                    'error'
                );
                return 0;
            }
            if ( defined $h{data} ) {
                $result = $h{data};
            }
            eval { tied(%h)->delete(); };
            if ($@) {
                $self->lmLog(
"Unable to delete assertion session $session (Message ID $samlID)",
                    'error'
                );
                return 0;
            }
            $self->lmLog(
                "Assertion session $session (Message ID $samlID) was deleted",
                'debug' );
            return $result;
        }
    }

    return 0;
}

## @method string resolveArtifact(Lasso::Profile profile, string artifact, int method)
# Resolve artifact to get real SAML message
# @param profile Lasso::Profile object
# @param artifact Artifact message
# @param method HTTP method
# @return SAML message
sub resolveArtifact {
    my ( $self, $profile, $artifact, $method ) = splice @_;
    my $message;

    # LWP User Agent
    my $ua = new LWP::UserAgent;
    push @{ $ua->requests_redirectable }, 'POST';

    # Login profile
    if ( $profile->isa("Lasso::Login") ) {

        # Init request message
        eval { Lasso::Login::init_request( $profile, $artifact, $method ); };
        return unless $self->checkLassoError($@);

        # Build request message
        eval { Lasso::Login::build_request_msg($profile); };
        return unless $self->checkLassoError($@);

        unless ( $profile->msg_url ) {
            $self->lmLog( "No artifcat resolution URL found", 'error' );
            return;
        }

        my $request = HTTP::Request->new( 'POST' => $profile->msg_url );
        $request->content_type('text/xml');
        $request->content( $profile->msg_body );

        $self->lmLog(
            "Send message " . $profile->msg_body . " to " . $profile->msg_url,
            'debug' );

        # SOAP call
        my $soap_answer = $ua->request($request);
        if ( $soap_answer->code() == "200" ) {
            $message = $soap_answer->content();
            $self->lmLog( "Get message $message", 'debug' );
        }
    }

    return $message;
}

## @method boolean storeArtifact(string id, string message, string session_id)
# Store artifact
# @param id Artifact ID
# @param message Artifact content
# @param session_id Session ID
# @return result
sub storeArtifact {
    my ( $self, $id, $message, $session_id ) = splice @_;
    my %h;

    eval { tie %h, $self->{samlStorage}, undef, $self->{samlStorageOptions}; };
    if ( $@ or !$id or !$message ) {
        $self->lmLog( "Unable to create artifact session: $@", 'error' );
        return 0;
    }

    $h{type}       = 'artifact';    # Session type
    $h{_utime}     = time();        # Creation time
    $h{ID}         = $id;
    $h{message}    = $message;
    $h{session_id} = $session_id;

    my $art_session_id = $h{_session_id};

    untie %h;

    $self->lmLog( "Keep artifact $id in session $art_session_id", 'debug' );

    return 1;
}

## @method hashRef loadArtifact(string id)
# Load artifact
# @param id Artifact ID
# @return Artifact session content
sub loadArtifact {
    my ( $self, $id ) = splice @_;
    my $art_session;
    my %h;

    unless ($id) {
        $self->lmLog( "Cannot load artifact because no id given", 'error' );
        return;
    }

    my $sessions =
      $self->{samlStorage}->searchOn( $self->{samlStorageOptions}, "ID", $id );

    if ( my @keys = keys %$sessions ) {

        my $nb_sessions = $#keys + 1;

        $self->lmLog( "Found $nb_sessions sessions for artifact $id", 'debug' );

        # There should only be 1 result
        return if ( $nb_sessions != 1 );

        my $session_id = shift @keys;
        my $session    = $session_id;

        # Open session
        eval {
            tie %h, $self->{samlStorage}, $session_id,
              $self->{samlStorageOptions};
        };
        if ($@) {
            $self->lmLog(
                "Unable to recover artifact session $session (ID $id): $@",
                'error' );
            return;
        }

        # Get session contents
        foreach ( keys %h ) {
            $art_session->{$_} = $h{$_};
        }

        # Delete session
        eval { tied(%h)->delete(); };
        if ($@) {
            $self->lmLog( "Unable to delete artifact session $session (ID $id)",
                'error' );
            return;
        }
        $self->lmLog( "Artifact session $session (ID $id) was deleted",
            'debug' );

        return $art_session;
    }

    return;
}

## @method string createArtifactResponse(Lasso::Login login)
# Create artifact response
# @param login Lasso::Login object
# @return Artifact response
sub createArtifactResponse {
    my ( $self, $login ) = splice @_;

    my $artifact_id = $login->assertionArtifact();

    # Load artifact message into login response
    my $art_session = $self->loadArtifact($artifact_id);
    eval { $login->set_artifact_message( $art_session->{message} ); };
    if ($@) {
        $self->checkLassoError($@);
        $self->lmLog( "Cannot load artifact message", 'error' );
        return;
    }

    $self->lmLog( "Response loaded", 'debug' );

    # Get Lasso session
    my $session_id = $art_session->{session_id};
    unless ($session_id) {
        $self->lmLog( "Cannot find session_id in artifact session", 'error' );
        return;
    }

    my $session = $self->getApacheSession( $session_id, 1 );
    unless ( defined $session ) {
        $self->lmLog( "Unable to open session $session_id", 'error' );
        return;
    }

    my $lassoSession = $session->{_lassoSessionDump};

    if ($lassoSession) {
        unless ( $self->setSessionFromDump( $login, $lassoSession ) ) {
            $self->lmLog( "Unable to load Lasso Session", 'error' );
            return;
        }
        $self->lmLog( "Lasso Session loaded", 'debug' );
    }

    # Build artifact response
    eval { Lasso::Login::build_response_msg($login); };
    if ($@) {
        $self->checkLassoError($@);
        $self->lmLog( "Cannot build artifact response", 'error' );
        return;
    }
    $self->lmLog( "Artifact response built", 'debug' );

    # Store Lasso session
    if ( $login->is_session_dirty ) {
        $self->lmLog( "Save Lasso session in session", 'debug' );
        $self->updateSession(
            { _lassoSessionDump => $login->get_session->dump }, $session_id );
    }

    # Return artifact message
    return $login->msg_body;
}

## @method boolean processArtRequestMsg(Lasso::Profile profile, string request)
# Process artifact request message
# @param profile Lasso::Profile object
# @param response SAML request
# @return result
sub processArtRequestMsg {
    my ( $self, $profile, $request ) = splice @_;

    # Login profile
    if ( $profile->isa("Lasso::Login") ) {

        eval { Lasso::Login::process_request_msg( $profile, $request ); };
        return $self->checkLassoError($@);

    }

    return 0;
}

## @method boolean processArtResponseMsg(Lasso::Profile profile, string response)
# Process artifact response message
# @param profile Lasso::Profile object
# @param response SAML response
# @return result
sub processArtResponseMsg {
    my ( $self, $profile, $response ) = splice @_;

    # Login profile
    if ( $profile->isa("Lasso::Login") ) {

        eval { Lasso::Login::process_response_msg( $profile, $response ); };
        return $self->checkLassoError($@);

    }

    return 0;
}

## @method string sendSOAPMessage(string endpoint, string message)
# Send SOAP message and get response
# @param endpoint SOAP End Point
# @param message SOAP message
# @return SOAP response
sub sendSOAPMessage {
    my ( $self, $endpoint, $message ) = splice @_;
    my $response;

    # LWP User Agent
    my $ua = new LWP::UserAgent;
    push @{ $ua->requests_redirectable }, 'POST';

    my $request = HTTP::Request->new( 'POST' => $endpoint );
    $request->content_type('text/xml');
    $request->content($message);

    $self->lmLog( "Send SOAP message $message to $endpoint", 'debug' );

    # SOAP call
    my $soap_answer = $ua->request($request);
    if ( $soap_answer->code() == "200" ) {
        $response = $soap_answer->content();
        $self->lmLog( "Get response $response", 'debug' );
    }
    else {
        $self->lmLog( "No response to SOAP request", 'debug' );
        return;
    }

    return $response;
}

## @method Lasso::AssertionQuery createAttributeRequest(Lasso::Server server, Lasso::Login login, string idp, hashref attributes)
# Create an attribute request
# @param server Lasso::Server object
# @param login Lasso::Login object
# @param idp IDP entityID
# @param attributes List of requested attributes
# @return assertion request
sub createAttributeRequest {
    my ( $self, $server, $login, $idp, $attributes ) = splice @_;
    my $query;

    # Create assertion query
    eval { $query = Lasso::AssertionQuery->new($server); };
    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    $self->lmLog( "Assertion query created", 'debug' );

    # Set identity
    return
      unless (
        $self->setIdentityFromDump( $query, $login->get_identity()->dump ) );

    $self->lmLog( "Identity set in query", 'debug' );

    # Init request
    my $method = Lasso::Constants::HTTP_METHOD_SOAP;
    my $type   = Lasso::Constants::ASSERTION_QUERY_REQUEST_TYPE_ATTRIBUTE;
    eval {
        Lasso::AssertionQuery::init_request( $query, $idp, $method, $type );
    };
    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    $self->lmLog( "Assertion query request initiated", 'debug' );

    # Store attributes in request
    my @requested_attributes;
    foreach ( keys %$attributes ) {

        # Create SAML2 Attribute
        my $attribute;

        eval { $attribute = Lasso::Saml2Attribute->new(); };
        if ($@) {
            $self->checkLassoError($@);
            return;
        }

        # Set attribute properties
        my ( $mandatory, $name, $format, $friendly_name ) =
          split( /;/, $attributes->{$_} );

        $attribute->Name($name)                  if defined $name;
        $attribute->NameFormat($format)          if defined $format;
        $attribute->FriendlyName($friendly_name) if defined $friendly_name;

        # Store attribute
        push @requested_attributes, $attribute;
    }

    # Set attributes in request
    eval { $query->request()->Attribute(@requested_attributes); };
    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    # Build message
    eval { Lasso::AssertionQuery::build_request_msg($query); };
    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    # Return query
    return $query;
}

## @method Lasso::AssertionQuery processAttributeResponse(Lasso::Server server, string response)
# Process an attribute response
# @param server Lasso::Server object
# @param response Response content
# @return assertion query
sub processAttributeResponse {
    my ( $self, $server, $response ) = splice @_;
    my $query;

    # Create assertion query
    eval { $query = Lasso::AssertionQuery->new($server); };
    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    $self->lmLog( "Assertion query created", 'debug' );

    # Process response
    eval { Lasso::AssertionQuery::process_response_msg( $query, $response ); };
    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    $self->lmLog( "Attribute response is valid", 'debug' );

    return $query;
}

## @method string getNameIDFormat(string format)
# Convert configuration string into SAML2 NameIDFormat string
# @param format configuration string
# @return SAML2 NameIDFormat string
sub getNameIDFormat {
    my ( $self, $format ) = splice @_;

    return Lasso::Constants::SAML2_NAME_IDENTIFIER_FORMAT_UNSPECIFIED
      if ( $format =~ /unspecified/i );
    return Lasso::Constants::SAML2_NAME_IDENTIFIER_FORMAT_EMAIL
      if ( $format =~ /email/i );
    return Lasso::Constants::SAML2_NAME_IDENTIFIER_FORMAT_X509
      if ( $format =~ /x509/i );
    return Lasso::Constants::SAML2_NAME_IDENTIFIER_FORMAT_WINDOWS
      if ( $format =~ /windows/i );
    return Lasso::Constants::SAML2_NAME_IDENTIFIER_FORMAT_KERBEROS
      if ( $format =~ /kerberos/i );
    return Lasso::Constants::SAML2_NAME_IDENTIFIER_FORMAT_ENTITY
      if ( $format =~ /entity/i );
    return Lasso::Constants::SAML2_NAME_IDENTIFIER_FORMAT_PERSISTENT
      if ( $format =~ /persistent/i );
    return Lasso::Constants::SAML2_NAME_IDENTIFIER_FORMAT_TRANSIENT
      if ( $format =~ /transient/i );
    return Lasso::Constants::SAML2_NAME_IDENTIFIER_FORMAT_ENCRYPTED
      if ( $format =~ /encrypted/i );

    return;
}

## @method int getHttpMethod(string method)
# Convert configuration string into Lasso HTTP Method integer
# @param method configuration string
# @return Lasso HTTP Method integer
sub getHttpMethod {
    my ( $self, $method ) = splice @_;

    return Lasso::Constants::HTTP_METHOD_POST
      if ( $method =~ /^(http)?[-_]?post$/i );
    return Lasso::Constants::HTTP_METHOD_REDIRECT
      if ( $method =~ /^(http)?[-_]?redirect$/i );
    return Lasso::Constants::HTTP_METHOD_SOAP
      if ( $method =~ /^(http)?[-_]?soap$/i );
    return Lasso::Constants::HTTP_METHOD_ARTIFACT_GET
      if ( $method =~ /^(artifact)[-_]get$/i );
    return Lasso::Constants::HTTP_METHOD_ARTIFACT_POST
      if ( $method =~ /^(artifact)[-_]post$/i );

    return;
}

## @method int getHttpMethodString(int method)
# Convert configuration Lasso HTTP Method integer into string
# @param method Lasso HTTP Method
# @return method string
sub getHttpMethodString {
    my ( $self, $method ) = splice @_;

    return "POST"     if ( $method == Lasso::Constants::HTTP_METHOD_POST );
    return "REDIRECT" if ( $method == Lasso::Constants::HTTP_METHOD_REDIRECT );
    return "SOAP"     if ( $method == Lasso::Constants::HTTP_METHOD_SOAP );
    return "ARTIFACT GET"
      if ( $method == Lasso::Constants::HTTP_METHOD_ARTIFACT_GET );
    return "ARTIFACT POST"
      if ( $method == Lasso::Constants::HTTP_METHOD_ARTIFACT_POST );

    return "UNDEFINED";
}
## @method int getFirstHttpMethod(Lasso::Server server, string entityID, int protcolType)
# Find a suitable HTTP method for an entity with a given protocol
# @param server Lasso::Server object
# @param entityID entity ID
# @param protocolType Lasso protocol type
# @return Lasso HTTP Method
sub getFirstHttpMethod {
    my ( $self, $server, $entityID, $protocolType ) = splice @_;
    my $entity_provider;
    my $method;

    # Get Lasso::Provider object
    eval {
        $entity_provider = Lasso::Server::get_provider( $server, $entityID );
    };
    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    # Find HTTP method
    eval {
        $method =
          Lasso::Provider::get_first_http_method( $server, $entity_provider,
            $protocolType );
    };
    if ($@) {
        $self->checkLassoError($@);
        return;
    }

    return $method;
}

## @method boolean disableSignature(Lasso::Profile profile)
# Modify Lasso signature hint to disable signature
# @param profile Lasso profile object
# @return result
sub disableSignature {
    my ( $self, $profile ) = splice @_;

    eval {
        Lasso::Profile::set_signature_hint( $profile,
            Lasso::Constants::PROFILE_SIGNATURE_HINT_FORBID );
    };

    return $self->checkLassoError($@);
}

## @method boolean forceSignature(Lasso::Profile profile)
# Modify Lasso signature hint to force signature
# @param profile Lasso profile object
# @return result
sub forceSignature {
    my ( $self, $profile ) = splice @_;

    eval {
        Lasso::Profile::set_signature_hint( $profile,
            Lasso::Constants::PROFILE_SIGNATURE_HINT_FORCE );
    };

    return $self->checkLassoError($@);
}

## @method boolean disableSignatureVerification(Lasso::Profile profile)
# Modify Lasso signature hint to disable signature verification
# @param profile Lasso profile object
# @return result
sub disableSignatureVerification {
    my ( $self, $profile ) = splice @_;

    eval {
        Lasso::Profile::set_signature_verify_hint( $profile,
            Lasso::Constants::PROFILE_SIGNATURE_VERIFY_HINT_IGNORE );
    };

    return $self->checkLassoError($@);
}

## @method string getAuthnContext(string context)
# Convert configuration string into SAML2 AuthnContextClassRef string
# @param context configuration string
# @return SAML2 AuthnContextClassRef string
sub getAuthnContext {
    my ( $self, $context ) = splice @_;

    return Lasso::Constants::SAML2_AUTHN_CONTEXT_KERBEROS
      if ( $context =~ /^kerberos$/i );
    return Lasso::Constants::SAML2_AUTHN_CONTEXT_PASSWORD_PROTECTED_TRANSPORT
      if ( $context =~ /^password[-_ ]protected[-_ ]transport$/i );
    return Lasso::Constants::SAML2_AUTHN_CONTEXT_PASSWORD
      if ( $context =~ /^password$/i );
    return Lasso::Constants::SAML2_AUTHN_CONTEXT_X509
      if ( $context =~ /^x509$/i );
    return Lasso::Constants::SAML2_AUTHN_CONTEXT_TLS_CLIENT
      if ( $context =~ /^tls[-_ ]client$/i );
    return Lasso::Constants::SAML2_AUTHN_CONTEXT_UNSPECIFIED
      if ( $context =~ /^unspecified$/i );

    return;
}

## @method string timestamp2samldate(string timestamp)
# Convert timestamp into SAML2 date format
# @param timestamp UNIX timestamp
# @return SAML2 date
sub timestamp2samldate {
    my ( $self, $timestamp ) = splice @_;

    my @t = gmtime($timestamp);
    my $samldate = POSIX::strftime( "%Y-%m-%dT%TZ", @t );

    $self->lmLog( "Convert timestamp $timestamp in SAML2 date: $samldate",
        'debug' );

    return $samldate;
}

## @method string samldate2timestamp(string samldate)
# Convert SAML2 date format into timestamp
# @param tsamldate SAML2 date format
# @return UNIX timestamp
sub samldate2timestamp {
    my ( $self, $samldate ) = splice @_;

    my ( $year, $mon, $mday, $hour, $min, $sec, $ztime ) =
      ( $samldate =~ /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(Z)?/ );

    my $timestamp =
      timegm( $sec, $min, $hour, $mday, $mon - 1, $year - 1900, 0 );

    $self->lmLog( "Convert SAML2 date $samldate in timestamp: $timestamp",
        'debug' );

    return $timestamp;
}

## @pmethod int sendLogoutResponseToServiceProvider(Lasso::Logout $logout, int $method, string $relaystate, int $wait)
# Send logout response issue from a logout request.
# @param $logout Lasso Logout object
# @param $method Method to use
# @param $relaystate The relay state
# @param $wait If true, do not call to autoRedirect or autoPost function
# @return boolean False if failed.
sub sendLogoutResponseToServiceProvider {
    my ( $self, $logout, $method, $relaystate, $seconds ) = splice @_;

    # Logout response
    unless ( $self->buildLogoutResponseMsg($logout) ) {
        $self->lmLog( "Unable to build SLO response", 'error' );
        return 0;
    }

    # Send response depending on request method
    # HTTP-REDIRECT
    if ( $method == Lasso::Constants::HTTP_METHOD_REDIRECT ) {

        # Redirect user to response URL
        my $slo_url = $logout->msg_url;
        $self->{urldc} = $slo_url;

        $self->lmLog( "Redirect user to $slo_url", 'debug' );

        # Redirect immediately
        if ( !$seconds ) {

            $self->_subProcess(qw(autoRedirect));

            # If we are here, there was a problem with HTTP-REDIRECT response
            $self->lmLog( "Logout response was not sent trough GET", 'error' );

            return 0;

        }

    }

    # HTTP-POST
    elsif ( $method == Lasso::Constants::HTTP_METHOD_POST ) {

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
    elsif ( $method == Lasso::Constants::HTTP_METHOD_SOAP ) {

        my $slo_body = $logout->msg_body;
        $self->{SOAPMessage} = $slo_body;

        $self->lmLog( "SOAP response $slo_body", 'debug' );

        $self->_subProcess(qw(returnSOAPMessage));

        # If we are here, there was a problem with SOAP response
        $self->lmLog( "Logout response was not sent trough SOAP", 'error' );

        return 0;

    }

    return 1;

}

## @pmethod int sendLogoutRequestToServiceProvider(Lasso::Logout $logout, string $providerID, int $method)
# Send a logout request to a service provider
# If information have to be displayed to users, such as iframe to send
# HTTP-Redirect or HTTP-POST logout request, then $self->{_info} will be
# updated.
# @param $logout Lasso Logout object
# @param $providerID The concerned service provider
# @param $method The method used to send the logout request
# @param $relay If SOAP method, build a relay logout request
# @return int Number of concerned providers.
sub sendLogoutRequestToServiceProvider {
    my ( $self, $logout, $providerID, $method, $relay ) = splice @_;
    my $server = $self->{_lassoServer};
    my $info;

    # Test if provider is mentionned
    if ( !$providerID ) {
        return ( 0, undef, undef );
    }

    # Find EntityID in SPList
    unless ( defined $self->{_spList}->{$providerID} ) {
        $self->lmLog( "$providerID does not match any known SP", 'error' );
        return ( 0, undef, undef );
    }

    # Get SP Name and Conf Key from EntityID
    my $providerName = $self->{_spList}->{$providerID}->{name};
    my $spConfKey    = $self->{_spList}->{$providerID}->{confKey};

    # Get first HTTP method
    my $protocolType = Lasso::Constants::MD_PROTOCOL_TYPE_SINGLE_LOGOUT;
    if ( !$method ) {
        $method =
          $self->getFirstHttpMethod( $server, $providerID, $protocolType );
    }

    # Fix a default value for the relay parameter
    $relay = 0 unless ( defined $relay );

    # Signature
    my $signSLOMessage =
      $self->{samlSPMetaDataOptions}->{$spConfKey}
      ->{samlSPMetaDataOptionsSignSLOMessage};

    unless ($signSLOMessage) {
        $self->lmLog( "Do not sign this SLO request", 'debug' );
        return ( 0, undef, undef )
          unless ( $self->disableSignature($logout) );
    }

    # Build the request unless this is a SOAP relay logout request
    unless ( $method == Lasso::Constants::HTTP_METHOD_SOAP && $relay ) {

        $self->lmLog( "No logout request found, build it", 'debug' );

        # Initiate the logout request
        unless ( $self->initLogoutRequest( $logout, $providerID, $method ) ) {
            $self->lmLog( "Initiate logout request failed for $providerID",
                'error' );
            return ( 0, $method, undef );
        }

        # Build request message
        unless ( $self->buildLogoutRequestMsg($logout) ) {
            $self->lmLog( "Build logout request failed for $providerID",
                'error' );
            return ( 0, $method, undef );
        }

    }

    # Send logout request to the provider depending of the request method
    # HTTP-REDIRECT
    if ( $method == Lasso::Constants::HTTP_METHOD_REDIRECT ) {

        $self->lmLog( "Send HTTP-REDIRECT logout request to $providerID",
            'debug' );

        # Redirect user to response URL
        my $slo_url = $logout->msg_url;

        $info .= '<li>'
          . $providerName . '...'
          . '<iframe src="'
          . $slo_url
          . '" alt="" marginwidth="0"'
          . ' marginheight="0" scrolling="no" style="border: none"'
          . ' width="0" height="0">'
          . '<img src="'
          . $slo_url
          . '" width="0" height="0" />'
          . '</iframe></li>';

    }

    # HTTP-POST
    # TODO
    elsif ( $method == Lasso::Constants::HTTP_METHOD_POST ) {

        $self->lmLog( "Send POST logout request to $providerID", 'debug' );

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
    elsif ( $method == Lasso::Constants::HTTP_METHOD_SOAP ) {

        # Build a relay request, to be used after SLO process is done
        if ($relay) {

            $self->lmLog( "Build SOAP relay logout request for $providerID",
                'debug' );

            my $random = new String::Random;
            my $samlID = $random->randregex('[a-z0-9]{32}');

            # Build needed information to be stored into samlStorage
            my $samlData = ();
            unless ( $logout->get_session() && $logout->get_identity() ) {
                $self->lmLog(
                    "No session and identity found into logout object",
                    'error' );
                return ( 0, $method, undef );
            }
            $samlData->{_lassoSessionDump}  = $logout->get_session->dump;
            $samlData->{_lassoIdentityDump} = $logout->get_identity->dump;
            $samlData->{_providerID}        = $providerID;

            # Store information in temporary storage, to be reused then.
            return ( 0, $method, undef )
              unless ( $self->storeReplayProtection( $samlID, $samlData ) );

            $self->lmLog( "Store request for $providerID", 'debug' );

            # Build the URL that could be used to play this logout request
            my $slo_url =
              $self->{portal} . '/saml/relaySingleLogoutSOAP?relay=' . $samlID;

            # Display information to the user
            $info .= '<li>'
              . $providerName
              . '...&nbsp;&nbsp;'
              . '<img src="'
              . $slo_url
              . '" width="10" height="10" /></li>';

        }

        # Send the request directly
        else {

            $self->lmLog( "Send SOAP logout request to $providerID", 'debug' );

            my $slo_url  = $logout->msg_url;
            my $slo_body = $logout->msg_body;

            # Send SOAP request and manage response
            my $sp_response = $self->sendSOAPMessage( $slo_url, $slo_body );

            unless ($sp_response) {
                $self->lmLog( "No logout response to SOAP request", 'error' );
                return ( 0, $method, undef );
            }

            # Process logout response
            my $sp_result =
              $self->processLogoutResponseMsg( $logout, $sp_response );

            unless ($sp_result) {
                $self->lmLog( "Fail to process logout response", 'error' );
                return ( 0, $method, undef );
            }

            $self->lmLog( "Logout response is valid", 'debug' );

        }

    }

    return ( 1, $method, $info );

}

## @pmethod int sendLogoutRequestToServiceProviders(Lasso::Logout logout)
# Send logout response issue from a logout request to all other service
# providers. If information have to be displayed to users, such as
# iframe to send HTTP-Redirect or HTTP-POST logout request, then
# $self->{_info} will be updated.
# @param logout Lasso Logout object
# @return int Number of concerned providers.
sub sendLogoutRequestToServiceProviders {
    my $self           = shift;
    my $logout         = shift;
    my $server         = $self->{_lassoServer};
    my $providersCount = 0;
    my $info           = '';

    # Get EntityID
    my $entityID = $logout->remote_providerID();

    # Reset providerID into Lasso::Logout object
    $self->resetProviderIdIndex($logout);

    # Header of the block which will be displayed to the user, if needed.
    $info .=
      &Lemonldap::NG::Portal::_i18n::msg
      ( Lemonldap::NG::Portal::Simple::PM_SAML_SPLOGOUT,
        $ENV{HTTP_ACCEPT_LANGUAGE} )
      . '<ul>';

    # Foreach SP found in session, get it from configuration, and send the
    # appropriate logout request (HTTP,POST,SOAP).
    while ( my $providerID = $self->getNextProviderId($logout) ) {

        # Do not process logout on SP that initiate the logout request
        next if ( $entityID && $entityID =~ /^$providerID$/ );

        # Send logout request
        my ( $rstatus, $rmethod, $rinfo ) =
          $self->sendLogoutRequestToServiceProvider( $logout, $providerID,
            undef, 1 );

        next unless ($rstatus);

        # Count providers that have to be request by HTTP redirect
        $providersCount++;

        # Add information if necessary
        if ($rinfo) {
            $info .= $rinfo;
        }

    }

    # End of information block to be displayed to the user.
    $info .= '</ul>';

    # Print some information to the user. The URL to be redirected should
    # not be send via a form (because it does not work all time).
    if ($providersCount) {
        $self->info($info);
        $self->setHiddenFormValue( 'HttpRedirect',     'true' );
        $self->setHiddenFormValue( 'HideSubmitButton', 'true' );
    }

    return $providersCount;

}

## @method boolean checkSignatureStatus(Lasso::Profile profile)
# Check signature status
# @param profile Lasso::Profile object
# @return result
sub checkSignatureStatus {
    my ( $self, $profile ) = splice @_;

    eval { Lasso::Profile::get_signature_status($profile); };

    return $self->checkLassoError($@);
}

## @method int authnContext2authnLevel(string authnContext)
# Return authentication level corresponding to authnContext
# @param authnContext SAML authentication context
# return authentication level
sub authnContext2authnLevel {
    my ( $self, $authnContext ) = splice @_;

    return 2 if ( $authnContext eq $self->getAuthnContext("password") );
    return 3
      if (
        $authnContext eq $self->getAuthnContext("password-protected-transport")
      );
    return 5 if ( $authnContext eq $self->getAuthnContext("tls-client") );
    return 0;

}

## @method int authnLevel2authnContext(int authnLevel)
# Return SAML authentication context corresponding to authnLevel
# @param authnLevel internal authentication level
# return SAML authentication context
sub authnLevel2authnContext {
    my ( $self, $authnLevel ) = splice @_;

    return $self->getAuthnContext("password") if ( $authnLevel == 2 );
    return $self->getAuthnContext("password-protected-transport")
      if ( $authnLevel == 3 );
    return $self->getAuthnContext("tls-client") if ( $authnLevel == 5 );
    return $self->getAuthnContext("unspecified");

}

## @method boolean checkDestination(Lasso::Node message, string url)
# If SAML Destination attribute is present, check it
# @param message SAML request or response
# @param url Requested URL
# @return Result
sub checkDestination {
    my ( $self, $message, $url ) = splice @_;
    my $destination;

    # Read Destination
    eval { $destination = $message->Destination(); };

    # Ok if no Destination
    if ( $@ or !$destination ) {
        $self->lmLog( "No Destination in SAML message", 'debug' );
        return 1;
    }

    $self->lmLog( "Destination $destination found in SAML message", 'debug' );

    # Compare Destination and URL
    if ( $destination =~ /^$url$/ ) {
        $self->lmLog( "Destination match URL $url", 'debug' );
        return 1;
    }
    else {
        $self->lmLog( "Destination does not match URL $url", 'error' );
        return 0;
    }
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::_SAML - Common SAML functions

=head1 SYNOPSIS

use Lemonldap::NG::Portal::_SAML;

=head1 DESCRIPTION

This module contains common methods for SAML authentication
and user information loading

=head1 METHODS

=head2 loadLasso

Load Lasso module

=head2 loadService

Load SAML service by creating a Lasso::Server

=head2 loadIDPs

Load SAML identity providers

=head2 loadSPs

Load SAML service providers

=head2 checkMessage

Check SAML requests and responses

=head2 checkLassoError

Log Lasso error code and message if this is actually a Lasso::Error with code > 0

=head2 createServer

Load service metadata and create Lasso::Server object

=head2 addIDP

Add IDP to an existing Lasso::Server

=head2 addSP

Add SP to an existing Lasso::Server

=head2 addProvider

Add provider to an existing Lasso::Server

=head2 getOrganizationName

Return name of organization picked up from metadata

=head2 createAuthnRequest

Create authentication request for selected IDP

=head2 createLogin

Create Lasso::Login object

=head2 initAuthnRequest

Init authentication request

=head2 buildAuthnRequestMsg

Build authentication request message

=head2 processAuthnRequestMsg

Process authentication request message

=head2 validateRequestMsg

Validate request message

=head2 buildAuthnResponseMsg

Build authentication response message

=head2 buildArtifactMsg

Build artifact message

=head2 buildAssertion

Build assertion

=head2 processAuthnResponseMsg

Process authentication response message

=head2 getNameIdentifier

Get NameID from Lasso Profile

=head2 createIdentity

Create Lasso::Identity object

=head2 createSession

Create Lasso::Session object

=head2 acceptSSO

Accept SSO from IDP

=head2 storeRelayState

Store information in relayState database and return

=head2 extractRelayState

Extract RelayState information into $self

=head2 getAssertion

Get assertion in Lasso::Login object

=head2 getAttributeValue

Get SAML attribute value corresponding to name, format and friendly_name
Multivaluated values are separated by ';'

=head2 validateConditions

Validate conditions

=head2 createLogoutRequest

Create logout request for selected entity

=head2 createLogout

Create Lasso::Logout object

=head2 initLogoutRequest

Init logout request

=head2 buildLogoutRequestMsg

Build logout request message

=head2 setSessionFromDump

Set session from dump in Lasso::Profile object

=head2 setIdentityFromDump

Set identity from dump in Lasso::Profile object

=head2 getMetaDataURL

Get URL stored in a service metadata configuration key

=head2 processLogoutResponseMsg

Process logout response message

=head2 processLogoutRequestMsg

Process logout request message

=head2 validateLogoutRequest

Validate logout request

=head2 buildLogoutResponseMsg

Build logout response msg

=head2 storeReplayProtection

Store ID of an SAML message in Replay Protection base

=head2 replayProtection

Check if SAML message do not correspond to a previously responded message

=head2 resolveArtifact

Resolve artifact to get the real SAML message

=head2 storeArtifact

Store artifact

=head2 loadArtifact

Load artifact

=head2 createArtifactResponse

Create artifact response

=head2 processArtRequestMsg

Process artifact response message

=head2 processArtResponseMsg

Process artifact response message

=head2 sendSOAPMessage

Send SOAP message and get response

=head2 createAttributeRequest

Create an attribute request

=head2 processAttributeResponse

Process an attribute response

=head2 getNameIDFormat

Convert configuration string into SAML2 NameIDFormat string

=head2 getHttpMethod

Convert configuration string into Lasso HTTP Method integer

=head2 getHttpMethodString

Convert configuration Lasso HTTP Method integer into string

=head2 getFirstHttpMethod

Find a suitable HTTP method for an entity with a given protocol

=head2 disableSignature

Modify Lasso signature hint to disable signature

=head2 forceSignature

Modify Lasso signature hint to force signature

=head2 disableSignatureVerification

Modify Lasso signature hint to disable signature verification

=head2 getAuthnContext

Convert configuration string into SAML2 AuthnContextClassRef string

=head2 timestamp2samldate

Convert timestamp into SAML2 date format

=head2 samldate2timestamp

Convert SAML2 date format into timestamp

=head2 sendLogoutResponseToServiceProvider

Send logout response issue from a logout request

=head2 sendLogoutRequestToServiceProvider

Send logout request to a service provider

=head2 sendLogoutRequestToServiceProviders

Send logout response issue from a logout request to all other service
providers. If information have to be displayed to users, such as
iframe to send HTTP-Redirect or HTTP-POST logout request, then          
$self->{_info} will be updated.                                         

=head2 checkSignatureStatus

Check signature status

=head2 authnContext2authnLevel

Return authentication level corresponding to authnContext

=head2 authnLevel2authnContext

Return SAML authentication context corresponding to authnLevel

=head2 checkDestination

If SAML Destination attribute is present, check it

=head1 SEE ALSO

L<Lemonldap::NG::Portal::AuthSAML>, L<Lemonldap::NG::Portal::UserDBSAML>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>,
Clement Oudot, E<lt>coudot@linagora.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Xavier Guimard, Clement Oudot

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
