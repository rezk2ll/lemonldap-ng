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

# INITIALIZATION

sub init {
    my ($self) = @_;
    1;
}

1;
