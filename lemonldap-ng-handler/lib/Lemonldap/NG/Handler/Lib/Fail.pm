package Lemonldap::NG::Handler::Lib::Fail;

use strict;
use base 'Lemonldap::NG::Handler::Main';

sub run {
    return $_[0]->SERVER_ERROR;
}

our $VERSION = '2.0.6';

1;
