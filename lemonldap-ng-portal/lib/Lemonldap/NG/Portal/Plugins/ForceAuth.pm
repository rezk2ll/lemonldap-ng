package Lemonldap::NG::Portal::Plugins::ForceAuth;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

extends 'Lemonldap::NG::Portal::Main::Plugin';

our $VERSION = '2.0.0';

sub init { 1 }

sub forAuthUser { 'forceAuth' }

sub forceAuth {
    my ( $self, $req ) = @_;

    # Don't force authentication if password is going to be changed
    return PE_OK if ( $req->param('newpassword') );

    # Do not force authentication if last successful authentication is recent
    my $last_authn_utime = $req->{sessionInfo}->{_lastAuthnUTime} || 0;
    if ( time() - $last_authn_utime < $self->{portalForceAuthnInterval} ) {
        $self->logger->debug(
"Authentication is recent, so do not force authentication for session $req->id"
        );
    }
    else {

        # Else, launch authentication process
        $self->logger->debug("Force reauthentication for session $req->id");
        $req->steps(
            [
                @{ $self->p->beforeAuth },
                $self->p->authProcess,
                @{ $self->p->betweenAuthAndDatas },
                $self->p->sessionDatas,
                @{ $self->p->afterDatas }
            ]
        );
    }
    return PE_OK;
}

1
