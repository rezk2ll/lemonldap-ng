## @file
# Common OpenID Connect functions

## @class
# Common OpenID Connect functions
package Lemonldap::NG::Portal::_OpenIDConnect;

use strict;
use JSON;
use MIME::Base64
  qw/encode_base64url encode_base64 decode_base64url decode_base64/;
use URI::Escape;
use Digest::SHA
  qw/hmac_sha256_base64 hmac_sha384_base64 hmac_sha512_base64 sha256 sha256_base64 sha384_base64 sha512_base64/;
use Crypt::OpenSSL::RSA;
use Crypt::OpenSSL::Bignum;
use utf8;
use base qw(Lemonldap::NG::Portal::_Browser);

our $VERSION = 2.00;
our $oidcCache;

BEGIN {
    eval {
        require threads::shared;
        threads::shared::share($oidcCache);
    };
}

## @method boolean loadOPs(boolean no_cache)
# Load OpenID Connect Providers and JWKS data
# @param no_cache Disable cache use
# @return boolean result
sub loadOPs {
    my ( $self, $no_cache ) = splice @_;

    # Check cache
    unless ($no_cache) {
        if ( $oidcCache->{_oidcOPList} ) {
            $self->lmLog( "Load OPs from cache", 'debug' );
            $self->{_oidcOPList} = $oidcCache->{_oidcOPList};
            return 1;
        }
    }

    # Check presence of at least one identity provider in configuration
    unless ( $self->{oidcOPMetaDataJSON}
        and keys %{ $self->{oidcOPMetaDataJSON} } )
    {
        $self->lmLog( "No OpenID Connect Provider found in configuration",
            'warn' );
    }

    # Extract JSON data
    $self->{_oidcOPList} = {};
    foreach ( keys %{ $self->{oidcOPMetaDataJSON} } ) {
        $self->{_oidcOPList}->{$_}->{conf} =
          $self->decodeJSON(
            $self->{oidcOPMetaDataJSON}->{$_}->{oidcOPMetaDataJSON} );
        $self->{_oidcOPList}->{$_}->{jwks} =
          $self->decodeJSON(
            $self->{oidcOPMetaDataJWKS}->{$_}->{oidcOPMetaDataJWKS} );
    }

    $oidcCache->{_oidcOPList} = $self->{_oidcOPList} unless $no_cache;

    return 1;
}

## @method boolean loadRPs(boolean no_cache)
# Load OpenID Connect Relying Parties
# @param no_cache Disable cache use
# @return boolean result
sub loadRPs {
    my ( $self, $no_cache ) = splice @_;

    # Check cache
    unless ($no_cache) {
        if ( $oidcCache->{_oidcRPList} ) {
            $self->lmLog( "Load RPs from cache", 'debug' );
            $self->{_oidcRPList} = $oidcCache->{_oidcRPList};
            return 1;
        }
    }

    # Check presence of at least one relying party in configuration
    unless ( $self->{oidcRPMetaDataOptions}
        and keys %{ $self->{oidcRPMetaDataOptions} } )
    {
        $self->lmLog( "No OpenID Connect Relying Party found in configuration",
            'warn' );
    }

    $self->{_oidcRPList} = $self->{oidcRPMetaDataOptions};
    $oidcCache->{_oidcRPList} = $self->{_oidcRPList} unless $no_cache;

    return 1;
}

## @method boolean refreshJWKSdata(boolean no_cache)
# Refresh JWKS data if needed
# @param no_cache Disable cache update
# @return boolean result
sub refreshJWKSdata {
    my ( $self, $no_cache ) = splice @_;

    unless ( $self->{oidcOPMetaDataJSON}
        and keys %{ $self->{oidcOPMetaDataJSON} } )
    {
        $self->lmLog(
            "No OpenID Provider configured, JWKS data will not be refreshed",
            'debug' );
        return 1;
    }

    foreach ( keys %{ $self->{oidcOPMetaDataJSON} } ) {

        # Refresh JWKS data if
        # 1/ oidcOPMetaDataOptionsJWKSTimeout > 0
        # 2/ jwks_uri defined in metadata

        my $jwksTimeout =
          $self->{oidcOPMetaDataOptions}->{$_}
          ->{oidcOPMetaDataOptionsJWKSTimeout};
        my $jwksUri = $self->{_oidcOPList}->{$_}->{conf}->{jwks_uri};

        unless ($jwksTimeout) {
            $self->lmLog( "No JWKS refresh timeout defined for $_, skipping...",
                'debug' );
            next;
        }

        unless ($jwksUri) {
            $self->lmLog( "No JWKS URI defined for $_, skipping...", 'debug' );
            next;
        }

        if ( $self->{_oidcOPList}->{$_}->{jwks}->{time} + $jwksTimeout > time )
        {
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

        $self->{_oidcOPList}->{$_}->{jwks}         = $content;
        $self->{_oidcOPList}->{$_}->{jwks}->{time} = time;
        $oidcCache->{_oidcOPList}->{$_}->{jwks}    = $content unless $no_cache;
        $oidcCache->{_oidcOPList}->{$_}->{jwks}->{time} = time unless $no_cache;

    }

    return 1;
}

## @method String getRP(String client_id)
# Get Relying Party corresponding to a Client ID
# @param client_id Client ID
# @return String result
sub getRP {
    my ( $self, $client_id ) = splice @_;
    my $rp;

    foreach ( keys %{ $self->{_oidcRPList} } ) {
        if ( $client_id eq
            $self->{_oidcRPList}->{$_}->{oidcRPMetaDataOptionsClientID} )
        {
            $rp = $_;
            last;
        }
    }

    return $rp;
}

## @method String getCallbackUri()
# Compute callback URI
# @return String Callback URI
sub getCallbackUri {
    my $self = shift;

    my $callback_get_param = $self->{oidcRPCallbackGetParam};

    my $callback_uri = $self->{portal};
    $callback_uri .=
      ( $self->{portal} =~ /\?/ )
      ? '&' . $callback_get_param . '=1'
      : '?' . $callback_get_param . '=1';

    # Use authChoiceParam in redirect URL
    if ( $self->param( $self->{authChoiceParam} ) ) {
        $callback_uri .= '&'
          . $self->{authChoiceParam} . '='
          . uri_escape( $self->param( $self->{authChoiceParam} ) );
    }

    $self->lmLog( "OpenIDConnect Callback URI: $callback_uri", 'debug' );

    return $callback_uri;
}

## @method String buildAuthorizationCodeAuthnRequest(String op, String state)
# Build Authentication Request URI for Authorization Code Flow
# @param op OpenIP Provider configuration key
# @param state State
# return String Authentication Request URI
sub buildAuthorizationCodeAuthnRequest {
    my ( $self, $op, $state ) = splice @_;

    my $authorize_uri =
      $self->{_oidcOPList}->{$op}->{conf}->{authorization_endpoint};
    my $client_id =
      $self->{oidcOPMetaDataOptions}->{$op}->{oidcOPMetaDataOptionsClientID};
    my $scope =
      $self->{oidcOPMetaDataOptions}->{$op}->{oidcOPMetaDataOptionsScope};
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

## @method String buildAuthorizationCodeAuthnResponse(String redirect_uri, String code, String state)
# Build Authentication Response URI for Authorization Code Flow
# @param redirect_uri Redirect URI
# @param code Code
# @param state State
# return String Authentication Response URI
sub buildAuthorizationCodeAuthnResponse {
    my ( $self, $redirect_uri, $code, $state ) = splice @_;

    my $response_url = $redirect_uri;

    $response_url .= ( $redirect_uri =~ /\?/ ? '&' : '?' );

    $response_url .= "code=" . uri_escape($code);

    if ($state) {
        $response_url .= "&state=" . uri_escape($state);
    }

    return $response_url;
}

## @method String buildImplicitAuthnResponse(String redirect_uri, String access_token, String id_token, String expires_in, String state)
# Build Authentication Response URI for Implicit Flow
# @param redirect_uri Redirect URI
# @param access_token Access token
# @param id_token ID token
# @param expires_in Expiration of access token
# @param state State
# return String Authentication Response URI
sub buildImplicitAuthnResponse {
    my ( $self, $redirect_uri, $access_token, $id_token, $expires_in, $state )
      = splice @_;

    my $response_url = $redirect_uri;

    $response_url .= "#id_token=" . uri_escape($id_token);

    if ($access_token) {
        $response_url .= "&access_token=" . uri_escape($access_token);
        $response_url .= "&token_type=bearer";
    }

    if ($expires_in) {
        $response_url .= "&expires_in=" . uri_escape($expires_in);
    }

    if ($state) {
        $response_url .= "&state=" . uri_escape($state);
    }

    return $response_url;
}

## @method String buildHybridAuthnResponse(String redirect_uri, String code, String access_token, String id_token, String expires_in, String state)
# Build Authentication Response URI for Hybrid Flow
# @param redirect_uri Redirect URI
# @param code Code
# @param access_token Access token
# @param id_token ID token
# @param expires_in Expiration of access token
# @param state State
# return String Authentication Response URI
sub buildHybridAuthnResponse {
    my ( $self, $redirect_uri, $code, $access_token, $id_token, $expires_in,
        $state )
      = splice @_;

    my $response_url = $redirect_uri;

    $response_url .= "#code=" . uri_escape($code);

    if ($access_token) {
        $response_url .= "&access_token=" . uri_escape($access_token);
        $response_url .= "&token_type=bearer";
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

    return $response_url;
}

## @method String getAuthorizationCodeAccessToken(String op, String code, String auth_method)
# Get Token response with autorization code
# @param op OpenIP Provider configuration key
# @param code Code
# @param auth_method Authentication Method
# return String Token response decoded content
sub getAuthorizationCodeAccessToken {
    my ( $self, $op, $code, $auth_method ) = splice @_;

    my $client_id =
      $self->{oidcOPMetaDataOptions}->{$op}->{oidcOPMetaDataOptionsClientID};
    my $client_secret =
      $self->{oidcOPMetaDataOptions}->{$op}
      ->{oidcOPMetaDataOptionsClientSecret};
    my $redirect_uri = $self->getCallbackUri;
    my $access_token_uri =
      $self->{_oidcOPList}->{$op}->{conf}->{token_endpoint};
    my $grant_type = "authorization_code";

    $self->lmLog(
        "Using auth method $auth_method to token endpoint $access_token_uri",
        'debug' );

    my $response;
    my %form;

    if ( $auth_method eq "client_secret_basic" ) {
        $form{"code"}         = $code;
        $form{"redirect_uri"} = $redirect_uri;
        $form{"grant_type"}   = $grant_type;

        $response = $self->ua->post(
            $access_token_uri, \%form,
            "Authorization" => "Basic "
              . encode_base64("$client_id:$client_secret"),
            "Content-Type" => 'application/x-www-form-urlencoded',
        );
    }

    if ( $auth_method eq "client_secret_post" ) {
        $form{"code"}          = $code;
        $form{"client_id"}     = $client_id;
        $form{"client_secret"} = $client_secret;
        $form{"redirect_uri"}  = $redirect_uri;
        $form{"grant_type"}    = $grant_type;

        $response = $self->ua->post( $access_token_uri, \%form,
            "Content-Type" => 'application/x-www-form-urlencoded' );
    }

    if ( $response->is_error ) {
        $self->lmLog( "Bad authorization response: " . $response->message,
            "error" );
        $self->lmLog( $response->content, 'debug' );
        return 0;
    }

    return $response->decoded_content;
}

## @method boolean checkTokenResponseValidity(HashRef json)
# Check validity of Token Response
# @param json JSON HashRef
# return boolean 1 if the response is valid, 0 else
sub checkTokenResponseValidity {
    my ( $self, $json ) = splice @_;

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

## @method boolean checkIDTokenValidity(String op, HashRef id_token)
# Check validity of ID Token
# @param op OpenIP Provider configuration key
# @param id_token ID Token payload as HashRef
# return boolean 1 if the token is valid, 0 else
sub checkIDTokenValidity {
    my ( $self, $op, $id_token ) = splice @_;

    my $client_id =
      $self->{oidcOPMetaDataOptions}->{$op}->{oidcOPMetaDataOptionsClientID};

    # Check issuer
    unless ( $id_token->{iss} eq $self->{_oidcOPList}->{$op}->{conf}->{issuer} )
    {
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
                    "More than one audiance, and azp not equal to client ID",
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

    # TODO check iat

    # TODO check nonce

    # TODO check acr

    # TODO check auth_time

    return 1;
}

## @method String getUserInfo(String op, String access_token)
# Get UserInfo response
# @param op OpenIP Provider configuration key
# @param access_token Access Token
# return String UserInfo response decoded content
sub getUserInfo {
    my ( $self, $op, $access_token ) = splice @_;

    my $userinfo_uri = $self->{_oidcOPList}->{$op}->{conf}->{userinfo_endpoint};

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

    return $response->decoded_content;
}

## @method HashRef decodeJSON(String json)
# Convert JSON to HashRef
# @param json JSON raw content
# @return HashRef JSON decoded content
sub decodeJSON {
    my ( $self, $json ) = splice @_;
    my $json_hash;

    eval { $json_hash = decode_json $json; };

    if ($@) {
        $json_hash->{error} = "parse_error";
    }

    return $json_hash;
}

## @method hashref getOpenIDConnectSession(string id)
# Try to recover the OpenID Connect session corresponding to id and return session
# If id is set to undef, return a new session
# @param id session reference
# @return Lemonldap::NG::Common::Session object
sub getOpenIDConnectSession {
    my ( $self, $id ) = splice @_;

    my $oidcSession = Lemonldap::NG::Common::Session->new(
        {
            storageModule        => $self->{oidcStorage},
            storageModuleOptions => $self->{oidcStorageOptions},
            cacheModule          => $self->{localSessionStorage},
            cacheModuleOptions   => $self->{localSessionStorageOptions},
            id                   => $id,
            kind                 => "OpenIDConnect",
        }
    );

    if ( $oidcSession->error ) {
        if ($id) {
            $self->_sub( 'userInfo',
                "OpenIDConnect session $id isn't yet available" );
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

## @method string storeState(array data)
# Store information in state database and return
# corresponding session_id
# @param data Array of information to store
# @return State Session ID
sub storeState {
    my ( $self, @data ) = splice @_;

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
    my $timeout      = $self->{timeout};
    my $stateTimeout = $self->{oidcRPStateTimeout} || $timeout;

    $infos->{_utime} = $time + ( $stateTimeout - $timeout );

    # Store infos in state session
    $stateSession->update($infos);

    # Return session ID
    return $stateSession->id;
}

## @method boolean extractState(string state)
# Extract state information into $self
# @param state state value
# @return result
sub extractState {
    my ( $self, $state ) = splice @_;

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

## @method arrayref extractJWT(String jwt)
# Extract parts of a JWT
# @param jwt JWT raw value
# @return arrayref JWT parts
sub extractJWT {
    my ( $self, $jwt ) = splice @_;

    my @jwt_parts = split( /\./, $jwt );

    return \@jwt_parts;
}

## @method boolean verifyJWTSignature(String op, String jwt)
# Check signature of a JWT
# @param op OpenIP Provider configuration key
# @param jwt JWT raw value
# @return boolean 1 if signature is verified, 0 else
sub verifyJWTSignature {
    my ( $self, $op, $jwt ) = splice @_;

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
        my $client_secret =
          $self->{oidcOPMetaDataOptions}->{$op}
          ->{oidcOPMetaDataOptionsClientSecret};

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

        # The public key is needed
        unless ( $self->{_oidcOPList}->{$op}->{jwks} ) {
            $self->lmLog( "Cannot verify $alg signature: no JWKS data found",
                'error' );
            return 0;
        }

        my $keys = $self->{_oidcOPList}->{$op}->{jwks}->{keys};
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

## @method boolean verifyHash(String value, String hash, String id_token)
# Check value hash
# @param value Value
# @param hash Hash
# @param id_token ID Token
# @return boolean 1 if hash is verified, 0 else
sub verifyHash {
    my ( $self, $value, $hash, $id_token ) = splice @_;

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

## @method String createHash(String value, String hash_level)
# Create Hash
# @param value Value to hash
# @param hash_level SHA Hash level
# @return String hash
sub createHash {
    my ( $self, $value, $hash_level ) = splice @_;

    $self->lmLog( "Use SHA $hash_level to hash $value", 'debug' );

    my $hash;

    if ( $hash_level eq "256" ) { $hash = sha256($value); }
    if ( $hash_level eq "384" ) { $hash = sha384($value); }
    if ( $hash_level eq "512" ) { $hash = sha512($value); }

    $hash = substr( $hash, 0, length($hash) / 2 );
    $hash = encode_base64url( $hash, "" );

    return $hash;
}

## @method void returnRedirectError(String redirect_url, String error, String error_description, String error_uri, String state, Boolean fragment)
# Create error redirection
# @param redirect_url Redirection URL
# @param error Error code
# @param error_description Human-readable ASCII encoded text description of the error
# @param error_uri URI of a web page that includes additional information about the error
# @param state OAuth 2.0 state value
# @param fragment Set to true to return fragment component
# @return void
sub returnRedirectError {
    my ( $self, $redirect_url, $error, $error_description, $error_uri, $state,
        $fragment )
      = splice @_;

    my $urldc = $redirect_url;

    if ($fragment) { $urldc .= "#"; }
    else {
        $urldc .= ( $redirect_url =~ /\?/ ? '&' : '?' );
    }

    $urldc .= "error=" . uri_escape($error);
    $urldc .= "&error_description=" . uri_escape($error_description)
      if defined $error_description;
    $urldc .= "&error_uri=" . uri_escape($error_uri) if defined $error_uri;
    $urldc .= "&state=" . uri_escape($state)         if defined $state;

    $self->lmLog( "Redirect user to $urldc", 'debug' );
    $self->{'urldc'} = $urldc;

    $self->_sub('autoRedirect');

    $self->quit;
}

## @method void returnJSONError(String error);
# Print JSON error
# @param error Error message
# @return void
sub returnJSONError {
    my ( $self, $error ) = splice @_;
    my $content = { "error" => "$error" };

    # We use to_json because values are already UTF-8 encoded
    my $json = to_json( $content, { pretty => 1 } );

# TODO Send 400 return code
# CGI always add HTML code to non 200 return code, which is not compatible with JSON response
    print $self->header('application/json');
    print $json;
}

## @method void returnJSON(String content);
# Print JSON content
# @param content Message
# @return void
sub returnJSON {
    my ( $self, $content ) = splice @_;

    # We use to_json because values are already UTF-8 encoded
    my $json = to_json( $content, { pretty => 1 } );

    $self->lmLog( "Return JSON: $json", 'debug' );

    print $self->header('application/json');
    print $json;
}

## @method void returnBearerError(String error_code, String error_message);
# Return Bearer error
# @param error_code Error code
# @param error_message Error message
# @return void
sub returnBearerError {
    my ( $self, $error_code, $error_message ) = splice @_;

    my $content = "error=$error_code,error_description=$error_message";

# TODO Send 400/401 return code
# CGI always add HTML code to non 200 return code, which is not compatible with JSON response

    print $self->header( -www_authenticate => $content );

}

## @method array getEndPointAuthenticationCredentials()
# Get Client ID and Client Secret
# @return array (client_id, client_secret)
sub getEndPointAuthenticationCredentials {
    my $self = shift;
    my ( $client_id, $client_secret );

    my $authorization = $ENV{HTTP_AUTHORIZATION};
    if ( $authorization =~ /^Basic (\w+)/i ) {
        $self->lmLog( "Method client_secret_basic used", 'debug' );
        ( $client_id, $client_secret ) = split( /:/, decode_base64($1) );
    }
    elsif ( $self->param('client_id') && $self->param('client_secret') ) {
        $self->lmLog( "Method client_secret_post used", 'debug' );
        $client_id     = $self->param('client_id');
        $client_secret = $self->param('client_secret');
    }

    return ( $client_id, $client_secret );
}

## @method String getEndPointAccessToken()
# Get Access Token
# @return access_token
sub getEndPointAccessToken {
    my $self = shift;
    my $access_token;

    my $authorization = $ENV{HTTP_AUTHORIZATION};
    if ( $authorization =~ /^Bearer (\w+)/i ) {
        $self->lmLog( "Bearer access token", 'debug' );
        $access_token = $1;
    }

    return $access_token;
}

## @method arrayref getAttributesListFromClaim(String claim)
# Return list of attributes authorized for a claim
# @param claim Claim
# @return arrayref attributes list
sub getAttributesListFromClaim {
    my ( $self, $claim ) = splice @_;
    my $attributes = {};

    # OpenID Connect standard claims
    $attributes->{profile} = [
        qw/name family_name given_name middle_name nickname preferred_username profile picture website gender birthdate zoneinfo locale updated_at/
    ];
    $attributes->{email} = [qw/email email_verified/];
    $attributes->{address} =
      [qw/formatted street_address locality region postal_code/];
    $attributes->{phone} = [qw/phone_number phone_number_verified/];

    # Additional claims
    # TODO

    return $attributes->{$claim};
}

## @method hashref buildUserInfoResponse(String scope, String rp, String user_session_id)
# Return Hash of UserInfo data
# @param scope OIDC scope
# @param rp Internal Relying Party identifier
# @param user_session_id User session identifier
# @return hashref UserInfo data
sub buildUserInfoResponse {
    my ( $self, $scope, $rp, $user_session_id ) = splice @_;
    my $userinfo_response = {};

    # Get user identifier
    my $apacheSession = $self->getApacheSession( $user_session_id, 1 );

    unless ($apacheSession) {
        $self->lmLog( "Unable to find user session", "error" );
        $self->returnJSONError("invalid_request");
        $self->quit;
    }
    my $user_id_attribute =
      $self->{oidcRPMetaDataOptions}->{$rp}->{oidcRPMetaDataOptionsUserIDAttr}
      || $self->{whatToTrace};
    my $user_id = $apacheSession->data->{$user_id_attribute};

    $self->lmLog( "Found corresponding user: $user_id", 'debug' );

    $userinfo_response->{sub} = $user_id;

    # Parse scope and return allowed attributes
    foreach my $claim ( split( /\s/, $scope ) ) {
        next if ( $claim eq "openid" );
        $self->lmLog( "Get attributes linked to claim $claim", 'debug' );
        my $list = $self->getAttributesListFromClaim($claim);
        next unless $list;
        foreach my $attribute (@$list) {
            my $session_key =
              $self->{oidcRPMetaDataExportedVars}->{$rp}->{$attribute};
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

## @method String createIDToken(hashref payload, String rp)
# Return ID Token
# @param payload ID Token content
# @param rp Internal Relying Party identifier
# @return String id_token ID Token as JWT
sub createIDToken {
    my ( $self, $payload, $rp ) = splice @_;

    # Get signature algorithm
    my $alg = $self->{oidcRPMetaDataOptions}->{$rp}
      ->{oidcRPMetaDataOptionsIDTokenSignAlg};
    $self->lmLog( "JWT signature algorithm: $alg", 'debug' );

    # Payload encoding
    my $id_token_payload = encode_base64( encode_json($payload), "" );

    # ID Token header
    my $id_token_header_hash = { typ => "JWT", alg => $alg };
    my $id_token_header =
      encode_base64( encode_json($id_token_header_hash), "" );

    if ( $alg eq "none" ) {

        return $id_token_header . "." . $id_token_payload;
    }

    if ( $alg eq "HS256" or $alg eq "HS384" or $alg eq "HS512" ) {

        # Sign with client secret
        my $client_secret =
          $self->{oidcRPMetaDataOptions}->{$rp}
          ->{oidcRPMetaDataOptionsClientSecret};

        my $digest;

        if ( $alg eq "HS256" ) {
            $digest =
              hmac_sha256_base64( $id_token_header . "." . $id_token_payload,
                $client_secret );
        }

        if ( $alg eq "HS384" ) {
            $digest =
              hmac_sha384_base64( $id_token_header . "." . $id_token_payload,
                $client_secret );
        }

        if ( $alg eq "HS512" ) {
            $digest =
              hmac_sha512_base64( $id_token_header . "." . $id_token_payload,
                $client_secret );
        }

        return $id_token_header . "." . $id_token_payload . "." . $digest;
    }

    if ( $alg eq "RS256" or $alg eq "RS384" or $alg eq "RS512" ) {

        # Get signing private key
        my $priv_key = $self->{oidcServicePrivateKeySig};
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
            $rsa_priv->sign( $id_token_header . "." . $id_token_payload ) );

        return $id_token_header . "." . $id_token_payload . "." . $digest;
    }

    $self->lmLog( "Algorithm $alg not supported to sign ID Token", 'debug' );

    return;
}

## @method String getFlowType(String response_type)
# Return flow type
# @param response_type Response type
# @return String flow
sub getFlowType {
    my ( $self, $response_type ) = splice @_;

    my $response_types = {
        "code"                => "authorizationcode",
        "id_token"            => "implicit",
        "id_token token"      => "implicit",
        "code id_token"       => "hybrid",
        "code token"          => "hybrid",
        "code id_token token" => "hybrid",
    };

    return $response_types->{$response_type};
}

## @method String getIDTokenSub(String id_token)
# Return sub field of an ID Token
# @param id_token ID Token
# @return String sub
sub getIDTokenSub {
    my ( $self, $id_token ) = splice @_;

    my $jwt     = $self->extractJWT($id_token);
    my $payload = decode_json( decode_base64( $jwt->[1] ) );

    return $payload->{sub};
}

## @method HashRef key2jwks(String key)
# Return JWKS representation of a key
# @param key Raw key
# @return HashRef JWKS key
sub key2jwks {
    my ( $self, $key ) = splice @_;
    my $hash = {};

    my $rsa_pub = Crypt::OpenSSL::RSA->new_public_key($key);
    my @params  = $rsa_pub->get_key_parameters();

    $hash->{n} = encode_base64( $params[0]->to_bin(), "" );
    $hash->{e} = encode_base64( $params[1]->to_bin(), "" );

    return $hash;
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

Get Token response with autorization code

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

=head2 returnRedirectError

Create error redirection

=head2 returnJSONError

Print JSON error

=head2 returnJSON

Print JSON content

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

=head2 createIDToken

Return ID Token

=head2 getFlowType

Return flow type

=head2 getIDTokenSub

Return sub field of an ID Token

=head2 key2jwks

Return JWKS representation of a key

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
