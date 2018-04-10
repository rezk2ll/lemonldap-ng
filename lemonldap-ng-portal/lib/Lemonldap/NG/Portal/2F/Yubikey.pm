package Lemonldap::NG::Portal::2F::Yubikey;

use strict;
use Mouse;
use JSON qw(from_json to_json);
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

has logo => ( is => 'rw', default => 'yubikey.png' );

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
        $self->conf->{yubikey2fActivation} =
          '$_2fDevices =~ /"type":\s*"UBK"/s';
    }
    unless ($self->conf->{yubikey2fClientID}
        and $self->conf->{yubikey2fSecretKey} )
    {
        $self->error('Missing mandatory parameters (Client ID and secret key)');
        return 0;
    }

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
    my $yubikey    = 0;
    my $_2fDevices = eval {
        $self->logger->debug("Looking for 2F Devices ...");
        from_json( $req->{sessionInfo}->{_2fDevices}, { allow_nonref => 1 } );
    };

    foreach (@$_2fDevices) {
        $self->logger->debug("Reading Yubikey ...");
        if ( $_->{type} eq 'UBK' ) {
            $yubikey = $_->{_yubikey};
            last;
        }
    }

    unless ($yubikey) {
        $self->userLogger->warn( 'User '
              . $req->{sessionInfo}->{ $self->conf->{whatToTrace} }
              . ' has no Yubikey registered' );
        return PE_BADCREDENTIALS;
    }
    $self->logger->debug("Found Yubikey : $yubikey");

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
    my $yubikey    = 0;
    my $_2fDevices = eval {
        $self->logger->debug("Looking for 2F Devices ...");
        from_json( $session->{_2fDevices}, { allow_nonref => 1 } );
    };

    foreach (@$_2fDevices) {
        $self->logger->debug("Reading Yubikey ...");
        if ( $_->{type} eq 'UBK' ) {
            $yubikey = $_->{_yubikey};
            last;
        }
    }

    if (
        index( $yubikey,
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
