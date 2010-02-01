## @file
# SAML Consumer skeleton

## @class
# SAML Consumer skeleton
package Lemonldap::NG::Portal::AuthSAML;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_SAML;    #inherits
use Lemonldap::NG::Common::Conf::SAML::Metadata;

our $VERSION = '0.1';

## @apmethod int authInit()
# Load Lasso and metadata
# TODO - cache Lasso::Server
# @return Lemonldap::NG::Portal error code
sub authInit {
    my $self = shift;

    # Load Lasso
    return PE_ERROR unless $self->loadLasso();

    # Activate SOAP
    $self->{Soap} = 1;

    # Check presence of service metadata in configuration
    return PE_ERROR unless $self->{samlServiceMetaData};

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
    # Provate key has to be inside service metadata
    my $server = $self->createServer( $service_metadata->toXML() );

    return PE_ERROR unless $server;

    $self->lmLog( "Service created", 'debug' );

    # Check presence of at least one identity provider in configuration
    unless ( $self->{samlIDPMetaData} and keys %{ $self->{samlIDPMetaData} } ) {
        $self->lmLog( "No IDP found in configuration", 'error' );
        return PE_ERROR;
    }

    # Load identity provider metadata
    # IDP are listed in $self->{samlIDPMetaData}
    # Each key is the IDP name and value is the metadata
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

        $self->lmLog( "IDP $_ added", 'debug' );
    }

    PE_OK;
}

## @apmethod int extractFormInfo()
# TODO
# @return Lemonldap::NG::Portal error code
sub extractFormInfo {
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

Lemonldap::NG::Portal::AuthSAML - TODO

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::AuthSAML;
  #TODO

=head1 DESCRIPTION

TODO

=head1 SEE ALSO

L<Lemonldap::NG::Portal>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
