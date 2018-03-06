# U2F second factor authentication
#
# This plugin handle authentications to ask U2F second factor for users that
# have registered their U2F key
package Lemonldap::NG::Portal::2F::U2F;

use 5.16.0;
use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_ERROR
  PE_OK
  PE_SENDRESPONSE
  PE_U2FFAILED
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::SecondFactor',
  'Lemonldap::NG::Portal::Lib::U2F';

# INITIALIZATION

has rule => ( is => 'rw' );

has prefix => ( is => 'ro', default => 'u' );

sub init {
    my ($self) = @_;

    # If self registration is enabled and "activation" is simply set to
    # "enabled", replace the rule to detect if user has register its key
    if (    $self->conf->{u2fSelfRegistration}
        and $self->conf->{u2fActivation} eq '1' )
    {
        $self->conf->{u2fActivation} = '$_u2fKeyHandle and $_u2fUserKey';
    }
    return 0
      unless ( $self->Lemonldap::NG::Portal::Main::SecondFactor::init()
        and $self->Lemonldap::NG::Portal::Lib::U2F::init() );
    1;
}

# RUNNING METHODS

# Main method
sub run {
    my ( $self, $req, $token ) = @_;

    my ( $kh, $uk );

    # Check if user is registered
    if ( my $res = $self->loadUser( $req, $req->sessionInfo ) ) {
        return PE_ERROR if ( $res == -1 );

        my $challenge = $req->data->{crypter}->authenticationChallenge;
        my $tmp       = $self->p->sendHtml(
            $req,
            'u2fcheck',
            params => {
                SKIN      => $self->conf->{portalSkin},
                CHALLENGE => $challenge,
                TOKEN     => $token
            }
        );
        $self->logger->debug("Prepare U2F verification");

        $req->response($tmp);
        return PE_SENDRESPONSE;
    }
    return PE_U2FFAILED;
}

sub verify {
    my ( $self, $req, $session ) = @_;

    # Check U2F signature
    if ( my $resp = $req->param('signature') ) {
        unless ( $self->loadUser( $req, $session ) == 1 ) {
            $req->error(PE_ERROR);
            return $self->fail($req);
        }
        if ( $req->data->{crypter}->authenticationVerify($resp) ) {
            $self->userLogger->info('U2F signature verified');
            return PE_OK;
        }
        else {
            $self->userLogger->notice( 'Invalid U2F signature for '
                  . $session->{ $self->conf->{whatToTrace} } . ' ('
                  . Crypt::U2F::Server::u2fclib_getError()
                  . ')' );
            $req->error(PE_U2FFAILED);
            $req->authResult(PE_U2FFAILED);
            return $self->fail($req);
        }
    }
    else {
        $self->userLogger->notice( 'No U2F response for user'
              . $session->{ $self->conf->{whatToTrace} } );
        $req->authResult(PE_U2FFAILED);
        return $self->fail($req);
    }
}

sub fail {
    my ( $self, $req ) = @_;
    $req->response(
        $self->p->sendHtml(
            $req,
            'u2fcheck',
            params => {
                AUTH_ERROR      => $req->error,
                AUTH_ERROR_TYPE => $req->error_type,
                SKIN            => $self->conf->{portalSkin},
                FAILED          => 1
            }
        )
    );
    return PE_SENDRESPONSE;
}

sub loadUser {
    my ( $self, $req, $session ) = @_;
    my ( $kh, $uk );
    if (    ( $kh = $session->{_u2fKeyHandle} )
        and ( $uk = $session->{_u2fUserKey} ) )
    {
        $req->data->{crypter} = $self->crypter(
            keyHandle => $self->decode_base64url($kh),
            publicKey => $self->decode_base64url($uk)
        );
        unless ( $req->data->{crypter} ) {
            $self->logger->error(
                'U2F error: ' . Crypt::U2F::Server::u2fclib_getError() );
            return -1;
        }
        return 1;
    }
    else {
        $self->userLogger->warn("U2F: user not registered");
        return 0;
    }
}

1;
