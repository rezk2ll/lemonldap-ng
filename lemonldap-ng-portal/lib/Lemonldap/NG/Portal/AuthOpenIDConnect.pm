##@file
# OpenIDConnect authentication backend file

##@class
# OpenIDConnect authentication backend class
package Lemonldap::NG::Portal::AuthOpenIDConnect;

use strict;
use JSON;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_Browser;
use MIME::Base64;
use URI::Escape;

our @ISA     = (qw(Lemonldap::NG::Portal::_Browser));
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

    my $client_id        = $self->{OIDCRPClientID};
    my $client_secret    = $self->{OIDCRPClientSecret};
    my $authorize_uri    = $self->{OIDCRPAuthorizeURI};
    my $access_token_uri = $self->{OIDCRPAccessTokenURI};

    my $scope = $self->{OIDCRPScope};

    my $callback_get_param = $self->{OIDCRPCallbackGetParam};

    my $callback_uri = $self->{portal} . "?$callback_get_param=1";

    # Check callback
    my $callback = $self->param($callback_get_param);

    unless ($callback) {

        # AuthN Request
        $self->lmLog( "Build OpenIDConnect AuthN Request", 'debug' );

        # TODO Save state
        my $state = "dummy";

        # Authorization Code Flow
        my $response_type = uri_escape("code");
        my $redirect_uri = uri_escape($callback_uri);

        $scope        = uri_escape($scope);
        $client_id    = uri_escape($client_id);
        $state        = uri_escape($state);

        $self->{urldc} = $authorize_uri
          . "?response_type=$response_type&client_id=$client_id&scope=$scope&redirect_uri=$redirect_uri&state=$state";

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

        # TODO Restore state

        # Token Request
        my $grant_type = "authorization_code";
        my %form;
        $form{"code"}          = $code;
        $form{"client_id"}     = $client_id;
        $form{"client_secret"} = $client_secret;
        $form{"redirect_uri"}  = $callback_uri;
        $form{"grant_type"}    = $grant_type;

        my $response = $self->ua->post( $access_token_uri, \%form,
            "Content-Type" => 'application/x-www-form-urlencoded' );

        if ( $response->is_error ) {
            $self->lmLog( "Bad authorization response: " . $response->message,
                "error" );
            $self->lmLog( $response->content, 'debug' );
            return PE_ERROR;
        }

        # Get access_token and id_token
        my $content = $response->decoded_content;
        my $json    = decode_json $content;

        if ( $json->{error} ) {
            $self->lmLog( "Error in token response:" . $json->{error},
                'error' );
            return PE_ERROR;
        }

        my $access_token = $json->{access_token};
        my $id_token     = $json->{id_token};

        $self->lmLog( "Access token: $access_token", 'debug' );
        $self->lmLog( "ID token: $id_token",         'debug' );

        # TODO verify JWT signature

        # Get ID token content
        my ( $id_token_header, $id_token_payload, $id_token_signature ) =
          split( /\./, $id_token );

        # TODO check signature
        my $id_token_payload_hash =
          decode_json( decode_base64($id_token_payload) );

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

