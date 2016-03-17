package Lemonldap::NG::Handler::Main;

use strict;
use Lemonldap::NG::Handler::Main::Init;
use Lemonldap::NG::Handler::Main::Reload;
use Lemonldap::NG::Handler::Main::Run;
use Lemonldap::NG::Handler::Main::SharedVariables;

our @ISA = qw(
  Lemonldap::NG::Handler::Main::Init
  Lemonldap::NG::Handler::Main::SharedVariables
  Lemonldap::NG::Handler::Main::Reload
  Lemonldap::NG::Handler::Main::Run
);

our $VERSION = '2.0.0';

1;
