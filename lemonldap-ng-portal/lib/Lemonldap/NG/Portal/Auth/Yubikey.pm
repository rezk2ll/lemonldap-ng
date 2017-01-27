package Lemonldap::NG::Portal::Auth::Yubikey;

use strict;
use Mouse;
use JSON;
use LWP::UserAgent;
use HTTP::Request;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR PE_FORMEMPTY);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base';

# INITIALIZATION

# Try to load Yubikey perl module
sub init {
    my ($self) = @_;
    eval { require Auth::Yubikey_WebClient };
    if ($@) {
        $self->error($@);
        return 0;
    }
    unless ($self->conf->{yubikeyClientID}
        and $self->conf->{yubikeySecretKey} )
    {
        $self->lmLog( "Missing mandatory parameters (Client ID and secret key)",
            'error' );
        return 0;
    }
    $self->conf->{yubikeyPublicIDSize} ||= 12;
    return 1;
}

sub extractFormInfo {
    my ( $self, $req ) = @_;

    # Get OTP
    my $otp = $req->param('yubikeyOTP');
    return PE_FORMEMPTY unless $otp;

    $self->lmLog( "Received Yubikey OTP $otp", 'debug' );

    # Verify OTP
    my $result = Auth::Yubikey_WebClient::yubikey_webclient(
        $otp,
        $self->conf->{yubikeyClientID},
        $self->conf->{yubikeySecretKey}
    );

    # Store user, which is the public ID part of the OTP
    $req->{user} = substr( $otp, 0, $self->conf->{yubikeyPublicIDSize} );

    PE_OK;
}

sub authenticate {
    PE_OK;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    $req->{sessionInfo}->{authenticationLevel} =
      $self->conf->{yubikeyAuthnLevel};
    PE_OK;
}

sub authLogout {
    PE_OK;
}

sub getDisplayType {
    return 'yubikeyform';
}

1;
