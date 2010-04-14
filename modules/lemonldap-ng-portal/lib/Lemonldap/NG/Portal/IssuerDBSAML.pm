## @file
# SAML Issuer file

## @class
# SAML Issuer class
package Lemonldap::NG::Portal::IssuerDBSAML;

use strict;
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
    my $saml_ars_url = $self->getMetaDataURL(
        "samlIDPSSODescriptorArtifactResolutionServiceArtifact");

    # Get HTTP request informations to know
    # if we are receving SAML request or response
    my $url            = $self->url();
    my $request_method = $self->request_method();
    my $content_type   = $self->content_type();

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
    my $self = shift;
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

    # Get HTTP request informations to know
    # if we are receving SAML request or response
    my $url            = $self->url();
    my $request_method = $self->request_method();
    my $content_type   = $self->content_type();

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

            # Validate request
            unless ( $self->validateRequestMsg( $login, 1, 1 ) ) {
                $self->lmLog( "Unable to validate SSO request message",
                    'error' );
                return PE_ERROR;
        }

            $self->lmLog( "SSO: authentication request is valid", 'debug' );

    # TODO Check AuthnRequest conditions
    
            # Convert authentication method into SAML2 string
            $authn_context = Lasso::Constants::SAML2_AUTHN_CONTEXT_UNSPECIFIED;

            if ( $self->get_module('auth') =~ /(LDAP|DBI)/i ) {
                if ( $self->https() ) {
                    $authn_context =
                      $self->getAuthnContext("password-protected-transport");
                }
                else {
                    $authn_context = $self->getAuthnContext("password");
                }
            }

            if ( $self->get_module('auth') =~ /(SSL)/i ) {
                $authn_context = $self->getAuthnContext("x509");
            }

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

            # Get response assertion
            my @response_assertions = $login->response->Assertion;

            unless ( $response_assertions[0] ) {
                $self->lmLog( "Unable to get response assertion", 'error' );
                return PE_ERROR;
            }

            # Set subject NameID
            $response_assertions[0]
              ->set_subject_name_id( $login->nameIdentifier );

            # Set response assertion
            $login->response->Assertion(@response_assertions);

            $self->lmLog( "NameID Format is $nameIDFormat",   'debug' );
            $self->lmLog( "NameID Content is $nameIDContent", 'debug' );

            # TODO relayState

    # TODO Push mandatory attributes

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
