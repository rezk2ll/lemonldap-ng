package Lemonldap::NG::Portal::Auth::Choice;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_FIRSTACCESS);

extends 'Lemonldap::NG::Portal::Lib::Choice';

sub init {
    return $_[0]->SUPER::init(0);
}

sub extractFormInfo {
    my ( $self, $req ) = @_;
    $self->checkChoice($req) or return PE_FIRSTACCESS;
    return $req->datas->{enabledMods0}->[0]->extractFormInfo($req);
}

sub authenticate {
    return $_[1]->datas->{enabledMods0}->[0]->authenticate( $_[1] );
}

sub authForce {
    $_[0]->checkChoice( $_[1] ) or return PE_OK;
    return $_[1]->datas->{enabledMods0}->[0]->authForce( $_[1] );
}

sub getDisplayType {
    $_[0]->checkChoice( $_[1] ) or return PE_OK;
    return $_[1]->datas->{enabledMods0}->[0]->getDisplayType( $_[1] );
}

1;
