package Lemonldap::NG::Portal::UserDB::Proxy;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants 'PE_OK';

extends 'Lemonldap::NG::Common::Module', 'Lemonldap::NG::Portal::Lib::Proxy';

our $VERSION = '2.0.0';

# RUNNING METHODS

sub setGroups {
    PE_OK;
}

1;
