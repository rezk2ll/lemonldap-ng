package Lemonldap::NG::Portal::Auth::LDAP;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;

our $VERSION = '2.0.0';

# Inheritance: UserDB::LDAP provides all needed ldap functions
extends
  qw(Lemonldap::NG::Portal::Auth::_WebForm Lemonldap::NG::Portal::UserDB::LDAP);

sub authenticate {
    my ( $self, $req ) = @_;
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
      $self->userBind( $req->datas->{dn}, password => $req->datas->{password} );

    # Remember password if password reset needed
    $req->datas->{oldpassword} = $self->{password}
      if ( $res == PE_PP_CHANGE_AFTER_RESET );

    return $res;

}

sub authLogout {
    PE_OK;
}

sub authForce {
    PE_OK;
}

# Test LDAP connection before trying to bind
sub userBind {
    my $self = shift;
    unless ($self->ldap
        and $self->ldap->root_dse( attrs => ['supportedLDAPVersion'] ) )
    {
        $self->ldap( $self->newLdap );
    }
    return $self->ldap ? $self->ldap->userBind(@_) : undef;
}

1;
