# Self Yubikey registration
package Lemonldap::NG::Portal::2F::Register::Yubikey;

use strict;
use Mouse;
use JSON qw(from_json to_json);
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_FORMEMPTY
  PE_ERROR
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

has prefix => ( is => 'rw', default => 'yubikey' );

has template => ( is => 'ro', default => 'yubikey2fregister' );

has logo => ( is => 'rw', default => 'yubikey.png' );

sub init {
    my ($self) = @_;
    $self->conf->{yubikey2fPublicIDSize} ||= 12;
    return 1;
}

# RUNNING METHODS

# Main method
sub run {
    my ( $self, $req, $action ) = @_;
    if ( $action eq 'register' ) {
        my $otp     = $req->param('otp');
        my $UBKName = $req->param('UBKName');
        my $epoch   = time();

        # Set default name if empty
        $UBKName ||= $epoch;
        if ( $otp
            and length($otp) > $self->conf->{yubikey2fPublicIDSize} )
        {
            my $keys = $req->userData->{_yubikeys} || '';
            $keys .= ( $keys ? ', ' : '' )
              . substr( $otp, 0, $self->conf->{yubikey2fPublicIDSize} );

            my $key = substr( $otp, 0, $self->conf->{yubikey2fPublicIDSize} );
            my $_2FDevices = eval {
                $self->logger->debug("Looking for 2F Devices ...");
                from_json( $req->userData->{_2FDevices},
                    { allow_nonref => 1 } );
            };
            unless ($_2FDevices) {
                $self->logger->debug("No 2F Device found");
                $_2FDevices = [];
            }

            # Search if Yubikey has been already registered
            my $SameUBKFound = 0;
            foreach (@$_2FDevices) {
                $self->logger->debug("Reading Yubikeys ...");
                if ( $_->{_yubikey} eq $key ) {
                    $SameUBKFound = 1;
                    last;
                }
            }

            $self->logger->debug("Same 2F Device found ? $SameUBKFound");
            if ($SameUBKFound) {
                $self->userLogger->error("Yubikey already registered !");
                return $self->p->sendHtml(
                    $req, 'error',
                    params => {
                        RAW_ERROR       => 'yourKeyIsAlreadyRegistered',
                        AUTH_ERROR_TYPE => 'warning',
                    }
                );
            }

            # Check if user can register one more device
            my $size    = @$_2FDevices;
            my $maxSize = $self->conf->{max2FDevices};
            $self->logger->debug("Nbr 2FDevices = $size / $maxSize");
            if ( $size >= $maxSize ) {
                $self->userLogger->error(
                    "Max number of 2F devices is reached !!!");
                return $self->p->sendHtml(
                    $req, 'error',
                    params => {
                        RAW_ERROR       => 'maxNumberof2FDevicesReached',
                        AUTH_ERROR_TYPE => 'warning',
                    }
                );
            }

            push @{$_2FDevices},
              {
                type     => 'UBK',
                name     => $UBKName,
                _yubikey => $key,
                epoch    => $epoch
              };

            $self->logger->debug(
                "Append 2F Device : { type => 'UBK', name => $UBKName }");
            $self->p->updatePersistentSession( $req,
                { _2FDevices => to_json($_2FDevices) } );

            $self->p->updatePersistentSession( $req, { _yubikeys => $keys } );
            return $self->p->sendHtml(
                $req, 'error',
                params => {
                    RAW_ERROR       => 'yourKeyIsRegistered',
                    AUTH_ERROR_TYPE => 'positive',
                }
            );
        }
        else {
            $self->userLogger->error('Yubikey 2F: no code or name');
            return $self->p->sendHtml(
                $req, 'error',
                params => {
                    AUTH_ERROR      => PE_FORMEMPTY,
                    AUTH_ERROR_TYPE => 'positive',
                }
            );
        }
    }

    # Check if unregistration is allowed
    unless ( $self->conf->{yubikey2fUserCanRemoveKey} ) {
        return $self->p->sendError( $req, 'notAuthorized', 400 );
    }

    if ( $action eq 'delete' ) {
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
            "Delete 2F Device : { type => 'UBK', epoch => $epoch }");
        $self->p->updatePersistentSession( $req,
            { _2FDevices => to_json( \@keep ) } );

        $self->userLogger->notice('Yubikey deletion succeed');
        return [
            200,
            [ 'Content-Type' => 'application/json', 'Content-Length' => 12, ],
            ['{"result":1}']
        ];

    }
    else {
        $self->userLogger->error("Unknown Yubikey action $action");
        return $self->p->sendHtml(
            $req, 'error',
            params => {
                AUTH_ERROR      => PE_ERROR,
                AUTH_ERROR_TYPE => 'positive',
            }
        );
    }
}

1;
