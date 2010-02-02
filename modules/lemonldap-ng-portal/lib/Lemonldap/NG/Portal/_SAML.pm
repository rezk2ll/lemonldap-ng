## @file
# Common SAML functions

## @class
# Common SAML functions
package Lemonldap::NG::Portal::_SAML;

use strict;
use base qw(Exporter);

our @EXPORT = qw(loadLasso checkLassoError createServer addIDP addProvider);

our $VERSION = '0.01';

## @method boolean loadLasso()
# Load Lasso module
# @return boolean result
sub loadLasso {
    my $self = shift;

    # Do not load Lasso twice
    return 1 if $self->{_lasso};

    # Catch GLib Lasso messages (require Glib)
    eval { use Glib; };
    unless ($@) {
        Glib::Log->set_handler(
            "Lasso",
            [qw/ error critical warning message info debug /],
            sub {
                $self->lmLog( $_[0] . " error " . $_[1] . ": " . $_[2],
                    'debug' );
            }
        );
    }
    else {
        $self->lmLog(
            "Glib Lasso messages will not be catched (require Glib module)",
            'info' );
    }

    # Load Lasso.pm
    eval { use Lasso; };
    if ($@) {
        $self->lmLog( "Module Lasso not found in @INC", 'error' );
        $self->lmLog( "$@",                             'debug' );
        return 0;
    }

    # Check Lasso version >= 2.2.91
    my $lasso_check_version_mode = Lasso::Constants::CHECK_VERSION_NUMERIC;
    my $check_version =
      Lasso::check_version( 2, 2, 91, $lasso_check_version_mode );

    unless ($check_version) {
        $self->lmLog( 'Lasso version >= 2.2.91 required', 'error' );
        return 0;
    }

    $self->lmLog( "Module Lasso loaded", 'debug' );

    # Remember we have loaded Lasso
    $self->{_lasso} = 1;

    return 1;
}

## @method boolean checkLassoError(Lasso::Error error, string level)
# Log Lasso error code and message if this is actually a Lasso::Error with code > 0
# @param Lasso::Error Lasso error object
# @param string optional log level (debug by default)
# @return 1 if no error
sub checkLassoError {
    my $self  = shift;
    my $error = shift;
    my $level = shift || 'debug';

    # Return if $error is not a Lasso::Error object
    return 1 unless ( ref($error) and $error->isa("Lasso::Error") );

    if ( $error->{code} ) {
        $self->lmLog(
            "Lasso error code " . $error->{code} . ": " . $error->{message},
            $level );
        return 0;
    }

    return 1;
}

## @method Lasso::Server createServer(string metadata, string private_key, string private_key_password, string certificate)
# Load service metadata and create Lasso::Server object
# @param string metadata
# @param string optional private key
# @param string optional private key password
# @param string optional certificate
# @return Lasso::Server object
sub createServer {
    my $self                 = shift;
    my $metadata             = shift;
    my $private_key          = shift || '';
    my $private_key_password = shift || '';
    my $certificate          = shift || '';

    my $server = Lasso::Server::new_from_buffers( $metadata, $private_key,
        $private_key_password, $certificate );

    unless ($server) {
        $self->lmLog( 'Unable to create Lasso server', 'error' );
    }

    return $server;
}

## @method boolean addIDP(Lasso::Server server, string metadata, string public_key, string ca_cert_chain)
# Add IDP to an existing Lasso::Server
# @param Lasso::Server Lasso::Server object
# @param string metadata IDP metadata
# @param string optional public key
# @param string optional ca cert chain
# @return boolean result
sub addIDP {
    my $self          = shift;
    my $server        = shift;
    my $metadata      = shift;
    my $public_key    = shift;
    my $ca_cert_chain = shift;

    return 0 unless ( $server->isa("Lasso::Server") and defined $metadata );

    return $self->addProvider( $server, Lasso::Constants::PROVIDER_ROLE_IDP,
        $metadata, $public_key, $ca_cert_chain );
}

## @method boolean addProvider(Lasso::Server server, int role, string metadata, string public_key, string ca_cert_chain)
# Add provider to an existing Lasso::Server
# @param Lasso::Server Lasso::Server object
# @param int role (IDP, SP or Both)
# @param string metadata IDP metadata
# @param string optional public key
# @param string optional ca cert chain
# @return boolean result
sub addProvider {
    my $self          = shift;
    my $server        = shift;
    my $role          = shift;
    my $metadata      = shift;
    my $public_key    = shift;
    my $ca_cert_chain = shift;

    return 0
      unless ( $server->isa("Lasso::Server")
        and defined $role
        and defined $metadata );

    eval {
        Lasso::Server::add_provider_from_buffer( $server, $role, $metadata,
            $public_key, $ca_cert_chain );
    };

    return $self->checkLassoError($@);

}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::_SAML

=head1 SYNOPSIS

use Lemonldap::NG::Portal::_SAML;

=head1 DESCRIPTION

This module contains common methods for SAML authentication
and user information loading

=head1 METHODS

=head2 loadLasso

Load Lasso module

=head2 checkLassoError

Log Lasso error code and message if this is actually a Lasso::Error with code > 0

=head2 createServer

Load service metadata and create Lasso::Server object

=head2 addIDP

Add IDP to an existing Lasso::Server

=head2 addProvider

Add provider to an existing Lasso::Server

=head1 SEE ALSO

L<Lemonldap::NG::Portal::AuthSAML>, L<Lemonldap::NG::Portal::UserDBSAML>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>,
Clement Oudot, E<lt>coudot@linagora.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Xavier Guimard, Clement Oudot

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
