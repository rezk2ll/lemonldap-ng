#!/usr/bin/perl

use Data::Dumper;
use Plack::Builder;

# Test
my $testApp = sub {
    my ($env) = @_;
    return [
        200,
        [ 'Content-Type' => 'text/plain' ],
        [ "Hello world\n\n" . Dumper($env) ],
    ];
};

my $test = builder {
    enable "Auth::LemonldapNG";
    $testApp;
};

use Lemonldap::NG::Portal::Main;
my $portal = builder {
    enable "Plack::Middleware::Static",
      path => '^/static/',
      root => '/home/xavier/dev/lemonldap/lemonldap-ng-portal/site/htdocs/';
    Lemonldap::NG::Portal::Main->run( {} );
};

use Lemonldap::NG::Manager;
my $manager = builder {
    enable "Plack::Middleware::Static",
      path => '^/static/',
      root => '/home/xavier/dev/lemonldap/lemonldap-ng-manager/site/htdocs/';
    enable "Plack::Middleware::Static",
      path => '^/doc/',
      root => '/home/xavier/dev/lemonldap/';
    enable "Plack::Middleware::Static",
      path => '^/lib/',
      root => '/home/xavier/dev/lemonldap/doc/pages/documentation/current/';
    enable "Plack::Middleware::Static",
      path => '^/fr-doc/',
      root => '/home/xavier/dev/lemonldap/po-doc/';
    Lemonldap::NG::Manager->run( {} );
};

builder {
    mount 'http://test1.example.com/'   => $test;
    mount 'http://auth.example.com/'    => $portal;
    mount 'http://manager.example.com/' => $manager;
};
