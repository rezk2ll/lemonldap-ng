## @file
# OpenIDConnect Issuer file

## @class
# OpenIDConnect Issuer class
package Lemonldap::NG::Portal::IssuerDBOpenIDConnect;

use strict;
use Lemonldap::NG::Portal::Simple;
use URI::Escape;
use JSON;
use MIME::Base64;
use Digest::SHA qw/hmac_sha256_base64/;
use base qw(Lemonldap::NG::Portal::_OpenIDConnect);

our $VERSION = '2.00';

## @method void issuerDBInit()
# Get configuration data
# @return Lemonldap::NG::Portal error code
sub issuerDBInit {
    my $self = shift;

    return PE_ERROR unless $self->loadRPs;

    return PE_OK;
}

## @apmethod int issuerForUnAuthUser()
# Get OIDC request
# @return Lemonldap::NG::Portal error code
sub issuerForUnAuthUser {

    my $self = shift;

    my $issuerDBOpenIDConnectPath = $self->{issuerDBOpenIDConnectPath};
    my $authorize_uri             = $self->{oidcServiceMetaDataAuthorizeURI};
    my $token_uri                 = $self->{oidcServiceMetaDataTokenURI};
    my $issuer                    = $self->{oidcServiceMetaDataIssuer};

    # Called URL
    my $url = $self->url();
    my $url_path = $self->url( -absolute => 1 );
    $url_path =~ s#^//#/#;

    # AUTHORIZE
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${authorize_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect AUTHORIZE URL",
            'debug' );

        # Save parameters
        foreach my $param (qw/response_type scope client_id state redirect_uri/)
        {
            $self->setHiddenFormValue( $param, $self->param($param) );
        }

    }

    # TOKEN
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${token_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect TOKEN URL",
            'debug' );

        # TODO check authorization header or other authentication scheme

        # Get code session
        my $code = $self->param('code');

        $self->lmLog( "OpenID Connect Code: $code", 'debug' );

        my $codeSession = $self->getOpenIDConnectSession($code);

        unless ($codeSession) {
            $self->lmLog( "Unable to find OIDC session $code", "error" );
            $self->returnJSONError("invalid_request");
            $self->quit;
        }

        # Check we have the same redirect_uri value
        unless (
            $self->param("redirect_uri") eq $codeSession->data->{redirect_uri} )
        {
            $self->lmLog(
                "Provided redirect_uri is different from "
                  . $codeSession->{redirect_uri},
                "error"
            );
            $self->returnJSONError("invalid_request");
            $codeSession->remove();
            $self->quit;
        }

        # Get user identifier
        my $apacheSession =
          $self->getApacheSession( $codeSession->data->{user_session_id}, 1 );

        unless ($apacheSession) {
            $self->lmLog(
                "Unable to find user session linked to OIDC session $code",
                "error" );
            $self->returnJSONError("invalid_request");
            $codeSession->remove();
            $self->quit;
        }

        my $user_id = $apacheSession->data->{_user};  # TODO configure attribute

        $self->lmLog( "Found corresponding user: $user_id", 'debug' );

        # Generate access_token
        my $accessTokenSession = $self->getOpenIDConnectSession;

        unless ($accessTokenSession) {
            $self->lmLog( "Unable to create OIDC session for access_token",
                "error" );
            $self->returnJSONError("invalid_request");
            $codeSession->remove();
            $self->quit;
        }

        my $access_token = $accessTokenSession->id;

        $self->lmLog( "Generated access token: $access_token", 'debug' );

        # Create id_token
        my $id_token_payload_hash = {
            iss       => $issuer,     # Issuer Identifier
            sub       => $user_id,    # Subject Identifier
            aud       => "dummy",     # client_id TODO
            exp       => "3600",      # expiration TODO
            iat       => time,        # Issued time
            auth_time => time         # Authentication time TODO
                                      # TODO acr
                                      # TODO amr
                                      # TODO azp
        };

        # JSON and base64
        my $id_token_payload =
          encode_base64( encode_json($id_token_payload_hash), "" );

        # Sign id_token with JWS
        # TODO Choose alg
        my $id_token_header_hash = { typ => "JWT", alg => "HS256" };
        my $id_token_header =
          encode_base64( encode_json($id_token_header_hash), "" );

        # Signature
        # TODO shared key
        my $key = "ABCDEFGHIJKL";
        my $digest =
          hmac_sha256_base64( $id_token_header . "." . $id_token_payload,
            $key );

        # TODO configure expiration
        my $expires_in = "3600";

        my $id_token =
          $id_token_header . "." . $id_token_payload . "." . $digest;

        $self->lmLog( "Generated id token: $id_token", 'debug' );

        # Send token response
        my $token_response = {
            access_token => $access_token,
            token_type   => 'Bearer',
            expires_in   => $expires_in,
            id_token     => $id_token,
        };

        $self->returnJSON($token_response);

        $self->lmLog( "Token response sent", 'debug' );

        $codeSession->remove();
        $self->quit;

    }

    PE_OK;
}

## @apmethod int issuerForAuthUser()
# Do nothing
# @return Lemonldap::NG::Portal error code
sub issuerForAuthUser {

    my $self = shift;

    my $issuerDBOpenIDConnectPath = $self->{issuerDBOpenIDConnectPath};
    my $authorize_uri             = $self->{issuerDBOpenIDConnectAuthorizeURI};
    my $token_uri                 = $self->{issuerDBOpenIDConnectTokenURI};

    # Session ID
    my $session_id = $self->{sessionInfo}->{_session_id} || $self->{id};

    # Called URL
    my $url = $self->url();
    my $url_path = $self->url( -absolute => 1 );
    $url_path =~ s#^//#/#;

    # AUTHORIZE
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${authorize_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect AUTHORIZE URL",
            'debug' );

        # Get parameters
        my $oidc_request = {};
        foreach my $param (qw/response_type scope client_id state redirect_uri/)
        {
            $oidc_request->{$param} = $self->getHiddenFormValue($param)
              || $self->param($param);
            $self->lmLog(
                "OIDC request parameter $param: " . $oidc_request->{$param},
                'debug' );
        }

        # TODO check all required parameters
        # TODO validate parameters against OAuth 2.0 spec

        # Authorization Code Flow
        if ( $oidc_request->{'response_type'} eq "code" ) {
            $self->lmLog( "OIDC auhtorization code flow requested", 'debug' );

            # Check openid scope
            unless ( $oidc_request->{'scope'} =~ /\bopenid\b/ ) {
                $self->lmLog( "No openid scope found", 'debug' );

                #TODO manage standard OAuth request
                return PE_OK;
            }

            # Check client_id
            $self->lmLog(
                "Request from client id " . $oidc_request->{'client_id'},
                'debug' );

            # Verify that client_id is registered in configuration
            my $rp = $self->getRP( $oidc_request->{'client_id'} );

            unless ($rp) {
                $self->lmLog(
                    "No registered Relaying Party found with client_id "
                      . $oidc_request->{'client_id'},
                    'error'
                );
                return PE_ERROR;
            }
            else {
                $self->lmLog(
                    "Cient id "
                      . $oidc_request->{'client_id'}
                      . " match RP $rp",
                    'debug'
                );
            }

            # TODO obtain consent

            # Prepare response
            my $response_url = $oidc_request->{'redirect_uri'};

            $response_url .=
              ( $oidc_request->{'redirect_uri'} =~ /\?/ ? '&' : '?' );

            # Generate code
            my $codeSession = $self->getOpenIDConnectSession();
            my $code        = $codeSession->id();
            $response_url .= "code=" . uri_escape($code);

            $self->lmLog( "Generated code: $code", 'debug' );

            # Store data in session
            $codeSession->update(
                {
                    redirect_uri    => $oidc_request->{'redirect_uri'},
                    user_session_id => $session_id,
                }
            );

            if ( $oidc_request->{state} ) {
                $response_url .=
                  "&state=" . uri_escape( $oidc_request->{'state'} );
            }

            $self->lmLog( "Redirect user to $response_url", 'debug' );
            $self->{'urldc'} = $response_url;

            $self->_sub('autoRedirect');
        }
    }

    # TOKEN
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${token_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect TOKEN URL",
            'debug' );

        # This should not happen
        $self->lmLog(
            "Token request found on an active SSO session, ignoring it",
            'error' );
        $self->returnJSONError("invalid_request");

        $self->quit;
    }

    PE_OK;
}

## @apmethod int issuerLogout()
# Do nothing
# @return Lemonldap::NG::Portal error code
sub issuerLogout {
    PE_OK;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::IssuerDBOpenIDConnect - OpenIDConnect Provider for Lemonldap::NG

=head1 DESCRIPTION

This is an OpenID Connect provider implementation in LemonLDAP::NG

=head1 SEE ALSO

L<Lemonldap::NG::Portal>

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
