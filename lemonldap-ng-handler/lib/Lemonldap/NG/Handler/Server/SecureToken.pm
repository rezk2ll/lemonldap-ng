# Auth-basic authentication with Lemonldap::NG rights management

# This specific handler is intended to be called directly by Apache

package Lemonldap::NG::Handler::Server::SecureToken;

use strict;

use base 'Lemonldap::NG::Handler::Lib::SecureToken',
  'Lemonldap::NG::Handler::Server::Main';

our $VERSION = '2.0.0';

1;
