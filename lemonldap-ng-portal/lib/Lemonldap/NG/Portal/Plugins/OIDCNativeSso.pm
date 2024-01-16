package Lemonldap::NG::Portal::Plugins::OIDCNativeSso;

use strict;
use Digest::SHA qw(sha256_hex);
use Mouse;
use Lemonldap::NG::Common::JWT             qw(getJWTPayload);
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_ERROR
  PE_OK
  PE_SENDRESPONSE
);
use String::Random qw/random_string/;

our $VERSION = '2.19.0';

extends 'Lemonldap::NG::Portal::Main::Plugin',
  'Lemonldap::NG::Portal::Lib::OpenIDConnect';

use constant hook => {

# Step 1 verify that device_sso scope is authorized during authorization request
    oidcResolveScope => 'resolveScope',

    # Step 2: generate device_secret
    oidcGenerateAccessToken   => 'accessTokenHook',
    oidcGenerateIDToken       => 'addDsHash',
    oidcGenerateTokenResponse => 'tokenResponse',

    # Step 3: give new access_token when device_secret is valid
    oidcGotTokenExchange => 'tokenExchangeHook',
};

has iss => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{oidcServiceMetaDataIssuer} || $_[0]->conf->{portal};
    }
);

sub init {
    1;
}

use constant sessionKind => 'OIDC';

# STEP 1: verify that device_sso scope is authorized during authorization request

sub resolveScope {
    my ( $self, $req, $scopeList, $rp ) = @_;
    unless ( $self->conf->{oidcRPMetaDataOptions}->{$rp}
        ->{oidcRPMetaDataOptionsAllowDeviceSso} )
    {
        my @scopes;

        # To keep $scopeList reference, empty related array then populate it
        while (@$scopeList) {
            my $tmp = shift(@$scopeList);
            if ( $tmp eq 'device_sso' ) {
                $self->userLogger->error(
                    "Request scope device_sso for an unauthorized RP: $rp");
            }
            else {
                push @scopes, $tmp unless $tmp eq 'device_sso';
            }
        }
        push @$scopeList, @scopes;
    }
    return PE_OK;
}

# STEP 2: generate device_secret
sub accessTokenHook {
    my ( $self, $req, $payload, $rp ) = @_;
    if ( $payload->{scope} =~ /\bdevice_sso\b/ ) {
        $req->data->{oidcNativeSso} = {
            scope   => $payload->{scope},
            ds_hash => random_string( 's' x 32 ),
        };
    }
    return PE_OK;
}

sub addDsHash {
    my ( $self, $req, $payload, $rp ) = @_;
    if ( $req->data->{oidcNativeSso} ) {
        $payload->{ds_hash} = $req->data->{oidcNativeSso}->{ds_hash};
    }
    return PE_OK;
}

sub tokenResponse {
    my ( $self, $req, $rp, $tokenResponse, $oidcSession, $sessionInfo ) = @_;
    if ( $req->data->{oidcNativeSso} ) {
        my %userInfo = ( ds_hash => $req->data->{oidcNativeSso}->{ds_hash} );
        for my $userKey ( grep !/^(_session|_utime$|_lastSeen$)/,
            keys %$sessionInfo )
        {
            $userInfo{$userKey} = $oidcSession->{$userKey};
        }
        my $deviceSecret = $self->getOpenIDConnectSession(
            undef,
            'device_secret',
            $self->rpOptions->{$rp}
              ->{oidcRPMetaDataOptionsOfflineSessionExpiration}
              || $self->conf->{oidcServiceOfflineSessionExpiration},
            {
                %userInfo,
                redirect_uri => $oidcSession->{redirect_uri},
                scope        => $req->data->{oidcNativeSso}->{scope},
                client_id    => $self->conf->{oidcRPMetaDataOptions}->{$rp}
                  ->{oidcRPMetaDataOptionsClientID},
                _session_uid => $sessionInfo->{_user},
                auth_time    => $sessionInfo->{_lastAuthnUTime},
                grant_type   => "authorizationcode",
                id_token_h   => sha256_hex( $tokenResponse->{id_token} ),
            },
        );
        $tokenResponse->{device_secret} = $deviceSecret->id;
    }
    return PE_OK;
}

use constant T_LOG_PREFIX => 'Native SSO token exchange: ';

# STEP 3: give new access_token when device_secret is valid
sub tokenExchangeHook {
    my ( $self, $req, $rp ) = @_;
    if ( $self->conf->{oidcRPMetaDataOptions}->{$rp}
        ->{oidcRPMetaDataOptionsAllowDeviceSso} )
    {
        # STEP 3.1: Check parameters

        # Required parameter list
        foreach (
            qw(audience subject_token subject_token_type actor_token actor_token_type)
          )
        {
            unless ( $req->param($_) ) {
                $self->userLogger->error( T_LOG_PREFIX . "missing $_" );
                return PE_ERROR;
            }
        }

        # Check for static parameters
        unless ( $req->param('subject_token_type') eq
            'urn:ietf:params:oauth:token-type:id_token'
            and $req->param('actor_token_type') eq
            'urn:x-oath:params:oauth:token-type:device-secret' )
        {
            $self->userLogger->error(
                T_LOG_PREFIX . 'Bad subject_token_type or actor_token_type' );
            return PE_ERROR;
        }

        # Check for audience that should be the issuer
        # (given by "iss" field of id_token)

        unless ( $req->param('audience') eq $self->iss ) {
            $self->userLogger->error( T_LOG_PREFIX
                  . 'missing or bad audience '
                  . $req->param('audience') );
            return PE_ERROR;
        }

        # Check for device_secret
        my $deviceSecret = $req->param('actor_token');
        my $session =
          $self->getOpenIDConnectSession( $deviceSecret, "device_secret" );
        unless ($session) {
            $self->userLogger->error(
                T_LOG_PREFIX . "bad device_secret $deviceSecret" );
            return PE_ERROR;
        }

        # Check for id_token
        my $idTokenHint = $req->param('subject_token');
        unless ( sha256_hex($idTokenHint) eq $session->data->{id_token_h} ) {
            $self->userLogger->error(
                T_LOG_PREFIX . 'subject_token does not match actor_token' );
            return PE_ERROR;
        }

        # Check also for ds_hash
        my $dsHash = getJWTPayload($idTokenHint)->{ds_hash};
        unless ( $dsHash eq $session->data->{ds_hash} ) {
            $self->userLogger->error( T_LOG_PREFIX . 'ds_hash mismatch' );
            return PE_ERROR;
        }

        $req->response( $self->p->sendJSONresponse( $req, { a => 1 } ) );
        return PE_SENDRESPONSE;
    }

    # Else ignore this request
    return PE_OK;
}

1;
