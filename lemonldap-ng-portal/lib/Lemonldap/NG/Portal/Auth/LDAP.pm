package Lemonldap::NG::Portal::Auth::LDAP;

use strict;
use Mouse;

our $VERSION = '2.0.0';

# Inheritance: UserDB::LDAP provides all needed ldap functions
extends
  qw(Lemonldap::NG::Portal::Auth::_WebForm Lemonldap::NG::Portal::UserDB::LDAP);

sub authenticate {
    unless ( $self->ldap ) {
        return PE_LDAPCONNECTFAILED;
    }

    # Set the dn unless done before
    unless ( $req->datas->{dn} ) {
        if ( my $tmp = $self->getUser($req) ) {
            return $tmp;
        }
    }

    my $res =
      $self->ldap->userBind( $req->datas->{dn}, password => $req->datas->{password} );

    # Remember password if password reset needed
    $req->datas->{oldpassword} = $self->{password}
      if ( $res == PE_PP_CHANGE_AFTER_RESET );

    $self->ldap->unbind;
    return $res;

}

sub authLogout {
    PE_OK;
}

sub authForce {
    PE_OK;
}

1;
