package Lemonldap::NG::Portal::Auth::Null;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base';

sub init {
    1;
}

sub extractFormInfo {
    my ( $self, $req ) = @_;
    $req->user('anonymous');
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

sub getDisplayType {
    return '';
}

1;
