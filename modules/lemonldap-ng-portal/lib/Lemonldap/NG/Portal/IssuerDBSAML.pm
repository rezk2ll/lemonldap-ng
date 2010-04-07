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

    # Get HTTP request informations to know
    # if we are receving SAML request or response
    my $url            = $self->url();
    my $request_method = $self->request_method();
    my $content_type   = $self->content_type();

    if ( $url =~ /^($saml_sso_soap_url|$saml_sso_get_url)$/i ) {

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

    if ( $url =~ /^($saml_sso_soap_url|$saml_sso_get_url)$/i ) {

        $self->lmLog( "URL $url detected as an SSO request URL", 'debug' );

        # Check message
        my ( $request, $response, $method, $relaystate, $artifact ) =
          $self->checkMessage( $url, $request_method, $content_type );

        # Process the request
        if ($request) {

            # Create Login object
            $login = $self->createLogin($server);

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
    
    # TODO Build NameID

    # TODO Build Assertion

    # TODO Push mandatory attributes

    # TODO Build AuthnResponse
    
    # TODO Send AuthnResponse

    }

    }

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
