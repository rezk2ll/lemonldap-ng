package Lemonldap::NG::Portal::Main::Request;

use strict;
use Mouse;

extends 'Lemonldap::NG::Common::PSGI::Request';

has steps       => ( is => 'rw' );
has datas       => ( is => 'rw' );
has id          => ( is => 'rw' );
has sessionInfo => ( is => 'rw' );
has respCookies => ( is => 'rw' );

sub wantJSON {
    return $_[0]->accept =~ m#(?:application|text)/json# ? 1 : 0;
}

1;
