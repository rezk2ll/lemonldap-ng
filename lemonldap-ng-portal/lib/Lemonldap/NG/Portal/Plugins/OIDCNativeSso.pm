package Lemonldap::NG::Portal::Plugins::OIDCNativeSso;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_ERROR
  PE_OK
  PE_SENDRESPONSE
);

our $VERSION = '2.19.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

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

sub init {
    1;
}

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
        $req->data->{oidcNativeSso} = 1;
    }
    return PE_OK;
}

sub addDsHash {
    my ( $self, $req, $payload, $rp ) = @_;
    if ( $req->data->{oidcNativeSso} ) {
        $payload->{ds_hash} = 'XXXX';
    }
    return PE_OK;
}

sub tokenResponse {
    my ( $self, $req, $rp, $tokenResponse, $oidcSession, $sessionInfo ) = @_;
    if ( $oidcSession->{scope} =~ /\bdevice_sso\b/ ) {
        $tokenResponse->{device_secret} = 'XXXXX';
    }
    return PE_OK;
}

# STEP 3: give new access_token when device_secret is valid
sub tokenExchangeHook {
    my ( $self, $req, $rp ) = @_;
    $req->response( $self->p->sendJSONresponse( $req, { a => 1 } ) );
    return PE_SENDRESPONSE;
}

1;
