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
    my $userinfo_uri              = $self->{oidcServiceMetaDataUserInfoURI};
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
            $self->setHiddenFormValue( $param,
                $self->getHiddenFormValue($param) || $self->param($param) );
        }

    }

    # TOKEN
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${token_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect TOKEN URL",
            'debug' );

        # Check authentication
        my ( $client_id, $client_secret ) =
          $self->getEndPointAuthenticationCredentials();

        unless ( $client_id && $client_secret ) {
            $self->lmLog(
"No authentication provided to get token, or authentication type not supported",
                "error"
            );
            $self->returnJSONError("unauthorized_client");
            $self->quit;
        }

        # Verify that client_id is registered in configuration
        my $rp = $self->getRP($client_id);

        unless ($rp) {
            $self->lmLog(
                "No registered Relaying Party found with client_id $client_id",
                'error'
            );
            $self->returnJSONError("unauthorized_client");
            $self->quit;
        }
        else {
            $self->lmLog( "Client id $client_id match RP $rp", 'debug' );
        }

        # Check client_secret
        unless ( $client_secret eq $self->{oidcRPMetaDataOptions}->{$rp}
            ->{oidcRPMetaDataOptionsClientSecret} )
        {
            $self->lmLog( "Wrong credentials", "error" );
            $self->returnJSONError("access_denied");
            $self->quit;
        }

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

        # Store data in access token
        $accessTokenSession->update(
            {
                scope           => $codeSession->data->{scope},
                rp              => $rp,
                user_session_id => $apacheSession->id,
                _utime          => time,
            }
        );

        my $access_token = $accessTokenSession->id;

        $self->lmLog( "Generated access token: $access_token", 'debug' );

        # ID token payload
        my $id_token_payload_hash = {
            iss       => $issuer,       # Issuer Identifier
            sub       => $user_id,      # Subject Identifier
            aud       => $client_id,    # Audience
            exp       => "3600",        # expiration TODO
            iat       => time,          # Issued time
            auth_time => time           # Authentication time TODO
                                        # TODO acr
                                        # TODO amr
                                        # TODO azp
        };

        # Create ID Token
        my $id_token = $self->createIDToken( $id_token_payload_hash, $rp );

        $self->lmLog( "Generated id token: $id_token", 'debug' );

        # TODO configure expiration
        my $expires_in = "3600";

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

    # USERINFO
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${userinfo_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect USERINFO URL",
            'debug' );

        my $access_token = $self->getEndPointAccessToken();

        unless ($access_token) {
            $self->lmLog( "Unable to get access_token", "error" );
            $self->returnBearerError( "invalid_request",
                "Access token not found in request" );
            $self->quit;
        }

        $self->lmLog( "Received Access Token $access_token", 'debug' );

        my $accessTokenSession = $self->getOpenIDConnectSession($access_token);

        unless ($accessTokenSession) {
            $self->lmLog(
                "Unable to get access token session for id $access_token",
                "error" );
            $self->returnBearerError( "invalid_token",
                "Access Token not found or expired" );
            $self->quit;
        }

        # Get access token session data
        my $scope           = $accessTokenSession->data->{scope};
        my $rp              = $accessTokenSession->data->{rp};
        my $user_session_id = $accessTokenSession->data->{user_session_id};

        my $userinfo_response =
          $self->buildUserInfoResponse( $scope, $rp, $user_session_id );

        $self->returnJSON($userinfo_response);

        $self->lmLog( "UserInfo response sent", 'debug' );

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
    my $userinfo_uri              = $self->{issuerDBOpenIDConnectUserInfoURI};

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

        # Get and save parameters
        my $oidc_request = {};
        foreach my $param (qw/response_type scope client_id state redirect_uri/)
        {
            $oidc_request->{$param} = $self->getHiddenFormValue($param)
              || $self->param($param);
            $self->lmLog(
                "OIDC request parameter $param: " . $oidc_request->{$param},
                'debug' );
            $self->setHiddenFormValue( $param, $oidc_request->{$param} );
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
                    "Client id "
                      . $oidc_request->{'client_id'}
                      . " match RP $rp",
                    'debug'
                );
            }

            # Obtain consent
            my $ask_for_consent = 1;
            if (    $self->{sessionInfo}->{"_oidc_consent_time_$rp"}
                and $self->{sessionInfo}->{"_oidc_consent_scope_$rp"} )
            {
                $ask_for_consent = 0;
                my $consent_time =
                  $self->{sessionInfo}->{"_oidc_consent_time_$rp"};
                my $consent_scope =
                  $self->{sessionInfo}->{"_oidc_consent_scope_$rp"};

                $self->lmLog(
"Consent already given for Relaying Party $rp (time: $consent_time, scope: $consent_scope)",
                    'debug'
                );

                # Check accepted scope
                foreach my $requested_scope (
                    split( /\s+/, $oidc_request->{'scope'} ) )
                {
                    if ( $consent_scope =~ /\b$requested_scope\b/ ) {
                        $self->lmLog( "Scope $requested_scope already accepted",
                            'debug' );
                    }
                    else {
                        $self->lmLog(
"Scope $requested_scope was not previously accepted",
                            'debug'
                        );
                        $ask_for_consent = 1;
                        last;
                    }
                }
            }
            if ($ask_for_consent) {
                if ( $self->param('confirm') == 1 ) {
                    $self->updatePersistentSession(
                        { "_oidc_consent_time_$rp" => time } );
                    $self->updatePersistentSession(
                        {
                            "_oidc_consent_scope_$rp" =>
                              $oidc_request->{'scope'}
                        }
                    );
                    $self->lmLog( "Consent given for Relaying Party $rp",
                        'debug' );
                }
                else {
                    $self->lmLog( "Obtain user consent for Relaying Party $rp",
                        'debug' );

                    my $display_name = $self->{oidcRPMetaDataOptions}->{$rp}
                      ->{oidcRPMetaDataOptionsDisplayName};
                    my $icon = $self->{oidcRPMetaDataOptions}->{$rp}
                      ->{oidcRPMetaDataOptionsIcon};
                    my $portalPath = $self->{portal};
                    $portalPath =~ s#^https?://[^/]+/?#/#;
                    $portalPath =~ s#[^/]+\.pl$##;

                    $self->info('<div class="oidc_consent_message">');
                    $self->info( '<img src="'
                          . $portalPath
                          . "skins/common/"
                          . $icon
                          . '" />' )
                      if $icon;
                    $self->info( '<h3>'
                          . sprintf( $self->msg(PM_OIDC_CONSENT),
                            $display_name )
                          . '</h3>' );
                    $self->info('<ul>');

                    foreach my $requested_scope (
                        split( /\s/, $oidc_request->{'scope'} ) )
                    {
                        my $message;
                        my $scope_messages = {
                            openid  => PM_OIDC_SCOPE_OPENID,
                            profile => PM_OIDC_SCOPE_PROFILE,
                            email   => PM_OIDC_SCOPE_EMAIL,
                            address => PM_OIDC_SCOPE_ADDRESS,
                            phone   => PM_OIDC_SCOPE_PHONE,
                        };
                        if ( $scope_messages->{$requested_scope} ) {
                            $message =
                              $self->msg( $scope_messages->{$requested_scope} );
                        }
                        else {
                            $message = $self->msg(PM_OIDC_SCOPE_OTHER) . " "
                              . $requested_scope;
                        }
                        $self->info("<li>$message</li>");
                    }
                    $self->info('</ul>');
                    $self->info('</div>');
                    $self->{activeTimer} = 0;
                    return PE_CONFIRM;
                }
            }

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
                    scope           => $oidc_request->{'scope'},
                    user_session_id => $session_id,
                    _utime          => time,
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

    # USERINFO
    if ( $url_path =~ m#${issuerDBOpenIDConnectPath}${userinfo_uri}# ) {

        $self->lmLog( "URL $url detected as an OpenID Connect USERINFO URL",
            'debug' );

        # This should not happen
        $self->lmLog(
            "UserInfo request found on an active SSO session, ignoring it",
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
