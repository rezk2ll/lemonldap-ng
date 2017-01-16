package Lemonldap::NG::Portal::Register::AD;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_LDAPERROR
  PE_OK
);

extends 'Lemonldap::NG::Portal::Register::LDAP';

our $VERSION = '2.0.0';

sub createUser {
    my ( $self, $req ) = @_;

    my $name =
      ucfirst $req->datas->{registerInfo}->{firstname} . " "
      . uc $req->datas->{registerInfo}->{lastname};

    my $mesg = $self->ldap->add(
        "cn=$name," . $self->conf->{ldapBase},
        attrs => [
            objectClass    => [qw/top person organizationalPerson user/],
            sAMAccountName => $req->datas->{registerInfo}->{login},
            cn             => $name,
            sn             => uc $req->datas->{registerInfo}->{lastname},
            givenName      => ucfirst $req->datas->{registerInfo}->{firstname},
            unicodePwd     => utf8(
                chr(34) . $req->datas->{registerInfo}->{password} . chr(34)
              )->utf16le(),
            mail => $req->datas->{registerInfo}->{mail},
        ]
    );

    if ( $mesg->is_error ) {
        $self->lmLog(
            "Can not create entry for " . $req->datas->{registerInfo}->{login},
            'error'
        );
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
        filter => "(sAMAccountName=$login)",
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
