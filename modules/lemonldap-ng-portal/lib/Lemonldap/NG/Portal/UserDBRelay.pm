## @file
# Relay userDB mechanism

## @class
# Relay userDB mechanism class
package Lemonldap::NG::Portal::UserDBRelay;

use strict;
use Lemonldap::NG::Portal::_Relay;
use Lemonldap::NG::Portal::Simple;
use base qw(Lemonldap::NG::Portal::_Relay);

our $VERSION = '0.1';

## @apmethod int userDBInit()
# Call Lemonldap::NG::Portal::_Relay::relayInit();
# @return Lemonldap::NG::Portal constant
*userDBInit = *Lemonldap::NG::Portal::_Relay::relayInit;

## @apmethod int getUser()
# Call Lemonldap::NG::Portal::_Relay::relayQuery()
# @return Lemonldap::NG::Portal constant
*getUser = *Lemonldap::NG::Portal::_Relay::relayQuery;

sub setGroups {
    PE_OK;
}
1;

