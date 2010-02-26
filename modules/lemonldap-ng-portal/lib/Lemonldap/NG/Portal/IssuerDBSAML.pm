## @file
# SAML Issuer file

## @class
# SAML Issuer class
package Lemonldap::NG::Portal::IssuerDBSAML;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_SAML;
our @ISA = qw(Lemonldap::NG::Portal::_SAML);

our $VERSION = '0.01';

## @method void issuerDBInit()
# TODO
# Load and check SAML configuration
# @return Lemonldap::NG::Portal error code
sub issuerDBInit {
    my $self = shift;
    $self->abort('This feature is not released');
    return PE_OK;
}

## @apmethod int issuerForUnAuthUser()
# TODO
# Check if there is an SAML authentication request.
# Called only for unauthenticated users, it store SAML request in
# $self->{url}
# @return Lemonldap::NG::Portal error code
sub issuerForUnAuthUser {
    my $self = shift;
    PE_OK;
}

## @apmethod int issuerForAuthUser()
# TODO
# Check if there is an SAML authentication request for an authenticated user
# and build assertions
# @return Lemonldap::NG::Portal error code
sub issuerForAuthUser {
    my $self = shift;
    PE_OK;
}

## @apmethod int issuerLogout()
# TODO
# @return Lemonldap::NG::Portal error code
sub issuerLogout {
    my $self = shift;
    PE_OK;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::IssuerDBSAML - SAML IssuerDB for Lemonldap::NG

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::IssuerDBSAML;
  #TODO

=head1 DESCRIPTION

SAML IssuerDB for Lemonldap::NG

=head1 SEE ALSO

L<Lemonldap::NG::Portal>

=head1 AUTHOR

Clément Oudot, E<lt>coudot@linagora.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Clément Oudot

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
