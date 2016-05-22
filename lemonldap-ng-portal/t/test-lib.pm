# Base library for portal tests

use strict;
use Data::Dumper;
use 5.10.0;

BEGIN {
    use_ok('Lemonldap::NG::Portal::Main');
}

our $client;
our $count = 1;
$Data::Dumper::Deparse = 1;
my $ini;

sub init {
    $ini = shift;
    $ini ||= {};
    $ini->{configStorage} ||= { type => 'File', dirName => 't' };
    $ini->{localSessionStorage} ||= '';
    $ini->{logLevel}            ||= 'error';
    $ini->{cookieName}          ||= 'lemonldap';
    $ini->{templateDir}         ||= 'site/templates';
    $ini->{staticPrefix}        ||= '/index.fcgi';
    $ini->{securedCookie} //= 0;
    $ini->{https}         //= 0;
    ok( $client = My::Cli->new(), 'Portal app' );
    count(1);
}

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

sub logout {
    my ($id) = @_;
    my $res;
    ok(
        $res = &client->_get(
            '/',
            query  => 'logout',
            cookie => "lemonldap=$id",
            accept => 'text/html'
        ),
        'Logout'
    );
    ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
    ok( $res = &client->_get( '/', cookie => "lemonldap=$id" ),
        'Disconnect request' );
    ok( $res->[0] == 401, 'Response is 401' ) or explain( $res, 401 );
    count(4);

}

sub clean_sessions {
    opendir D, 't/sessions' or die $!;
    foreach ( grep { /^[^\.]/ } readdir(D) ) {
        unlink "t/sessions/$_", "t/sessions/lock/Apache-Session-$_.lock";
    }
    opendir D, 't/sessions/lock' or die $!;
    foreach ( grep { /^[^\.]/ } readdir(D) ) {
        unlink "t/sessions/lock/$_";
    }
}

sub getCookies {
    my $req  = shift;
    my @hdrs = @{ $req->[1] };
    my $res  = {};
    while ( my $name = shift @hdrs ) {
        my $v = shift @hdrs;
        if ( $name eq 'Set-Cookie' ) {
            if ( $v =~ /^(\w+)=([^;]+)/ ) {
                $res->{$1} = $2;
            }
        }
    }
    return $res;
}

package My::Cli;

use strict;
use Mouse;

extends 'Lemonldap::NG::Common::PSGI::Cli::Lib';

has app => (
    is      => 'ro',
    isa     => 'CodeRef',
    builder => sub {
        return Lemonldap::NG::Portal::Main->run($ini);
    }
);

sub _get {
    my ( $self, $path, %args ) = @_;
    return $self->app->(
        {
            'HTTP_ACCEPT' => $args{accept}
              || 'application/json, text/plain, */*',
            'HTTP_ACCEPT_LANGUAGE' => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
            'HTTP_CACHE_CONTROL'   => 'max-age=0',
            ( $args{cookie} ? ( 'HTTP_COOKIE' => $args{cookie} ) : () ),
            'HTTP_HOST' => 'auth.example.com',
            'HTTP_USER_AGENT' =>
              'Mozilla/5.0 (VAX-4000; rv:36.0) Gecko/20350101 Firefox',
            'PATH_INFO'   => $path,
            'REMOTE_ADDR' => '127.0.0.1',
            (
                $args{remote_user}
                ? ( 'REMOTE_USER' => $args{remote_user} )
                : ()
            ),
            'REQUEST_METHOD' => 'GET',
            'REQUEST_URI'    => $path . ( $args{query} ? "?$args{query}" : '' ),
            ( $args{query} ? ( 'QUERY_STRING' => $args{query} ) : () ),
            'SCRIPT_NAME'     => '',
            'SERVER_NAME'     => 'auth.example.com',
            'SERVER_PORT'     => '8002',
            'SERVER_PROTOCOL' => 'HTTP/1.1',
        }
    );
}

1;
