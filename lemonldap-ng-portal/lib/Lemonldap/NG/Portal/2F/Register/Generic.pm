# A generic 2FA module which registers a simple value into the psession
# This is meant to be used with sfExtra
package Lemonldap::NG::Portal::2F::Register::Generic;

use strict;
use Mouse;
use JSON qw(from_json to_json);
use Lemonldap::NG::Common::Crypto;
use Lemonldap::NG::Portal::Main::Constants 'PE_OK';

our $VERSION = '2.0.15';

extends qw(
  Lemonldap::NG::Portal::2F::Register::Base
);

with 'Lemonldap::NG::Portal::Lib::2fDevices';

# INITIALIZATION

has ott => (
    is      => 'ro',
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

# The verification module that we'll use
has verificationModule => (
    is       => 'rw',
    isa      => 'Lemonldap::NG::Portal::Lib::Code2F',
    weak_ref => 1,
);

# Overriden by sfExtra
has prefix   => ( is => 'rw', default => 'generic' );
has template => ( is => 'ro', default => 'generic2fregister' );
has welcome  => ( is => 'ro', default => 'generic2fwelcome' );
has logo     => ( is => 'rw', default => 'generic.png' );

sub run {
    my ( $self, $req, $action ) = @_;
    my $user = $req->userData->{ $self->conf->{whatToTrace} };
    return $self->p->sendError( $req, 'PE82', 400 )
      unless $user;

    # Check if device can be updated
    my $msg = $self->canUpdateSfa( $req, $action );
    return $self->p->sendError( $req, $msg, 400 ) if $msg;

    # Send a code to generic
    if ( $action eq 'sendcode' ) {

        my $generic = $req->param('generic');

        unless ($generic) {
            $self->userLogger->info(
                'Generic2F registration: empty validation form');
            return $self->p->sendError( $req, 'PE79', 200 );
        }

        # Generate and send code

        # Save current session info into a token
        my $sessionInfo = { %{ $req->userData } };

        # inject candidate value
        $sessionInfo->{destination} = $generic;

        my $token = $self->ott->createToken($sessionInfo);

        my $result =
          $self->verificationModule->challenge( $req, $sessionInfo, $token );

        return $self->p->sendError( $req, 'serverError', 500 ) unless $result;

        # Send response
        $self->userLogger->notice(
            "Send verification code to $generic for $user");
        my $json_response = "{\"result\":1,\"token\":\"$token\"}";
        return [
            200,
            [
                'Content-Type'   => 'application/json',
                'Content-Length' => length($json_response),
            ],
            [$json_response]
        ];
    }

    # Verification that user has a valid generic
    if ( $action eq 'verify' ) {

        my $generic     = $req->param('generic');
        my $genericname = $req->param('genericname') || "MyDevice";
        my $genericcode = $req->param('genericcode');
        my $tokenid     = $req->param("token");
        my $epoch       = time();

        # Verify code
        my $token = $self->ott->getToken( $tokenid, 1 );

        my $res = $self->verificationModule->verify_supplied_code( $req, $token,
            $genericcode );

        unless ( $res == PE_OK ) {
            return $self->p->sendError( $req, "PE$res", 400 );
        }

        # Now generic is verified, let's store it in persistent data

        # Reading existing 2FDevices
        $self->logger->debug("Looking for 2F Devices...");

        my @generics_devices =
          $self->find2fDevicesByType( $req, $req->userData, $self->prefix );

        # Delete previous generic if any
        if (@generics_devices) {
            unless (
                $self->del2fDevices( $req, $req->userData, \@generics_devices )
              )
            {
                $self->logger->error("Unable to delete old generic");
                return $self->p->sendError( $req, 'serverError', 500 );
            }
            else {
                $self->logger->debug("Old generic deleted");
            }
        }

        # Add a new one
        if (
            $self->add2fDevice(
                $req,
                $req->userData,
                {
                    "name"     => "$genericname",
                    "type"     => $self->prefix,
                    "epoch"    => "$epoch",
                    "_generic" => "$generic"
                }
            )
          )
        {
            $self->userLogger->notice(
                "Registration of generic $genericname succeeds for $user");
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
            $self->logger->debug("Unable to add generic");
            return $self->p->sendError( $req, 'serverError', 500 );
        }
    }
    elsif ( $action eq 'delete' ) {

        # Check if unregistration is allowed
        return $self->p->sendError( $req, 'notAuthorized', 400 )
          unless $self->userCanRemove;

        my $epoch = $req->param('epoch')
          or return $self->p->sendError( $req, '"epoch" parameter is missing',
            400 );

        if ( $self->del2fDevice( $req, $req->userData, $self->prefix, $epoch ) )
        {
            $self->userLogger->notice("Generic2F deleted for $user");
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
        $self->logger->error("Unknown action -> $action");
        return $self->p->sendError( $req, 'unknownAction', 400 );
    }
}

1;

