package Lemonldap::NG::Portal::Main::SecondFactor;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_NOTOKEN
  PE_TOKENEXPIRED
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

has ott => (
    is      => 'rw',
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->{conf}->{formTimeout} );
        return $ott;
    }
);

has prefix => ( is => 'rw' );

has logo => ( is => 'rw', default => '2f.png' );

sub init {
    my ($self) = @_;
    $self->addUnauthRoute( $self->prefix . '2fcheck' => '_verify',   ['POST'] );
    $self->addUnauthRoute( $self->prefix . '2fcheck' => '_redirect', ['GET'] );
    1;
}

sub _redirect {
    my ( $self, $req ) = @_;
    my $arg = $req->env->{QUERY_STRING};
    return [
        302, [ Location => $self->conf->{portal} . ( $arg ? "?$arg" : '' ) ], []
    ];
}

sub _verify {
    my ( $self, $req ) = @_;

    # Check token
    my $token;
    unless ( $token = $req->param('token') ) {
        $self->userLogger->error( $self->prefix . ' 2F access without token' );
        $req->mustRedirect(1);
        return $self->p->do( $req, [ sub { PE_NOTOKEN } ] );
    }

    my $session;
    unless ( $session = $self->ott->getToken($token) ) {
        $self->userLogger->info('Token expired');
        return $self->p->do( $req, [ sub { PE_TOKENEXPIRED } ] );
    }

    # Launch second factor verification
    my $res = $self->verify( $req, $session );

    # Case error
    if ($res) {
        $req->noLoginDisplay(1);
        return $self->p->do( $req, [ sub { $res } ] );
    }

    # Else restore session
    $req->sessionInfo($session);
    $req->id( delete $req->sessionInfo->{_2fRealSession} );
    $req->urldc( delete $req->sessionInfo->{_2fUrldc} );
    $self->p->rebuildCookies($req);
    $req->mustRedirect(1);
    $self->userLogger->notice( $self->prefix
          . '2F verification for '
          . $req->sessionInfo->{ $self->conf->{whatToTrace} } );
    if ( my $l = $self->conf->{ $self->prefix . '2fAuthnLevel' } ) {
        $self->p->updateSession( $req, { authenticationLevel => $l } );
    }
    return $self->p->do( $req, [ sub { PE_OK } ] );
}

1;
__END__

=pod

=encoding utf8

=head1 NAME

Lemonldap::NG::Portal::Main::SecondFactor - Base class for
L<Lemonldap::NG::Portal> second factor plugins.

=head1 SYNOPSIS

  package Lemonldap::NG::Portal::2F::MySecondFactor;
  use Mouse;
  use Lemonldap::NG::Portal::Main::Constants qw(
    PE_OK
    PE_BADCREDENTIALS
    PE_SENDRESPONSE
  );
  extends 'Lemonldap::NG::Portal::Main::SecondFactor';
  
  # Prefix that will be used in parameter names. The form used to enter the
  # second factor must post its result to "/my2fcheck" (if "my" is the prefix).
  has prefix => ( is => 'ro', default => 'my' );
  
  sub init {
      my ($self) = @_;
      # Insert here initialization process
      return $self->SUPER::init();
  }
  # Required 2nd factor send method
  sub run {
      my ( $self, $req, $token ) = @_;
      # $token must be inserted in a hidden input in your form with the name
      # "token"
      ...
      # A LLNG constant must be returned. Example:
      $req->response($my_psgi_response)
      return PE_SENDRESPONSE;
  }
  sub verify {
      my ( $self, $req, $session ) = @_;
      # Use $req->param('field') to get POST responses
      ...
      if($req->param('result') eq $goodResult) {
        return PE_OK;
      }
      else {
        return PE_BADCREDENTIALS
      }
  }

Enable your plugin in lemonldap-ng.ini, section [portal]:

=over

=item <prefix>2fActivation (required): 1, 0 or a rule

=item <prefix>2fAuthnLevel (optional): change authentication level for users
authenticated by this plugin

=back

Example:

  [portal]
  customPlugins = Lemonldap::NG::Portal::2F::MyPlugin
  my2fActivation = 1
  my2fAuthnLevel = 4

=head1 DESCRIPTION

Lemonldap::NG::Portal::Main::SecondFactor provides a simple framework to build
Lemonldap::NG second authentication factor plugin.

See Lemonldap::NG::Portal::Plugins::External2F or
Lemonldap::NG::Portal::Plugins::U2F for examples.

=head1 SEE ALSO

L<http://lemonldap-ng.org>

=head2 OTHER POD FILES

=over

=item Writing an authentication module: L<Lemonldap::NG::Portal::Auth>

=item Writing a UserDB module: L<Lemonldap::NG::Portal::UserDB>

=item Writing a second factor module: L<Lemonldap::NG::Portal::Main::SecondFactor>

=item Writing an issuer module: L<Lemonldap::NG::Portal::Main::Issuer>

=item Writing an other plugin: L<Lemonldap::NG::Portal::Main::Plugin>

=item Request object: L<Lemonldap::NG::Portal::Main::Request>

=item Adding parameters in the manager: L<Lemonldap::NG::Manager::Build>

=back

=head1 AUTHORS

=over

=item LemonLDAP::NG team L<http://lemonldap-ng.org/team>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues>

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
