package Lemonldap::NG::Portal::Auth::DBI;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::_WebForm',
  'Lemonldap::NG::Portal::Lib::DBI';

sub init {
    my ($self) = @_;
    return $self->dbh;
}

sub authenticate {
    my ( $self, $req ) = @_;
    return $self->check_password($req) ? PE_OK : PE_BADCREDENTIALS;
}

sub authLogout {
    PE_OK;
}

sub authForce {
    PE_OK;
}

1;
