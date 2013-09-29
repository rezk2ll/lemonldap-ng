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
# Since the job is done by AuthGoogle, here just check that required
# attributes are not null
# @return Lemonldap::NG::Portal error code
sub setSessionInfo {
    my $self = shift;
    foreach my $k ( keys %{ $self->{exportedVars} } ) {
        my $attr = $k;
        next
          unless ( $attr =~ s/^!//
            and $self->{exportedVars}->{$k} =~
            /^(?:(?:la(?:nguag|stnam)|firstnam)e|country|email)$/ );
        unless ( defined( $self->{sessionInfo}->{$attr} ) ) {
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

