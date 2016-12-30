package Lemonldap::NG::Portal::Auth::SAML;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_CONFIRM
  PE_ERROR
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base',
  'Lemonldap::NG::Portal::Lib::OpenIDConnect';

# INTERFACE

has oplist => ( is => 'rw', default => sub { [] } );
has opNumber => ( is => 'rw', default => 0 );

# INITIALIZATION

sub init {
    my ($self) = @_;
    return 0 unless ( $self->loadOPs and $self->refreshJWSdata );
    my @tab = ( sort keys %{ $self->oidcOPList } );
    unless (@tab) {
        $self->lmLog( "No OP configured", 'error' );
        return 0;
    }
    $self->opNumber( scalar @tab );
    my @list = ();

    my $portalPath = $self->{portal};
    $portalPath =~ s#^https?://[^/]+/?#/#;

    foreach (@tab) {
        my $name = $self->conf->{oidcOPMetaDataOptions}->{$_}
          ->{oidcOPMetaDataOptionsDisplayName};
        my $icon = $self->conf->{oidcOPMetaDataOptions}->{$_}
          ->{oidcOPMetaDataOptionsIcon};
        my $img_src;

        if ($icon) {
            $img_src =
              ( $icon =~ m#^https?://# )
              ? $icon
              : $portalPath . $self->p->staticPrefix . "/common/" . $icon;
        }

        push @list,
          {
            val   => $_,
            name  => $name,
            icon  => $img_src,
            class => "openidconnect",
          };
    }
    $self->oplist( [@list] );
    return 1;
}

# RUNNING METHODS

sub extractFormInfo {
    my ( $self, $req ) = @_;

    # Check callback
    if ( $req->param( $self->conf->{oidcRPCallbackGetParam} ) ) {

        $self->lmLog(
            'OpenIDConnect callback URI detected: ' . $req->uri, 'debug' );

        # AuthN Response
        my $state = $req->param('state');

        # Restore state
        if ($state) {
            if ( $self->extractState($req, $state) ) {
                $self->lmLog( "State $state extracted", 'debug' );
            }
            else {
                $self->lmLog( "Unable to extract state $state", 'error' );
                return PE_ERROR;
            }
        }

        # Get OpenID Provider
        $self->lmLog( "################### TODO: verify this (Auth:52)",
            'debug' );
        my $op = $req->datas->{_oidcOPCurrent};

        unless ($op) {
            $self->lmLog( "OpenID Provider not found", 'error' );
            return PE_ERROR;
        }

        $self->lmLog( "Using OpenID Provider $op", 'debug' );

        # Check error
        my $error = $req->param("error");
        if ($error) {
            my $error_description = $req->param("error_description");
            my $error_uri         = $req->param("error_uri");

            $self->lmLog( "Error returned by $op Provider: $error", 'error' );
            $self->lmLog( "Error description: $error_description",  'error' )
              if $error_description;
            $self->lmLog( "Error URI: $error_uri", 'error' ) if $error_uri;

            return PE_ERROR;
        }

        # Get access_token and id_token
        my $code = $req->param("code");
        my $auth_method =
          $self->conf->{oidcOPMetaDataOptions}->{$op}
          ->{oidcOPMetaDataOptionsTokenEndpointAuthMethod};

        my $content =
          $self->getAuthorizationCodeAccessToken( $req, $op, $code,
            $auth_method );
        return PE_ERROR unless $content;

        my $json = $self->decodeJSON($content);

        if ( $json->{error} ) {
            $self->lmLog( "Error in token response:" . $json->{error},
                'error' );
            return PE_ERROR;
        }

        # Check validity of token response
        unless ( $self->checkTokenResponseValidity($json) ) {
            $self->lmLog( "Token response is not valid", 'error' );
            return PE_ERROR;
        }
        else {
            $self->lmLog( "Token response is valid", 'debug' );
        }

        my $access_token = $json->{access_token};
        my $id_token     = $json->{id_token};

        $self->lmLog( "Access token: $access_token", 'debug' );
        $self->lmLog( "ID token: $id_token",         'debug' );

        # Verify JWT signature
        if ( $self->conf->{oidcOPMetaDataOptions}->{$op}
            ->{oidcOPMetaDataOptionsCheckJWTSignature} )
        {
            unless ( $self->verifyJWTSignature( $id_token, $op ) ) {
                $self->lmLog( "JWT signature verification failed", 'error' );
                return PE_ERROR;
            }
            $self->lmLog( "JWT signature verified", 'debug' );
        }
        else {
            $self->lmLog( "JWT signature check disabled", 'debug' );
        }

        my $id_token_payload = $self->extractJWT($id_token)->[1];

        my $id_token_payload_hash =
          $self->decodeJSON( decode_base64($id_token_payload) );

        # Check validity of Access Token (optional)
        my $at_hash = $id_token_payload_hash->{at_hash};
        if ($at_hash) {
            unless ( $self->verifyHash( $access_token, $at_hash, $id_token ) ) {
                $self->lmLog( "Access token hash verification failed",
                    'error' );
                return PE_ERROR;
            }
            $self->lmLog( "Access token hash verified", 'debug' );
        }
        else {
            $self->lmLog(
                "No at_hash in ID Token, access token will not be verified",
                'debug' );
        }

        # Check validity of ID Token
        unless ( $self->checkIDTokenValidity( $op, $id_token_payload_hash ) ) {
            $self->lmLog( 'ID Token not valid', 'error' );
            return PE_ERROR;
        }
        else {
            $self->lmLog( 'ID Token is valid', 'debug' );
        }

        # Get user id defined in 'sub' field
        my $user_id = $id_token_payload_hash->{sub};

        # Remember tokens
        $req->datas->{access_token} = $access_token;
        $req->datas->{id_token}     = $id_token;

        $self->lmLog( "Found user_id: " . $user_id, 'debug' );
        $self->{user} = $user_id;

        return PE_OK;
    }

    # No callback, choose Provider and send authn request
    my $op;

    unless ( $op = $req->param("idp") ) {
        $self->lmLog( "Redirecting user to OP list", 'debug' );

        # Auto select provider if there is only one
        if ( $self->opNumber == 1 ) {
            $op = $self->opList->[0];
            $self->lmLog( "Selecting the only defined OP: $op", 'debug' );
        }

        else {

            # IDP list
            my @list = ();

            my $portalPath = $self->{portal};
            $portalPath =~ s#^https?://[^/]+/?#/#;

            foreach ( @{ $self->oplist } ) {
                my $name = $self->conf->{oidcOPMetaDataOptions}->{$_}
                  ->{oidcOPMetaDataOptionsDisplayName};
                my $icon = $self->conf->{oidcOPMetaDataOptions}->{$_}
                  ->{oidcOPMetaDataOptionsIcon};
                my $img_src;

                if ($icon) {
                    $img_src =
                      ( $icon =~ m#^https?://# )
                      ? $icon
                      : $portalPath . "skins/common/" . $icon;
                }

                push @list,
                  {
                    val   => $_,
                    name  => $name,
                    icon  => $img_src,
                    class => "openidconnect",
                  };
            }
            $req->datas->{list}  = $self->opList;
            $req->datas->{confirmRemember} = 0;

            $req->datas->{login} = 1;
            return PE_CONFIRM;
        }
    }

    # Provider is choosen
    $self->lmLog( "OpenID Provider $op choosen", 'debug' );

    $req->datas->{_oidcOPCurrent} = $op;

    # AuthN Request
    $self->lmLog( "Build OpenIDConnect AuthN Request", 'debug' );

    # Save state
    my $state = $self->storeState(qw/urldc checkLogins _oidcOPCurrent/);

    # Authorization Code Flow
    $req->urldc( $self->buildAuthorizationCodeAuthnRequest( $req, $op, $state ) );

    $self->lmLog( "Redirect user to " . $self->{urldc}, 'debug' );

    $req->steps([]);

    return PE_OK;
}

sub authenticate {
    PE_OK;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    my $op   = $req->datas->{_oidcOPCurrent};

    $req->{sessionInfo}->{authenticationLevel} = $self->conf->{oidcAuthnLevel};

    $req->{sessionInfo}->{OpenIDConnect_OP} = $op;
    $req->{sessionInfo}->{OpenIDConnect_access_token} = $req->datas->{access_token};

    # Keep ID Token in session
    my $store_IDToken = $self->conf->{oidcOPMetaDataOptions}->{$op}->{oidcOPMetaDataOptionsStoreIDToken};
    if ($store_IDToken) {
        $self->lmLog( "Store ID Token in session", 'debug' );
        $req->{sessionInfo}->{OpenIDConnect_IDToken} = $req->datas->{id_token};
    }
    else {
        $self->lmLog( "ID Token will not be stored in session", 'debug' );
    }

    PE_OK;
}

sub authLogout {
    my ( $self, $req ) = @_;

    my $op = $req->{sessionInfo}->{OpenIDConnect_OP};

    # Find endession endpoint
    my $endsession_endpoint =
      $self->oidcOPList->{$op}->{conf}->{end_session_endpoint};

    if ($endsession_endpoint) {
        my $logout_url = $self->conf->{portal} . '?logout=1';
        $req->urldc(
          $self->buildLogoutRequest( $endsession_endpoint,
            $self->{sessionInfo}->{OpenIDConnect_IDToken}, $logout_url ));

        $self->lmLog(
            "OpenID Connect logout to $op will be done on ".$req->urldc,
            'debug' );
    }
    else {
        $self->lmLog( "No end session endpoint found for $op", 'debug' );
    }
    PE_OK;
}

sub getDisplayType {
    return "logo";
}

# Internal methods

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::Auth::OpenIDConnect - Perl extension for building Lemonldap::NG
compatible portals with OpenID Connect.

=head1 SYNOPSIS

=head1 DESCRIPTION

OpenID Connect authentication module.

See L<http://lemonldap-ng.org> for usage and other methods.

=head1 SEE ALSO

L<http://lemonldap-ng.org/>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2014-2016 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item Copyright (C) 2016 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

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
