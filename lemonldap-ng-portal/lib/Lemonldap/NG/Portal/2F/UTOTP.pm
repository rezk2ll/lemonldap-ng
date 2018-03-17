package Lemonldap::NG::Portal::2F::UTOTP;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

has prefix => ( is => 'ro', default => 'totp' );

has logo => ( is => 'rw', default => 'totp.png' );

has u2f => ( is => 'rw' );

has totp => ( is => 'rw' );

use Lemonldap::NG::Portal::Main::Constants qw(
  PE_FORMEMPTY
  PE_OK
  PE_SENDRESPONSE
);

sub init {
    my ($self) = @_;
    foreach (qw(U2F TOTP)) {
        unless ( $self->{ lc($_) } = $self->p->loadPlugin("::2F::$_") ) {
            $self->error("Unable to load ::2F::$_");
            return 0;
        }
    }
    return 1;
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
        my $r1 = $self->u2f->verify( $req, $session );
        if ( $r1 == PE_OK ) {
            return PE_OK;
        }
    }
    if ( $req->param('code') ) {
        return $self->totp->verify( $req, $session );
    }
    return ( $r1 ? $r1 : PE_FORMEMPTY );
}

1;
