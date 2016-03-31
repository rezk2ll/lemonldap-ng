##@class Lemonldap::NG::Portal::Main::Run
# Serve request part of Lemonldap::NG portal
#
# Methods:
#  - handler():    verify that portal configuration is the same that the
#                  underlying handler configuration before launching
#                  Lemonldap::NG::Common::PSGI::Router::handler() (which parse
#                  routes)
#
# Entry points:
#  - "/test": * authenticated() for already authenticated users
#             + pleaseAuth() for others
package Lemonldap::NG::Portal::Main::Run;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Request;

our $VERSION = '2.0.0';

sub handler {
    my ( $self, $req ) = shift;
    unless ($self->conf->{cfgNum}
        and $self->conf->{cfgNum} eq HANDLER->lmConf->{cfgNum} )
    {
        $self->reloadConf();
    }
    bless $req, 'Lemonldap::NG::Portal::Main::Request';
    return $self->SUPER::handler($req);
}

# CORE REST API

# Methods that handle /test
sub authenticated {
    my ( $self, $req ) = @_;
    return $self->sendJSONresponse( $req, { status => 1 } );
}

sub pleaseAuth {
    my ( $self, $req ) = @_;
    return $self->sendJSONresponse( $req, { status => 0 } );
}

# MAIN ENTRY POINTS

sub login {
    my ( $self, $req ) = @_;
    return $self->process(
        'rememberArgs', @{ $self->beforeAuthProcess },
        @authProcess,   @{ $self->addSessionData },
        @sessionDatas,  @{ $self->afterAuthProcess }
    );
}

sub postLogin {
    my ( $self, $req ) = @_;
    return $self->process(
        @{ $self->beforeAuthProcess },
        @authProcess, @{ $self->addSessionData },
        @sessionDatas, @{ $self->afterAuthProcess }
    );
}

sub authenticatedRequest {
}

# TODO in run
#  - mustRedirect
#  - store AuthnLevel in session (setSessionInfo)
#    $self->{sessionInfo}->{authenticationLevel} = $self->_authentication->AuthnLevel

1;
