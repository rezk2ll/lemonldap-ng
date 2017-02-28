package Lemonldap::NG::Portal::UserDB::Choice;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_FIRSTACCESS);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Lib::Choice';

# INITIALIZATION

sub init {
    return $_[0]->SUPER::init(1);
}

# RUNNING METHODS

sub getUser {
    my ( $self, $req ) = @_;
    $self->checkChoice($req) or return PE_FIRSTACCESS;
    return $req->datas->{enabledMods1}->[0]->getUser($req);
}

sub setSessionInfo {
    return $_[1]->datas->{enabledMods1}->[0]->setSessionInfo( $_[1] );
}

sub setGroups {
    $_[0]->checkChoice( $_[1] );
    return $_[1]->datas->{enabledMods1}->[0]->setGroups( $_[1] );
}

1;
