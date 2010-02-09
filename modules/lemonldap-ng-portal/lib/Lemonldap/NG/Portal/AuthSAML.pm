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
    unless ( $self->{samlIDPMetaData}
        and keys %{ $self->{samlIDPMetaData} } )
    {
        $self->lmLog( "No IDP found in configuration", 'error' );
        return PE_ERROR;
    }

    # Load identity provider metadata
    # IDP are listed in $self->{samlIDPMetaData}
    # Each key is the IDP name and value is the metadata
    # Build IDP list for later use in extractFormInfo
    foreach ( keys %{ $self->{samlIDPMetaData} } ) {

        $self->lmLog( "Get Metadata for IDP $_", 'debug' );

        # Get metadata from configuration
        my $idp_metadata = Lemonldap::NG::Common::Conf::SAML::Metadata->new();
        unless (
            $idp_metadata->initializeFromConfHash(
                $self->{samlIDPMetaData}->{$_}
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
    my $idp;

    # 1. Get URL parameters to know if we are receving an assertion
    my $url              = $self->url();
    my $saml_acs_art_url = (
        split(
            /;/,
            $self->{samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact}
        )
    )[3];
    my $saml_acs_post_url = (
        split(
            /;/, $self->{samlSPSSODescriptorAssertionConsumerServiceHTTPPost}
        )
    )[3];
    my $saml_acs_get_url = (
        split(
            /;/,
            $self->{samlSPSSODescriptorAssertionConsumerServiceHTTPRedirect}
        )
    )[3];

    if ( $url =~ /^($saml_acs_art_url|$saml_acs_post_url|$saml_acs_get_url)$/i )
    {

        $self->lmLog( "URL $url detected as an assertion consumer URL",
            'debug' );

        # 1.1 HTTP REDIRECT
        if ( $url =~ /^$saml_acs_get_url$/i ) {

            # Response in query string
            my $response = $self->query_string();

            # TODO use CGI(-oldstyle_urls) in Common/CGI.pm to avoid this
            $response =~ s/;/&/g;

            $self->lmLog( "HTTP-REDIRECT: SAML Response $response", 'debug' );

            # Create Login object
            $login = $self->createLogin($server);

            # Process authentication response
            my $result = $self->processAuthnResponseMsg( $login, $response );

            unless ($result) {
                $self->lmLog(
                    "HTTP-REDIRECT: Fail to process authentication response",
                    'error' );
                return PE_ERROR;
            }

            # TODO validate response
            $self->lmLog( "HTTP-REDIRECT: authentication response is valid",
                'debug' );

            # Get NameID
            my $nameid = $self->getNameIdentifier($login);

            $self->abort("Work in progress");
        }

        # 1.2 POST
        # TODO

        # 1.3 ARTEFACT (SOAP)
        # TODO

        return PE_OK;
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
                '<tr><td><input type="radio" name="idp" value="'
              . $self->{_idpList}->{$_}->{entityID}
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
          . "</h3>\n<h4>$idp</h4>\n<input type=\"hidden\" name=\"idp\" value=\"$idp\" />\n";

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
    # TODO store urldc in RelayState
    $login = $self->createAuthnRequest( $server, $idp );

    unless ($login) {
        $self->lmLog( "Could not create authentication request on $idp",
            'error' );
        return PE_ERROR;
    }

    $self->lmLog( "Authentication request created", 'debug' );

    # Redirect user to IDP SSO URL
    # Replace urldc value by SSO URL value and call sub autoRedirect
    # TODO Manage other transport (POST, SOAP, ...)
    my $sso_url = $login->msg_url;
    $self->lmLog( "Redirect user to $sso_url", 'debug' );

    $self->{urldc} = $sso_url;
    $self->{error} = $self->_subProcess(qw(autoRedirect));

    return $self->{error};
}

## @apmethod int setAuthSessionInfo()
# Extract attributes sent in authentication statement
# @return Lemonldap::NG::Portal error code
sub setAuthSessionInfo {
    my $self = shift;

    # TODO

    PE_OK;
}

## @apmethod int authenticate()
# Accept SSO from IDP
# @return PE_OK
sub authenticate {
    my $self = shift;

    #TODO Lasso::Login::accept_sso( $login )

    PE_OK;
}

## @apmethod void authLogout()
# Logout SP
# @return nothing
sub authLogout {
    my $self = shift;

    # TODO

    return;
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
