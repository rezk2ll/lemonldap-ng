##@file
# LDAP register backend file

##@class
# LDAP register backend class
package Lemonldap::NG::Portal::RegisterDBLDAP;

use strict;
use Lemonldap::NG::Portal::Simple;

## @method int computeLogin
# Compute a login from register infos
# @result Lemonldap::NG::Portal constant
sub computeLogin {
    my ($self) = splice @_;

    # Get first letter of firstname and lastname
    my $login =
      substr( lc $self->{registerInfo}->{firstname}, 0, 1 )
      . lc $self->{registerInfo}->{lastname};

    # TODO check in LDAP for uid unicity

    $self->{registerInfo}->{login} = $login;

    return PE_OK;
}

## @method int createUser
# Insert new user
# @result Lemonldap::NG::Portal constant
sub createUser {
    my ($self) = splice @_;

    my $mesg = $self->ldap->add(
        "uid=" . $self->{registerInfo}->{login} . "," . $self->{ldapBase},
        attrs => [
            objectClass => [qw/top person organizationalPerson inetOrgPerson/],
            uid         => $self->{registerInfo}->{login},
            cn          => ucfirst $self->{registerInfo}->{firstname} . " "
              . uc $self->{registerInfo}->{lastname},
            sn           => uc $self->{registerInfo}->{lastname},
            givenName    => ucfirst $self->{registerInfo}->{firstname},
            userPassword => $self->{registerInfo}->{password}
        ]
    );

    if ( $mesg->is_error ) {
        $self->lmLog(
            "Can not create entry for " . $self->{registerInfo}->{login},
            'error' );
        $self->lmLog( "LDAP error " . $mesg->error, 'error' );
        return PE_LDAPERROR;
    }

    return PE_OK;
}

1;
