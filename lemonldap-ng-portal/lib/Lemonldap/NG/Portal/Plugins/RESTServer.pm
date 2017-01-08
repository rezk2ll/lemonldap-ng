# Session server plugin for REST requests
#
# This plugin adds the following entry points:
# - Sessions
#   * GET /sessions/<type>/<session-id>          : get session datas
#   * GET /sessions/<type>/<session-id>/<key>    : get a session key value
#   * POST /sessions/<type>                      : create a session
#   * PUT /sessions/<type>/<session-id>          : update some keys
#   * DELETE /adminSessions/<type>/<session-id>  : delete a session
#
# - Configuration
#   * GET /confs/latest                          : get the last config metadata
#   * GET /confs/<cfgNum>                        : get the metadata for config
#                                                  n° <cfgNum>
#   * GET /confs/<latest|cfgNum>/<key>           : get conf key value
#   * GET /confs/<latest|cfgNum>?full            : get the full configuration
#   * GET /authorisation?url=<base64-encoded-url>: ask if url is authorizated
# where <type> is the session type ("global" for SSO session)
#
# Note that the "getCookie" method (authentification via SOAP) exists for REST
# requests directly by using '/' path : the portal recognize REST calls and
# generate JSON response instead of web page.
#
# There is no conflict with SOAP server, they can be used together

package Lemonldap::NG::Portal::Plugins::RESTServer;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

sub init {
    my ($self) = @_;
    my @parents = ('Lemonldap::NG::Portal::Main::Plugin');
    if ( $self->conf->{restConfigServer} ) {
        push @parents, 'Lemonldap::NG::Common::Conf::RESTServer';

        # Methods inherited from Lemonldap::NG::Common::Conf::RESTServer
        $self->addUnauthRoute(
            confs => {
                ':cfgNum' => [
                    qw(virtualHosts samlIDPMetaDataNodes samlSPMetaDataNodes
                      applicationList oidcOPMetaDataNodes oidcRPMetaDataNodes
                      authChoiceModules grantSessionRules)
                ]
            },
            ['GET'],
        );
        $self->addUnauthRoute(
            confs => { ':cfgNum' => { '*' => 'getKey' } },
            ['GET']
        );
    }
    if ( $self->conf->{restSessionServer} ) {
        push @parents, 'Lemonldap::NG::Common::Session::REST';

        # Methods inherited from Lemonldap::NG::Common::Session::REST
        $self->addUnauthRoute(
            sessions => { ':sessionType' => 'session' },
            ['GET']
        );
        $self->addUnauthRoute(
            sessions => { ':sessionType' => 'newSession' },
            ['POST']
        );
        $self->addUnauthRoute(
            sessions =>
              { ':sessionType' => { ':sessionId' => 'updateSession' } },
            ['PUT']
        );
        $self->addUnauthRoute(
            sessions => { ':sessionType' => { ':sessionId' => 'delSession' } },
            ['DELETE']
        );
    }
    $self->addAuthRoute(
        authorization => 'isUrlAuthorized',
        [ 'GET', 'POST' ]
    );
    extends @parents;
    return 1;
}

sub updateSession {
    my ( $self, $req ) = @_;
}

sub delSession {
    my ( $self, $req ) = @_;
}

sub isUrlAuthorized {
    my ( $self, $req ) = @_;
}

1;
