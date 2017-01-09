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
# - Sessions for connected users (if restSessionServer is on):
#   * GET /mysession/<type>                      : get session datas
#   * GET /mysession/<type>/key                  : get session key
#   * DELETE /mysession                          : ask for logout
#
# - Configuration (if restConfigServer is on)
#   * GET /confs/latest                          : get the last config metadata
#   * GET /confs/<cfgNum>                        : get the metadata for config
#                                                  n° <cfgNum>
#   * GET /confs/<latest|cfgNum>/<key>           : get conf key value
#   * GET /confs/<latest|cfgNum>?full            : get the full configuration
#   where <type> is the session type ("global" for SSO session)
#
# - Authorizations for connected users (always):
#   * GET /mysession/?authorizationfor=<base64-encoded-url>: ask if url is
#                                                            authorizated
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
    my ($self)  = @_;
    my @parents = ('Lemonldap::NG::Portal::Main::Plugin');
    my $add     = 0;
    if ( $self->conf->{restConfigServer} ) {
        push @parents, 'Lemonldap::NG::Common::Conf::RESTServer';
        $add++;

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
        $add++;

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
            sessions => { ':sessionType' => 'updateSession' },
            ['PUT']
        );
        $self->addUnauthRoute(
            sessions => { ':sessionType' => 'delSession' },
            ['DELETE']
        );
        $self->addAuthRoute(
            mysession => { ':sessionType' => 'getMyKey' },
            [ 'GET', 'POST' ]
        );
        $self->addAuthRoute( mysession => 'delMySession', ['DELETE'] );
    }

    # Methods always available
    $self->addAuthRoute(
        mysession => { '*' => 'mysession' },
        [ 'GET', 'POST' ]
    );
    extends @parents if ($add);
    return 1;
}

sub newSession {
    my ( $self, $req ) = @_;
    my $mod = $self->getMod($req)
      or return $self->p->sendError( $req, undef, 400 );
    my $infos = $req->jsonBodyToObj
      or return $self->p->sendError( $req, undef, 400 );
    $infos->{_utime} = time();

    my $session = $self->getApacheSession($mod);
    return $self->p->sendError( $req, 'Unable to create session', 500 )
      unless ($session);

    $session->update($infos);

    $self->lmLog(
        'REST request to create a session for '
          . $session->data->{ $self->conf->{whatToTrace} },
        'debug'
    );
    return $self->p->sendJSONresponse( $req, { result => 1 } );
}

sub updateSession {
    my ( $self, $req, $id ) = @_;
    my $mod = $self->getMod($req)
      or return $self->p->sendError( $req, undef, 400 );
    return $self->p->sendError( $req, 'ID is required', 400 ) unless ($id);

    # Get session
    my $session = $self->getApacheSession( $mod, $id )
      or return $self->p->sendError( $req, 'Session id does not exists', 400 );

    # Get new info
    my $infos = $req->jsonBodyToObj
      or return $self->p->sendError( $req, undef, 400 );

    # Store them
    $self->lmLog( "REST request to update session $id", 'debug' );
    $session->update($infos);
    return $self->p->sendJSONresponse( $req, { result => 1 } );
}

sub delSession {
    my ( $self, $req, $id ) = @_;
    my $mod = $self->getMod($req)
      or return $self->p->sendError( $req, undef, 400 );
    return $self->p->sendError( $req, 'ID is required', 400 ) unless ($id);

    # Get session
    my $session = $self->getApacheSession( $mod, $id )
      or return $self->p->sendError( $req, 'Session id does not exists', 400 );

    # Delete it
    $self->lmLog( "REST request to delete session $id", 'debug' );
    my $res = $self->p->_deleteSession($session);
    $self->lmLog( " Result is $res", 'debug' );
    return $self->p->sendJSONresponse( $req, { result => $res } );
}

sub delMySession {
    my ( $self, $req, $id ) = @_;
    return $self->delSession( $req, $req->id );
}

sub mysession {
    my ( $self, $req ) = @_;

    # 1. whoami
    if ( defined $req->param('whoami') ) {
        return $self->p->sendJSONresponse( $res,
            { result => $req->sessionInfo->{ $self->conf->{whatToTrace} } } );
    }

    # Verify authorizationfor arg
    elsif ( my $url = $req->param('authorizationfor') ) {

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
        my $res =
          $self->p->HANDLER->grant( $req->userDatas, $uri, undef, $host );
        $self->lmLog( " Result is $res", 'debug' );
        return $self->p->sendJSONresponse( $req, { result => $res } );
    }
    return $self->p->sendError( $req,
        'whoami or authorizationfor is required', 400 );
}

sub getMyKey {
    my ( $self, $req, $key ) = @_;
    return $self->session( $req, $req->id, $key );
}

1;
