package Lemonldap::NG::Portal::Auth::Base;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Common::Module';

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
  
  sub authForce {
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
Authentication modules are independant objects that are instanciated by
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

=head2 Methods that must be provided by an authentication module

=head3 init()

Method launched after object creation (after each configuration reload). It
must return a true value if authentication module is ready, false else.

=head3 Methods called at each request

All these methods must return a Lemonldap::NG::Portal::Main::Constants value.
They are called with one argument: a L<Lemonldap::NG::Portal::Main::Request>
object.

=head4 extractFormInfo($req)

First authentication method called during authentication process. It must set
$req->user that will be used by the userDB object to get user informations.

=head4 authenticate($req)

Last method called during authentication process.

=head4 authForce($req)

=head4 authLogout($req)

=cut
