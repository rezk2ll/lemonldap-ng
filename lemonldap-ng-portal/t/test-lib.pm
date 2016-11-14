# Base library for portal tests
package main;

use strict;
use Data::Dumper;
use 5.10.0;

use_ok('Lemonldap::NG::Portal::Main');

our $count = 1;
$Data::Dumper::Deparse = 1;
my $ini;

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

package LLNG::Manager::Test;

use strict;
use Mouse;

extends 'Lemonldap::NG::Common::PSGI::Cli::Lib';

our $defaultIni = {
    configStorage       => { type => 'File', dirName => 't' },
    localSessionStorage => '',
    logLevel            => 'error',
    cookieName          => 'lemonldap',
    domain              => 'example.com',
    templateDir         => 'site/templates',
    staticPrefix        => '/index.fcgi',
    securedCookie       => 0,
    https               => 0,
};

has app => (
    is      => 'rw',
    isa     => 'CodeRef',
);

has ini => ( is => 'rw',
default => sub { $defaultIni; },
trigger => sub {
    my($self,$ini) = @_;
    foreach my $k (keys %$defaultIni) {
        $ini->{$k} //= $defaultIni->{$k};
    }
    $self->{ini} = $ini;
    main::ok($self->{app} = Lemonldap::NG::Portal::Main->run($ini),'Portal app');
    main::count(1);
    $self;
}
);

sub logout {
    my ($self,$id) = @_;
    my $res;
    main::ok(
        $res = $self->_get(
            '/',
            query  => 'logout',
            cookie => "lemonldap=$id",
            accept => 'text/html'
        ),
        'Logout'
    );
    main::ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
    my $c;
    main::ok( ( defined( $c = $self->getCookies($res)->{lemonldap} ) and not $c ),
        'Cookie is deleted' )
      or explain( $res->[1], "Set-Cookie => 'lemonldap='" );
    main::ok( $res = $self->_get( '/', cookie => "lemonldap=$id" ),
        'Disconnect request' )
      or explain( $res, '[<code>,<hdrs>,<content>]' );
    main::ok( $res->[0] == 401, 'Response is 401' ) or explain( $res, 401 );
    main::count(5);

}

sub getCookies {
    my ($self,$resp) = @_;
    my @hdrs = @{ $resp->[1] };
    my $res  = {};
    while ( my $name = shift @hdrs ) {
        my $v = shift @hdrs;
        if ( $name eq 'Set-Cookie' ) {
            if ( $v =~ /^(\w+)=([^;]*)/ ) {
                $res->{$1} = $2;
            }
        }
    }
    return $res;
}

sub _get {
    my ( $self, $path, %args ) = @_;
    return $self->app->(
        {
            'HTTP_ACCEPT' => $args{accept}
              || 'application/json, text/plain, */*',
            'HTTP_ACCEPT_LANGUAGE' => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
            'HTTP_CACHE_CONTROL'   => 'max-age=0',
            ( $args{cookie} ? ( HTTP_COOKIE => $args{cookie} ) : () ),
            'HTTP_HOST' => 'auth.example.com',
            'HTTP_USER_AGENT' =>
              'Mozilla/5.0 (VAX-4000; rv:36.0) Gecko/20350101 Firefox',
            'PATH_INFO' => $path,
            ( $args{referer} ? ( REFERER => $args{referer} ) : () ),
            'REMOTE_ADDR' => '127.0.0.1',
            (
                $args{remote_user}
                ? ( 'REMOTE_USER' => $args{remote_user} )
                : ()
            ),
            'REQUEST_METHOD' => 'GET',
            'REQUEST_URI'    => $path . ( $args{query} ? "?$args{query}" : '' ),
            ( $args{query} ? ( QUERY_STRING => $args{query} ) : () ),
            'SCRIPT_NAME'     => '',
            'SERVER_NAME'     => 'auth.example.com',
            'SERVER_PORT'     => '8002',
            'SERVER_PROTOCOL' => 'HTTP/1.1',
            ( $args{custom} ? %{ $args{custom} } : () ),
        }
    );
}

sub _post {
    my ( $self, $path, $body, %args ) = @_;
    die "$body must be a IO::Handle"
      unless ( ref($body) and $body->can('read') );
    return $self->app->(
        {
            'HTTP_ACCEPT' => $args{accept}
              || 'application/json, text/plain, */*',
            'HTTP_ACCEPT_LANGUAGE' => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
            'HTTP_CACHE_CONTROL'   => 'max-age=0',
            ( $args{cookie} ? ( HTTP_COOKIE => $args{cookie} ) : () ),
            'HTTP_HOST' => 'auth.example.com',
            'HTTP_USER_AGENT' =>
              'Mozilla/5.0 (VAX-4000; rv:36.0) Gecko/20350101 Firefox',
            'PATH_INFO' => $path,
            ( $args{query} ? ( QUERY_STRING => $args{query} ) : () ),
            ( $args{referer} ? ( REFERER => $args{referer} ) : () ),
            'REMOTE_ADDR' => '127.0.0.1',
            (
                $args{remote_user}
                ? ( 'REMOTE_USER' => $args{remote_user} )
                : ()
            ),
            'REQUEST_METHOD' => 'POST',
            'REQUEST_URI'    => $path . ( $args{query} ? "?$args{query}" : '' ),
            'SCRIPT_NAME'     => '',
            'SERVER_NAME'     => 'auth.example.com',
            'SERVER_PORT'     => '8002',
            'SERVER_PROTOCOL' => 'HTTP/1.1',
            ( $args{custom} ? %{ $args{custom} } : () ),
            'psgix.input.buffered' => 1,
            'psgi.input'           => $body,
            'CONTENT_LENGTH' => $args{length} // scalar( ( stat $body )[7] ),
            'CONTENT_TYPE'   => $args{type}
              || 'application/x-www-form-urlencoded',
        }
    );
}

1;
