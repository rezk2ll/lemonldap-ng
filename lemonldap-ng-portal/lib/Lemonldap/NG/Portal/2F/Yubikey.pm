package Lemonldap::NG::Portal::2F::Yubikey;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_BADCREDENTIALS
  PE_FORMEMPTY
  PE_OK
  PE_SENDRESPONSE
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::SecondFactor';

# INITIALIZATION

has prefix => ( is => 'ro', default => 'yubikey' );

has logo => ( is => 'rw', default => 'u2f.png' );

has yubi => ( is => 'rw' );

sub init {
    my ($self) = @_;
    eval { require Auth::Yubikey_WebClient };
    if ($@) {
        $self->logger->error($@);
        return 0;
    }
    if (    $self->conf->{yubikey2fSelfRegistration}
        and $self->conf->{yubikey2fActivation} eq '1' )
    {
        $self->conf->{yubikey2fActivation} = '$_yubikeys';
    }
    unless ($self->conf->{yubikey2fClientID}
        and $self->conf->{yubikey2fSecretKey} )
    {
        $self->error('Missing mandatory parameters (Client ID and secret key)');
        return 0;
    }
    $self->conf->{yubikey2fPublicIDSize} ||= 12;
    $self->yubi(
        Auth::Yubikey_WebClient->new(
            {
                id    => $self->conf->{yubikey2fClientID},
                api   => $self->conf->{yubikey2fSecretKey},
                nonce => $self->conf->{yubikey2fNonce},
                url   => $self->conf->{yubikey2fUrl}
            }
        )
    );
    return $self->SUPER::init();
}

sub run {
    my ( $self, $req, $token ) = @_;

    unless ( $req->{sessionInfo}->{_yubikeys} ) {
        $self->userLogger->warn( 'User '
              . $req->{sessionInfo}->{ $self->conf->{whatToTrace} }
              . ' has no Yubikey registered' );
        return PE_BADCREDENTIALS;
    }

    # Prepare form
    my $tmp = $self->p->sendHtml(
        $req,
        'ext2fcheck',
        params => {
            SKIN      => $self->conf->{portalSkin},
            TOKEN     => $token,
            TARGET    => '/yubikey2fcheck',
            INPUTLOGO => 'yubikey.png',
            LEGEND    => 'clickOnYubikey',
        }
    );
    $self->logger->debug("Display Yubikey form");

    $req->response($tmp);
    return PE_SENDRESPONSE;
}

sub verify {
    my ( $self, $req, $session ) = @_;
    my $code;
    unless ( $code = $req->param('code') ) {
        $self->userLogger->error('Yubikey 2F: no code');
        return PE_FORMEMPTY;
    }

    # Verify OTP
    if (
        index( $session->{_yubikeys},
            substr( $code, 0, $self->conf->{yubikey2fPublicIDSize} ) ) == -1
      )
    {
        $self->userLogger->warn('Yubikey not registered');
        return PE_BADCREDENTIALS;
    }
    if ( $self->yubi->otp($code) ne 'OK' ) {
        $self->userLogger->warn('Yubikey verification failed');
        return PE_BADCREDENTIALS;
    }
    PE_OK;
}

1
