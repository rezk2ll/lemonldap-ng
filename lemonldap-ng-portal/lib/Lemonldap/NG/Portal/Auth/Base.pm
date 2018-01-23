package Lemonldap::NG::Portal::Auth::Base;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# PROPERTIES

has authnLevel => ( is => 'rw' );

1;
