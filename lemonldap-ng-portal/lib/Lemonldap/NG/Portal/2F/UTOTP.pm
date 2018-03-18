package Lemonldap::NG::Portal::2F::UTOTP;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::SecondFactor';

# INITIALIZATION

has prefix => ( is => 'ro', default => 'utotp' );

has logo => ( is => 'rw', default => 'utotp.png' );

has u2f => ( is => 'rw' );

has totp => ( is => 'rw' );

use Lemonldap::NG::Portal::Main::Constants qw(
  PE_FORMEMPTY
  PE_OK
  PE_SENDRESPONSE
);

sub init {
    my ($self) = @_;
    if (    $self->conf->{utotp2fSelfRegistration}
        and $self->conf->{utotp2fActivation} eq '1' )
    {
        $self->conf->{utotp2fActivation} =
          '$_totp2fSecret or $_u2fKeyHandle and $_u2fUserKey';
    }
    foreach (qw(U2F TOTP)) {
        # Arg "noRoute" is set for sub 2F modules to avoid enabling direct
        # REST routes
        unless ( $self->{ lc($_) } =
            $self->p->loadModule( "::2F::$_", undef, noRoute => 1 ) )
        {
            $self->error("Unable to load ::2F::$_");
            return 0;
        }
    }
    return $self->SUPER::init();
}

# RUNNING METHODS

sub run {
    my ( $self, $req, $token ) = @_;
    $self->logger->debug('Generate TOTP form');

    # Prepare form
    my $tmp = $self->p->sendHtml(
        $req,
        'utotp2fcheck',
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
    my ($r1);
    if ( $req->param('signature') ) {
        $self->logger->debug('UTOTP: U2F response detected');
        my $r1 = $self->u2f->verify( $req, $session );
        if ( $r1 == PE_OK ) {
            return PE_OK;
        }
    }
    if ( $req->param('code') ) {
        $self->logger->debug('UTOTP: TOTP response detected');
        return $self->totp->verify( $req, $session );
    }
    return ( $r1 ? $r1 : PE_FORMEMPTY );
}

1;
