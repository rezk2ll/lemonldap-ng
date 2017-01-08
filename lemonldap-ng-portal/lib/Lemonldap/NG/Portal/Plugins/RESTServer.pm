# Session server plugin for REST requests
#
# This plugin adds the following entry points:
# - Sessions (if restSessionServer is on)
#   * GET /sessions/<type>/<session-id>          : get session datas
#   * GET /sessions/<type>/<session-id>/<key>    : get a session key value
#   * POST /sessions/<type>                      : create a session
#   * PUT /sessions/<type>/<session-id>          : update some keys
#   * DELETE /adminSessions/<type>/<session-id>  : delete a session
#
# - Session keys for connected users:
#   * GET /mysession/?authorizationfor=<base64-encoded-url>: ask if url is authorizated
#   * GET /mysession/<type>/key
#   * DELETE /mysession to logout
#
# - Configuration (if restConfigServer is on)
#   * GET /confs/latest                          : get the last config metadata
#   * GET /confs/<cfgNum>                        : get the metadata for config
#                                                  n° <cfgNum>
#   * GET /confs/<latest|cfgNum>/<key>           : get conf key value
#   * GET /confs/<latest|cfgNum>?full            : get the full configuration
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
use MIME::Base64;

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

        # Methods written below
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
        mysession => { '*' => 'mysession' },
        [ 'GET', 'POST' ]
    );
    $self->addAuthRoute(
        mysession => { ':sessionType' => 'getMyKey' },
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

sub mysession {
    my ( $self, $req ) = @_;

    # Verify authorizationfor arg
    my $url = $req->param('authorizationfor')
      or
      return $self->p->sendError( $req, 'authorizationfor is required', 400 );

    # Verify that value is base64 encoded
    return $self->p->sendError( $req, "Value must be in BASE64", 400 )
      if ( $url =~ m#[^A-Za-z0-9\+/=]# );
    $req->urldc( decode_base64($url) );

    # Check for XSS problems
    return $self->p->sendError( $req, 'XSS attack detected', 400 )
      if ( $self->p->checkXSSAttack( 'authorizationfor', $req->urldc ) );

    # Split URL
    my ( $host, $uri ) = ( $url =~ m#^https?://([^/]+)(/.*)?$# );
    return $self->p->sendError( $req, 'Bad URL', 400 ) unless ($host);

    $self->lmLog( "Looking for authorization for $url", 'debug' );

    # Now check for authorization
    my $res = $self->p->HANDLER->grant( $req->userDatas, $uri, undef, $host );
    $self->lmLog( "Result is $res", 'debug' );
    return $self->p->sendJSONresponse( $req, { result => $res } );
}

sub getMyKey {
    my ( $self, $req, $key ) = @_;
    return $self->p->sendError( $req, 'A key is required', 400 )
      unless ($key);
    return $self->session( $req, $req->id, $key );
}

1;
