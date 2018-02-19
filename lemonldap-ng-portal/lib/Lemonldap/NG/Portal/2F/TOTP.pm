package Lemonldap::NG::Portal::2F::TOTP;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_BADCREDENTIALS
  PE_ERROR
  PE_FORMEMPTY
  PE_OK
  PE_SENDRESPONSE
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::SecondFactor';

# INITIALIZATION

sub init {
    my ($self) = @_;
    if ( $self->conf->{totpActivation} eq '1' ) {
        $self->conf->{totpActivation} = '$_totpSecret';
    }
    $self->conf->{totpInterval} ||= 30;
    $self->conf->{totpRange}    ||= 1;
    return $self->SUPER::init();
}

# RUNNING METHODS

sub run {
    my ( $self, $req, $token ) = @_;

    # Prepare form
    my $tmp = $self->p->sendHtml(
        $req,
        'ext2fcheck',
        params => {
            SKIN  => $self->conf->{portalSkin},
            TOKEN => $token
        }
    );
    $self->logger->debug("Prepare TOTP 2F verification");

    $req->response($tmp);
    return PE_SENDRESPONSE;
}

sub verify {
    my ( $self, $req, $session ) = @_;
    my $code;
    unless ( $code = $req->param('code') ) {
        $self->userLogger->error('TOTP 2F: no code');
        return PE_FORMEMPTY;
    }

    my $s = eval { decode_base32( $session->{_totpSecret} ) };
    if ($@) {
        $self->logger->error("Bad characters in secret, aborting");
        return PE_ERROR;
    }
    for ( 0 .. $self->conf->{totpRange} ) {
        if ( $code eq $self->code( $s, $_ ) ) {
            $self->userLogger->info('TOTP verified');
            return PE_OK;
        }
    }
    $self->userLogger->notice(
        'Invalid TOTP for ' . $session->{ $self->conf->{whatToTrace} } . ')' );
    return PE_BADCREDENTIALS;
}

sub code {
    my ( $self, $secret, $r ) = @_;
    my $hmac = hmac_sha1_hex(
        pack(
            'H*',
            sprintf(
                '%016x',
                int(
                    ( time + $r * $self->conf->{totpInterval} ) /
                      $self->conf->{totpInterval}
                )
            )
        ),
        _decode_base32($secret),
    );

    return sprintf(
        '%06d',
        (
            hex( substr( $hmac, hex( substr( $hmac, -1 ) ) * 2, 8 ) ) &
              0x7fffffff
        ) % 1000000
    );
}

1;
