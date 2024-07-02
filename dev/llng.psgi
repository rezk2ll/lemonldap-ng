#!/usr/bin/perl

use Data::Dumper;
use Plack::Builder;

system('make');

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
    mount 'http://test1.llng.localhost/'   => $test;
    mount 'http://test2.llng.localhost/'   => $test;
    mount 'http://auth.llng.localhost/'    => $portal;
    mount 'http://manager.llng.localhost/' => $manager;
};
