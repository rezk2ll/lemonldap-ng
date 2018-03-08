package Lemonldap::NG::Portal::2F::Engines::Default;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

sub init {
    return 1;
}

1;
