# Self U2F registration
package Lemonldap::NG::Portal::Register::U2F;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Lib::U2F';

# INITIALIZATION

sub init {
    my ($self) = @_;
    return 0 unless $self->SUPER::init;
    $self->addAuthRoute( u2fregister => { ':action' => 'run' }, ['POST'] );
    $self->addAuthRoute( 'u2fregister.html' => undef, ['GET'] );
    return 1;
}

# RUNNING METHODS

# Main method
sub run {
    my ( $self, $req ) = @_;
    my $action = $req->param('action');

    if ( $action eq 'register' ) {
        my $challenge = $self->crypter->registrationChallenge;
        return [ 200, [ 'Content-Type' => 'application/json' ], [$challenge] ];
    }
    if ( $action eq 'registration' ) {
        my $resp;
        unless ( $resp = $req->param('registration') ) {
            return $self->p->sendError( $req, 'Missing registration parameter',
                400 );
        }
        $self->logger->debug("Get registration data $resp");
        my ( $keyHandle, $userKey ) = $self->crypter->registrationVerify($resp);
        if ( $keyHandle and $userKey ) {
            $self->p->updatePersistentSession(
                $req,
                {
                    _u2fKeyHandle => $self->encode_base64url( $keyHandle, '' ),
                    _u2fUserKey   => $self->encode_base64url( $userKey,   '' )
                }
            );
            return [
                200, [ 'Content-Type' => 'application/json' ],
                ['{"result":1}']
            ];
        }
        my $err = Crypt::U2F::Server::Simple::lastError();
        $self->p->userError("U2F Registration failed: $err");
        return $self->p->sendError( $req, $err, 200 );
    }
    if ( $action eq 'verify' ) {
        my ( $err, $error ) = $self->loadUser($req);
        if ( $err == -1 ) {
            return $self->p->sendError( $req, "U2F error: $error", 200 );
        }
        elsif ( $err == 0 ) {
            return $self->p->sendError( $req, "noU2FKeyFound" );
        }
        my $challenge = $self->crypter->authenticationChallenge;
        return [ 200, [ 'Content-Type' => 'application/json' ], [$challenge] ];
    }
    if ( $action eq 'signature' ) {
        my $resp;
        unless ( $resp = $req->param('signature') ) {
            return $self->p->sendError( $req, 'Missing signature parameter',
                400 );
        }
        my ( $err, $error ) = $self->loadUser($req);
        if ( $err == -1 ) {
            return $self->p->sendError( $req, "U2F error: $error", 200 );
        }
        elsif ( $err == 0 ) {
            return $self->p->sendError( $req, "noU2FKeyFound" );
        }
        my $res = ( $self->crypter->authenticationVerify($resp) ? 1 : 0 );
        return [
            200, [ 'Content-Type' => 'application/json' ],
            [qq'{"result":$res}']
        ];
    }
}

sub loadUser {
    my ( $self, $req ) = @_;
    my $uid     = $req->userData->{ $self->conf->{whatToTrace} };
    my $session = $self->p->getPersistentSession($uid);
    my $kh      = $session->data->{_u2fKeyHandle};
    my $uk      = $session->data->{_u2fUserKey};
    unless ( $kh and $uk ) {
        return 0;
    }
    $self->crypter->{keyHandle} = $self->decode_base64url($kh);
    $self->crypter->{publicKey} = $self->decode_base64url($uk);
    unless ( $self->crypter->setKeyHandle and $self->crypter->setPublicKey ) {
        my $error = Crypt::U2F::Server::Simple::lastError();
        return ( -1, $error );
    }
    return 1;
}

1;
