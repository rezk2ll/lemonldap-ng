#!/usr/bin/env perl

use warnings;

BEGIN {
    $pwd = `pwd`;
    chomp $pwd;
    eval qq{
        use lib "$pwd/../lemonldap-ng-common/blib/lib";
        use lib "$pwd/../lemonldap-ng-handler/blib/lib";
        use lib "$pwd/../lemonldap-ng-portal/blib/lib";
        use lib "$pwd/../lemonldap-ng-manager/blib/lib";
    };
    die $@ if ($@);
}
use Lemonldap::NG::Manager;
use Plack::Handler::CGI;

Plack::Handler::CGI->new->run( Lemonldap::NG::Manager->run( {} ) );

