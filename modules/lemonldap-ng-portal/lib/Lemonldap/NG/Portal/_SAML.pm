## @file
# Common SAML functions

## @class
# Common SAML functions
package Lemonldap::NG::Portal::_SAML;

use strict;
use XML::Simple;
use MIME::Base64;
use LWP::UserAgent;    # SOAP call
use HTTP::Request;     # SOAP call

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

## @method Lasso::Login createAuthnRequest(Lasso::Server server, string idp, int method)
# Create authentication request for selected IDP
# @param server Lasso::Server object
# @param entityID IDP entityID
# @param method HTTP method
# @return Lasso::Login object
sub createAuthnRequest {
    my ( $self, $server, $idp, $method ) = splice @_;

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
    foreach (qw /_idp urldc/) {
        $infos->{$_} = $self->{$_} if $self->{$_};
    }
    my $relaystate = $self->storeRelayState($infos);
    $login->msg_relayState($relaystate);
    $self->lmLog( "Set $relaystate in RelayState", 'debug' );

    # Customize request
    # TODO Get customization parameters from IDP configuration
    my $request = $login->request();
    $request->NameIDPolicy()
      ->Format(Lasso::Constants::SAML2_NAME_IDENTIFIER_FORMAT_PERSISTENT);
    $request->NameIDPolicy()->AllowCreate(1);

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
    eval {
        tie %h, $self->{globalStorage}, undef, $self->{globalStorageOptions};
    };
    if ($@) {
        $self->lmLog( "Unable to create relaystate session", 'error' );
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
        tie %h, $self->{globalStorage}, $relaystate,
          $self->{globalStorageOptions};
    };
    if ($@) {
        $self->lmLog( "Unable to open relaystate session", 'error' );
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

## @method string getAttributeValue(string name, string format, string friendly_name, array_ref attributes)
# Get SAML attribute value corresponding to name, format and friendly_name
# Multivaluated values are separated by ';'
# @param name SAML attribute name
# @param format optional SAML attribute format
# @param friendly_name optional SAML attribute friendly name
# @return attribute value
sub getAttributeValue {
    my ( $self, $name, $format, $friendly_name, $attributes ) = splice @_;
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
            $value .= $content . ";" if $content;
        }
        $value =~ s/;$//;
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

## @method Lasso::Logout createLogoutRequest(Lasso::Server server, string session_dump, int method)
# Create logout request for selected entity
# @param server Lasso::Server object
# @param session_dump Lasso::Session dump
# @param method HTTP method
# @return Lasso::Login object
sub createLogoutRequest {
    my ( $self, $server, $session_dump, $method ) = splice @_;
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

## @method boolean setSessionFromDump(Lasso::Profile profile)
# Set session from dump in Lasso::Profile object
# @param profile Lasso::Profile object
# @param dump Lasso::Session XML dump
# @return result
sub setSessionFromDump {
    my ( $self, $profile, $dump ) = splice @_;

    eval { Lasso::Profile::set_session_from_dump( $profile, $dump ); };

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
# @return result
sub storeReplayProtection {
    my ( $self, $samlID ) = splice @_;
    my %h;

    eval {
        tie %h, $self->{globalStorage}, undef, $self->{globalStorageOptions};
    };
    if ( $@ or !$samlID ) {
        $self->lmLog( "Unable to create replay protection session", 'error' );
        return 0;
    }

    $h{type}   = 'assertion';    # Session type
    $h{_utime} = time();         # Creation time
    $h{ID}     = $samlID;

    my $session_id = $h{_session_id};

    untie %h;

    $self->lmLog(
        "Keep Logout request ID $samlID in assertion session $session_id",
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
      $self->{globalStorage}
      ->searchOn( $self->{globalStorageOptions}, "ID", $samlID );

    if ( my @keys = keys %$sessions ) {

        # A session was found
        foreach (@keys) {
            my $session = $_;

            # Delete it
            eval {
                tie %h, $self->{globalStorage}, $_,
                  $self->{globalStorageOptions};
            };
            if ($@) {
                $self->lmLog(
"Unable to recover assertion session $session (Message ID $samlID)",
                    'error'
                );
                return 0;
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
            return 1;
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

    return $response;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::_SAML

=head1 SYNOPSIS

use Lemonldap::NG::Portal::_SAML;

=head1 DESCRIPTION

This module contains common methods for SAML authentication
and user information loading

=head1 METHODS

=head2 loadLasso

Load Lasso module

=head2 checkLassoError

Log Lasso error code and message if this is actually a Lasso::Error with code > 0

=head2 createServer

Load service metadata and create Lasso::Server object

=head2 addIDP

Add IDP to an existing Lasso::Server

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

=head2 processArtResponseMsg

Process artifact response message

=head2 sendSOAPMessage

Send SOAP message and get response

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
