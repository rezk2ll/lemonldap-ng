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
    $self->{Soap} = 1;

        # Check presence of service metadata and private key in configuration
        unless ($self->{samlServiceMetaData}
            and $self->{samlServicePrivateKey} )
        {
            $self->lmLog(
            "SAML service metadata or private key not found in configuration",
            'error' );
            return PE_ERROR;
        }

        # Get metadata from configuration
        $self->lmLog( "Get Metadata for this service", 'debug' );
    my $service_metadata = Lemonldap::NG::Common::Conf::SAML::Metadata->new();
        unless (
            $service_metadata->initializeFromConfHash(
                $self->{samlServiceMetaData}
            )
          )
        {
            $self->lmLog( "Fail to read Service Metadata from configuration",
                'error' );
            return PE_ERROR;
        }

        # Create Lasso server with service metadata
        my $server = $self->createServer(
            $service_metadata->toXML(),
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
        my $name = $idp_metadata->{Organization}->{OrganizationName} || $_;
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
    my $self = shift;
    my $server = $self->{_lassoServer};
    my $idp;

    # 1. Get authentication statement
    # if ( authnStatement ) ...
    # TODO - check authstatement
    # else
    
    # 2. IDP resolution
    
    # Get IDP resolution cookie
    my %cookies = fetch CGI::Cookie;
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
        my $html = "<h3>";
        $html .=
          &Lemonldap::NG::Portal::_i18n::msg( PM_SAML_IDPSELECT,
            $ENV{HTTP_ACCEPT_LANGUAGE} );
        $html .= "</h3>\n";

        foreach ( keys %{ $self->{_idpList} } ) {
            $html .=
                "<input type=\"radio\" name=\"idp\" value=\""
              . $self->{_idpList}->{$_}->{entityID}
              . "\" />\n";
            $html .= $self->{_idpList}->{$_}->{name};
            $html .= "<br />";
        }

        $html .= "<input type=\"checkbox\" name=\"cookie_type\" value=\"1\">";
        $html .=
          &Lemonldap::NG::Portal::_i18n::msg( PM_REMEMBERCHOICE,
            $ENV{HTTP_ACCEPT_LANGUAGE} );
        $html .= "<br />\n";

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
        my $html = "<h3>";
        $html .=
          &Lemonldap::NG::Portal::_i18n::msg( PM_SAML_IDPCHOOSEN,
            $ENV{HTTP_ACCEPT_LANGUAGE} );
        $html .= "</h3>\n";

        $html .= "<p>$idp</p>\n";

        $html .= "<input type=\"hidden\" name=\"idp\" value=\"$idp\" />\n";

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
    my $login = $self->createAuthnRequest( $server, $idp );

    unless ($login) {
        $self->lmLog( "Could not create authentication request on $idp",
            'error' );
        return PE_ERROR;
    }
    $self->lmLog( "Authentication request created", 'debug' );

    PE_OK;
}

## @apmethod int setAuthSessionInfo()
# TODO
# @return Lemonldap::NG::Portal error code
sub setAuthSessionInfo {
    PE_OK;
}

## @apmethod int authenticate()
# Does nothing here
# @return PE_OK
sub authenticate {
    PE_OK;
}

## @apmethod void authLogout()
# TODO
sub authLogout {
}

## @apmethod array SAMLIssuerLinks()
# TODO
# @return 2 arrays: HTTP links and SAML issuer names
sub SAMLIssuerLinks {
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
