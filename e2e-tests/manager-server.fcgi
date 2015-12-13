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
use Plack::Handler::FCGI;
use Lemonldap::NG::Manager;

# Roll your own
my $server = Plack::Handler::FCGI->new();

#$server->run(
#    sub {
#        use Data::Dumper;
#        return [ "200", [ 'Content-Type' => 'text/plain' ], [ Dumper(\@_,\%ENV) ] ];
#    }
#);
$server->run( Lemonldap::NG::Manager->run( {} ) );
