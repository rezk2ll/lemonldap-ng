## @file
# Common OpenID Connect functions

## @class
# Common OpenID Connect functions
package Lemonldap::NG::Portal::Lib::OpenIDConnect;

use strict;
use Crypt::OpenSSL::Bignum;
use Crypt::OpenSSL::RSA;
use Digest::SHA
  qw/hmac_sha256_base64 hmac_sha384_base64 hmac_sha512_base64 sha256 sha384
  sha512 sha256_base64 sha384_base64 sha512_base64/;
use JSON;
use LWP::UserAgent;
use MIME::Base64 qw/encode_base64 decode_base64/;
use Mouse;
use URI::Escape;

use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

our $VERSION = '2.0.0';

# OpenID Connect standard claims
use constant PROFILE => [
    qw/name family_name given_name middle_name nickname preferred_username
      profile picture website gender birthdate zoneinfo locale updated_at/
];
use constant EMAIL => [qw/email email_verified/];
use constant ADDRESS =>
  [qw/formatted street_address locality region postal_code/];
use constant PHONE => [qw/phone_number phone_number_verified/];

# PROPERTIES

has oidcOPList   => ( is => 'rw', default => sub { {} }, );
has oidcRPList   => ( is => 'rw', default => sub { {} }, );
has rpAttributes => ( is => 'rw', default => sub { {} }, );

# return LWP::UserAgent object
has ua => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {

        # TODO : LWP options to use a proxy for example
        my $ua = LWP::UserAgent->new();
        push @{ $ua->requests_redirectable }, 'POST';
        $ua->env_proxy();
        return $ua;
    }
);

# METHODS

# Load OpenID Connect Providers and JWKS data
# @param no_cache Disable cache use
# @return boolean result
sub loadOPs {
    my ($self) = @_;

    # Check cache
    # Check presence of at least one identity provider in configuration
    unless ( $self->conf->{oidcOPMetaDataJSON}
        and keys %{ $self->conf->{oidcOPMetaDataJSON} } )
    {
        $self->lmLog( "No OpenID Connect Provider found in configuration",
            'warn' );
    }

    # Extract JSON data
    foreach ( keys %{ $self->{oidcOPMetaDataJSON} } ) {
        $self->oidcOPList->{$_}->{conf} =
          $self->decodeJSON( $self->conf->{oidcOPMetaDataJSON}->{$_} );
        $self->oidcOPList->{$_}->{jwks} =
          $self->decodeJSON( $self->conf->{oidcOPMetaDataJWKS}->{$_} );
    }
    return 1;
}

# Load OpenID Connect Relying Parties
# @param no_cache Disable cache use
# @return boolean result
sub loadRPs {
    my ($self) = @_;

    # Check presence of at least one relying party in configuration
    unless ( $self->conf->{oidcRPMetaDataOptions}
        and keys %{ $self->conf->{oidcRPMetaDataOptions} } )
    {
        $self->lmLog( "No OpenID Connect Relying Party found in configuration",
            'warn' );
    }
    $self->oidcRPList( $self->conf->{oidcRPMetaDataOptions} );
    foreach my $rp ( keys %{ $self->oidcRPList } ) {
        my $attributes = {
            profile => PROFILE,
            email   => EMAIL,
            address => ADDRESS,
            phone   => PHONE,
        };

        # Additional claims
        my $extraClaims =
          $self->conf->{oidcRPMetaDataOptionsExtraClaims}->{$rp};

        if ($extraClaims) {
            foreach my $claim ( keys %$extraClaims ) {
                $self->lmLog( "Using extra claim $claim for $rp", 'debug' );
                my @extraAttributes = split( /\s/, $extraClaims->{$claim} );
                $attributes->{$claim} = \@extraAttributes;
            }
        }
        $self->rpAttributes->{$rp} = $attributes;
    }
    return 1;
}

# Refresh JWKS data if needed
# @param no_cache Disable cache update
# @return boolean result
sub refreshJWKSdata {
    my ($self) = @_;

    unless ( $self->conf->{oidcOPMetaDataJSON}
        and keys %{ $self->conf->{oidcOPMetaDataJSON} } )
    {
        $self->lmLog(
            "No OpenID Provider configured, JWKS data will not be refreshed",
            'debug' );
        return 1;
    }

    foreach ( keys %{ $self->conf->{oidcOPMetaDataJSON} } ) {

        # Refresh JWKS data if
        # 1/ oidcOPMetaDataOptionsJWKSTimeout > 0
        # 2/ jwks_uri defined in metadata

        my $jwksTimeout =
          $self->conf->{oidcOPMetaDataOptions}->{$_}
          ->{oidcOPMetaDataOptionsJWKSTimeout};
        my $jwksUri = $self->oidcOPList->{$_}->{conf}->{jwks_uri};

        unless ($jwksTimeout) {
            $self->lmLog( "No JWKS refresh timeout defined for $_, skipping...",
                'debug' );
            next;
        }

        unless ($jwksUri) {
            $self->lmLog( "No JWKS URI defined for $_, skipping...", 'debug' );
            next;
        }

        if ( $self->oidcOPList->{$_}->{jwks}->{time} + $jwksTimeout > time ) {
            $self->lmLog( "JWKS data still valid for $_, skipping...",
                'debug' );
            next;
        }

        $self->lmLog( "Refresh JWKS data for $_ from $jwksUri", 'debug' );

        my $response = $self->ua->get($jwksUri);

        if ( $response->is_error ) {
            $self->lmLog(
                "Unable to get JWKS data for $_ from $jwksUri: "
                  . $response->message,
                "warn"
            );
            $self->lmLog( $response->content, 'debug' );
            next;
        }

        my $content = $self->decodeJSON( $response->decoded_content );

        $self->oidcOPList->{$_}->{jwks} = $content;
        $self->oidcOPList->{$_}->{jwks}->{time} = time;

    }
    return 1;
}

# Get Relying Party corresponding to a Client ID
# @param client_id Client ID
# @return String result
sub getRP {
    my ( $self, $client_id ) = @_;
    my $rp;

    foreach ( keys %{ $self->oidcRPList } ) {
        if ( $client_id eq
            $self->oidcRPList->{$_}->{oidcRPMetaDataOptionsClientID} )
        {
            $rp = $_;
            last;
        }
    }
    return $rp;
}

# Compute callback URI
# @return String Callback URI
sub getCallbackUri {
    my ( $self, $req ) = @_;

    my $callback_get_param = $self->conf->{oidcRPCallbackGetParam};

    my $callback_uri = $self->conf->{portal};
    $callback_uri .=
      ( $self->{portal} =~ /\?/ )
      ? '&' . $callback_get_param . '=1'
      : '?' . $callback_get_param . '=1';

    # Use authChoiceParam in redirect URL
    if ( $req->param( $self->conf->{authChoiceParam} ) ) {
        $callback_uri .= '&'
          . $self->{authChoiceParam} . '='
          . uri_escape( $req->param( $self->conf->{authChoiceParam} ) );
    }

    $self->lmLog( "OpenIDConnect Callback URI: $callback_uri", 'debug' );
    return $callback_uri;
}

# Build Authentication Request URI for Authorization Code Flow
# @param op OpenIP Provider configuration key
# @param state State
# return String Authentication Request URI
sub buildAuthorizationCodeAuthnRequest {
    my ( $self, $req, $op, $state ) = @_;

    my $authorize_uri =
      $self->oidcOPList->{$op}->{conf}->{authorization_endpoint};
    my $client_id =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsClientID};
    my $scope =
      $self->conf->{oidcOPMetaDataOptions}->{$op}->{oidcOPMetaDataOptionsScope};
    my $use_nonce =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsUseNonce};
    my $response_type = "code";
    my $redirect_uri  = $self->getCallbackUri($req);
    my $display =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsDisplay};
    my $prompt =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsPrompt};
    my $max_age =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsMaxAge};
    my $ui_locales =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsUiLocales};
    my $acr_values =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsAcrValues};

    my $nonce;
    if ($use_nonce) {
        my $nonceSession = $self->getOpenIDConnectSession($req);
        $nonceSession->update( { '_utime' => time } );
        $nonce = $nonceSession->id;
    }
    $client_id     = uri_escape($client_id);
    $scope         = uri_escape($scope);
    $response_type = uri_escape($response_type);
    $redirect_uri  = uri_escape($redirect_uri);
    $state         = uri_escape($state) if defined $state;
    $nonce         = uri_escape($nonce) if defined $nonce;
    $display       = uri_escape($display) if defined $display;
    $prompt        = uri_escape($prompt) if defined $prompt;
    $max_age       = uri_escape($max_age) if defined $max_age;
    $ui_locales    = uri_escape($ui_locales) if defined $ui_locales;
    $acr_values    = uri_escape($acr_values) if defined $acr_values;

    my $authn_uri =
        $authorize_uri
      . ( $authorize_uri =~ /\?/ ? '&' : '?' )
      . "response_type=$response_type"
      . "&client_id=$client_id"
      . "&scope=$scope"
      . "&redirect_uri=$redirect_uri";
    $authn_uri .= "&state=$state"           if defined $state;
    $authn_uri .= "&nonce=$nonce"           if defined $nonce;
    $authn_uri .= "&display=$display"       if defined $display;
    $authn_uri .= "&prompt=$prompt"         if defined $prompt;
    $authn_uri .= "&max_age=$max_age"       if $max_age;
    $authn_uri .= "&ui_locales=$ui_locales" if defined $ui_locales;
    $authn_uri .= "&acr_values=$acr_values" if defined $acr_values;

    $self->lmLog(
        "OpenIDConnect Authorization Code Flow Authn Request: $authn_uri",
        'debug' );

    return $authn_uri;
}

# Build Authentication Response URI for Authorization Code Flow
# @param redirect_uri Redirect URI
# @param code Code
# @param state State
# @param session_state Session state
# return String Authentication Response URI
sub buildAuthorizationCodeAuthnResponse {
    my ( $self, $redirect_uri, $code, $state, $session_state ) = @_;

    my $response_url = $redirect_uri;

    $response_url .= ( $redirect_uri =~ /\?/ ? '&' : '?' );

    $response_url .= "code=" . uri_escape($code);

    if ($state) {
        $response_url .= "&state=" . uri_escape($state);
    }

    if ($session_state) {
        $response_url .= "&session_state=" . uri_escape($session_state);
    }

    return $response_url;
}

# Build Authentication Response URI for Implicit Flow
# @param redirect_uri Redirect URI
# @param access_token Access token
# @param id_token ID token
# @param expires_in Expiration of access token
# @param state State
# @param session_state Session state
# return String Authentication Response URI
sub buildImplicitAuthnResponse {
    my ( $self, $redirect_uri, $access_token, $id_token, $expires_in, $state,
        $session_state )
      = @_;

    my $response_url = "$redirect_uri#id_token=" . uri_escape($id_token);
    if ($access_token) {
        $response_url .=
          "&token_type=bearer&access_token=" . uri_escape($access_token);
    }
    if ($expires_in) {
        $response_url .= "&expires_in=" . uri_escape($expires_in);
    }
    if ($state) {
        $response_url .= "&state=" . uri_escape($state);
    }
    if ($session_state) {
        $response_url .= "&session_state=" . uri_escape($session_state);
    }
    return $response_url;
}

# Build Authentication Response URI for Hybrid Flow
# @param redirect_uri Redirect URI
# @param code Code
# @param access_token Access token
# @param id_token ID token
# @param expires_in Expiration of access token
# @param state State
# @param session_state Session state
# return String Authentication Response URI
sub buildHybridAuthnResponse {
    my (
        $self,     $redirect_uri, $code,  $access_token,
        $id_token, $expires_in,   $state, $session_state
    ) = @_;

    my $response_url = "$redirect_uri#code=" . uri_escape($code);
    if ($access_token) {
        $response_url .=
          "&token_type=bearer&access_token=" . uri_escape($access_token);
    }
    if ($id_token) {
        $response_url .= "&id_token=" . uri_escape($id_token);
    }
    if ($expires_in) {
        $response_url .= "&expires_in=" . uri_escape($expires_in);
    }
    if ($state) {
        $response_url .= "&state=" . uri_escape($state);
    }
    if ($session_state) {
        $response_url .= "&session_state=" . uri_escape($session_state);
    }
    return $response_url;
}

# Get Token response with authorization code
# @param op OpenIP Provider configuration key
# @param code Code
# @param auth_method Authentication Method
# return String Token response decoded content
sub getAuthorizationCodeAccessToken {
    my ( $self, $req, $op, $code, $auth_method ) = @_;

    my $client_id =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsClientID};
    my $client_secret =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsClientSecret};
    my $redirect_uri = $self->getCallbackUri($req);
    my $access_token_uri =
      $self->oidcOPList->{$op}->{conf}->{token_endpoint};
    my $grant_type = "authorization_code";

    unless ( $auth_method =~ /^client_secret_(basic|post)$/o ) {
        $self->lmLog( "Bad authentication method on token endpoint", 'error' );
        return 0;
    }

    $self->lmLog(
        "Using auth method $auth_method to token endpoint $access_token_uri",
        'debug' );

    my $response;

    if ( $auth_method eq "client_secret_basic" ) {
        my $form = {
            code         => $code,
            redirect_uri => $redirect_uri,
            grant_type   => $grant_type
        };

        $response = $self->ua->post(
            $access_token_uri, $form,
            "Authorization" => "Basic "
              . encode_base64( "$client_id:$client_secret", '' ),
            "Content-Type" => 'application/x-www-form-urlencoded',
        );
    }

    elsif ( $auth_method eq "client_secret_post" ) {
        my $form = {
            code          => $code,
            client_id     => $client_id,
            client_secret => $client_secret,
            redirect_uri  => $redirect_uri,
            grant_type    => $grant_type
        };

        $response = $self->ua->post( $access_token_uri, $form,
            "Content-Type" => 'application/x-www-form-urlencoded' );
    }
    else {
        $self->lmLog( "Unknown auth method $auth_method", 'error' );
    }

    if ( $response->is_error ) {
        $self->lmLog( "Bad authorization response: " . $response->message,
            "error" );
        $self->lmLog( $response->content, 'debug' );
        return 0;
    }
    return $response->decoded_content;
}

# Check validity of Token Response
# return boolean 1 if the response is valid, 0 else
sub checkTokenResponseValidity {
    my ( $self, $json ) = @_;

    # token_type MUST be Bearer
    unless ( $json->{token_type} eq "Bearer" ) {
        $self->lmLog(
            "Token type is " . $json->{token_type} . " but must be Bearer",
            'error' );
        return 0;
    }

    # id_token MUST be present
    unless ( $json->{id_token} ) {
        $self->lmLog( "No id_token", 'error' );
        return 0;
    }

    return 1;
}

# Check validity of ID Token
# return boolean 1 if the token is valid, 0 else
sub checkIDTokenValidity {
    my ( $self, $op, $id_token ) = @_;

    my $client_id =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsClientID};
    my $acr_values =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsAcrValues};
    my $max_age =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsMaxAge};
    my $id_token_max_age =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsIDTokenMaxAge};
    my $use_nonce =
      $self->conf->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsUseNonce};

    # Check issuer
    unless ( $id_token->{iss} eq $self->oidcOPList->{$op}->{conf}->{issuer} ) {
        $self->lmLog( "Issuer mismatch", 'error' );
        return 0;
    }

    # Check audience
    if ( ref $id_token->{aud} ) {
        my @audience = @{ $id_token->{aud} };
        unless ( grep $_ eq $client_id, @audience ) {
            $self->lmLog( "Client ID not found in audience array", 'error' );
            return 0;
        }

        if ( $#audience > 1 ) {
            unless ( $id_token->{azp} eq $client_id ) {
                $self->lmLog(
                    "More than one audience, and azp not equal to client ID",
                    'error' );
                return 0;
            }
        }
    }
    else {
        unless ( $id_token->{aud} eq $client_id ) {
            $self->lmLog( "Audience mismatch", 'error' );
            return 0;
        }
    }

    # Check time
    unless ( time < $id_token->{exp} ) {
        $self->lmLog( "ID token expired", 'error' );
        return 0;
    }

    # Check iat
    my $iat = $id_token->{iat};
    if ($id_token_max_age) {
        unless ( $iat + $id_token_max_age > time ) {
            $self->lmLog( "ID token too old (Max age: $id_token_max_age)",
                'error' );
            return 0;
        }
    }

    # Check nonce
    if ($use_nonce) {
        my $nonce = $id_token->{nonce};
        unless ($nonce) {
            $self->lmLog( "Nonce was not returned by OP $op", 'error' );
            return 0;
        }
        else {
            # Get nonce session
            my $nonceSession = $self->getOpenIDConnectSession($nonce);
            unless ($nonceSession) {
                $self->lmLog( "Nonce $nonce verification failed", 'error' );
                return 0;
            }
            else {
                $nonceSession->remove;
                $self->lmLog( "Nonce $nonce deleted", 'debug' );
            }
        }
    }

    # Check acr
    my $acr = $id_token->{acr};
    if ( defined $acr_values ) {
        unless ($acr) {
            $self->lmLog( "ACR was not returned by OP $op", 'error' );
            return 0;
        }
        unless ( $acr_values =~ /\b$acr\b/i ) {
            $self->lmLog(
                "ACR $acr not listed in request ACR values ($acr_values)",
                'error' );
            return 0;
        }
    }

    # Check auth_time
    my $auth_time = $id_token->{auth_time};
    if ($max_age) {
        unless ($auth_time) {
            $self->lmLog( "Auth time was not returned by OP $op", 'error' );
            return 0;
        }
        if ( $auth_time + $max_age > time ) {
            $self->lmLog(
"Authentication time ($auth_time) is too old (Max age: $max_age)",
                'error'
            );
            return 0;
        }
    }

    return 1;
}

# Get UserInfo response
# return String UserInfo response decoded content
sub getUserInfo {
    my ( $self, $op, $access_token ) = @_;

    my $userinfo_uri = $self->oidcOPList->{$op}->{conf}->{userinfo_endpoint};

    unless ($userinfo_uri) {
        $self->lmLog( "UserInfo URI not found in $op configuration", 'error' );
        return 0;
    }

    $self->lmLog(
        "Request User Info on $userinfo_uri with access token $access_token",
        'debug' );

    my $response = $self->ua->get( $userinfo_uri,
        "Authorization" => "Bearer $access_token" );

    if ( $response->is_error ) {
        $self->lmLog( "Bad userinfo response: " . $response->message, "error" );
        $self->lmLog( $response->content,                             'debug' );
        return 0;
    }

    my $content_type = $response->header('Content-Type');
    if ( $content_type =~ /json/ ) {
        return $response->decoded_content;
    }
    elsif ( $content_type =~ /jwt/ ) {
        my $jwt = $response->decoded_content;
        return unless $self->verifyJWTSignature( $op, $jwt );
        my $jwt_parts = $self->extractJWT($jwt);
        return $jwt_parts->[1];
    }
}

# Convert JSON to HashRef
# @return HashRef JSON decoded content
sub decodeJSON {
    my ( $self, $json ) = @_;
    my $json_hash;

    eval { $json_hash = from_json $json; };

    if ($@) {
        $json_hash->{error} = "parse_error";
    }

    return $json_hash;
}

# Try to recover the OpenID Connect session corresponding to id and return session
# If id is set to undef, return a new session
# @return Lemonldap::NG::Common::Session object
sub getOpenIDConnectSession {
    my ( $self, $id ) = @_;

    my $oidcSession = Lemonldap::NG::Common::Session->new(
        {
            storageModule        => $self->conf->{oidcStorage},
            storageModuleOptions => $self->conf->{oidcStorageOptions},
            cacheModule          => $self->conf->{localSessionStorage},
            cacheModuleOptions   => $self->conf->{localSessionStorageOptions},
            id                   => $id,
            kind                 => "OpenIDConnect",
        }
    );

    if ( $oidcSession->error ) {
        if ($id) {
            $self->p->userInfo("OpenIDConnect session $id isn't yet available");
        }
        else {
            $self->lmLog( "Unable to create new OpenIDConnect session",
                'error' );
            $self->lmLog( $oidcSession->error, 'error' );
        }
        return undef;
    }

    return $oidcSession;
}

# Store information in state database and return
# corresponding session_id
# @return State Session ID
sub storeState {
    my ( $self, @data ) = @_;

    # check if there are data to store
    my $infos;
    foreach (@data) {
        $infos->{$_} = $self->{$_} if $self->{$_};
    }
    return unless ($infos);

    # Create state session
    my $stateSession = $self->getOpenIDConnectSession();

    return unless $stateSession;

    # Session type
    $infos->{_type} = "state";

    # Set _utime for session autoremove
    # Use default session timeout and relayState session timeout to compute it
    my $time         = time();
    my $timeout      = $self->conf->{timeout};
    my $stateTimeout = $self->conf->{oidcRPStateTimeout} || $timeout;

    $infos->{_utime} = $time + ( $stateTimeout - $timeout );

    # Store infos in state session
    $stateSession->update($infos);

    # Return session ID
    return $stateSession->id;
}

# Extract state information into $self
sub extractState {
    my ( $self, $state ) = @_;

    return 0 unless $state;

    # Open state session
    my $stateSession = $self->getOpenIDConnectSession($state);

    return 0 unless $stateSession;

    # Push values in $self
    foreach ( keys %{ $stateSession->data } ) {
        next if $_ =~ /(type|_session_id|_utime)/;
        $self->{$_} = $stateSession->data->{$_};
    }

    # Delete state session
    if ( $stateSession->remove ) {
        $self->lmLog( "State $state was deleted", 'debug' );
    }
    else {
        $self->lmLog( "Unable to delete state $state", 'error' );
        $self->lmLog( $stateSession->error,            'error' );
    }

    return 1;
}

# Extract parts of a JWT
# @return arrayref JWT parts
sub extractJWT {
    my ( $self, $jwt ) = @_;

    my @jwt_parts = split( /\./, $jwt );

    return \@jwt_parts;
}

# Check signature of a JWT
# @return boolean 1 if signature is verified, 0 else
sub verifyJWTSignature {
    my ( $self, $jwt, $op, $rp ) = @_;

    $self->lmLog( "Verification of JWT signature: $jwt", 'debug' );

    # Extract JWT parts
    my $jwt_parts = $self->extractJWT($jwt);

    # Read header
    my $jwt_header_part = $jwt_parts->[0];
    my $jwt_header_hash =
      $self->decodeJSON( decode_base64url($jwt_header_part) );

    # Get signature algorithm
    my $alg = $jwt_header_hash->{alg};

    $self->lmLog( "JWT signature algorithm: $alg", 'debug' );

    if ( $alg eq "none" ) {

        # If none alg, signature should be empty
        if ( $jwt_parts->[2] ) {
            $self->lmLog(
                "Signature "
                  . $jwt_parts->[2]
                  . " is present but algorithm is 'none'",
                'debug'
            );
            return 0;
        }
        return 1;
    }

    if ( $alg eq "HS256" or $alg eq "HS384" or $alg eq "HS512" ) {

        # Check signature with client secret
        my $client_secret;
        $client_secret =
          $self->conf->{oidcOPMetaDataOptions}->{$op}
          ->{oidcOPMetaDataOptionsClientSecret}
          if ($op);
        $client_secret =
          $self->conf->{oidcRPMetaDataOptions}->{$rp}
          ->{oidcRPMetaDataOptionsClientSecret}
          if ($rp);

        my $digest;

        if ( $alg eq "HS256" ) {
            $digest =
              hmac_sha256_base64( $jwt_parts->[0] . "." . $jwt_parts->[1],
                $client_secret );
        }

        if ( $alg eq "HS384" ) {
            $digest =
              hmac_sha384_base64( $jwt_parts->[0] . "." . $jwt_parts->[1],
                $client_secret );
        }

        if ( $alg eq "HS512" ) {
            $digest =
              hmac_sha512_base64( $jwt_parts->[0] . "." . $jwt_parts->[1],
                $client_secret );
        }

        # Convert + and / to get Base64 URL valid (RFC 4648)
        $digest =~ s/\+/-/g;
        $digest =~ s/\//_/g;

        unless ( $digest eq $jwt_parts->[2] ) {
            $self->lmLog(
                "Digest $digest not equal to signature " . $jwt_parts->[2],
                'debug' );
            return 0;
        }
        return 1;
    }

    if ( $alg eq "RS256" or $alg eq "RS384" or $alg eq "RS512" ) {

        if ($rp) {
            $self->lmLog( "Algorithm $alg not supported", 'debug' );
            return 0;
        }

        # The public key is needed
        unless ( $self->oidcOPList->{$op}->{jwks} ) {
            $self->lmLog( "Cannot verify $alg signature: no JWKS data found",
                'error' );
            return 0;
        }

        my $keys = $self->oidcOPList->{$op}->{jwks}->{keys};
        my $key_hash;

        # Find Key ID associated with signature
        my $kid = $jwt_header_hash->{kid};

        if ($kid) {
            $self->lmLog( "Search key with id $kid", 'debug' );
            foreach (@$keys) {
                if ( $_->{kid} eq $kid ) {
                    $key_hash = $_;
                    last;
                }
            }
        }
        else {
            $key_hash = shift @$keys;
        }

        unless ($key_hash) {
            $self->lmLog( "No key found in JWKS data", 'error' );
            return 0;
        }

        $self->lmLog( "Found public key parameter n: " . $key_hash->{n},
            'debug' );
        $self->lmLog( "Found public key parameter e: " . $key_hash->{e},
            'debug' );

        # Create public key
        my $n =
          Crypt::OpenSSL::Bignum->new_from_bin(
            decode_base64url( $key_hash->{n} ) );
        my $e =
          Crypt::OpenSSL::Bignum->new_from_bin(
            decode_base64url( $key_hash->{e} ) );

        my $public_key = Crypt::OpenSSL::RSA->new_key_from_parameters( $n, $e );

        if ( $alg eq "RS256" ) {
            $public_key->use_sha256_hash;
        }

        if ( $alg eq "RS384" ) {
            $public_key->use_sha384_hash;
        }

        if ( $alg eq "RS512" ) {
            $public_key->use_sha512_hash;
        }

        return $public_key->verify(
            $jwt_parts->[0] . "." . $jwt_parts->[1],
            decode_base64url( $jwt_parts->[2] )
        );
    }

    # Other algorithms not managed
    $self->lmLog( "Algorithm $alg not known", 'debug' );

    return 0;
}

### HERE

# Check value hash
# @param value Value
# @param hash Hash
# @param id_token ID Token
# @return boolean 1 if hash is verified, 0 else
sub verifyHash {
    my ( $self, $value, $hash, $id_token ) = @_;

    $self->lmLog( "Verification of value $value with hash $hash", 'debug' );

    # Extract ID token parts
    my $jwt_parts = $self->extractJWT($id_token);

    # Read header
    my $jwt_header_part = $jwt_parts->[0];
    my $jwt_header_hash =
      $self->decodeJSON( decode_base64url($jwt_header_part) );

    # Get signature algorithm
    my $alg = $jwt_header_hash->{alg};

    $self->lmLog( "ID Token signature algorithm: $alg", 'debug' );

    if ( $alg eq "none" ) {

        # Not supported
        $self->lmLog( "Cannot check hash without signature algorithm",
            'debug' );
        return 0;
    }

    if ( $alg =~ /(?:\w{2})(\d{3})/ ) {

        # Hash Level
        my $hash_level = $1;

        $self->lmLog( "Use SHA $hash_level to check hash", 'debug' );

        my $cHash = $self->createHash( $value, $hash_level );

        # Compare values
        unless ( $cHash eq $hash ) {
            $self->lmLog( "Hash $hash not equal to hash $cHash", 'debug' );
            return 0;
        }
        return 1;
    }

    # Other algorithms not managed
    $self->lmLog( "Algorithm $alg not known", 'debug' );

    return 0;
}

# Create Hash
# @param value Value to hash
# @param hash_level SHA Hash level
# @return String hash
sub createHash {
    my ( $self, $value, $hash_level ) = @_;

    $self->lmLog( "Use SHA $hash_level to hash $value", 'debug' );

    my $hash;

    if ( $hash_level eq "256" ) { $hash = sha256($value); }
    if ( $hash_level eq "384" ) { $hash = sha384($value); }
    if ( $hash_level eq "512" ) { $hash = sha512($value); }

    $hash = substr( $hash, 0, length($hash) / 2 );
    $hash = encode_base64url( $hash, "" );

    return $hash;
}

# Create error redirection
# @param redirect_url Redirection URL
# @param error Error code
# @param error_description Human-readable ASCII encoded text description of the error
# @param error_uri URI of a web page that includes additional information about the error
# @param state OAuth 2.0 state value
# @param fragment Set to true to return fragment component
# @return void
sub returnRedirectError {
    my ( $self, $req, $redirect_url, $error, $error_description, $error_uri,
        $state, $fragment )
      = @_;

    my $urldc =
        $redirect_url
      . ( $fragment ? '#' : $redirect_url =~ /\?/ ? '&' : '?' )
      . "error="
      . uri_escape($error);
    $urldc .= "&error_description=" . uri_escape($error_description)
      if defined $error_description;
    $urldc .= "&error_uri=" . uri_escape($error_uri) if defined $error_uri;
    $urldc .= "&state=" . uri_escape($state)         if defined $state;

    $self->lmLog( "Redirect user to $urldc", 'debug' );
    $self->{'urldc'} = $urldc;

    $req->steps( [] );
    return PE_OK;
}

#sub returnJSONStatus {
#my ( $self, $req, $content, $status_code ) = @_;
# replace this call by $self->p->sendJSONresponse($req,$content,code=>$status_code)

#sub returnJSONError {
#my ( $self, $error ) = @_;
#replace this by $self->p->sendError($req, $error,400);

#sub returnJSON {
#my ( $self, $content ) = @_;
#replace this call by $self->p->sendJSONresponse($req,$content)

# Return Bearer error
# @param error_code Error code
# @param error_message Error message
# @return GI response
sub returnBearerError {
    my ( $self, $error_code, $error_message ) = @_;

    # TODO: verify this
    return [
        401,
        [
            'WWW-Authenticate' =>
              "error=$error_code,error_description=$error_message"
        ],
        [qq#{"error":$error_code,"error_description":"$error_message"}#]
    ];
}

# Get Client ID and Client Secret
# @return array (client_id, client_secret)
sub getEndPointAuthenticationCredentials {
    my ( $self, $req ) = @_;
    my ( $client_id, $client_secret );

    my $authorization = $req->authorization;
    if ( $authorization =~ /^Basic (\w+)/i ) {
        $self->lmLog( "Method client_secret_basic used", 'debug' );
        eval {
            ( $client_id, $client_secret ) = split( /:/, decode_base64($1) );
        };
        $self->lmLog( "Bad authentication header: $@", 'error' ) if ($@);
    }
    elsif ( $req->param('client_id') and $req->param('client_secret') ) {
        $self->lmLog( "Method client_secret_post used", 'debug' );
        $client_id     = $req->param('client_id');
        $client_secret = $req->param('client_secret');
    }

    return ( $client_id, $client_secret );
}

# Get Access Token
# @return access_token
sub getEndPointAccessToken {
    my ( $self, $req ) = @_;
    my $access_token;

    my $authorization = $req->authorization;
    if ( $authorization =~ /^Bearer (\w+)/i ) {
        $self->lmLog( "Bearer access token", 'debug' );
        $access_token = $1;
    }
    elsif ( $access_token = $req->param('access_token') ) {
        $self->lmLog( "GET/POST access token", 'debug' );
    }

    return $access_token;
}

# Return list of attributes authorized for a claim
# @param rp RP name
# @param claim Claim
# @return arrayref attributes list
sub getAttributesListFromClaim {
    my ( $self, $rp, $claim ) = @_;
    return $self->rpAttributes->{$rp}->{$claim};
}

# Return Hash of UserInfo data
# @param scope OIDC scope
# @param rp Internal Relying Party identifier
# @param user_session_id User session identifier
# @return hashref UserInfo data
sub buildUserInfoResponse {
    my ( $self, $scope, $rp, $user_session_id ) = @_;
    my $userinfo_response = {};

    # Get user identifier
    my $apacheSession = $self->p->getApacheSession( $user_session_id, 1 );

    unless ($apacheSession) {
        $self->lmLog( "Unable to find user session", "error" );
        return undef;
    }
    my $user_id_attribute =
      $self->conf->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsUserIDAttr}
      || $self->conf->{whatToTrace};
    my $user_id = $apacheSession->data->{$user_id_attribute};

    $self->lmLog( "Found corresponding user: $user_id", 'debug' );

    $userinfo_response->{sub} = $user_id;

    # Parse scope and return allowed attributes
    foreach my $claim ( split( /\s/, $scope ) ) {
        next if ( $claim eq "openid" );
        $self->lmLog( "Get attributes linked to claim $claim", 'debug' );
        my $list = $self->getAttributesListFromClaim( $rp, $claim );
        next unless $list;
        foreach my $attribute (@$list) {
            my $session_key =
              $self->conf->{oidcRPMetaDataExportedVars}->{$rp}->{$attribute};
            if ($session_key) {
                my $session_value = $apacheSession->data->{$session_key};
                utf8::decode($session_value);

                # Address is a JSON object
                if ( $claim eq "address" ) {
                    $userinfo_response->{address}->{$attribute} =
                      $session_value;
                }
                else {
                    $userinfo_response->{$attribute} = $session_value;
                }
            }
        }
    }

    return $userinfo_response;
}

# Return JWT
# @param payload JWT content
# @param alg Signature algorithm
# @param rp Internal Relying Party identifier
# @return String jwt JWT
sub createJWT {
    my ( $self, $payload, $alg, $rp ) = @_;

    # Payload encoding
    my $jwt_payload = encode_base64( to_json($payload), "" );

    # JWT header
    my $jwt_header_hash = { typ => "JWT", alg => $alg };
    $jwt_header_hash->{kid} = $self->conf->{oidcServiceKeyIdSig}
      if $self->conf->{oidcServiceKeyIdSig};
    my $jwt_header = encode_base64( to_json($jwt_header_hash), "" );

    if ( $alg eq "none" ) {

        return $jwt_header . "." . $jwt_payload;
    }

    if ( $alg eq "HS256" or $alg eq "HS384" or $alg eq "HS512" ) {

        # Sign with client secret
        my $client_secret =
          $self->conf->{oidcRPMetaDataOptions}->{$rp}
          ->{oidcRPMetaDataOptionsClientSecret};

        my $digest;

        if ( $alg eq "HS256" ) {
            $digest = hmac_sha256_base64( $jwt_header . "." . $jwt_payload,
                $client_secret );
        }

        if ( $alg eq "HS384" ) {
            $digest = hmac_sha384_base64( $jwt_header . "." . $jwt_payload,
                $client_secret );
        }

        if ( $alg eq "HS512" ) {
            $digest = hmac_sha512_base64( $jwt_header . "." . $jwt_payload,
                $client_secret );
        }

        # Convert + and / to get Base64 URL valid (RFC 4648)
        $digest =~ s/\+/-/g;
        $digest =~ s/\//_/g;

        return $jwt_header . "." . $jwt_payload . "." . $digest;
    }

    elsif ( $alg eq "RS256" or $alg eq "RS384" or $alg eq "RS512" ) {

        # Get signing private key
        my $priv_key = $self->conf->{oidcServicePrivateKeySig};
        my $rsa_priv = Crypt::OpenSSL::RSA->new_private_key($priv_key);

        if ( $alg eq "RS256" ) {
            $rsa_priv->use_sha256_hash;
        }

        if ( $alg eq "RS384" ) {
            $rsa_priv->use_sha384_hash;
        }

        if ( $alg eq "RS512" ) {
            $rsa_priv->use_sha512_hash;
        }

        my $digest = encode_base64url(
            $rsa_priv->sign( $jwt_header . "." . $jwt_payload ) );

        return $jwt_header . "." . $jwt_payload . "." . $digest;
    }

    $self->lmLog( "Algorithm $alg not supported to sign JWT", 'debug' );

    return;
}

# Return ID Token
# @param payload ID Token content
# @param rp Internal Relying Party identifier
# @return String id_token ID Token as JWT
sub createIDToken {
    my ( $self, $payload, $rp ) = @_;

    # Get signature algorithm
    my $alg = $self->conf->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsIDTokenSignAlg};
    $self->lmLog( "ID Token signature algorithm: $alg", 'debug' );

    return $self->createJWT( $payload, $alg, $rp );
}

# Return flow type
# @param response_type Response type
# @return String flow
sub getFlowType {
    my ( $self, $response_type ) = @_;

    return {
        "code"                => "authorizationcode",
        "id_token"            => "implicit",
        "id_token token"      => "implicit",
        "code id_token"       => "hybrid",
        "code token"          => "hybrid",
        "code id_token token" => "hybrid",
    }->{$response_type};
}

# Return sub field of an ID Token
# @param id_token ID Token
# @return String sub
sub getIDTokenSub {
    my ( $self, $id_token ) = @_;
    my $payload = $self->getJWTJSONData($id_token);
    return $payload->{sub};
}

# Return payload of a JWT as Hash ref
# @param jwt JWT
# @return HashRef payload
sub getJWTJSONData {
    my ( $self, $jwt ) = @_;
    my $jwt_parts = $self->extractJWT($jwt);
    return from_json( decode_base64url( $jwt_parts->[1] ) );
}

# Return JWKS representation of a key
# @param key Raw key
# @return HashRef JWKS key
sub key2jwks {
    my ( $self, $key ) = @_;

    my $rsa_pub = Crypt::OpenSSL::RSA->new_public_key($key);
    my @params  = $rsa_pub->get_key_parameters();

    return {
        n => encode_base64url( $params[0]->to_bin(), "" ),
        e => encode_base64url( $params[1]->to_bin(), "" ),
    };
}

# Build Logout Request URI
# @param redirect_uri Redirect URI
# @param id_token_hint ID Token
# @param post_logout_redirect_uri Callback URI
# @param state State
# return String Logout URI
sub buildLogoutRequest {
    my ( $self, $redirect_uri, @args ) = @_;

    my @tab = (qw(id_token_hint post_logout_redirect_uri state));
    my @prms;
    for ( my $i = 0 ; $i < 3 ; $i++ ) {
        push @prms, "$tab[$i]=" . uri_escape( $args[$i] )
          if defined( $args[$i] );
    }
    my $response_url = $redirect_uri;
    $response_url .= ( $response_url =~ /\?/ ? '&' : '?' ) . join( '&', @prms )
      if (@prms);
    return $response_url;
}

# Build Logout Response URI
# @param redirect_uri Redirect URI
# @param state State
# return String Logout URI
sub buildLogoutResponse {
    my ( $self, $redirect_uri, $state ) = @_;

    my $response_url = $redirect_uri;

    if ($state) {
        $response_url .= ( $redirect_uri =~ /\?/ ? '&' : '?' );
        $response_url .= "state=" . uri_escape($state);
    }

    return $response_url;
}

# Create session_state parameter
# @param session_id Session ID
# @param client_id CLient ID
# return String Session state
sub createSessionState {
    my ( $self, $session_id, $client_id ) = @_;

    my $salt = encode_base64url( $self->conf->{cipher}->encrypt($client_id) );
    my $data = $client_id . " " . $session_id . " " . $salt;

    my $hash = sha256_base64($data);
    while ( length($hash) % 4 ) {
        $hash .= '=';
    }

    my $session_state = $hash . "." . $salt;

    return $session_state;
}

# Get request JWT from request uri
# @param request_uri request uri
# return String request JWT
sub getRequestJWT {
    my ( $self, $request_uri ) = @_;

    my $response = $self->ua->get($request_uri);

    if ( $response->is_error ) {
        $self->lmLog( "Unable to get request JWT on $request_uri", 'error' );
        return;
    }

    return $response->decoded_content;
}

# Create JS code needed on OP side to manage session
# return String JS code
sub getSessionManagementOPIFrameJS {
    my ($self) = @_;

    return q@window.addEventListener("message", receiveMessage, false);
function receiveMessage(e){
  var message = e.data;
  client_id = decodeURIComponent(message.split(' ')[0]);
  session_state = decodeURIComponent(message.split(' ')[1]);
  var salt = decodeURIComponent(session_state.split('.')[1]);
  var opbs = document.cookie.replace(/(?:(?:^|.*;\s*)@
      . $self->conf->{cookieName} . q@\s*\=\s*([^;]*).*$)|^.*$/, "$1");
  var hash = CryptoJS.SHA256(client_id + ' ' + opbs + ' ' + salt);
  var ss = hash.toString(CryptoJS.enc.Base64) + '.'  + salt;
  if (session_state == ss) {
    stat = 'unchanged';
  } else {
    stat = 'changed';
  }
  e.source.postMessage(stat,e.origin);
}@;
}

### Import encode_base64url and decode_base64url from recent MIME::Base64 module:
sub encode_base64url {
    my $e = encode_base64( shift, '' );
    $e =~ s/=+\z//;
    $e =~ tr[+/][-_];
    return $e;
}

sub decode_base64url {
    my $s = shift;
    $s =~ tr[-_][+/];
    $s .= '=' while length($s) % 4;
    return decode_base64($s);
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

=head2 loadOPs

Load OpenID Connect Providers and JWKS data

=head2 loadRPs

Load OpenID Connect Relying Parties

=head2 refreshJWKSdata

Refresh JWKS data if needed

=head2 getRP

Get Relying Party corresponding to a Client ID

=head2 getCallbackUri

Compute callback URI

=head2 buildAuthorizationCodeAuthnRequest

Build Authentication Request URI for Authorization Code Flow

=head2 buildAuthorizationCodeAuthnResponse

Build Authentication Response URI for Authorization Code Flow

=head2 buildImplicitAuthnResponse

Build Authentication Response URI for Implicit Flow

=head2 buildHybridAuthnResponse

Build Authentication Response URI for Hybrid Flow

=head2 getAuthorizationCodeAccessToken

Get Token response with authorization code

=head2 checkTokenResponseValidity

Check validity of Token Response

=head2 getUserInfo

Get UserInfo response

=head2 decodeJSON

Convert JSON to HashRef

=head2 getOpenIDConnectSession

Try to recover the OpenID Connect session corresponding to id and return session

=head2 storeState

Store information in state database and return

=head2 extractState

Extract state information into $self

=head2 extractJWT

Extract parts of a JWT

=head2 verifyJWTSignature

Check signature of a JWT

=head2 verifyHash

Check value hash

=head2 createHash

Create Hash

=head2 returnBearerError

Return Bearer error

=head2 getEndPointAuthenticationCredentials

Get Client ID and Client Secret

=head2 getEndPointAccessToken

Get Access Token

=head2 getAttributesListFromClaim

Return list of attributes authorized for a claim

=head2 buildUserInfoResponse

Return Hash of UserInfo data

=head2 createJWT

Return JWT

=head2 createIDToken

Return ID Token

=head2 getFlowType

Return flow type

=head2 getIDTokenSub

Return sub field of an ID Token

=head2 getJWTJSONData

Return payload of a JWT as Hash ref

=head2 key2jwks

Return JWKS representation of a key

=head2 buildLogoutRequest

Build Logout Request URI

=head2 buildLogoutResponse

Build Logout Response URI 

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
