# Self U2F registration
package Lemonldap::NG::Portal::2F::Register::U2F;

use strict;
use Mouse;
use JSON qw(from_json to_json);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Lib::U2F';

# INITIALIZATION

has prefix => ( is => 'rw', default => 'u' );

has template => ( is => 'ro', default => 'u2fregister' );

has logo => ( is => 'rw', default => 'u2f.png' );

sub init {
    my ($self) = @_;
    return 0 unless $self->SUPER::init;
    return 1;
}

# RUNNING METHODS

# Main method
sub run {
    my ( $self, $req, $action ) = @_;

    if ( $action eq 'register' ) {
        my $challenge = $self->crypter->registrationChallenge;
        $self->logger->debug("Register challenge: $challenge");
        return [
            200,
            [
                'Content-Type'   => 'application/json',
                'Content-Length' => length($challenge),
            ],
            [$challenge]
        ];
        return [ 200, [ 'Content-Type' => 'application/json' ], [$challenge] ];
    }
    if ( $action eq 'registration' ) {
        my ( $resp, $challenge );
        $self->logger->debug('Registration response');
        unless ($resp = $req->param('registration')
            and $challenge = $req->param('challenge') )
        {
            return $self->p->sendError( $req, 'Missing registration parameter',
                400 );
        }
        $self->logger->debug("Get registration data $resp");
        $self->logger->debug("Get challenge $challenge");
        eval { $challenge = from_json($challenge)->{challenge} };
        if ($@) {
            $self->userLogger->error("Bad challenge: $@");
            return $self->p->sendError( $req, 'Bad challenge', 400 );
        }
        my $c = $self->crypter;
        if ( $c->setChallenge($challenge) ) {
            my ( $keyHandle, $userKey ) = $c->registrationVerify($resp);
            if ( $keyHandle and $userKey ) {

                my $_2FDevices = eval {
                    $self->logger->debug("Looking for 2F Devices ...");

                    # Read existing 2FDevices
                    from_json( $req->userData->{_2FDevices},
                        { allow_nonref => 1 } );
                };
                unless ($_2FDevices) {
                    $self->logger->debug("No 2F Device found");

                    # Set default value
                    $_2FDevices = [];
                }
                my $keyName = $req->param('keyName');
                my $epoch   = time();

                # Set default name if empty
                $keyName ||= $epoch;
                $self->logger->debug("Key name : $keyName");

                push @{$_2FDevices},
                  {
                    type       => 'U2F',
                    name       => $keyName,
                    _userKey   => $self->encode_base64url( $userKey, '' ),
                    _keyHandle => $keyHandle,
                    epoch      => $epoch
                  };
                $self->logger->debug(
                    "Append 2F Device : { type => 'U2F', name => $keyName }");
                $self->p->updatePersistentSession( $req,
                    { _2FDevices => to_json($_2FDevices) } );

                $self->p->updatePersistentSession(
                    $req,
                    {
                        _u2fKeyHandle =>
                          $self->encode_base64url( $keyHandle, '' ),
                        _u2fUserKey => $self->encode_base64url( $userKey, '' )
                    }
                );
                return [
                    200,
                    [
                        'Content-Type'   => 'application/json',
                        'Content-Length' => 12,
                    ],
                    ['{"result":1}']
                ];
            }
        }
        my $err = Crypt::U2F::Server::Simple::lastError();
        $self->userLogger->warn("U2F Registration failed: $err");
        return $self->p->sendError( $req, $err, 200 );
    }

    elsif ( $action eq 'verify' ) {
        $self->logger->debug('Verification challenge req');
        my ( $err, $error ) = $self->loadUser($req);
        if ( $err == -1 ) {
            return $self->p->sendError( $req, "U2F error: $error", 200 );
        }
        elsif ( $err == 0 ) {
            return $self->p->sendError( $req, "noU2FKeyFound" );
        }
        my $challenge = $req->datas->{crypter}->authenticationChallenge;
        return [
            200,
            [
                'Content-Type'   => 'application/json',
                'Content-Length' => length($challenge),
            ],
            [$challenge]
        ];
    }
    elsif ( $action eq 'signature' ) {
        $self->logger->debug('Verification response');
        my ( $challenge, $resp );
        unless ($challenge = $req->param('challenge')
            and $resp = $req->param('signature') )
        {
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
        $self->logger->debug("Get verify response $resp");
        $req->datas->{crypter}->setChallenge($challenge);
        my $res =
          ( $req->datas->{crypter}->authenticationVerify($resp) ? 1 : 0 );
        return [
            200,
            [ 'Content-Type' => 'application/json', 'Content-Length' => 12, ],
            [qq'{"result":$res}']
        ];
    }

    # Check if unregistration is allowed
    unless ( $self->conf->{u2fUserCanRemoveKey} ) {
        return $self->p->sendError( $req, 'notAuthorized', 200 );
    }

    if ( $action eq 'unregister' ) {
        my $challenge = $self->crypter->registrationChallenge;
        return [
            200,
            [
                'Content-Type'   => 'application/json',
                'Content-Length' => length($challenge),
            ],
            [$challenge]
        ];
    }
    elsif ( $action eq 'unregistration' ) {
        $self->p->updatePersistentSession(
            $req,
            {
                _u2fKeyHandle => '',
                _u2fUserKey   => ''
            }
        );
        $self->userLogger->notice('U2F key unregistration succeed');
        return [
            200,
            [ 'Content-Type' => 'application/json', 'Content-Length' => 12, ],
            ['{"result":1}']
        ];
        my $err = Crypt::U2F::Server::Simple::lastError();
        $self->userLogger->warn("U2F Unregistration failed: $err");
        return $self->p->sendError( $req, $err, 200 );
    }
    elsif ( $action eq 'delete' ) {
        my $epoch      = $req->param('epoch');
        my $_2FDevices = eval {
            $self->logger->debug("Loading 2F Devices ...");

            # Read existing 2FDevices
            from_json( $req->userData->{_2FDevices}, { allow_nonref => 1 } );
        };

        my @keep = ();
        while (@$_2FDevices) {
            my $element = shift @$_2FDevices;
            $self->logger->debug("Looking for 2F device to delete ...");
            push @keep, $element unless ( $element->{epoch} eq $epoch );
        }

        $self->logger->debug(
            "Delete 2F Device : { type => 'U2F', epoch => $epoch }");
        $self->p->updatePersistentSession( $req,
            { _2FDevices => to_json( \@keep ) } );

        $self->p->updatePersistentSession(
            $req,
            {
                _u2fKeyHandle => '',
                _u2fUserKey   => ''
            }
        );
        $self->userLogger->notice('U2F key unregistration succeed');
        return [
            200,
            [ 'Content-Type' => 'application/json', 'Content-Length' => 12, ],
            ['{"result":1}']
        ];
        my $err = Crypt::U2F::Server::Simple::lastError();
        $self->userLogger->warn("U2F Unregistration failed: $err");
        return $self->p->sendError( $req, $err, 200 );
    }
    $self->logger->error("Unknown action $action");
    return $self->p->sendError( $req, 'notAuthorized', 200 );
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
    $req->datas->{crypter} = $self->crypter(
        keyHandle => $self->decode_base64url($kh),
        publicKey => $self->decode_base64url($uk)
    );
    unless ( $req->datas->{crypter} ) {
        my $error = Crypt::U2F::Server::Simple::lastError();
        return ( -1, $error );
    }
    return 1;
}

1;
