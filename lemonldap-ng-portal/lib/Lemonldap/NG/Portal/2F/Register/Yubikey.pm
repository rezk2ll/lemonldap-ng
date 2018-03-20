package Lemonldap::NG::Portal::2F::Register::Yubikey;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_FORMEMPTY
  PE_ERROR
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

has prefix => ( is => 'rw', default => 'yubikey' );

has template => ( is => 'ro', default => 'yubikey2fregister' );

has logo => ( is => 'rw', default => 'u2f.png' );

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
        my $otp = $req->param('otp');
        if ( $otp and length($otp) > 12 ) {
            my $keys = $req->userData->{_yubikeys} || '';
            $keys .= ( $keys ? ', ' : '' )
              . substr( $otp, 0, $self->conf->{yubikeyPublicIDSize} );
            $self->p->updatePersistentSession( $req, { _yubikeys => $keys } );
        }
        else {
            $self->userLogger->error('Yubikey 2F: no code');
            return PE_FORMEMPTY;
        }
    }
    else {
        $self->userLogger->error("Unknown Yubikey action $action");
        return PE_ERROR;
    }
}

1;
