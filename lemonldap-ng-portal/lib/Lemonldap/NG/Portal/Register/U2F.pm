package Lemonldap::NG::Portal::Register::U2F;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

has crypter => ( is => 'rw' );

has origin => (
    is      => 'rw',
    default => sub {
        my $p = $_[0]->{conf}->{portal};
        $p =~ s#^(https?://[^/]+).*$#$1#;
        return $p;
    }
);

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
                appId  => $self->origin,
                origin => $self->origin,
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
    if ( my $response = $req->param('registration') ) {
        $self->lmLog( "Get registration data $response", 'debug' );
        my ( $keyHandle, $userKey ) =
          $self->crypter->registrationVerify($response);
        if ( $keyHandle and $userKey ) {
            $self->p->updatePersistentSession( $req,
                { _u2fHandle => $keyHandle, _u2fKey => $userKey } );
            return $self->p->sendHtml( $req, 'u2fregister',
                params => { SUCCESS => 1 } );
        }
        $self->p->userError( 'U2F Registration failed: '
              . Crypt::U2F::Server::Simple::lastError() );
        return $self->p->sendHtml( $req, 'u2fregister',
            params => { FAILED => 1 } );
    }
    my $challenge = $self->crypter->registrationChallenge;
    return $self->p->sendHtml( $req, 'u2fregister',
        params => { CHALLENGE => $challenge, APPID => $self->origin } );
}

1;
