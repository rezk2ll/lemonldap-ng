package Lemonldap::NG::Handler::PSGI::Server;

use strict;
use Mouse;

extends 'Lemonldap::NG::Handler::PSGI';

sub router {
    return [ 200, [], [] ];
}

sub _run {
    my $self = shift;
    my $res = $self->SUPER::_run(@_);
    # TODO: insert headers
    return $res;
}

1;
