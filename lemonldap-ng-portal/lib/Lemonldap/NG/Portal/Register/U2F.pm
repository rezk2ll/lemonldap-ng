# Self U2F registration
package Lemonldap::NG::Portal::Register::U2F;

use strict;
use Mouse;
use MIME::Base64;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Lib::U2F';

# INITIALIZATION

sub init {
    my ($self) = @_;
    return 0 unless $self->SUPER::init;
    $self->addAuthRoute( u2fregister => 'run', [ 'GET', 'POST' ] );
    return 1;
}

# RUNNING METHODS

# Main method
sub run {
    my ( $self, $req ) = @_;

    # Check for registration response
    if ( my $response = $req->param('registration') ) {
        $self->lmLog( "Get registration data $response", 'debug' );
        my ( $keyHandle, $userKey ) =
          $self->crypter->registrationVerify($response);
        if ( $keyHandle and $userKey ) {
            $self->p->updatePersistentSession(
                $req,
                {
                    _u2fHandle => encode_base64( $keyHandle, '' ),
                    _u2fKey    => encode_base64( $userKey,   '' )
                }
            );
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
