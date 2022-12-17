# Self Password 2F registration
package Lemonldap::NG::Portal::2F::Register::Password;

use strict;
use Mouse;
use JSON qw(from_json to_json);
use Lemonldap::NG::Common::Crypto;

our $VERSION = '2.0.16';

extends 'Lemonldap::NG::Portal::2F::Register::Base';
with 'Lemonldap::NG::Portal::Lib::2fDevices';

# INITIALIZATION

has prefix   => ( is => 'rw', default => 'password' );
has template => ( is => 'ro', default => 'password2fregister' );
has welcome  => ( is => 'ro', default => 'PE71' );
has logo     => ( is => 'rw', default => 'password.png' );
has ott      => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        my $timeout = $_[0]->{conf}->{sfRegisterTimeout}
          // $_[0]->{conf}->{formTimeout};
        $ott->timeout($timeout);
        return $ott;
    }
);

has 'key' => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->conf->{password2fKey} || $self->conf->{key};
    }
);

has 'crypto' => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        Lemonldap::NG::Common::Crypto->new( $self->key );
    }
);

sub run {
    my ( $self, $req, $action ) = @_;
    my $user = $req->userData->{ $self->conf->{whatToTrace} };
    return $self->p->sendError( $req, 'PE82', 400 )
      unless $user;

    # Check if Password 2F can be updated
    my $msg = $self->canUpdateSfa( $req, $action );
    return $self->p->sendError( $req, $msg, 400 ) if $msg;

    # Verification that user has a valid password
    if ( $action eq 'verify' ) {

        # Check Password
        my $password       = $req->param('password');
        my $passwordverify = $req->param('passwordverify');

        unless ( $password and $passwordverify ) {
            $self->userLogger->info(
                'Password 2F registration: empty validation form');
            return $self->p->sendError( $req, 'missingPassword', 200 );
        }

        # Invalid try is returned with a 200 code. Javascript will read error
        # and propose to retry
        if ( $password ne $passwordverify ) {
            $self->userLogger->notice(
"Password 2F registration: password verification failed for $user"
            );
            return $self->p->sendError( $req, 'PE34', 200 );
        }
        $self->logger->debug('Password 2F verified');

        # Now password is verified, let's store it in persistent data
        my $secret = $self->crypto->encrypt($password);

        # Reading existing 2FDevices
        $self->logger->debug("Looking for 2F devices...");

        my @passwords_devices =
          $self->find2fDevicesByType( $req, $req->userData, $self->type );

        # Delete previous password if any
        if (@passwords_devices) {
            unless (
                $self->del2fDevices(
                    $req, $req->userData, \@passwords_devices
                )
              )
            {
                $self->logger->error("Unable to delete old password");
                return $self->p->sendError( $req, 'serverError', 500 );
            }
            else {
                $self->logger->debug("Old password deleted");
            }
        }

        # Add a new one
        if (
            $self->add2fDevice(
                $req,
                $req->userData,
                {
                    _secret => $secret,
                    name    => 'password',
                    type    => $self->type,
                    epoch   => time()
                }
            )
          )
        {
            $self->userLogger->notice(
                "Registration of password succeeds for $user");
            return [
                200,
                [
                    'Content-Type'   => 'application/json',
                    'Content-Length' => 12,
                ],
                ['{"result":1}']
            ];
        }
        else {
            $self->logger->debug("Unable to add password");
            return $self->p->sendError( $req, 'serverError', 500 );
        }
    }
    elsif ( $action eq 'delete' ) {

        # Check if unregistration is allowed
        return $self->p->sendError( $req, 'notAuthorized', 400 )
          unless $self->conf->{password2fUserCanRemoveKey};

        my $epoch = $req->param('epoch')
          or return $self->p->sendError( $req, '"epoch" parameter is missing',
            400 );

        if ( $self->del2fDevice( $req, $req->userData, $self->type, $epoch ) ) {
            $self->userLogger->notice("Password 2F deleted for $user");
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
    else {
        $self->logger->error("Unknown Password 2F action -> $action");
        return $self->p->sendError( $req, 'unknownAction', 400 );
    }
}

1;
