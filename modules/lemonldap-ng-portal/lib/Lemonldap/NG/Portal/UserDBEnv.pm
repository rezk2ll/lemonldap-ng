## @file
# Env userDB mechanism

## @class
# Env userDB mechanism class
package Lemonldap::NG::Portal::UserDBEnv;

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
# Fetch all environment variables declared in exportedVars
# @return Lemonldap::NG::Portal constant
sub setSessionInfo {
    my $self = shift;

    # Check access to %ENV
    unless ( defined %ENV ) {
        $self->lmLog("No environment variables available", 'error');
        return PE_ERROR;
    }

    # Parse exportedVars
    if ( ref( $self->{exportedVars} ) eq 'HASH' ) {
        foreach ( keys %{ $self->{exportedVars} } ) {
            if ( exists $ENV{ $self->{exportedVars}->{$_} } ) {
                $self->{sessionInfo}->{$_} = $ENV{ $self->{exportedVars}->{$_} };
            }
        }
    }

    PE_OK;
}

## @apmethod int setGroups()
# Do nothing
# @return Lemonldap::NG::Portal constant
sub setGroups {
    PE_OK;
}
1;

