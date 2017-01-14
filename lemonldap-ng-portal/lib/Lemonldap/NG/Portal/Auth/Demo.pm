##@file
# Demo authentication backend file

##@class
# Demo authentication backend class
package Lemonldap::NG::Portal::Auth::Demo;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_BADCREDENTIALS);

extends qw(Lemonldap::NG::Portal::Auth::_WebForm);

our $VERSION = '2.0.0';

use constant AuthnLevel => 0;

# INITIALIZATION

# Initialize demo accounts
# @return Lemonldap::NG::Portal constant
sub init {
    my $self = shift;

    # Add warning in log
    $self->lmLog(
        "Using demonstration mode, go to Manager to edit the configuration",
        'warn' );

    1;
}

# RUNNING METHODS

sub authenticate {
    my ( $self, $req ) = @_;

    return PE_BADCREDENTIALS unless ( $req->{user} eq $req->datas->{password} );

    PE_OK;
}

sub authLogout {
    PE_OK;
}

1;
