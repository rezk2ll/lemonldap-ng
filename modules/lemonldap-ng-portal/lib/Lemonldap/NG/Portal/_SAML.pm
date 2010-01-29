## @file
# Common SAML functions

## @class
# Common SAML functions
package Lemonldap::NG::Portal::_SAML;

use strict;
use base qw(Exporter);

our @EXPORT = qw(loadLasso);

our $VERSION = '0.01';

## @method boolean loadLasso()
# Load Lasso module
# @return boolean result
sub loadLasso {
    my $self = shift;

    eval { require Lasso; };
    if ($@) {
        $self->lmLog( "Module Lasso not found in @INC", 'error' );
        $self->lmLog( "$@",                             'debug' );
        return 0;
    }

    my $version = $Lasso::VERSION;

    $self->lmLog( "Module Lasso $version loaded", 'debug' );
    return 1;
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
