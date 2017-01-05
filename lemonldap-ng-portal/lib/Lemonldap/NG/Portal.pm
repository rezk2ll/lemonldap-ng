## @file
# Alias for Lemonldap::NG::SharedConf

## @class
# Alias for Lemonldap::NG::SharedConf
package Lemonldap::NG::Portal;

our $VERSION = '2.0.0';
use Lemonldap::NG::Portal::SharedConf;
use base 'Lemonldap::NG::Portal::SharedConf';

1;

__END__

=pod

=encoding utf8

=head1 NAME

Lemonldap::NG::Portal - The authentication portal part of Lemonldap::NG Web-SSO
system.

=head1 DESCRIPTION

Lemonldap::NG is a modular Web-SSO based on Apache::Session modules. It
simplifies the build of a protected area with a few changes in the application.

It manages both authentication and authorization and provides headers for
accounting. So you can have a full AAA protection for your web space as
described below.

Lemonldap::NG::Portal provides portal components. See
L<http://lemonldap-ng.org> for more.

=head1 OTHER POD FILES

Most of the documentation is available on the website
L<http://lemonldap-ng.org>.

=over

=item Writing an authentication module: L<Lemonldap::NG::Portal::Auth::Base>

=item Writing an issuer module: L<Lemonldap::NG::Portal::Main::Issuer>

=item Writing another type of plugin: L<Lemonldap::NG::Portal::Main::Plugin>

=item Request object: L<Lemonldap::NG::Portal::Main::Request>

=item Adding parameters in the manager: L<Lemonldap::NG::Manager::Build>

=back

=head1 SEE ALSO

L<http://lemonldap-ng.org>

=head1 AUTHORS

=over

=item LemonLDAP::NG team L<http://lemonldap-ng.org/team>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

See COPYING file for details.

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
