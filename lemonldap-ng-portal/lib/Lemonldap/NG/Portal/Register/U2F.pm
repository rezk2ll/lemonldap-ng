package Lemonldap::NG::Portal::Register::U2F;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

has crypter => ( is => 'rw' );

sub init {
    my ($self) = @_;
    eval 'use Crypt::U2F::Server::Simple';
    if ($@) {
        $self->error("Can't load U2F library: $@");
        return 0;
    }
    unless (
        $self->crypter(
            Crypt::U2F::Server::Simple->new(
                appId  => $self->conf->{u2fAppId},
                origin => $self->conf->{portal},
            )
        )
      )
    {
        $self->error( Crypt::U2F::Server::Simple::lastError() );
        return 0;
    }
    $self->addAuthRoute( u2fregister => 'run', [ 'GET', 'POST' ] );
    return 1;
}

sub run {
    my ( $self, $req ) = @_;

    # Check for registration response
    if ( my $rd = $req->param('registration') ) {
        $self->lmLog( "Get registration data $rd", 'debug' );
        my ( $keyHandle, $userKey ) = $self->crypter->registrationVerify($rd);
        if ( $keyHandle and $userKey ) {
            $self->lmLog( "Handle: $keyHandle, Key: $userKey", 'debug' );
            $self->p->updatePersistentSession( $req,
                { _u2fHandle => $keyHandle, _u2fKey => $userKey } );
            return $self->p->sendHtml( $req, 'u2fregister',
                params => { SUCCESS => 1 } );
        }
        else {
            $self->lmLog(
                'U2F Registration failed: '
                  . Crypt::U2F::Server::Simple::lastError(),
                'notice'
            );
            return $self->p->sendHtml( $req, 'u2fregister',
                params => { FAILED => 1 } );
        }
    }
    my $challenge = $self->crypter->registrationChallenge;
    return $self->p->sendHtml( $req, 'u2fregister',
        params =>
          { CHALLENGE => $challenge, APPID => $self->conf->{u2fAppId} } );
}

1;
