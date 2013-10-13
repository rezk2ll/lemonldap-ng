## @file
# UserDB WebID module

## @class
# UserDB WebID module
package Lemonldap::NG::Portal::UserDBWebID;

use strict;
use Lemonldap::NG::Portal::Simple;

our $VERSION = '1.3.0';

## @apmethod int userDBInit()
# Check if authentication module is WebID
# @return Lemonldap::NG::Portal error code
sub userDBInit {
    my $self = shift;

    unless ( $self->get_module('auth') =~ /^WebID/ ) {
        $self->lmLog(
'UserDBWebID isn\'t useable unless authentication module is set to WebID',
            'error'
        );
        return PE_ERROR;
    }
    PE_OK;
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

    # TODO
    PE_OK;
}

## @apmethod int setGroups()
# Does nothing
# @return Lemonldap::NG::Portal error code
sub setGroups {
    PE_OK;
}

1;
