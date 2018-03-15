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
      root => '__PORTALSITEDIR__';
    Lemonldap::NG::Portal::Main->run( {} );
};

# Build manager app
use Lemonldap::NG::Manager;
my $manager = builder {
    enable "Plack::Middleware::Static",
      path => '^/static/',
      root => '__MANAGERSITEDIR__';
    enable "Plack::Middleware::Static",
      path => '^/doc/',
      root => '__DEFDOCDIR__../';
    enable "Plack::Middleware::Static",
      path => '^/lib/',
      root => '__DEFDOCDIR__pages/documentation/current/';
    enable "Plack::Middleware::Static",
      path => '^/fr-doc/',
      root => '__FRDOCDIR__../';
    Lemonldap::NG::Manager->run( {} );
};

# Global app
builder {
    mount 'http://test1.example.com/'   => $test;
    mount 'http://auth.example.com/'    => $portal;
    mount 'http://manager.example.com/' => $manager;
};
