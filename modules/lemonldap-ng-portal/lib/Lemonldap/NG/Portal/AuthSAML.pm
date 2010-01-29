## @file
# SAML Consumer skeleton

## @class
# SAML Consumer skeleton
package Lemonldap::NG::Portal::AuthSAML;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_SAML;    #inherits

our $VERSION = '0.1';

our $metadata_dir             = "/tmp";
our $service_metadata_file    = $metadata_dir . "/metadata.xml";
our $service_private_key_file = $metadata_dir . "/private-key.pem";

## @apmethod int authInit()
# Load Lasso and metadata
# @return Lemonldap::NG::Portal error code
sub authInit {
    my $self = shift;

    # Load Lasso
    return PE_ERROR unless $self->loadLasso();

    # Activate SOAP
    $self->{Soap} = 1;

    # Load service metadata
    unless ( -r $service_metadata_file || -r $service_private_key_file ) {

        # TODO - serialize XML from configuration data
        # TODO - use a test to rebuild XML if file is too old
    }

    my $server =
      $self->createServer( $service_metadata_file, $service_private_key_file );

    return PE_ERROR unless $server;

    # Load entities metadata

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
