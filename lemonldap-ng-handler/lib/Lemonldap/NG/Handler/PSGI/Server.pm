package Lemonldap::NG::Handler::PSGI::Server;

use strict;
use Mouse;
use Lemonldap::NG::Handler::SharedConf qw(:tsv);

extends 'Lemonldap::NG::Handler::PSGI';

sub router {
    return [ 200, [], [] ];
}

sub _run {
    my $self = shift;
    return sub {
        my $req = $_[0];
        $self->lmLog( 'New request', 'debug' );
        my $res = $self->_authAndTrace($req);

        # TODO: transform headers in $res->[1]
        return $res;
    };
}

1;
