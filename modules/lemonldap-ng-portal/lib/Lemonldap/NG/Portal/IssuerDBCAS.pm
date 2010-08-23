## @file
# CAS Issuer file

## @class
# CAS Issuer class
package Lemonldap::NG::Portal::IssuerDBCAS;

use strict;
use Lemonldap::NG::Portal::Simple;

our $VERSION = '0.01';

## @method void issuerDBInit()
# TODO
# @return Lemonldap::NG::Portal error code
sub issuerDBInit {
    my $self = shift;
    PE_OK;
}

## @apmethod int issuerForUnAuthUser()
# TODO
# @return Lemonldap::NG::Portal error code
sub issuerForUnAuthUser {
    my $self = shift;
    PE_OK;
}

## @apmethod int issuerForAuthUser()
# TODO
# @return Lemonldap::NG::Portal error code
sub issuerForAuthUser {
    my $self   = shift;
    PE_OK;
}

## @apmethod int issuerLogout()
# Do nothing
# @return Lemonldap::NG::Portal error code
sub issuerLogout {
    PE_OK;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::IssuerDBCAS - CAS IssuerDB for LemonLDAP::NG

=head1 DESCRIPTION

CAS Issuer implementation in LemonLDAP::NG

=head1 SEE ALSO

L<Lemonldap::NG::Portal>
http://www.jasig.org/cas/protocol

=head1 AUTHOR

Clement OUDOT, E<lt>clement@oodo.,etE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Clement OUDOT

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
