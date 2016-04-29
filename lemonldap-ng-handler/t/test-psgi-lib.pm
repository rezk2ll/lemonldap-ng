# Base library for tests

use strict;
use Data::Dumper;
use 5.10.0;
use_ok('Lemonldap::NG::Common::PSGI::Cli::Lib');

our $client;
our $count = 1;
$Data::Dumper::Deparse = 1;

my $module;

sub init {
    my $arg = shift;
    if ($arg) {
        $module = $arg;
        use_ok($module);
    }
    ok( $client = Lemonldap::NG::Handler::PSGI::Cli::Lib->new(),
        'Client object' );
    count(2);
}

sub client {
    return $client;
}

sub module {
    if ( my $arg = shift ) {
        $module = $arg;
    }
    return $module;
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

package Lemonldap::NG::Handler::PSGI::Cli::Lib;

use Mouse;

extends 'Lemonldap::NG::Common::PSGI::Cli::Lib';

has app => (
    is      => 'ro',
    isa     => 'CodeRef',
    builder => sub {
        return $module->run(
            {
                configStorage => { type => 'File', dirName => 't' },
                logLevel      => 'warn',
                cookieName    => 'lemonldap',
                securedCookie => 0,
                https         => 0,
            }
        );
    }
);

sub _get {
    my ( $self, $path, $query, $host, $cookie ) = @_;
    $query //= '';
    $host ||= 'test1.example.com';
    return $self->app->(
        {
            'HTTP_ACCEPT'          => 'text/html',
            'SCRIPT_NAME'          => 'lmAuth',
            'SERVER_NAME'          => '127.0.0.1',
            'QUERY_STRING'         => $query,
            'HTTP_CACHE_CONTROL'   => 'max-age=0',
            'HTTP_ACCEPT_LANGUAGE' => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
            'PATH_INFO'            => $path,
            'REQUEST_METHOD'       => 'GET',
            'REQUEST_URI'          => '/lmauth',
            'X_ORIGINAL_URI'       => $path . ( $query ? "?$query" : '' ),
            'SERVER_PORT'          => '80',
            'SERVER_PROTOCOL'      => 'HTTP/1.1',
            'HTTP_USER_AGENT' =>
              'Mozilla/5.0 (VAX-4000; rv:36.0) Gecko/20350101 Firefox',
            'REMOTE_ADDR' => '127.0.0.1',
            'HTTP_HOST'   => $host,
            ( $cookie ? ( HTTP_COOKIE => $cookie ) : ( HTTP_COOKIE => '' ) )
        }
    );
}

1;
