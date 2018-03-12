package Lemonldap::NG::Portal::Password::Choice;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_ERROR);

extends 'Lemonldap::NG::Portal::Password::Base',
  'Lemonldap::NG::Portal::Lib::Choice';

our $VERSION = '2.0.0';

sub init {
    my ($self) = @_;
    return (  $self->Lemonldap::NG::Portal::Password::Base::init()
          and $self->Lemonldap::NG::Portal::Lib::Choice::init(2) );
}

sub confirm {
    my ( $self, $req, $pwd ) = @_;
    $self->checkChoice($req) or return PE_ERROR;
    return $req->datas->{enabledMods2}->[0]->confirm( $req, $pwd );
}

sub modifyPassword {
    my ( $self, $req, $pwd ) = @_;
    $self->checkChoice($req) or return PE_ERROR;
    return $req->datas->{enabledMods2}->[0]->modifyPassword( $req, $pwd );
}

1;
