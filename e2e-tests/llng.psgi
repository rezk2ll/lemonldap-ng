#!/usr/bin/perl

use Data::Dumper;
use Plack::Builder;

# Basic test app
my $testApp = sub {
    my ($env) = @_;
    return [
        200,
        [ 'Content-Type' => 'text/plain' ],
        [ "Hello LLNG world\n\n" . Dumper($env) ],
    ];
};

# Build protected app
my $test = builder {
    enable "Auth::LemonldapNG";
    $testApp;
};

# Build portal app
use Lemonldap::NG::Portal::Main;
my $portal = builder {
    enable "Plack::Middleware::Static",
      path => '^/static/',
      root => 'lemonldap-ng-portal/site/htdocs/';
    Lemonldap::NG::Portal::Main->run( {} );
};

# Build manager app
use Lemonldap::NG::Manager;
my $manager = builder {
    enable "Plack::Middleware::Static",
      path => '^/static/',
      root => 'lemonldap-ng-manager/site/htdocs/';
    enable "Plack::Middleware::Static",
      path => '^/doc/',
      root => '.';
    enable "Plack::Middleware::Static",
      path => '^/lib/',
      root => 'doc/pages/documentation/current/';
    Lemonldap::NG::Manager->run( {} );
};

# Global app
builder {
    mount 'http://test1.example.com/'   => $test;
    mount 'http://auth.example.com/'    => $portal;
    mount 'http://manager.example.com/' => $manager;
};
