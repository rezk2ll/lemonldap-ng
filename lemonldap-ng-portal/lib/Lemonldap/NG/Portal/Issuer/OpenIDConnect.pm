package Lemonldap::NG::Portal::Issuer::OpenIDConnect;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_ERROR
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Issuer',
  'Lemonldap::NG::Portal::Lib::OpenIDConnect';

# INITIALIZATION

sub init {
    my ($self) = @_;

    # Initialize RP list
    return 0
      unless ( $self->Lemonldap::NG::Portal::Main::Issuer::init()
        and $self->loadRPs );

    # Manage RP requests
    $self->addRouteFromConf(
        'Unauth',
        oidcServiceMetaDataTokenURI        => 'token',
        oidcServiceMetaDataUserInfoURI     => 'userInfo',
        oidcServiceMetaDataJWKSURI         => 'jwks',
        oidcServiceMetaDataRegistrationURI => 'registration',
        oidcServiceMetaDataEndSessionURI   => 'endSessionDone',
        oidcServiceMetaDataCheckSessionURI => 'checkSession',
    );

    # Manage user requests
    $self->addRouteFromConf(
        'Auth',
        oidcServiceMetaDataTokenURI        => 'badAuthRequest',
        oidcServiceMetaDataUserInfoURI     => 'badAuthRequest',
        oidcServiceMetaDataJWKSURI         => 'badAuthRequest',
        oidcServiceMetaDataRegistrationURI => 'badAuthRequest',
        oidcServiceMetaDataCheckSessionURI => 'checkSession',
    );
    return 1;
}

# RUNNING METHODS

# Main method (launched only for authenticated users, see Main/Issuer)
sub run {
    my ( $self, $req, $path ) = @_;
    if ($path) {

        # AUTHORIZE
        if ( $path eq $self->conf->{oidcServiceMetaDataAuthorizeURI} ) {
        }
        elsif ( $path eq $self->conf->{oidcServiceMetaDataEndSessionURI} ) {
        }
    }
    $self->lmLog( "Unknown OIDC url $path, skipping", 'error' );
    return PE_OK;
}

sub token {
    my ( $self, $req ) = @_;
    $self->lmLog( "URL detected as an OpenID Connect TOKEN URL", 'debug' );

    # Check authentication
    my ( $client_id, $client_secret ) =
      $self->getEndPointAuthenticationCredentials($req);

    unless ( $client_id && $client_secret ) {
        $self->lmLog(
"No authentication provided to get token, or authentication type not supported",
            "error"
        );
        return $self->p->sendError($req, 'unauthorized_client', 401);
    }

    # Verify that client_id is registered in configuration
    my $rp = $self->getRP($client_id);

    unless ($rp) {
        $self->lmLog(
            "No registered Relying Party found with client_id $client_id",
            'error' );
        return $self->p->sendError($req,"unauthorized_client",403);
    }
    else {
        $self->lmLog( "Client id $client_id match RP $rp", 'debug' );
    }

    # Check client_secret
    unless ( $client_secret eq $self->conf->{oidcRPMetaDataOptions}->{$rp}
        ->{oidcRPMetaDataOptionsClientSecret} )
    {
        $self->lmLog( "Wrong credentials for $rp", "error" );
        return $self->p->sendError("access_denied",403);
    }

    # Get code session
    my $code = $self->param('code');

    $self->lmLog( "OpenID Connect Code: $code", 'debug' );

    my $codeSession = $self->getOpenIDConnectSession($code);

    unless ($codeSession) {
        $self->lmLog( "Unable to find OIDC session $code", "error" );
        $self->p->sendError($req,"invalid_request",400);
    }

    # Check we have the same redirect_uri value
    unless (
        $req->param("redirect_uri") eq $codeSession->data->{redirect_uri} )
    {
        $self->lmLog(
            "Provided redirect_uri is different from "
              . $codeSession->{redirect_uri},
            "error"
        );
        $self->p->sendError($req,"invalid_request",400);
    }

    # Get user identifier
    my $apacheSession =
      $self->p->getApacheSession( $codeSession->data->{user_session_id}, 1 );

    unless ($apacheSession) {
        $self->lmLog(
            "Unable to find user session linked to OIDC session $code",
            "error" );
        $codeSession->remove();
        $self->p->sendError($req,"invalid_request",400);
    }

    my $user_id_attribute =
      $self->conf->{oidcRPMetaDataOptions}->{$rp}->{oidcRPMetaDataOptionsUserIDAttr}
      || $self->conf->{whatToTrace};
    my $user_id = $apacheSession->data->{$user_id_attribute};

    $self->lmLog( "Found corresponding user: $user_id", 'debug' );

    # Generate access_token
    my $accessTokenSession = $self->getOpenIDConnectSession;

    unless ($accessTokenSession) {
        $self->lmLog( "Unable to create OIDC session for access_token",
            "error" );
        $codeSession->remove();
        $self->p->sendError($req,"invalid_request",400);
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

    # Compute hash to store in at_hash
    my $alg = $self->conf->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsIDTokenSignAlg};
    my ($hash_level) = ( $alg =~ /(?:\w{2})(\d{3})/ );
    my $at_hash = $self->createHash( $access_token, $hash_level );

    # ID token payload
    my $id_token_exp = $self->conf->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsIDTokenExpiration};
    $id_token_exp += time;

    my $id_token_acr = "loa-" . $apacheSession->data->{authenticationLevel};

    my $id_token_payload_hash = {
        iss => $issuer,          # Issuer Identifier
        sub => $user_id,         # Subject Identifier
        aud => [$client_id],     # Audience
        exp => $id_token_exp,    # expiration
        iat => time,             # Issued time
        auth_time =>
          $apacheSession->data->{_lastAuthnUTime},    # Authentication time
        acr => $id_token_acr,    # Authentication Context Class Reference
        azp => $client_id,       # Authorized party
                                 # TODO amr
    };

    my $nonce = $codeSession->data->{nonce};
    $id_token_payload_hash->{nonce} = $nonce if defined $nonce;
    $id_token_payload_hash->{'at_hash'} = $at_hash if $at_hash;

    # Create ID Token
    my $id_token = $self->createIDToken( $id_token_payload_hash, $rp );

    $self->lmLog( "Generated id token: $id_token", 'debug' );

    # Send token response
    my $expires_in = $self->conf->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsAccessTokenExpiration};

    my $token_response = {
        access_token => $access_token,
        token_type   => 'Bearer',
        expires_in   => $expires_in,
        id_token     => $id_token,
    };

    $self->lmLog( "Send token response", 'debug' );

    $codeSession->remove();
    return $self->p->sendJSONresponse($req,$token_response);
}

sub userInfo {
    my ( $self, $req ) = @_;
}

sub jwks {
    my ( $self, $req ) = @_;
}

sub registration {
    my ( $self, $req ) = @_;
}

sub endSessionDone {
    my ( $self, $req ) = @_;
}

sub checkSession {
    my ( $self, $req ) = @_;
}

sub badAuthRequest {
    my ( $self, $req ) = @_;
    return $self->p->sendError( $req,
        $req->uri . ' may not be called by an authenticated user', 400 );
}

sub logout {
    my ( $self, $req ) = @_;
}

# Internal methods

sub addRouteFromConf {
    my ( $self, $type, %subs ) = @_;
    my $adder = "add${type}Route";
    foreach ( keys %subs ) {
        my $sub  = $subs{$_};
        my $path = $self->conf->{$_};
        unless ($path) {
            $self->lmLog( "$_ parameter not defined", 'error' );
            next;
        }
        $self->$adder( $self->path => { $path => $sub }, [ 'GET', 'POST' ] );
    }
}

1;
__END__
