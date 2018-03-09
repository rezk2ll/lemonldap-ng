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

extends 'Lemonldap::NG::Portal::Main::SecondFactor',
  'Lemonldap::NG::Common::TOTP';

# INITIALIZATION

has prefix => ( is => 'ro', default => 'totp' );

has logo => ( is => 'rw', default => 'totp.png' );

sub init {
    my ($self) = @_;

    # If self registration is enabled and "activation" is simply set to
    # "enabled", replace the rule to detect if user has register its key
    if (    $self->conf->{totp2fSelfRegistration}
        and $self->conf->{totp2fActivation} eq '1' )
    {
        $self->conf->{totp2fActivation} = '$_totp2fSecret';
    }
    $self->conf->{totp2fInterval} ||= 30;
    $self->conf->{totp2fRange}    ||= 1;
    return $self->SUPER::init();
}

# RUNNING METHODS

sub run {
    my ( $self, $req, $token ) = @_;
    $self->logger->debug('Generate TOTP form');

    # Prepare form
    my $tmp = $self->p->sendHtml(
        $req,
        'totp2fcheck',
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
    $self->logger->debug('TOTP verification');
    my $code;
    unless ( $code = $req->param('code') ) {
        $self->userLogger->error('TOTP 2F: no code');
        return PE_FORMEMPTY;
    }

    my $r = $self->verifyCode(
        $self->conf->{totp2fInterval},
        $self->conf->{totp2fRange},
        $self->conf->{totp2fDigits},
        $session->{_totp2fSecret}, $code
    );
    if ( $r == -1 ) { return PE_ERROR; }
    elsif ($r) {
        $self->userLogger->info('TOTP succeed');
        return PE_OK;
    }
    else {
        $self->userLogger->notice( 'Invalid TOTP for '
              . $session->{ $self->conf->{whatToTrace} }
              . ')' );
        return PE_BADCREDENTIALS;
    }
}

1;
