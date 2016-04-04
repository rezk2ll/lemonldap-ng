package Lemonldap::NG::Portal::Main::Request;

# Developpers, be careful: new() is never called so default values will not be
# taken in account (see Portal::Run::handler())

use strict;
use Mouse;

extends 'Lemonldap::NG::Common::PSGI::Request';

# List of methods to call
has steps => ( is => 'rw' );

# Datas shared between methods
has datas => ( is => 'rw', default => sub { {} } );

# Session datas when created
has id          => ( is => 'rw' );
has sessionInfo => ( is => 'rw' );
has user        => ( is => 'rw' );

# Response cookies (list of strings built by cookie())
has respCookies => ( is => 'rw' );

# Template to display (if not defined, login or menu)
has template => ( is => 'rw' );

# Boolean to indicate that response must be a redirection
has mustRedirect => ( is => 'rw' );

# Boolean to indicate that url isn't Base64 encoded
has urlNotBase64 => ( is => 'rw' );

sub wantJSON {
    return $_[0]->accept =~ m#(?:application|text)/json# ? 1 : 0;
}

1;
