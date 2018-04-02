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
        if (    $UBKName
            and $otp
            and length($otp) > $self->conf->{yubikey2fPublicIDSize} )
        {
            my $keys = $req->userData->{_yubikeys} || '';
            $keys .= ( $keys ? ', ' : '' )
              . substr( $otp, 0, $self->conf->{yubikey2fPublicIDSize} );

            my $key = substr( $otp, 0, $self->conf->{yubikey2fPublicIDSize} );
            my $list2FDevices = eval {
                $self->logger->debug("Looking for 2F Devices ...");
                from_json( $req->userData->{list2FDevices},
                    { allow_nonref => 1 } );
            };
            unless ($list2FDevices) {
                $self->logger->debug("No 2F Device found");
                $list2FDevices = [];
            }
            push @{$list2FDevices},
              {
                type     => 'UBK',
                name     => $UBKName,
                _yubikey => $key,
                epoch    => time()
              };
            $self->logger->debug(
                "Append 2F Device : { type => 'UBK', name => $UBKName }");
            $self->p->updatePersistentSession( $req,
                { list2FDevices => to_json($list2FDevices) } );

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

    elsif ( $action eq 'delete' ) {
        my $epoch = $req->param('epoch');

        my $list2FDevices = eval {
            $self->logger->debug("Loading 2F Devices ...");

            # Read existing 2FDevices
            from_json( $req->userData->{list2FDevices}, { allow_nonref => 1 } );
        };

        my @keep = ();
        while (@$list2FDevices) {
            my $element = shift @$list2FDevices;
            $self->logger->debug("Looking for 2F Device to delete ...");
            push @keep, $element unless ( $element->{epoch} eq $epoch );
        }

        $self->logger->debug(
            "Delete 2F Device : { type => 'UBK', epoch => $epoch }");
        $self->p->updatePersistentSession( $req,
            { list2FDevices => to_json( \@keep ) } );

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
