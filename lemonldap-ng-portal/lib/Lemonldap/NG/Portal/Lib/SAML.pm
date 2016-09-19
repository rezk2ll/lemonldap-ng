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

has lassoServer      => ( is => 'rw' );
has spList           => ( is => 'rw', default => sub { {} } );
has idpList          => ( is => 'rw', default => sub { {} } );
has privateKeyEnc    => ( is => 'rw' );
has privateKeyEncPwd => ( is => 'rw' );

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
                $_[0]->lmLog( $_[0] . " error " . $_[1] . ": " . $_[2],
                    'debug' );
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

    # use signature cert for encryption unless defined
    if ( $self->conf->{samlServicePrivateKeyEnc} ) {
        $self->privateKeyEnc( $self->conf->{samlServicePrivateKeyEnc} );
        $self->privateKeyEncPwd( $self->conf->{samlServicePrivateKeyEncPwd} );
    }
    else {
        $self->privateKeyEnc( $self->conf->{samlServicePrivateKeySig} );
        $self->privateKeyEncPwd( $self->conf->{samlServicePrivateKeySigPwd} );
    }

    unless ($self->conf->{samlServicePublicKeySig}
        and $self->conf->{samlServicePrivateKeySig} )
    {
        $self->error('SAML private and public key not found in configuration');
        return 0;
    }

    # TODO
    $self->lassoServer( $self->loadService() ) or return 0;
    return 1;
}

sub loadService {
    my ($self) = @_;
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
        $self->privateKeyEnc,
        $self->privateKeyEncPwd,
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

1;
