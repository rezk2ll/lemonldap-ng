##@class Lemonldap::NG::Portal::Main::Run
# Serve request part of Lemonldap::NG portal
#
# Methods:
#  - handler():    verify that portal configuration is the same that the
#                  underlying handler configuration before launching
#                  Lemonldap::NG::Common::PSGI::Router::handler() (which parse
#                  routes)
package Lemonldap::NG::Portal::Main::Run;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Request;

our $VERSION = '2.0.0';

sub handler {
    my($self,$req) = shift;
    unless ( $self->conf->{cfgNum} and $self->conf->{cfgNum} eq HANDLER->lmConf->{cfgNum} ) {
        $self->reloadConf()
    }
    bless $req, 'Lemonldap::NG::Portal::Main::Request';
    return $self->SUPER::handler($req);
}

# TODO in run
#  - mustRedirect
#  - store AuthnLevel in session (setSessionInfo)
#    $self->{sessionInfo}->{authenticationLevel} = $self->_authentication->AuthnLevel

1;
