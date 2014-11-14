## @file
# Common OpenID Connect functions

## @class
# Common OpenID Connect functions
package Lemonldap::NG::Portal::_OpenIDConnect;

use strict;
use JSON;
use MIME::Base64;
use URI::Escape;
use base qw(Lemonldap::NG::Portal::_Browser);

our $VERSION = '2.00';

## @method String getCallbackUri()
# Compute callback URI
# @return String Callback URI
sub getCallbackUri {
    my $self = shift;

    my $callback_get_param = $self->{OIDCRPCallbackGetParam};

    my $callback_uri = $self->{portal};
    $callback_uri .=
      ( $self->{portal} =~ /\?/ )
      ? '&' . $callback_get_param . '=1'
      : '?' . $callback_get_param . '=1';

    $self->lmLog( "OpenIDConnect Callback URI: $callback_uri", 'debug' );

    return $callback_uri;
}

## @method Strind buildAuthorizationCodeAuthnRequest(String state)
# Build Authentication Request URI for Authorization Code Flow
# @param state State
# return String Authentication Request URI
sub buildAuthorizationCodeAuthnRequest {
    my ( $self, $state ) = splice @_;

    my $authorize_uri = $self->{OIDCRPAuthorizeURI};
    my $client_id     = $self->{OIDCRPClientID};
    my $scope         = $self->{OIDCRPScope};
    my $response_type = "code";
    my $redirect_uri  = $self->getCallbackUri;

    $client_id     = uri_escape($client_id);
    $scope         = uri_escape($scope);
    $response_type = uri_escape($response_type);
    $redirect_uri  = uri_escape($redirect_uri);
    $state         = uri_escape($state) if defined $state;

    my $authn_uri = $authorize_uri;
    $authn_uri .= ( $authorize_uri =~ /\?/ ? '&' : '?' );
    $authn_uri .= "response_type=$response_type";
    $authn_uri .= "&client_id=$client_id";
    $authn_uri .= "&scope=$scope";
    $authn_uri .= "&redirect_uri=$redirect_uri";
    $authn_uri .= "&state=$state" if defined $state;

    $self->lmLog(
        "OpenIDConnect Authorization Code Flow Authn Request: $authn_uri",
        'debug' );

    return $authn_uri;
}

## @method Strind getAuthorizationCodeAccessToken(String code)
# Get Token response with autorization code
# @param code Code
# return String Token response decoded content
sub getAuthorizationCodeAccessToken {
    my ( $self, $code ) = splice @_;

    my $client_id        = $self->{OIDCRPClientID};
    my $client_secret    = $self->{OIDCRPClientSecret};
    my $redirect_uri     = $self->getCallbackUri;
    my $access_token_uri = $self->{OIDCRPAccessTokenURI};
    my $grant_type       = "authorization_code";
    my %form;

    $form{"code"}          = $code;
    $form{"client_id"}     = $client_id;
    $form{"client_secret"} = $client_secret;
    $form{"redirect_uri"}  = $redirect_uri;
    $form{"grant_type"}    = $grant_type;

    my $response = $self->ua->post( $access_token_uri, \%form,
        "Content-Type" => 'application/x-www-form-urlencoded' );

    if ( $response->is_error ) {
        $self->lmLog( "Bad authorization response: " . $response->message,
            "error" );
        $self->lmLog( $response->content, 'debug' );
        return 0;
    }

    return $response->decoded_content;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::_OpenIDConnect - Common OpenIDConnect functions

=head1 SYNOPSIS

use Lemonldap::NG::Portal::_OpenIDConnect;

=head1 DESCRIPTION

This module contains common methods for OpenIDConnect authentication
and user information loading

=head1 METHODS

=head2 getCallbackUri

Compute callback URI

=head2 buildAuthorizationCodeAuthnRequest

Build Authentication Request URI for Authorization Code Flow

=head2 getAuthorizationCodeAccessToken

Get Token response with autorization code

=head1 SEE ALSO

L<Lemonldap::NG::Portal::AuthOpenIDConnect>, L<Lemonldap::NG::Portal::UserDBOpenIDConnect>

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
