## @file
# UserDB OpenID module

## @class
# UserDB OpenID module
package Lemonldap::NG::Portal::UserDBOpenID;

use strict;
use Lemonldap::NG::Portal::Simple;

our $VERSION = '0.01';

## @apmethod int userDBInit()
# Check if authentication module is OpenID
# @return Lemonldap::NG::Portal error code
sub userDBInit {
    my $self = shift;
    if (   $self->{authentication} =~ /^OpenID/
        or $self->{stack}->[0]->[0]->{m} =~ /^OpenID/ )
    {
        return PE_OK;
    }
    else {
        $self->lmLog(
'UserDBOpenID isn\'t useable unless authentication module is set to OpenID',
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
# Check if there are some exportedVars in OpenID response.
# See http://openid.net/specs/openid-simple-registration-extension-1_0.html
# for more
# @return Lemonldap::NG::Portal error code
sub setSessionInfo {
    my $self = shift;
    if ( ref( $self->{exportedVars} ) eq 'HASH' ) {
        foreach my $k ( keys %{ $self->{exportedVars} } ) {
            $k =~ s/^!//;
            $self->{sessionInfo}->{$k} =
              $self->param("openid.sreg.$self->{exportedVars}->{$k}")
              if ( $k =~
/^(?:(?:(?:full|nick)nam|languag|postcod|timezon)e|country|gender|email|dob)$/
              );
        }
    }
    else {
        $self->abort('Only hash reference are supported now in exportedVars');
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

