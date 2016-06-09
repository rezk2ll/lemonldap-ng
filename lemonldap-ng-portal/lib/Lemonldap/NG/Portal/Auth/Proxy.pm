package Lemonldap::NG::Portal::Auth::Proxy;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::_WebForm',
  'Lemonldap::NG::Portal::Lib::Proxy';

# RUNNING METHODS

sub authForce {
    0;
}

sub authLogout {
    PE_OK;
}

sub getDisplayType {
    return "standardform";
}

1;
