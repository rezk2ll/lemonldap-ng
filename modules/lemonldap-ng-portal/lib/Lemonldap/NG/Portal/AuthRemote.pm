## @file
# Remote authentication module

## @class
# Remote authentication module: It simply check the remote session using cross
# domain mechanism.
package Lemonldap::NG::Portal::AuthRemote;

use strict;
use Lemonldap::NG::Portal::_Remote;
use Lemonldap::NG::Portal::Simple;
use base qw(Lemonldap::NG::Portal::_Remote);

*authInit = *Lemonldap::NG::Portal::_Remote::init;

## @apmethod int extractFormInfo()
# Call checkRemoteId() and set $self->{user} and $self->{password}
# @return Lemonldap::NG::Portal constant
sub extractFormInfo {
    my $self = shift;
    my $r    = $self->checkRemoteId();
    return $r unless ( $r == PE_OK );
    $self->{user} =
      $self->{rSessionInfo}->{ $self->{remoteUserField} || 'uid' };
    $self->{password} = $self->{rSessionInfo}->{'_password'};
    PE_OK;
}

## @apmethod int setAuthSessionInfo()
# Delete stored password if local policy does not accept stored passwords.
# @return Lemonldap::NG::Portal constant
sub setAuthSessionInfo {
    PE_OK;
}

## @apmethod int authenticate()
# Does nothing.
# @return Lemonldap::NG::Portal constant
sub authenticate {
    PE_OK;
}

1;

