## @file
# UserDB SAML module

## @class
# UserDB SAML module
package Lemonldap::NG::Portal::UserDBSAML;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_SAML;
our @ISA = qw(Lemonldap::NG::Portal::_SAML);

our $VERSION = '0.01';

## @apmethod int userDBInit()
# Check if authentication module is SAML
# @return Lemonldap::NG::Portal error code
sub userDBInit {
    my $self = shift;
    if (   $self->{authentication} =~ /^SAML/
        or $self->{stack}->[0]->[0]->{m} =~ /^SAML/ )
    {
        return PE_OK;
    }
    else {
        return PE_ERROR;
    }
}

## @apmethod int getUser()
# Does nothing
# @return Lemonldap::NG::Portal error code
sub getUser {
    PE_OK;
}

## @apmethod int setSessionInfo()
# Get all required attributes
# @return Lemonldap::NG::Portal error code
sub setSessionInfo {
    my $self   = shift;
    my $server = $self->{_lassoServer};
    my $login  = $self->{_lassoLogin};
    my $idp    = $self->{_idp};

    my $exportedAttr;

    # Get all required attributes, not already set
    # in setAuthSessionInfo()
    foreach ( keys %{ $self->{samlIDPMetaDataExportedAttributes}->{$idp} } ) {

        # Extract fields from exportedAttr value
        my ( $mandatory, $name, $format, $friendly_name ) =
          split( /;/,
            $self->{samlIDPMetaDataExportedAttributes}->{$idp}->{$_} );

        # Keep mandatory attributes not sent in authentication response
        if ( $mandatory and not defined $self->{sessionInfo}->{$_} ) {
            $exportedAttr->{$_} =
              $self->{samlIDPMetaDataExportedAttributes}->{$idp}->{$_};
            $self->lmLog( "Attribute $_ will be requested to $idp", 'debug' );
        }
    }

    unless ( keys %$exportedAttr ) {
        $self->lmLog(
            "All mandatory attributes were present in authentication response",
            'debug'
        );
        return PE_OK;
    }

    # Build Attribute Request
    my $IDPentityID = $self->{_idpList}->{$idp}->{entityID};
    my $query =
      $self->createAttributeRequest( $server, $login, $IDPentityID,
        $exportedAttr );

    unless ($query) {
        $self->lmLog( "Unable to build attribute request for $idp", 'error' );
        return PE_ERROR;
    }

    # Use SOAP to send request and get response
    my $query_url  = $query->msg_url;
    my $query_body = $query->msg_body;

    # Send SOAP request and manage response
    my $response = $self->sendSOAPMessage( $query_url, $query_body );

    unless ($response) {
        $self->lmLog( "No attribute response to SOAP request", 'error' );
        return PE_ERROR;
    }

    # Manage Attribute Response
    my $result = $self->processAttributeResponse( $server, $response );

    unless ($result) {
        $self->lmLog( "Fail to process attribute response", 'error' );
        return PE_ERROR;
    }

    # Attributes in response
    my @response_attributes;
    eval {
        @response_attributes =
          $result->getAssertion()->AttributeStatement()->Attribute();
    };
    if ($@) {
        $self->lmLog( "No attributes defined in attribute response", 'error' );
        return PE_ERROR;
    }

    # Check we have all required attributes
    foreach ( keys %$exportedAttr ) {

        # Extract fields from exportedAttr value
        my ( $mandatory, $name, $format, $friendly_name ) =
          split( /;/, $exportedAttr->{$_} );

        # Try to get value
        my $value = $self->getAttributeValue( $name, $format, $friendly_name,
            \@response_attributes );

        unless ($value) {
            $self->lmLog(
                "Attribute $_ is mandatory, but was not delivered by $idp",
                'error' );
            return PE_ERROR;
        }

        # Store value in sessionInfo
        $self->{sessionInfo}->{$_} = $value;
    }

    return PE_OK;

}

## @apmethod int setGroups()
# Does nothing
# @return Lemonldap::NG::Portal error code
sub setGroups {
    PE_OK;
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::UserDBSAML - SAML User backend

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::UserDBSAML;

=head1 DESCRIPTION

Collect all required attributes trough SAML Attribute Requests

=head1 SEE ALSO

L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Portal::AuthSAML>, L<Lemonldap::NG::Portal::_SAML>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>, Clement Oudot, E<lt>coudot@linagora.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
