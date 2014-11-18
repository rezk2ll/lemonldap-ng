##@file
# OpenIDConnect authentication backend file

##@class
# OpenIDConnect authentication backend class
package Lemonldap::NG::Portal::AuthOpenIDConnect;

use strict;
use Lemonldap::NG::Portal::Simple;
use MIME::Base64;
use base qw(Lemonldap::NG::Portal::_OpenIDConnect);

our $VERSION = '2.00';

## @apmethod int authInit()
# Does nothing
# @return Lemonldap::NG::Portal constant
sub authInit {
    PE_OK;
}

## @apmethod int setAuthSessionInfo()
# Set _user value to 'anonymous' and authenticationLevel to 0
# @return Lemonldap::NG::Portal constant
sub setAuthSessionInfo {
    my $self = shift;

    $self->{sessionInfo}->{'_user'} = $self->{user};
    $self->{sessionInfo}->{authenticationLevel} = $self->{nullAuthnLevel};

    $self->{sessionInfo}->{OpenIDConnect_access_token} =
      $self->{tmp}->{access_token};
    $self->{sessionInfo}->{OpenIDConnect_IDToken} = $self->{tmp}->{IDToken};

    PE_OK;
}

## @apmethod int extractFormInfo()
# Does nothing
# @return Lemonldap::NG::Portal constant
sub extractFormInfo {
    my $self = shift;

    # Check callback
    my $callback_get_param = $self->{OIDCRPCallbackGetParam};
    my $callback           = $self->param($callback_get_param);

    unless ($callback) {

        # AuthN Request
        $self->lmLog( "Build OpenIDConnect AuthN Request", 'debug' );

        # Save state
        my $state = $self->storeState(qw/urldc checkLogins/);

        my $stateSession = $self->storeState();

        # TODO Use AuthChoiceParam in redirect URL

        # Authorization Code Flow
        $self->{urldc} = $self->buildAuthorizationCodeAuthnRequest($state);

        $self->lmLog( "Redirect user to " . $self->{urldc}, 'debug' );

        return $self->_subProcess(qw(autoRedirect));
    }
    else {

        $self->lmLog(
            "OpenIDConnect callback URI detected: "
              . $self->url( -path_info => 1, -query => 1 ),
            'debug'
        );

        # AuthN Response
        my $state = $self->param("state");
        my $code  = $self->param("code");

        # Restore state
        if ($state) {
            if ( $self->extractState($state) ) {
                $self->lmLog( "State $state extracted", 'debug' );
            }
            else {
                $self->lmLog( "Unable to extract state $state", 'error' );
                return PE_ERROR;
            }
        }

        # Get access_token and id_token
        my $content = $self->getAuthorizationCodeAccessToken($code);
        return PE_ERROR unless $content;

        my $json = $self->decodeJSON($content);

        if ( $json->{error} ) {
            $self->lmLog( "Error in token response:" . $json->{error},
                'error' );
            return PE_ERROR;
        }

        my $access_token = $json->{access_token};
        my $id_token     = $json->{id_token};

        $self->lmLog( "Access token: $access_token", 'debug' );
        $self->lmLog( "ID token: $id_token",         'debug' );

        # Verify JWT signature
        if ( $self->{OIDCRPCheckJWTSignature} ) {
            unless ( $self->verifyJWTSignature($id_token) ) {
                $self->lmLog( "JWT signature verification failed", 'error' );
                return PE_ERROR;
            }
        }

        # Get ID token content
        my ( $id_token_header, $id_token_payload, $id_token_signature ) =
          split( /\./, $id_token );

        my $id_token_payload_hash =
          $self->decodeJSON( decode_base64($id_token_payload) );

        my $user_id = $id_token_payload_hash->{sub};

        # Remember tokens
        $self->{tmp}->{access_token} = $access_token;
        $self->{tmp}->{id_token}     = $id_token_payload_hash;

        $self->lmLog( "Found user_id: " . $user_id, 'debug' );
        $self->{user} = $user_id;

        return PE_OK;
    }

    PE_OK;
}

## @apmethod int authenticate()
# Does nothing.
# @return Lemonldap::NG::Portal constant
sub authenticate {
    PE_OK;
}

## @apmethod int authFinish()
# Does nothing.
# @return Lemonldap::NG::Portal constant
sub authFinish {
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
    return 0;
}

## @method string getDisplayType
# @return display type
sub getDisplayType {
    return "logo";
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::AuthOpenIDConnect - Perl extension for building Lemonldap::NG
compatible portals with OpenID Connect.

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::SharedConf;
  my $portal = new Lemonldap::NG::Portal::Simple(
         configStorage     => {...}, # See Lemonldap::NG::Portal
         authentication    => 'OpenIDConnect',
    );

  if($portal->process()) {
    # Write here the menu with CGI methods. This page is displayed ONLY IF
    # the user was not redirected here.
    print $portal->header('text/html; charset=utf-8'); # DON'T FORGET THIS (see CGI(3))
    print "...";

    # or redirect the user to the menu
    print $portal->redirect( -uri => 'https://portal/menu');
  }
  else {
    print $portal->header('text/html; charset=utf-8'); # DON'T FORGET THIS (see CGI(3))
    print "<html><body><h1>Unable to work</h1>";
    print "This server isn't well configured. Contact your administrator.";
    print "</body></html>";
  }

=head1 DESCRIPTION

OpenID Connect authentication module.

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

=item Copyright (C) 2014 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

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

