package Lemonldap::NG::Handler::API::PSGI::Server;

use strict;
our $VERSION = '1.9.0';

use base Lemonldap::NG::Handler::API::PSGI;

sub uri {
    return $Lemonldap::NG::Handler::API::PSGI::$request->original_uri;
}

1;
