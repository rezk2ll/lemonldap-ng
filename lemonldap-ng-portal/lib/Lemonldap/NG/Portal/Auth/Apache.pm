package Lemonldap::NG::Portal::Auth::Apache;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_ERROR PE_OK);

our $VERSION = '0.1';

extends 'Lemonldap::NG::Portal::Auth::Base';

sub init {
    1;
}

sub extractFormInfo {
    my ( $self, $req ) = @_;
    unless ( $req->{user} = $req->{REMOTE_USER} ) {
        $self->lmLog( 'Apache is not configured to authenticate users!',
            'error' );
        return PE_ERROR;
    }

    # This is needed for Kerberos authentication
    $req->{user} =~ s/^(.*)@.*$/$1/g;
    PE_OK;
}

sub authenticate {
    PE_OK;
}

sub authForce {
    0;
}

sub authLogout {
    PE_OK;
}

sub getDisplayType {
    return 'logo';
}

1;
