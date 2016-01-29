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
        my $res = $self->_authAndTrace(
            Lemonldap::NG::Common::PSGI::Request->new( $_[0] ) );

        # Transform 302 responses in 401 since Nginx refuse it
        if($res->[0] == 302 or $res->[0] == 303) {
            $res->[0] = 401;
            push @{$res->[1]},'X-Location' => $tsv->{portal}
        }

        # TODO: transform headers in $res->[1]
        return $res;
    };
}

1;
