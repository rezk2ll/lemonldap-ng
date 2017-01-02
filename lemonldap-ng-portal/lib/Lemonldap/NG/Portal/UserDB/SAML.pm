package Lemonldap::NG::Portal::UserDB::SAML;

use strict;
use Encode;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_SAML_ATTR_ERROR
  PE_SAML_LOAD_IDP_ERROR
  PE_SAML_LOAD_SERVICE_ERROR
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Common::Module', 'Lemonldap::NG::Portal::Lib::SAML';

# INITIALIZATION

sub init {
    my ($self) = @_;

    unless ( $self->p->getModule( undef, 'auth' ) =~ /^SAML/ ) {
        $self->error( "SAML user module requires SAML authentication" );
        return 0;
    }

    # SAML service has been already loaded
    $self->lassoServer(
        $self->p->loadedModules->{'Lemonldap::NG::Portal::Auth::SAML'}
          ->lassoServer );
    return 1;
}

# RUNNING METHODS

# Does nothing
sub getUser {
    PE_OK;
}

# Get all required attributes
sub setSessionInfo {
    my ( $self, $req ) = @_;
    my $idp        = $req->datas->{_idp};
    my $idpConfKey = $req->datas->{_idpConfKey};
    my $nameid     = $req->datas->{_nameID};

    my $exportedAttr;

    # Force UTF-8
    my $force_utf8 =
      $self->conf->{samlIDPMetaDataOptions}->{$idpConfKey}
      ->{samlIDPMetaDataOptionsForceUTF8};

    # Get all required attributes, not already set
    # in setAuthSessionInfo()
    foreach (
        keys %{ $self->conf->{samlIDPMetaDataExportedAttributes}->{$idpConfKey}
        } )
    {

        # Extract fields from exportedAttr value
        my ( $mandatory, $name, $format, $friendly_name ) =
          split( /;/,
            $self->conf->{samlIDPMetaDataExportedAttributes}->{$idpConfKey}
              ->{$_} );

        # Keep mandatory attributes not sent in authentication response
        if ( $mandatory and not defined $req->{sessionInfo}->{$_} ) {
            $exportedAttr->{$_} =
              $self->conf->{samlIDPMetaDataExportedAttributes}->{$idpConfKey}
              ->{$_};
            $self->lmLog( "Attribute $_ will be requested to $idpConfKey",
                'debug' );
        }
    }

    unless ( keys %$exportedAttr ) {
        $self->lmLog(
            "All mandatory attributes were present in authentication response",
            'debug'
        );
        return PE_OK;
    }

    # Save current Lasso::Server object, and get a new one
    my $current_server = $self->lassoServer;
    $self->loadService(1);
    my $server = $self->lassoServer;

    unless ($server) {
        $self->lmLog( "Unable to create service for attribute request",
            'error' );
        return PE_SAML_LOAD_SERVICE_ERROR;
    }

    $self->lmLog( "Service for attribute request created", 'debug' );

    # Add current IDP as Attribute Authority
    my $idp_metadata =
      $self->conf->{samlIDPMetaDataXML}->{$idpConfKey}->{samlIDPMetaDataXML};

    if ( $self->conf->{samlMetadataForceUTF8} ) {
        $idp_metadata = encode( "utf8", $idp_metadata );
    }

    # Add this IDP to Lasso::Server as AA
    unless ( $self->addAA( $server, $idp_metadata ) ) {
        $self->lmLog(
            "Fail to use IDP $idpConfKey Metadata as Attribute Authority",
            'error' );
        return PE_SAML_LOAD_IDP_ERROR;
    }

    # Build Attribute Request
    my $query =
      $self->createAttributeRequest( $server, $idp, $exportedAttr, $nameid );

    unless ($query) {
        $self->lmLog( "Unable to build attribute request for $idpConfKey",
            'error' );
        return PE_SAML_ATTR_ERROR;
    }

    # Use SOAP to send request and get response
    my $query_url  = $query->msg_url;
    my $query_body = $query->msg_body;

    # Send SOAP request and manage response
    my $response = $self->sendSOAPMessage( $query_url, $query_body );

    unless ($response) {
        $self->lmLog( "No attribute response to SOAP request", 'error' );
        return PE_SAML_ATTR_ERROR;
    }

    # Manage Attribute Response
    my $result = $self->processAttributeResponse( $server, $response );

    unless ($result) {
        $self->lmLog( "Fail to process attribute response", 'error' );
        return PE_SAML_ATTR_ERROR;
    }

    # Attributes in response
    my @response_attributes;
    eval {
        @response_attributes =
          $result->response()->Assertion()->AttributeStatement()->Attribute();
    };
    if ($@) {
        $self->lmLog( "No attributes defined in attribute response", 'error' );
        return PE_SAML_ATTR_ERROR;
    }

    # Check we have all required attributes
    foreach ( keys %$exportedAttr ) {

        # Extract fields from exportedAttr value
        my ( $mandatory, $name, $format, $friendly_name ) =
          split( /;/, $exportedAttr->{$_} );

        # Try to get value
        my $value = $self->getAttributeValue( $name, $format, $friendly_name,
            \@response_attributes, $force_utf8 );

        unless ($value) {
            $self->lmLog(
"Attribute $_ is mandatory, but was not delivered by $idpConfKey",
                'error'
            );
            return PE_SAML_ATTR_ERROR;
        }

        $self->lmLog( "Get value $value for attribute $_", 'debug' );

        # Store value in sessionInfo
        $req->{sessionInfo}->{$_} = $value;
    }

    # Restore current Lasso::Server
    $self->lassoServer = $current_server;

    PE_OK;
}

# Does nothing
sub setGroups {
    PE_OK;
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::UserDB::SAML - SAML User backend

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::UserDB::SAML;

=head1 DESCRIPTION

Collect all required attributes trough SAML Attribute Requests

=head1 SEE ALSO

L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Portal::Auth::SAML>, L<Lemonldap::NG::Portal::Lib::SAML>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Thomas Chemineau, E<lt>thomas.chemineau@gmail.comE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2009-2017 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2009-2015 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item Copyright (C) 2010 by Thomas Chemineau, E<lt>thomas.chemineau@gmail.comE<gt>

=back

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.

=cut
