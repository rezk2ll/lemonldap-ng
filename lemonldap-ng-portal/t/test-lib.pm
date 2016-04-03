# Base library for portal tests

use strict;
use Data::Dumper;
use 5.10.0;
use_ok('Lemonldap::NG::Common::PSGI::Cli::Lib');
use_ok('Lemonldap::NG::Portal::Main');

our $client;
our $count = 3;
$Data::Dumper::Deparse = 1;

ok(
    $client = Lemonldap::NG::Common::PSGI::Cli::Lib->new(
        {
            app => Lemonldap::NG::Portal::Main->run(
                {
                    configStorage => { type => 'File', dirName => 't' },
                    logLevel      => 'debug',
                    cookieName    => 'lemonldap',
                    securedCookie => 0,
                    https         => 0,
                }
            ),
        }
    ),
    'Portal app'
);

sub client {
    return $client;
}

sub count {
    my $c = shift;
    $count += $c if ($c);
    return $count;
}

sub explain {
    my ( $get, $ref ) = @_;
    $get = Dumper($get) if ( ref $get );
    print STDERR "Expect $ref, get $get\n";
}

1;
