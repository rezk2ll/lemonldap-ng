#!/usr/bin/perl

use Data::Dumper;
use Plack::Builder;

# Basic test app
my $testApp = sub {
    my ($env) = @_;
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent   = 1;
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

my $domain = $ENV{DNSDOMAIN} || "example.com";

# Global app
if ( $ENV{PORT} and $ENV{DNSDOMAIN} ) {
    print STDERR <<EOF;
LemonLDAP demo server:
* http://test1.$ENV{DNSDOMAIN}:$ENV{PORT}/
* http://auth.$ENV{DNSDOMAIN}:$ENV{PORT}/
* http://manager.$ENV{DNSDOMAIN}:$ENV{PORT}/

EOF
}
builder {
    mount "http://test1.$domain/"   => $test;
    mount "http://auth.$domain/"    => $portal;
    mount "http://manager.$domain/" => $manager;
};
