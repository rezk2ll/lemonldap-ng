##@file
# Demo authentication backend file

##@class
# Demo authentication backend class
package Lemonldap::NG::Portal::Auth::Demo;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;

extends qw(Lemonldap::NG::Portal::Auth::_WebForm);

our $VERSION = '2.0.0';

use constant AuthnLevel => 0;

## @apmethod int authInit()
# Initialize demo accounts
# @return Lemonldap::NG::Portal constant
sub init {
    my $self = shift;

    # Add warning in log
    $self->lmLog(
        "Using demonstration mode, go in Manager to edit the configuration",
        'warn' );

    1;
}

## @apmethod int authenticate()
# Does nothing.
# @return Lemonldap::NG::Portal constant
sub authenticate {
    my ( $self, $req ) = @_;

    return PE_BADCREDENTIALS unless ( $req->{user} eq $req->datas->{password} );

    PE_OK;
}

## @apmethod int authLogout()
# Does nothing
# @return Lemonldap::NG::Portal constant
sub authLogout {
    PE_OK;
}

## @apmethod boolean authForce()
# Does nothing
# @return result
sub authForce {
    PE_OK;
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::AuthDemo - Perl extension for building Lemonldap::NG
compatible portals with built-in authentication.

=head1 SYNOPSIS


=head1 DESCRIPTION

This library just overload few methods of Lemonldap::NG::Portal::Simple to 
create sessions for sample users.

See L<Lemonldap::NG::Portal::Simple> for usage and other methods.

=head1 SEE ALSO

L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Portal::Simple>,
L<http://lemonldap-ng.org/>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2012 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

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

