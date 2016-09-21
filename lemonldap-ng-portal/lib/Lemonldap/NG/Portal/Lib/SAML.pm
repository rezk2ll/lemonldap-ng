package Lemonldap::NG::Portal::Lib::SAML;

use strict;
use Mouse;
use Lemonldap::NG::Common::Conf::SAML::Metadata;
use Lemonldap::NG::Common::Session;
use XML::Simple;
use MIME::Base64;
use String::Random;
use HTTP::Request;         # SOAP call
use POSIX qw(strftime);    # Convert SAML2 date into timestamp
use Time::Local;           # Convert SAML2 date into timestamp
use Encode;                # Encode attribute values
use URI;                   # Get metadata URL path

our $VERSION = '2.0.0';

# PROPERTIES

has lassoServer => ( is => 'rw' );
has spList      => ( is => 'rw', default => sub { {} } );
has idpList     => ( is => 'rw', default => sub { {} } );

# INITIALIZATION

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
        Glib::Log->set_handler(
            "Lasso",
            [qw/ error critical warning message info debug /],
            sub {
                $_[0]
                  ->lmLog( $_[0] . " error " . $_[1] . ": " . $_[2], 'debug' );
            }
        );
    }

    # Load Lasso.pm
    eval 'use Lasso;';
    if ($@) {
        print STDERR "Lasso.pm not loaded: $@";
        eval
'use constant LASSO => 0;use constant BADLASSO => 0;use constant LASSOTHINSESSIONS => 0';
    }
    else {
        no strict 'subs';
        eval 'use constant LASSO => 1';

        # Check Lasso version >= 2.3.0
        my $lasso_check_version_mode =
          eval 'Lasso::Constants::CHECK_VERSION_NUMERIC';
        my $check_version =
          Lasso::check_version( 2, 3, 0, $lasso_check_version_mode );
        unless ($check_version) {
            eval 'use constant BADLASSO => 1';
        }
        else {
            eval 'use constant BADLASSO => 0';
        }

        # Try to set thin-sessions flag
        eval 'Lasso::set_flag("thin-sessions");';
        if ($@) {
            eval 'use constant LASSOTHINSESSIONS => 0';
        }
        else {
            eval 'use constant LASSOTHINSESSIONS => 1';
        }
    }

}

sub init {
    my ($self) = @_;

    # Check for Lasso errors/messages (see BEGIN)
    unless (LASSO) {
        $self->error("Module Lasso not loaded (see below)");
        return 0;
    }

    if (BADLASSO) {
        $self->error('Lasso version >= 2.3.0 required');
        return 0;
    }

    unless (LASSOTHINSESSIONS) {
        $self->lmLog( 'Lasso thin-sessions flag could not be set', 'warn' );
    }
    else {
        $self->lmLog( 'Lasso thin-sessions flag set', 'debug' );
    }

    # Conf initialization

    return 0 unless ( $self->lassoServer( $self->loadService ) );
}

sub loadService {
    my ($self) = @_;

    # Check if certificate is available
    unless ($self->conf->{samlServicePublicKeySig}
        and $self->conf->{samlServicePrivateKeySig} )
    {
        $self->error('SAML private and public key not found in configuration');
        return 0;
    }

    my $serviceCertificate;
    if (    $self->conf->{samlServiceUseCertificateInResponse}
        and $self->conf->{samlServicePublicKeySig} =~ /CERTIFICATE/ )
    {
        $serviceCertificate = $self->conf->{samlServicePublicKeySig};
        $self->lmLog( 'Certificate will be used in SAML responses', 'debug' );

    }

    # Get metadata from configuration
    $self->lmLog( "Get Metadata for this service", 'debug' );
    my $service_metadata = Lemonldap::NG::Common::Conf::SAML::Metadata->new();

    # Create Lasso server with service metadata
    my $server = $self->createServer(
        $service_metadata->serviceToXML(
            $self->getApacheHtdocsPath() . "/skins/common/saml2-metadata.tpl",
            $self
        ),
        $self->conf->{samlServicePrivateKeySig},
        $self->conf->{samlServicePrivateKeySigPwd},

        # use signature cert for encryption unless defined
        (
            $self->conf->{samlServicePrivateKeyEnc}
            ? (
                $self->conf->{samlServicePrivateKeyEnc},
                $self->conf->{samlServicePrivateKeyEncPwd}
              )
            : (
                $self->conf->{samlServicePrivateKeySig},
                $self->conf->{samlServicePrivateKeySigPwd}
            )
        ),
        $serviceCertificate
    );

    # Log
    unless ($server) {
        $self->error('Unable to create Lasso server');
        return 0;
    }
    $self->lmLog( "Service created", 'debug' );

    return $server;
}

sub loadIDPs {
    my ($self) = @_;

    # Check presence of at least one identity provider in configuration
    unless ( $self->conf->{samlIDPMetaDataXML}
        and keys %{ $self->conf->{samlIDPMetaDataXML} } )
    {
        $self->lmLog( "No IDP found in configuration", 'warn' );
    }

    # Load identity provider metadata
    # IDP metadata are listed in $self->{samlIDPMetaDataXML}
    # Each key is the IDP name
    # Build IDP list for later use in extractFormInfo
    $self->idpList( {} );

    # TODO: QUESTION: do we have to return 0 (<=> block initialization) if one
    #                 IdP load fails ?
    foreach ( keys %{ $self->conf->{samlIDPMetaDataXML} } ) {
        $self->lmLog( "Get Metadata for IDP $_", 'debug' );

        my $idp_metadata =
          $self->conf->{samlIDPMetaDataXML}->{$_}->{samlIDPMetaDataXML};

        # Check metadata format
        if ( ref $idp_metadata eq "HASH" ) {
            $self->error(
"Metadata for IDP $_ is in old format. Please reload them from Manager"
            );
            return 0;
        }

        if ( $self->conf->{samlMetadataForceUTF8} ) {
            $idp_metadata = encode( "utf8", $idp_metadata );
        }

        # Add this IDP to Lasso::Server
        my $result = $self->addIDP( $self->lassoServer, $idp_metadata );

        unless ($result) {
            $self->error("Fail to use IDP $_ Metadata");
            return 0;
        }

        # Store IDP entityID and Organization Name
        my ($entityID) = ( $idp_metadata =~ /entityID="(.+?)"/i );
        my $name = $self->getOrganizationName( $self->lassoServer, $entityID )
          || ucfirst($_);
        $self->idpList->{$entityID}->{confKey} = $_;
        $self->idpList->{$entityID}->{name}    = $name;

        # Set encryption mode
        my $encryption_mode = $self->conf->{samlIDPMetaDataOptions}->{$_}
          ->{samlIDPMetaDataOptionsEncryptionMode};
        my $lasso_encryption_mode = $self->getEncryptionMode($encryption_mode);

        unless (
            $self->setProviderEncryptionMode(
                $self->lassoServer->get_provider($entityID),
                $lasso_encryption_mode
            )
          )
        {
            $self->error(
                "Unable to set encryption mode $encryption_mode on IDP $_");
            return 0;
        }

        $self->lmLog( "Set encryption mode $encryption_mode on IDP $_",
            'debug' );

        $self->lmLog( "IDP $_ added", 'debug' );
    }
    return 1;
}

sub loadSPs {
    my ($self) = @_;

    # Check presence of at least one service provider in configuration
    unless ( $self->conf->{samlSPMetaDataXML}
        and keys %{ $self->conf->{samlSPMetaDataXML} } )
    {
        $self->lmLog( "No SP found in configuration", 'warn' );
    }

    # Load service provider metadata
    # SP metadata are listed in $self->{samlSPMetaDataXML}
    # Each key is the SP name
    # Build SP list for later use in extractFormInfo
    $self->spList( {} );
    foreach ( keys %{ $self->conf->{samlSPMetaDataXML} } ) {

        $self->lmLog( "Get Metadata for SP $_", 'debug' );

        my $sp_metadata =
          $self->conf->{samlSPMetaDataXML}->{$_}->{samlSPMetaDataXML};

        # Check metadata format
        if ( ref $sp_metadata eq "HASH" ) {
            $self->error(
"Metadata for SP $_ is in old format. Please reload them from Manager"
            );
            return 0;
        }

        if ( $self->conf->{samlMetadataForceUTF8} ) {
            $sp_metadata = encode( "utf8", $sp_metadata );
        }

        # Add this SP to Lasso::Server
        my $result = $self->addSP( $self->lassoServer, $sp_metadata );

        unless ($result) {
            $self->error("Fail to use SP $_ Metadata");
            return 0;
        }

        # Store SP entityID and Organization Name
        my ($entityID) = ( $sp_metadata =~ /entityID="(.+?)"/i );
        my $name = $self->getOrganizationName( $self->lassoServer, $entityID )
          || ucfirst($_);
        $self->spList->{$entityID}->{confKey} = $_;
        $self->spList->{$entityID}->{name}    = $name;

        # Set encryption mode
        my $encryption_mode = $self->conf->{samlSPMetaDataOptions}->{$_}
          ->{samlSPMetaDataOptionsEncryptionMode};
        my $lasso_encryption_mode = $self->getEncryptionMode($encryption_mode);

        unless (
            $self->setProviderEncryptionMode(
                $self->lassoServer->get_provider($entityID),
                $lasso_encryption_mode
            )
          )
        {
            $self->error(
                "Unable to set encryption mode $encryption_mode on SP $_");
            return 0;
        }

        $self->lmLog( "Set encryption mode $encryption_mode on SP $_",
            'debug' );

        $self->lmLog( "SP $_ added", 'debug' );
    }

    return 1;
}

1;
