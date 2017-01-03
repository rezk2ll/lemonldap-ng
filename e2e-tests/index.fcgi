#!/usr/bin/env perl

# TODO: remove this
BEGIN {
    $pwd = `pwd`;
    chomp $pwd;
    eval qq{
        use lib "$pwd/../../lemonldap-ng-common/blib/lib";
        use lib "$pwd/../../lemonldap-ng-handler/blib/lib";
        use lib "$pwd/../../lemonldap-ng-portal/blib/lib";
        use lib "$pwd/../../lemonldap-ng-manager/blib/lib";
    };
    die $@ if ($@);
}
use Plack::Handler::FCGI;
use Lemonldap::NG::Portal::Main;

# Roll your own
my $server = Plack::Handler::FCGI->new();
$server->run( Lemonldap::NG::Portal::Main->run( {} ) );
