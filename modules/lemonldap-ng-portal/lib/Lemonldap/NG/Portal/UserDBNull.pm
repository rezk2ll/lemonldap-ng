## @file
# Null userDB mechanism

## @class
# Null userDB mechanism class
package Lemonldap::NG::Portal::UserDBNull;

use strict;
use Lemonldap::NG::Portal::Simple;

our $VERSION = '0.1';

## @apmethod int userDBInit()
# Do nothing
# @return Lemonldap::NG::Portal constant
sub userDBInit {
    PE_OK;
}

## @apmethod int getUser()
# Do nothing
# @return Lemonldap::NG::Portal constant
sub getUser {
    PE_OK;
}

## @apmethod int setSessionInfo()
# Store just user field (set by Auth*) in $whatToTrace.
# @return Lemonldap::NG::Portal constant
sub setSessionInfo {
    my $self = shift;
    $self->{sessionInfo}->{$self->{whatToTrace}} = $self->{user};
    PE_OK;
}

## @apmethod int setGroups()
# Do nothing
# @return Lemonldap::NG::Portal constant
sub setGroups {
    PE_OK;
}
1;

