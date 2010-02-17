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
    # Each key is the IDP name and value is the metadata key
    # Build IDP list for later use in extractFormInfo
    foreach ( keys %{ $self->{samlIDPMetaData} } ) {

        $self->lmLog( "Get Metadata for IDP $_", 'debug' );

        # Get metadata from configuration
        my $idp_metadata = Lemonldap::NG::Common::Conf::SAML::Metadata->new();
        unless (
            $idp_metadata->initializeFromConfHash(
                $self->{samlIDPMetaData}->{$_}->{metadata}
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
    my %h;

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

        # Create Login object
        $login = $self->createLogin($server);

        # 1.1 HTTP REDIRECT
        if ( $url =~ /^$saml_acs_get_url$/i ) {

            # Response in query string
            my $response = $self->query_string();

            $self->lmLog( "HTTP-REDIRECT: SAML Response $response", 'debug' );

            # Process authentication response
            my $result = $self->processAuthnResponseMsg( $login, $response );

            unless ($result) {
                $self->lmLog(
                    "HTTP-REDIRECT: Fail to process authentication response",
                    'error' );
                return PE_ERROR;
            }

            $self->lmLog( "HTTP-REDIRECT: authentication response is valid",
                'debug' );
        }

        # 1.2 POST
        # TODO

        # 1.3 ARTEFACT (SOAP)
        # TODO

        # Get SAML response
        my $saml_response = $login->response();
        unless ($saml_response) {
            $self->lmLog( "No SAML response found", 'error' );
            return PE_ERROR;
        }

        # Replay protection if this is a response to a created authn request
        my $assertion_responded = $saml_response->InResponseTo;
        if ($assertion_responded) {
            my $assertion_sessions =
              $self->{globalStorage}->searchOn( $self->{globalStorageOptions},
                "ID", $assertion_responded, );

            if ( my @assertion_keys = keys %$assertion_sessions ) {

                # A session was found
                foreach (@assertion_keys) {

                    # Delete it
                    eval {
                        tie %h, $self->{globalStorage}, undef,
                          $self->{globalStorageOptions};
                    };
                    if ($@) {
                        $self->lmLog(
"Unable to recover assertion session $_ (assertion ID $assertion_responded)",
                            'error'
                        );
                        return PE_ERROR;
                    }
                    eval { tied(%h)->delete(); };
                    if ($@) {
                        $self->lmLog(
"Unable to delete assertion session $_ (assertion ID $assertion_responded)",
                            'error'
                        );
                        return PE_ERROR;
                    }
                    $self->lmLog(
"Assertion session $_ (assertion ID $assertion_responded) was deleted",
                        'debug'
                    );
                }
            }
            else {

                # Assertion was already consumed or is expired
                # Force authentication replay
                $self->lmLog(
"Assertion $assertion_responded already used or expired, replay authentication",
                    'error'
                );
                delete $self->{urldc};
                $self->{mustRedirect} = 1;
                $self->{error}        = $self->_subProcess(qw(autoRedirect));
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
            $self->lmLog( "Time or Audience conditions not validated",
                'error' );
            return PE_ERROR;
        }

        $self->lmLog( "Conditions validated", 'debug' );

        # Check OneTimeUse flag
        # TODO

        # Check ProxyRestriction flag
        # TODO

        #  Extract RelayState information
        if ( $self->extractRelayState($login) ) {
            $self->lmLog( "RelayState found in authentication assertion",
                'debug' );
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

        # Store Lasso::Login object
        $self->{_lassoLogin} = $login;

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
    $self->{_idp} = $idp;
    my $IDPentityID = $self->{_idpList}->{$idp}->{entityID};
    $login = $self->createAuthnRequest( $server, $IDPentityID );

    unless ($login) {
        $self->lmLog( "Could not create authentication request on $IDPentityID",
            'error' );
        return PE_ERROR;
    }

    $self->lmLog( "Authentication request created", 'debug' );

    # Keep assertion ID in memory to prevent replay
    my $assertion_id = $login->request()->ID;
    eval {
        tie %h, $self->{globalStorage}, undef, $self->{globalStorageOptions};
    };
    if ( $@ or !$assertion_id ) {
        $self->lmLog( "Unable to store assertion ID", 'error' );
        return PE_ERROR;
    }
    $h{type}   = 'assertion';     # Session type
    $h{_utime} = time();          # Creation time
    $h{ID}     = $assertion_id;
    my $assertion_session_id = $h{_session_id};
    untie %h;

    $self->lmLog(
"Keep assertion ID $assertion_id in assertion session $assertion_session_id",
        'debug'
    );

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
        foreach ( keys %{ $self->{samlIDPMetaData}->{$idp}->{exportedAttr} } ) {

            # Extract fields from exportedAttr value
            my ( $mandatory, $name, $format, $friendly_name ) =
              split( /;/,
                $self->{samlIDPMetaData}->{$idp}->{exportedAttr}->{$_} );

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

    PE_OK;
}

## @apmethod int authenticate()
# Accept SSO from IDP
# @return PE_OK
sub authenticate {
    my $self   = shift;
    my $server = $self->{_lassoServer};
    my $login  = $self->{_lassoLogin};

    # Accept SSO
    unless ( $self->acceptSSO($login) ) {
        $self->lmLog( "Error while accepting SSO from IDP", 'error' );
        return PE_ERROR;
    }

    # Dump Lasso objects in session
    $self->{sessionInfo}->{_lassoLoginDump} = $login->dump();

    # Set authenticationLevel
    $self->{sessionInfo}->{authenticationLevel} = 5;

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
