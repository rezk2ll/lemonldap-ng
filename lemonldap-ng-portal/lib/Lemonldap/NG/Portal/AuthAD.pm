##@file
# AD authentication backend file

##@class
# AD authentication backend class
package Lemonldap::NG::Portal::AuthAD;

use strict;

our $VERSION = '1.3.0';
use base qw(Lemonldap::NG::Portal::AuthLDAP);

*_formateFilter = *Lemonldap::NG::Portal::UserDBAD::formateFilter;

## @apmethod int authenticate()
# Authenticate user by LDAP mechanism.
# Check AD specific attribute to get password state.
# @return Lemonldap::NG::Portal constant
sub authenticate {
    my $self = shift;

    my $res = $self->SUPER::authenticate;

    # Check specific AD attributes
    # TODO

    return $res;
}

1;
