# U2F second factor authentication
#
# This plugin handle authentications to ask U2F second factor for users that
# have registered their U2F key
package Lemonldap::NG::Portal::2F::U2F;

use 5.16.0;
use strict;
use Mouse;
use JSON qw(from_json to_json);
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

has logo => ( is => 'rw', default => 'u2f.png' );

sub init {
    my ($self) = @_;

    # If self registration is enabled and "activation" is simply set to
    # "enabled", replace the rule to detect if user has registered its key
    if (    $self->conf->{u2fSelfRegistration}
        and $self->conf->{u2fActivation} eq '1' )
    {
        $self->conf->{u2fActivation} = '$_2fDevices =~ /"type":\s*"U2F"/s';
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
        return PE_ERROR     if ( $res == -1 );
        return PE_U2FFAILED if ( $res == 0 );

        my $challenge = $req->datas->{crypter}->authenticationChallenge;
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
    if (    my $resp = $req->param('signature')
        and my $challenge = $req->param('challenge') )
    {
        unless ( $self->loadUser( $req, $session ) == 1 ) {
            $req->error(PE_ERROR);
            return $self->fail($req);
        }

        $self->logger->debug("Get challenge: $challenge");
        if ( not $req->datas->{crypter}->setChallenge($challenge) ) {
            $self->logger->error(
                $@ ? $@ : Crypt::U2F::Server::Simple::lastError() );
            $req->error(PE_ERROR);
            return $self->fail($req);
        }
        if ( $req->datas->{crypter}->authenticationVerify($resp) ) {
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
        $self->userLogger->notice( 'No valid U2F response for user'
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

    my $_2fDevices = eval {
        $self->logger->debug("Loading 2F Devices ...");

        # Read existing 2FDevices
        from_json( $session->{_2fDevices}, { allow_nonref => 1 } );
    };

    unless ($_2fDevices) {
        $self->logger->debug("No 2F Device found");

        # Set default value
        @$_2fDevices = [];
    }

    my @u2fs = ();
    foreach (@$_2fDevices) {
        $self->logger->debug("Reading U2F keys if exists ...");
        if ( $_->{type} eq 'U2F' ) {
            $self->logger->debug( "_userKey = " . $_->{_userKey} );
            $self->logger->debug( "_keyHandle = " . $_->{_keyHandle} );
            $_->{_userKey} = $self->decode_base64url( $_->{_userKey} );
            push @u2fs, $_;
        }
    }

    if (    ( $kh = $u2fs[0]{_keyHandle} )
        and ( $uk = $u2fs[0]{_userKey} ) )
    {
        $self->logger->debug("kh & uk -> OK");
        $req->datas->{crypter} = $self->crypter(
            keyHandle => $kh,
            publicKey => $uk
        );
        unless ( $req->datas->{crypter} ) {
            $self->logger->error(
                'U2F error: ' . Crypt::U2F::Server::u2fclib_getError() );
            return -1;
        }
        return 1;
    }
    else {
        $self->userLogger->info("U2F: user not registered");
        return 0;
    }
}

1;
