package Lemonldap::NG::Portal::Register::LDAP;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Lib::LDAP;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_LDAPCONNECTFAILED
  PE_LDAPERROR
  PE_OK
);

extends 'Lemonldap::NG::Portal::UserDB::LDAP';

our $VERSION = '2.0.0';

# RUNNING METHODS

sub init {
    my ($self) = @_;
}

# Compute a login from register infos
# @result Lemonldap::NG::Portal constant
sub computeLogin {
    my ( $self, $req ) = @_;
    return PE_LDAPCONNECTFAILED unless $self->ldap and $self->bind();

    # Get first letter of firstname and lastname
    my $login =
      substr( lc $req->datas->{registerInfo}->{firstname}, 0, 1 )
      . lc $req->datas->{registerInfo}->{lastname};

    my $finalLogin = $login;

    # The uid must be unique
    my $i = 0;
    while ( $self->isLoginUsed($finalLogin) ) {
        $i++;
        $finalLogin = $login . $i;
    }

    $req->datas->{registerInfo}->{login} = $finalLogin;
    return PE_OK;
}

## @method int createUser
# Do nothing
# @result Lemonldap::NG::Portal constant
sub createUser {
    my ( $self, $req ) = @_;

    # LDAP connection has been verified by computeLogin
    my $mesg = $self->ldap->add(
        "uid=" . $req->datas->{registerInfo}->{login} . "," . $self->conf->{ldapBase},
        attrs => [
            objectClass => [qw/top person organizationalPerson inetOrgPerson/],
            uid         => $req->datas->{registerInfo}->{login},
            cn          => ucfirst $req->datas->{registerInfo}->{firstname} . " "
              . uc $req->datas->{registerInfo}->{lastname},
            sn           => uc $req->datas->{registerInfo}->{lastname},
            givenName    => ucfirst $req->datas->{registerInfo}->{firstname},
            userPassword => $req->datas->{registerInfo}->{password},
            mail         => $req->datas->{registerInfo}->{mail},
        ]
    );

    if ( $mesg->is_error ) {
        $self->lmLog(
            "Can not create entry for " . $req->datas->{registerInfo}->{login},
            'error' );
        $self->lmLog( "LDAP error " . $mesg->error, 'error' );

        $self->ldap->unbind();
        $self->{flags}->{ldapActive} = 0;

        return PE_LDAPERROR;
    }
    return PE_OK;
}

# PRIVATE METHODS

# Search if login is already in use
sub isLoginUsed {
    my ( $self, $login ) = @_;

    my $mesg = $self->ldap->search(
        base   => $self->conf->{ldapBase},
        filter => "(uid=$login)",
        scope  => "sub",
        attrs  => ['1.1'],
    );

    if ( $mesg->code() != 0 ) {
        $self->lmLog( "LDAP Search error for $login: " . $mesg->error, 'warn' );
        return 1;
    }

    if ( $mesg->count() > 0 ) {
        $self->lmLog( "Login $login already used in LDAP", 'debug' );
        return 1;
    }

    return 0;
}

1;
