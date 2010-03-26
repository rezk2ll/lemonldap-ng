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
# TODO
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
# TODO
# Check if there is an SAML authentication request.
# Called only for unauthenticated users, it store SAML request in
# $self->{url}
# @return Lemonldap::NG::Portal error code
sub issuerForUnAuthUser {
    my $self = shift;
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

    my $saml_sso_soap_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceSOAP", 1 );
    my $saml_sso_soap_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceSOAP", 2 );
    my $saml_sso_get_url =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceHTTP", 1 );
    my $saml_sso_get_url_ret =
      $self->getMetaDataURL( "samlIDPSSODescriptorSingleSignOnServiceHTTP", 2 );

    # 1.1 SSO request
    if ( $url =~ /^($saml_sso_soap_url|$saml_sso_get_url)$/i )
    {   

        $self->lmLog( "URL $url detected as an SSO request URL", 'debug' );

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

        # 1.2.1 HTTP POST AND SOAP
        elsif ( $request_method =~ /^POST$/ ) {

            # 1.2.2 POST
            if ( $content_type !~ /xml/ ) {

                $method = Lasso::Constants::HTTP_METHOD_POST;
                $self->lmLog( "SSO method: HTTP-POST", 'debug' );

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

        if ( $request ) {

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
                $self->lmLog( "Found isPassive flag in assertion conditions",
                    'debug' );
                return PE_ERROR;
            }

        }

    }

    PE_OK;
}

## @apmethod int issuerForAuthUser()
# TODO
# Check if there is an SAML authentication request for an authenticated user
# and build assertions
# @return Lemonldap::NG::Portal error code
sub issuerForAuthUser {
    my $self = shift;

    print STDERR "IssuerDBSAML: issuerForAuthUser\n";

    PE_OK;
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

Lemonldap::NG::Portal::IssuerDBSAML - SAML IssuerDB for Lemonldap::NG

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::IssuerDBSAML;
  #TODO

=head1 DESCRIPTION

SAML IssuerDB for Lemonldap::NG

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
