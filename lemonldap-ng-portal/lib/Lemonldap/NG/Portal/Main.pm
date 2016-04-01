package Lemonldap::NG::Portal::Main;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends(
    'Lemonldap::NG::Handler::PSGI::Try',
    'Lemonldap::NG::Portal::Main::Init',
    'Lemonldap::NG::Portal::Main::Run',
    'Lemonldap::NG::Portal::Main::Process',
);

1;
