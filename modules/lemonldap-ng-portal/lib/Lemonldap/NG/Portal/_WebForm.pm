##@file
# Web form authentication backend file

##@class
# Web form authentication backend class
package Lemonldap::NG::Portal::_WebForm;

use Lemonldap::NG::Portal::Simple qw(:all);
use strict;

## @apmethod int authInit()
# Does nothing.
# @return Lemonldap::NG::Portal constant
sub authInit {
    PE_OK;
}

## @apmethod int extractFormInfo()
# Read username and password from POST datas
# @return Lemonldap::NG::Portal constant
sub extractFormInfo {
    my $self = shift;
    return PE_FIRSTACCESS
      unless ( $self->param('user') );
    return PE_FORMEMPTY
      unless ( length( $self->{'user'} = $self->param('user') ) > 0
        && ( ( length( $self->{'password'} = $self->param('password') ) > 0 )
        || ( length( $self->{'newpassword'} = $self->param('newpassword') ) > 0 ) ) );
    $self->{'oldpassword'} = $self->param('oldpassword');
    $self->{'confirmpassword'} = $self->param('confirmpassword');
    PE_OK;
}

## @apmethod int setAuthSessionInfo()
# Set password in session datas if wanted.
# @return Lemonldap::NG::Portal constant
sub setAuthSessionInfo {
    my $self = shift;

    # Level 2 for web form based authentication
    $self->{sessionInfo}->{authenticationLevel} = 2;

    # Store user submitted login for basic rules
    $self->{sessionInfo}->{'_user'} = $self->{'user'};

    # Store submitted password if set in configuration
    # WARNING: it can be a security hole
    if ( $self->{storePassword} ) {
        $self->{sessionInfo}->{'_password'} = $self->{'newpassword'} || $self->{'password'};
    }
    PE_OK;
}

1;
