package Lemonldap::NG::Portal::Auth::Choice;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_FIRSTACCESS);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Lib::Choice';

sub init {
    return $_[0]->SUPER::init(0);
}

sub extractFormInfo {
    my ( $self, $req ) = @_;
    unless ( $self->checkChoice($req) ) {
        foreach my $mod ( values %{ $self->modules } ) {
            if ( $mod->can('setSecurity') ) {
                $mod->setSecurity($req);
                last;
            }
        }
        return PE_FIRSTACCESS;
    }
    return $req->datas->{enabledMods0}->[0]->extractFormInfo($req);
}

sub authenticate {
    return $_[1]->datas->{enabledMods0}->[0]->authenticate( $_[1] );
}

sub setAuthSessionInfo {
    return $_[1]->datas->{enabledMods0}->[0]->setAuthSessionInfo( $_[1] );
}

sub authLogout {
    $_[0]->checkChoice( $_[1] ) or return PE_OK;
    return $_[1]->datas->{enabledMods0}->[0]->authLogout( $_[1] );
}

1;
