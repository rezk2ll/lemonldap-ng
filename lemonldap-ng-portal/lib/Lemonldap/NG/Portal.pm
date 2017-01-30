## @file
# Alias for Lemonldap::NG::SharedConf

## @class
# Alias for Lemonldap::NG::SharedConf
package Lemonldap::NG::Portal;

our $VERSION = '2.0.0';
use Lemonldap::NG::Portal::Main;
use base 'Lemonldap::NG::Portal::Main';

1;

__END__

=pod

=encoding utf8

=head1 NAME

Lemonldap::NG::Portal - The authentication portal part of Lemonldap::NG Web-SSO
system.

=head1 SYNOPSIS

Use any of Plack launcher. Example:

  #!/usr/bin/env plackup
  
  use Lemonldap::NG::Portal;
  
  # This must be the last instruction! See PSGI for more
  Lemonldap::NG::Portal->run($opts);

=head1 DESCRIPTION

Lemonldap::NG is a modular Web-SSO based on Apache::Session modules. It
simplifies the build of a protected area with a few changes in the application.

It manages both authentication and authorization and provides headers for
accounting. So you can have a full AAA protection for your web space as
described below.

Lemonldap::NG::Portal provides portal components. See
L<http://lemonldap-ng.org> for more.

=head1 KINEMATICS

The portal object is based on L<Lemonldap::NG::Handler::Try>: underlying
handler tries to authenticate user and then follow the routes (auth/unauth)
declared during initialization.

=head2 Initialization

The intialisation process subscribes portal to handler configuration reload and
ask for handler initialization (L<Lemonldap::NG::Portal::Main::Init>).
So configuration read is triggered by handler at each reload.

During configuration reload, every enabled components are loaded as plugins:

=over

=item authentication module

=item userDB module

=item other enabled plugins (issuers,...)

=back

init() is called for each plugin. If one plugin initialization fails (init()
returns 0), the portal responds a 500 status code for each request.

See L<Lemonldap::NG::Portal::Main::Plugin> to see how to write modules.

=head2 Main route

The "/" route is declared in L<Lemonldap::NG::Portal::Main::Init>. It points to
different methods in L<Lemonldap::NG::Portal::Main::Run>. Theses methods choose
methods to call in the process and call do().

do() stores methods to call in $req->steps and launches
Lemonldap::NG::Portal::Main::Process::process(). This method removes each method
stored in $req->steps and launches it. If the result is PE_OK, proces()
continues, else it returns the error code.

If the request was an Ajax one, do() responds in JSON format else it manages
redirection if any. Else it calls
Lemonldap::NG::Portal::Main::Display::display() to have template and arguments,
then it launch Lemonldap::NG::Common::PSGI::sendHtml() with them.

=head1 DEVELOPER INSTRUCTIONS

Portal main object is defined in Lemonldap::NG::Portal::Main::* classes. Other
components are plugins. Plugins must not store any hash key in the main object.

Main and plugin keys must be initializated during initialization. They must
be read-only during receiving requests.

The L<Lemonldap::NG::Portal::Main::Request> request has fixed keys. A plugin
that wants to store a temporary key must store it in $req->datas or use
defined keys, but it must never create a root key. Plugin keys may have
explicit names to avoid conflicts.

Whole configuration is always available. It is stored in $self->conf. It must
not be modified by anyone even during initialization or receiving request
(during initialization, copy the value in the plugin namespace instead).

All plugins can dial with the portal methods using $self->p which points to
portal main object. Some main methods are mapped to the plugin namespace:

=over

=item lmLog()

=item error() accessor (use it to store error during initialization)

=back

=head1 SEE ALSO

Most of the documentation is available on the website
L<http://lemonldap-ng.org>

=head2 OTHER POD FILES

=over

=item Writing an authentication module: L<Lemonldap::NG::Portal::Auth::Base>

=item Writing an issuer module: L<Lemonldap::NG::Portal::Main::Issuer>

=item Writing another type of plugin: L<Lemonldap::NG::Portal::Main::Plugin>

=item Request object: L<Lemonldap::NG::Portal::Main::Request>

=item Adding parameters in the manager: L<Lemonldap::NG::Manager::Build>

=back

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
