## @file
# Common SAML functions

## @class
# Common SAML functions
package Lemonldap::NG::Portal::_SAML;

use strict;
use base qw(Exporter);

our @EXPORT = qw(
  loadLasso checkLassoError createServer addIDP addProvider
  createAuthnRequest createLogin getHttpMethod initAuthnRequest
  buildAuthnRequestMsg
);

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

    # If $error is not a Lasso::Error object, display error string
    unless ( ref($error) and $error->isa("Lasso::Error") ) {
        return 1 unless $error;
        $self->lmLog( "Lasso error: $error", $level );
        return 0;
    }

    # Else check error code and error message
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
# @param string private key
# @param string optional private key password
# @param string optional certificate
# @return Lasso::Server object
sub createServer {
    my $self                 = shift;
    my $metadata             = shift;
    my $private_key          = shift;
    my $private_key_password = shift;
    my $certificate          = shift;
    my $server;

    eval {
        $server = Lasso::Server::new_from_buffers( $metadata, $private_key,
        $private_key_password, $certificate );
    };

    $self->checkLassoError($@);

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
## @method Lasso::Login createAuthnRequest(Lasso::Server server, string idp)
# Create authentication request for selected IDP
# @param Lasso::Server server
# @param string entityID
# @return Lasso::Login object
sub createAuthnRequest {
    my $self   = shift;
    my $server = shift;
    my $idp    = shift;

    # Create Lasso Login
    my $login = $self->createLogin($server);

    unless ($login) {
        $self->lmLog( 'Unable to create Lasso login', 'error' );
        return;
    }

    # Get HTTP method for selected IDP
    my $method = $self->getHttpMethod( $server, $idp );

    $self->lmLog( "Use HTTP method $method", 'debug' );

    # Init authentication request
    unless ( $self->initAuthnRequest( $login, $idp, $method ) ) {
        $self->lmLog( "Could not initiate authentication request on $idp",
            'error' );
        return;
    }

    # Build authentication request
    unless ( $self->buildAuthnRequestMsg($login) ) {
        $self->lmLog( "Could not build authentication request on $idp",
            'error' );
        return;
    }

    return $login;
}

## @method Lasso::Login createLogin(Lasso::Server server)
# Create Lasso::Login object
# @param Lasso::Server server
# @return Lasso::Login object
sub createLogin {
    my $self   = shift;
    my $server = shift;
    my $login;

    eval { $login = Lasso::Login->new($server); };

    $self->checkLassoError($@);

    return $login;
}

## @method int getHttpMethod(Lasso::Server server, string idp)
# Find a compatible HTTP method
# @param Lasso::Server server
# @param string entityID
# @return int HTTP method
sub getHttpMethod {
    my $self   = shift;
    my $server = shift;
    my $idp    = shift;

    # TODO

    # By default, use HTTP REDIRECT
    return Lasso::Constants::HTTP_METHOD_REDIRECT;
}

## @method boolean initAuthnRequest(Lasso::Login login, string idp, int method)
# Init authentication request
# @param Lasso::Login login
# @param string entityID
# @param int HTTP method
# @return boolean result
sub initAuthnRequest {
    my $self   = shift;
    my $login  = shift;
    my $idp    = shift;
    my $method = shift;

    eval { Lasso::Login::init_authn_request( $login, $idp, $method ); };

    return $self->checkLassoError($@);
}

## @method boolean buildAuthnRequestMsg(Lasso::Login login)
# Build authentication request message
# @param Lasso::Login login
# @return boolean result
sub buildAuthnRequestMsg {
    my $self  = shift;
    my $login = shift;

    eval { Lasso::Login::build_authn_request_msg($login); };

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

=head2 createAuthnRequest

Create authentication request for selected IDP

=head2 createLogin

Create Lasso::Login object

=head2 getHttpMethod

Find a compatible HTTP method

=head2 initAuthnRequest

Init authentication request

=head2 buildAuthnRequestMsg

Build authentication request message

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
