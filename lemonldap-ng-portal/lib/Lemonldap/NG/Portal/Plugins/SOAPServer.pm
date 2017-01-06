# Session server plugin for SOAP call
#
# This plugin adds the following entry points:
#  * POST /sessions     , methods: getCookies getAttributes isAuthorizedURI
#                                  getMenuApplications
#  * POST /adminSessions, methods: getAttributes setAttributes isAuthorizedURI
#                                  getMenuApplications newSession deleteSession
#                                  get_key_from_all_sessions
#  * POST /config       , methods: getConfig lastCfg
#
# There is no conflict with REST server, they can be used together

package Lemonldap::NG::Portal::Plugins::SOAPServer;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

has server => ( is => 'rw' );

# INITIALIZATION

sub init {
    my ($self) = @_;
    eval { require Lemonldap::NG::Common::PSGI::SOAPServer };
    if ($@) {
        $self->error($@);
        return 0;
    }
    $self->server( Lemonldap::NG::Common::PSGI::SOAPServer->new );
    $self->addUnauthRoute( sessions      => 'unauthSessions',      ['POST'] );
    $self->addUnauthRoute( adminSessions => 'unauthAdminSessions', ['POST'] );
    $self->addUnauthRoute( config        => 'config',              ['POST'] );
    $self->addAuthRoute( sessions      => 'badSoapRequest'  ['POST'] );
    $self->addAuthRoute( adminSessions => 'badSoapRequest', ['POST'] );
    $self->addAuthRoute( config        => 'badSoapRequest'  ['POST'] );
    1;
}

sub unauthSessions {
    my ( $self, $req ) = @_;
}

sub unauthAdminSessions {
    my ( $self, $req ) = @_;
}

sub config {
    my ( $self, $req ) = @_;
}

sub badSoapRequest {
    my ( $self, $req ) = @_;
}

1;
