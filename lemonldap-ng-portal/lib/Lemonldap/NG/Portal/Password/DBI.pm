package Lemonldap::NG::Portal::Password::DBI;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR);

extends 'Lemonldap::NG::Portal::Password::Base',
  'Lemonldap::NG::Portal::Lib::DBI';

our $VERSION = '2.0.0';

sub init {
    my ($self) = @_;
    return $self->dbh;
}

sub confirm {
    my ( $self, $req, $pwd ) = @_;
    return $self->check_password( $req->user, $pwd );
}

sub modifyPassword {
    my ( $self, $req ) = @_;
    return $self->modify_password( $req->user, $pwd ) ? PE_OK : PE_ERROR;
}

1;
