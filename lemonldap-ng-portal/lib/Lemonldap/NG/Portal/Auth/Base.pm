package Lemonldap::NG::Portal::Auth::Base;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# PROPERTIES

has authnLevel => ( is => 'rw' );

1;

__END__

=pod

=encoding utf8

=head1 NAME

Lemonldap::NG::Portal::Auth::Base - Base module for LemonLDAP::NG
authentication modules.

=head1 SYNOPSIS

  package Lemonldap::NG::Portal::Auth::My;
  
  use strict;
  use Mouse;
  # Add constants used by this module
  use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);
  
  our $VERSION = '0.1';
  
  extends 'Lemonldap::NG::Portal::Auth::Base';

  sub init {
      ...
  }
  
  sub extractFormInfo {
      my ( $self, $req ) = @_;
      ...
  }
  
  sub authenticate {
      my ( $self, $req ) = @_;
      ...
  }
  
  sub authLogout {
      my ( $self, $req ) = @_;
      ...
  }
  
  sub getDisplayType {
      return ...;
  }
  
  1;

=head1 DESCRIPTION

This base library must be used to build Lemonldap::NG authentication modules.
Authentication modules are independent objects that are instantiated by
Lemonldap::NG portal. They must provides methods described below.

=head1 METHODS

=head2 Accessors and methods provided by Lemonldap::NG::Portal::Auth::Base

=over

=item p: portal object

=item conf: configuration hash (as reference)

=item lmLog: alias for p->lmLog method

=item error: alias for p->error method

=item authnLevel: Lemonldap::NG authentication level

=back

=head3 "Routes" management

Like any module that inherits from Lemonldap::NG::Portal::Plugin,
Lemonldap::NG::Portal::Auth::Base provides URI path functions:

=over

=item addAuthRoute: wrapper to L<Lemonldap::NG::Handler::PSGI::Try>
addAuthRoute() method

=item addUnauthRoute: wrapper to L<Lemonldap::NG::Handler::PSGI::Try>
addUnauthRoute() method

=back

Exemple:

  sub init {
      ...
      $self->addAuthRoute( saml => { proxy => "proxySub" }, [ 'GET', 'POST' ] );
      ...
  }
  sub proxySub {
      my ( $self, $req ) = @_;
      ...
      # This sub must return a PSGI response. Example
      return [ 302, [ Location => 'http://x.y/' ], [] ];
  }

This means that requests http://auth.../saml/proxy will be given to proxySub()
method.

=head2 Methods that must be provided by an authentication module

=head3 init()

Method launched after object creation (after each configuration reload). It
must return a true value if authentication module is ready, false else.

=head3 Methods called at each request

All these methods must return a Lemonldap::NG::Portal::Main::Constants value.
They are called with one argument: a L<Lemonldap::NG::Portal::Main::Request>
object.

Note: if you want to change process() next steps, you just have to change
$req->steps array.

=head4 extractFormInfo($req)

First authentication method called during authentication process. It must set
$req->user that will be used by the userDB object to get user information.

=head4 authenticate($req)

Last method called during authentication process.

=head4 authForce($req)

=head4 authLogout($req)

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
