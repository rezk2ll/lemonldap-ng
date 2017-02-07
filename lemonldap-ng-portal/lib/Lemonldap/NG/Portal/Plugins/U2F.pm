# U2F second factor authentication
#
# This plugin handle authentications to ask U2F second factor for users that
# have registered their U2F key
package Lemonldap::NG::Portal::Plugins::U2F;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_BADCREDENTIALS
  PE_ERROR
  PE_OK
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
        $ott->timeout( $_[0]->conf->{formTimeout} );
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

        # TODO: remove cookie and set token
        my $challenge = $self->crypter->authenticationChallenge;
        return $self->sendHtml( $req, 'u2fcheck',
            params => { CHALLENGE => $challenge } );
    }
    return PE_OK;
}

sub verify {
    my ( $self, $req ) = @_;

    # TODO: set sessionInfo with token
    if ( my $resp = $req->param('u2fSignature') ) {
        unless ( $self->loadUser($req) == 1 ) {
            return $self->p->do( $req, [ sub { PE_ERROR } ] );
        }
        if ( $self->crypter->authenticationVerify($resp) ) {

            # OK
            return [ 200, [ 'Content-Type', 'text/plain' ], ['OK'] ];
        }
        else {
            return $self->p->do( $req, [ sub { PE_BADCREDENTIALS } ] );
        }
    }
    else {
        $self->p->userNotice( 'No U2F response for user'
              . $req->sessionInfo->{ $self->conf->{whatToTrace} } );
        return $self->p->do( $req, [ sub { PE_BADCREDENTIALS } ] );
    }
}

sub loadUser {
    my ( $self, $req ) = @_;
    my ( $kh, $uk );
    if (    ( $kh = $req->sessionInfo->{_u2fKeyHandle} )
        and ( $uk = $req->sessionInfo->{_u2fUserKey} ) )
    {
        $self->crypter->{keyHandle} = $kh;
        $self->crypter->{publicKey} = $uk;
        unless ( $self->crypter->setKeyHandle and $self->crypter->setPublicKey )
        {
            $self->lmLog(
                'U2F error: ' . Crypt::U2F::Server::u2fclib_getError(),
                'error' );
            return -1;
        }
        return 1;
    }
    else {
        return 0;
    }
}

1;
