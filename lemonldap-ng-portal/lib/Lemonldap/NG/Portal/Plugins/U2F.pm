# U2F second factor authentication
#
# This plugin handle authentications to ask U2F second factor for users that
# have registered their U2F key
package Lemonldap::NG::Portal::Plugins::U2F;

use 5.16.0;
use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_ERROR
  PE_NOTOKEN
  PE_OK
  PE_SENDRESPONSE
  PE_TOKENEXPIRED
  PE_U2FFAILED
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Lib::U2F';

# INTERFACE

sub afterDatas { 'run' }

# INITIALIZATION

has ott => (
    is      => 'rw',
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->{conf}->{formTimeout} );
        return $ott;
    }
);

sub init {
    my ($self) = @_;
    $self->addUnauthRoute( u2fcheck => 'verify', ['POST'] );
    return 0 unless $self->SUPER::init;
    1;
}

# RUNNING METHODS

# Main method
sub run {
    my ( $self, $req ) = @_;
    my ( $kh, $uk );

    # Check if user is registered
    if ( my $res = $self->loadUser($req) ) {
        return PE_ERROR if ( $res == -1 );

        $req->sessionInfo->{_u2fRealSession} = $req->id;
        my $token = $self->ott->createToken( $req->sessionInfo );
        $req->id(0);
        $self->p->rebuildCookies($req);

        my $challenge = $self->crypter->authenticationChallenge;
        my $tmp       = $self->p->sendHtml(
            $req,
            'u2fcheck',
            params => {
                SKIN      => $self->conf->{portalSkin},
                CHALLENGE => $challenge,
                TOKEN     => $token
            }
        );
        $self->logger->debug( 'Prepare U2F verification for '
              . $req->sessionInfo->{ $self->conf->{whatToTrace} } );

        $req->response($tmp);
        delete $req->{authResult};
        return PE_SENDRESPONSE;
    }
    return PE_OK;
}

sub verify {
    my ( $self, $req ) = @_;

    # TODO: set sessionInfo with token
    my $token;
    unless ( $token = $req->param('token') ) {
        $self->userLogger->error('U2F access without token');
        $req->error(PE_NOTOKEN);
        return $self->fail($req);
    }
    unless ( $req->sessionInfo( $self->ott->getToken($token) ) ) {
        $self->userLogger->info('Token expired');
        $req->error(PE_TOKENEXPIRED);
        return $self->fail($req);
    }
    if ( my $resp = $req->param('signature') ) {
        unless ( $self->loadUser($req) == 1 ) {
            $req->error(PE_ERROR);
            return $self->fail($req);
        }
        if ( $self->crypter->authenticationVerify($resp) ) {
            $req->id( delete $req->sessionInfo->{_u2fRealSession} );
            $self->p->rebuildCookies($req);
            $req->mustRedirect(1);
            $self->userLogger->notice( 'U2F signature verified for '
                  . $req->sessionInfo->{ $self->conf->{whatToTrace} } );
            if ( my $l = $self->conf->{u2fAuthnLevel} ) {
                $self->p->updateSession( $req, { authenticationLevel => $l } );
            }
            return $self->p->do( $req, [ sub { PE_OK } ] );
        }
        else {
            $self->userLogger->notice( 'Invalid U2F signature for '
                  . $req->sessionInfo->{ $self->conf->{whatToTrace} } . ' ('
                  . Crypt::U2F::Server::u2fclib_getError()
                  . ')' );
            $req->error(PE_U2FFAILED);
            $req->authResult(PE_U2FFAILED);
            return $self->fail($req);
        }
    }
    else {
        $self->userLogger->notice( 'No U2F response for user'
              . $req->sessionInfo->{ $self->conf->{whatToTrace} } );
        $req->authResult(PE_U2FFAILED);
        return $self->fail($req);
    }
}

sub fail {
    my ( $self, $req ) = @_;
    return $self->p->sendHtml(
        $req,
        'u2fcheck',
        params => {
            AUTH_ERROR      => $req->error,
            AUTH_ERROR_TYPE => $req->error_type,
            SKIN            => $self->conf->{portalSkin},
            FAILED          => 1
        }
    );
}

sub loadUser {
    my ( $self, $req ) = @_;
    my ( $kh, $uk );
    if (    ( $kh = $req->sessionInfo->{_u2fKeyHandle} )
        and ( $uk = $req->sessionInfo->{_u2fUserKey} ) )
    {
        $self->crypter->{keyHandle} = $self->decode_base64url($kh);
        $self->crypter->{publicKey} = $self->decode_base64url($uk);
        unless ($self->crypter->setKeyHandle
            and $self->crypter->setPublicKey )
        {
            $self->logger->error(
                'U2F error: ' . Crypt::U2F::Server::u2fclib_getError() );
            return -1;
        }
        return 1;
    }
    else {
        return 0;
    }
}

1;
