package Lemonldap::NG::Handler::PSGI::Server;

use strict;
use Mouse;
use Lemonldap::NG::Handler::SharedConf qw(:tsv);

extends 'Lemonldap::NG::Handler::PSGI';

## @method PSGI-Response router($res)
# If PSGI is used as an authentication FastCGI only, this method will be
# called for authenticated users and will set headers in response without
# content.
# @param $req Lemonldap::NG::Common::PSGI::Request
sub router {
    my ( $self, $req ) = @_;
    my $hdrs = $req->{respHeaders} || {};
    return [
        200, [ 'Lm-Remote-User', $self->userId, 'Content-Length', 0, %$hdrs ],
        []
    ];
}

1;
