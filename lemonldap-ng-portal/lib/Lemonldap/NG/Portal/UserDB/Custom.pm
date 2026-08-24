package Lemonldap::NG::Portal::UserDB::Custom;

use strict;
use Lemonldap::NG::Portal::Lib::CustomModule;

our @ISA = qw(Lemonldap::NG::Portal::Lib::CustomModule);
use constant {
    custom_name       => "UserDB",
    custom_config_key => "customUserDB",
};

1;
