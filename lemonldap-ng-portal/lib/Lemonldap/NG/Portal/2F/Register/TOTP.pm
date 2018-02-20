# Self U2F registration
package Lemonldap::NG::Portal::2F::Register::TOTP;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Common::Module', 'Lemonldap::NG::Common::TOTP';

# INITIALIZATION

has ott => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->conf->{formTimeout} );
        return $ott;
    }
);

sub init {
    my ($self) = @_;
    return 0 unless $self->SUPER::init;
    if ( $self->conf->{totpSelfRegister} ) {
        $self->addAuthRoute(
            totpregister => { ':action' => 'selfRegister' },
            ['POST']
        );
        $self->addAuthRoute( 'totpregister.html' => undef, ['GET'] );
    }
    return 1;
}

sub selfRegister {
    my ( $self, $req ) = @_;
    my $action = $req->param('action');
    my $user   = $req->userData->{ $self->conf->{whatToTrace} };
    unless ($user) {
        return $self->p->sendError( $req,
            'No ' . $self->conf->{whatToTrace} . ' found in user datas', 500 );
    }

    # Verification that user has a valid TOTP app
    if ( $action eq 'verify' ) {

        # Get form token
        my $token = $req->param('token');
        unless ($token) {
            $self->userLogger->warn(
                "TOTP registration: register try without token for $user");
            return $self->p->sendError( $req, 'Go away', 400 );
        }

        # Verify that token exists in DB (note that "keep" flag is set to
        # permit more than 1 try during token life
        unless ( $token = $self->ott->getToken( $token, 1 ) ) {
            $self->userLogger->notice(
                "TOTP registration: token expired for $user");
            return $self->p->sendError( $req, 'PE82', 400 );
        }

        # Token is valid, so we have the master key proposed
        # ($token->{_totp2fSecret})

        # Now check TOTP code to verify that user has a valid TOTP app
        my $code = $req->param('code');
        unless ($code) {
            $self->logger->userInfo('TOTP registration: empty validation form');
            return $self->p->sendError( $req, 'missingCode', 400 );
        }
        my $r = $self->verifyCode(
            $self->conf->{totp2fInterval},
            $self->conf->{totp2fRange},
            $token->{_totp2fSecret}, $code
        );
        if ( $r == -1 ) {
            return $self->p->sendError( 'serverError', 500 );
        }

        # Invalid try is returned with a 200 code. Javascript will read error
        # and propose to retry
        elsif ( $r == 0 ) {
            $self->userLogger->notice(
                "TOTP registration: invalid TOTP for $user");
            return $self->p->sendError( $req, 'badCode', 200 );
        }
        $self->logger->debug('TOTP code verified');

        # Now code is verified, let's store the master key in persistent datas
        $self->p->updatePersistentSession( $req,
            { _totp2fSecret => $token->{_totp2fSecret} } );
        $self->userLogger->logger('TOTP registration succeed');
        return [ 200, [ 'Content-Type' => 'application/json' ],
            ['{"result":1}'] ];
    }
    # Get or generate master key
    elsif($action eq 'getkey') {
    }
}

1;
