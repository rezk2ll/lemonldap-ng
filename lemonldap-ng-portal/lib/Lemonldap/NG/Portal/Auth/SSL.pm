package Lemonldap::NG::Portal::Auth::SSL;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants
  qw(PE_OK PE_BADCERTIFICATE PE_CERTIFICATEREQUIRED);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base';

# PROPERTIES

has SSLField => ( is => 'rw' );

# INITIALIZATION

sub init {
    my ($self) = @_;
    $self->SSLField( $self->conf->{SSLVar} ||= 'SSL_CLIENT_S_DN_Email' );
    return 1;
}

# Read username in SSL environment variables, or return an error
# @return Lemonldap::NG::Portal constant
sub extractFormInfo {
    my ( $self, $req ) = @_;
    return PE_OK
      if ( $req->user( $req->env->{ $self->SSLField } ) );
    if ( $req->{SSL_CLIENT_S_DN} ) {
        $self->p->userError(
            "$self->SSLField was not found in user certificate");
        return PE_BADCERTIFICATE;
    }
    else {
        $self->p->userError('No certificate found');
        return PE_CERTIFICATEREQUIRED;
    }
}

sub authenticate {
    PE_OK;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    $req->{sessionInfo}->{authenticationLevel} = $self->conf->{SSLAuthnLevel};
    PE_OK;
}

sub getDisplayType {
    return "logo";
}

1;
