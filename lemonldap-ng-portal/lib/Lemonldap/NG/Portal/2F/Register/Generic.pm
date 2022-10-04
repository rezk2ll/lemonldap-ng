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

# The verification module that we'll use
has verificationModule => (
    is  => 'rw',
    isa => 'Lemonldap::NG::Portal::Lib::Code2F',
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

    # Check if SelfRegisteredMail can be updated
    my $msg = $self->canUpdateSfa( $req, $action );
    return $self->p->sendError( $req, $msg, 400 ) if $msg;

    # Send a code to generic
    if ( $action eq 'sendcode' ) {

        # Check SelfRegisteredMail
        my $generic       = $req->param('generic');

        unless ( $generic ) {
            $self->userLogger->info(
'[SelfRegisteredMail 2F] SelfRegisteredMail registration: empty validation form'
            );
            return $self->p->sendError( $req, 'PE79',
                200 );
        }

        # Generate and send code

        my $token = $self->ott->createToken;
        my $code  = $self->random->randregex( $self->conf->{mail2fCodeRegex} );
        $self->logger->debug("Generated two-factor code: $code");
        $self->ott->updateToken( $token, __mail2fcode => $code );

        # Build mail content
        my $tr      = $self->translate($req);
        my $subject = $self->conf->{mail2fSubject};

        unless ($subject) {
            $subject = 'mail2fSubject';
            $tr->( \$subject );
        }
        my ( $body, $html );
        if ( $self->conf->{mail2fBody} ) {

            # We use a specific text message, no html
            $body = $self->conf->{mail2fBody};

            # Replace variables in body
            $body =~ s/\$code/$code/g;
            $body =~ s/\$(\w+)/$req->{sessionInfo}->{$1} || ''/ge;

        }
        else {

            # Use HTML template
            $body = $self->loadMailTemplate(
                $req,
                'mail_2fcode',
                filter => $tr,
                params => {
                    code => $code,
                },
            );
            $html = 1;
        }

        # Send mail
        unless ( $self->send_mail( $generic, $subject, $body, $html ) ) {
            $self->logger->error(
                'Unable to send 2F code mail to ' . $generic );
            return $self->p->sendError( $req, 'mailNotSent', 200 );
        }

        # Send response
        $self->userLogger->notice(
"[SelfRegisteredMail 2F] Send verification code to $generic for $user"
        );
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

        # Check SelfRegisteredMail
        my $generic     = $req->param('generic');
        my $genericname = $req->param('genericname') || "MyDevice";
        my $genericcode = $req->param('genericcode');
        my $tokenid     = $req->param("token");
        my $epoch       = time();

        # Verify code
        my $token = $self->ott->getToken( $tokenid, 1 );
        my $code  = $token->{__mail2fcode};

        unless ($code) {
            $self->logger->error(
                "[SelfRegisteredMail 2F] No token or code found");
            return $self->p->sendError( $req, 'serverError', 500 );
        }

        unless ( $code eq $genericcode ) {
            $self->logger->error("[SelfRegisteredMail 2F] Code mismatch");
            return $self->p->sendError( $req, 'badCode', 200 );
        }

        # Remove token
        $self->ott->getToken($tokenid);

        unless ( $res == PE_OK ) {
            return $self->p->sendError( $req, "PE$res", 400 );
        }

        # Now generic is verified, let's store it in persistent data

        # Reading existing 2FDevices
        $self->logger->debug(
            "[SelfRegisteredMail 2F] Looking for 2F Devices...");

        my @generics_devices =
          $self->find2fDevicesByType( $req, $req->userData,
            "SelfRegisteredMail" );

        # Delete previous generic if any
        if (@generics_devices) {
            unless (
                $self->del2fDevices( $req, $req->userData, \@generics_devices )
              )
            {
                $self->logger->error(
                    "[SelfRegisteredMail 2F] Unable to delete old generic");
                return $self->p->sendError( $req, 'serverError', 500 );
            }
            else {
                $self->logger->debug(
                    "[SelfRegisteredMail 2F] Old generic deleted");
            }
        }

        # Add a new one
        if (
            $self->add2fDevice(
                $req,
                $req->userData,
                {
                    "name"     => "$genericname",
                    "type"     => "SelfRegisteredMail",
                    "epoch"    => "$epoch",
                    "_generic" => "$generic"
                }
            )
          )
        {
            $self->userLogger->notice(
"[SelfRegisteredMail 2F] Registration of generic $genericname succeeds for $user"
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
        else {
            $self->logger->debug(
                "[SelfRegisteredMail 2F] Unable to add generic");
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

        if (
            $self->del2fDevice(
                $req, $req->userData, "SelfRegisteredMail", $epoch
            )
          )
        {
            $self->userLogger->notice(
                "[SelfRegisteredMail 2F] SelfRegisteredMail deleted for $user");
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
        $self->logger->error(
"[SelfRegisteredMail 2F] Unknown SelfRegisteredMail action -> $action"
        );
        return $self->p->sendError( $req, 'unknownAction', 400 );
    }
}

1;

