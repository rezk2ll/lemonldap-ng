# Base library for tests

use strict;
use Data::Dumper;
use 5.10.0;
use_ok('Lemonldap::NG::Common::PSGI::Cli::Lib');

our $client;

ok(
    $client = Lemonldap::NG::Common::PSGI::Cli::Lib->new(
        app => sub {
            return Lemonldap::NG::Handler::PSGI->run(configStorage => { type => 'File', dirName => 't' });
        }
    ),
    'Client object'
);

sub client {
    return $client;
}

our $count = 2;

sub count {
    my $c = shift;
    $count += $c if ($c);
    return $count;
}

1;
