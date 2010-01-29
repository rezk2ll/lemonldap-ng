## @file
# Common SAML functions

## @class
# Common SAML functions
package Lemonldap::NG::Portal::_SAML;

use strict;
use base qw(Exporter);

our @EXPORT = qw(loadLasso checkLassoError createServer);

our $VERSION = '0.01';

## @method boolean loadLasso()
# Load Lasso module
# @return boolean result
sub loadLasso {
    my $self = shift;

    # Load Lasso.pm
    eval { use Lasso; };
    if ($@) {
        $self->lmLog( "Module Lasso not found in @INC", 'error' );
        $self->lmLog( "$@",                             'debug' );
        return 0;
    }

    # Check version
    my $lasso_check_version_mode = Lasso::Constants::CHECK_VERSION_NUMERIC;

# TODO - wait for perl binding correction
# See http://perso.entrouvert.org/~bdauvergne/git/cgit.cgi?url=lasso-perso/commit/&h=release-2.2.91&id=2da646f9629f3e148fce619ff7de322dbb34cd8d
    my $check_version = 1;

#    my $check_version = Lasso::check_version( 2, 2, 91, $lasso_check_version_mode );

    unless ($check_version) {
        $self->lmLog( 'Lasso version too old', 'error' );
        return 0;
    }

    $self->lmLog( "Module Lasso loaded", 'debug' );
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

## @method Lasso::Server createServer(string metadata, string private key, string private key password, string certificate)
# Load service metadata and create Lasso::Server object
# @param string metadata file
# @param string private key
# @param string private key password
# @param string certificate
# @return Lasso::Server object
sub createServer {
    my $self                 = shift;
    my $metadata             = shift;
    my $private_key          = shift;
    my $private_key_password = shift;
    my $certificate          = shift;

    my $server =
      new Lasso::Server( $metadata, $private_key, $private_key_password,
        $certificate );

    unless ($server) {
        $self->lmLog( 'Unable to create Lasso server', 'error' );
    }

    $self->lmLog( 'Lasso server dump ' . Lasso::Server::dump($server),
        'debug' );

    return $server;
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
