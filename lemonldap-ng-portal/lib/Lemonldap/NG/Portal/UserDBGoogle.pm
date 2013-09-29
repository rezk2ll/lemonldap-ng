## @file
# UserDB Google module

## @class
# UserDB Google module
package Lemonldap::NG::Portal::UserDBGoogle;

use strict;
use Lemonldap::NG::Portal::Simple;

our $VERSION = '1.0.0';

## @apmethod int userDBInit()
# Check if authentication module is Google
# @return Lemonldap::NG::Portal error code
sub userDBInit {
    my $self = shift;

    if ( $self->get_module('auth') eq 'Google' ) {
    }
    else {
        $self->lmLog(
'UserDBGoogle isn\'t useable unless authentication module is set to Google',
            'error'
        );
        return PE_ERROR;
    }
}

## @apmethod int getUser()
# Does nothing
# @return Lemonldap::NG::Portal error code
sub getUser {
    PE_OK;
}

## @apmethod int setSessionInfo()
# Check if there are some exportedVars in Google response.
# See https://developers.google.com/accounts/docs/OpenID#Parameters
# for more
# @return Lemonldap::NG::Portal error code
sub setSessionInfo {
    my $self = shift;
    foreach my $k ( keys %{ $self->{exportedVars} } ) {
        my $attr = $k;
        my $required = ( $attr =~ s/^!// );
        if ( $self->{exportedVars}->{$k} =~
            /^(?:(?:la(?:nguag|stnam)|firstnam)e|country|email)$/ )
        {
            $self->{sessionInfo}->{$attr} = $self->{googleSessionInfo}->{$attr};
        }
        else {
            $self->lmLog(
                'Ignoring attribute '
                  . $self->{exportedVars}->{$k}
                  . ' which is not a valid Google OpenID AX attribute',
                'warn'
            );
        }
        if ( $required and not defined( $self->{sessionInfo}->{$attr} ) ) {
            $self->lmLog(
"Required parameter $attr is not provided by Google server, aborted",
                'warn'
            );

            $self->{mustRedirect} = 0;
            return PE_MISSINGREQATTR;
        }
    }
    PE_OK;
}

## @apmethod int setGroups()
# Does nothing
# @return Lemonldap::NG::Portal error code
sub setGroups {
    PE_OK;
}

1;

