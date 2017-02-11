# Auth-basic authentication with Lemonldap::NG rights management

# This specific handler is intended to be called directly by Apache

package Lemonldap::NG::Handler::ApacheMP2::ZimbraPreAuth;

use strict;

use base 'Lemonldap::NG::Handler::Lib::ZimbraPreAuth',
  'Lemonldap::NG::Handler::ApacheMP2::Main';

our $VERSION = '2.0.0';

1;
