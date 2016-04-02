package Lemonldap::NG::Portal::Main::Request;

use strict;
use Mouse;

extends 'Lemonldap::NG::Common::PSGI::Request';

# List of methods to call
has steps       => ( is => 'rw' );

# Datas shared between methods
has datas       => ( is => 'rw', default => sub { {} } );

# Session datas when created
has id          => ( is => 'rw' );
has sessionInfo => ( is => 'rw' );

# Response cookies (list of strings built by cookie())
has respCookies => ( is => 'rw' );

# Template to display (if not defined, login or menu)
has template    => ( is => 'rw' );

sub wantJSON {
    return $_[0]->accept =~ m#(?:application|text)/json# ? 1 : 0;
}

1;
