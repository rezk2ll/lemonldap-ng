#!/usr/bin/env plackup

use lib 'lemonldap-ng-common/blib/lib';
use lib 'lemonldap-ng-handler/blib/lib';

use Lemonldap::NG::Handler::PSGI::Server;

Lemonldap::NG::Handler::PSGI::Server->run({});
