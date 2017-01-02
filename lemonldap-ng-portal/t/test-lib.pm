# Base library for portal tests
package main;

use strict;
use Data::Dumper;
use LWP::UserAgent;
use URI::Escape;
use 5.10.0;

no warnings 'redefine';

BEGIN {
    use_ok('Lemonldap::NG::Portal::Main');
}

our $count = 1;
$Data::Dumper::Deparse = 1;
my $ini;

sub count {
    my $c = shift;
    $count += $c if ($c);
    return $count;
}

sub main::explain {
    my ( $get, $ref ) = @_;
    $get = Dumper($get) if ( ref $get );
    print STDERR "Expect $ref, get $get\n";
}

sub clean_sessions {
    opendir D, 't/sessions' or die $!;
    foreach ( grep { /^[^\.]/ } readdir(D) ) {
        unlink "t/sessions/$_", "t/sessions/lock/Apache-Session-$_.lock";
    }
    foreach my $dir (qw(t/sessions/lock t/sessions/saml/lock t/sessions/saml)) {
        if ( -d $dir ) {
            opendir D, $dir or die $!;
            foreach ( grep { /^[^\.]/ } readdir(D) ) {
                unlink "$dir/$_";
            }
        }
    }
}

sub expectRedirection {
    my ( $res, $location ) = @_;
    ok( $res->[0] == 302, ' Get redirection' )
      or explain( $res->[0], 302 );
    count(1);
    if ( ref $location ) {
        my @match;
        @match = ( getRedirection($res) =~ $location );
        ok( @match, ' Location header found' )
          or explain( $res->[1], "Location match: " . Dumper($location) );
        count(1);
        return @match;
    }
    else {
        ok( getRedirection($res) eq $location, " Location is $location" )
          or explain( $res->[1], "Location => $location" );
count(1);
    }
}

sub expectAutoPost {
    my @r = expectForm(@_);
    my $method = pop @r;
    ok ( $method =~ /^post$/i, ' Method is POST' ) or explain (\@r,'POST');
    count(1);
    return @r;
}

sub expectForm {
    my ( $res, $hostRe, $uriRe, @requiredFields ) = @_;
    expectOK($res);
    count(1);
    if (
        ok(
            $res->[2]->[0] =~
              m@<form.+?action="(?:http://([^/]+)(/.*?)?|(#))".+method="(post|get)"@is,
            ' Page contains a form'
        )
      )
    {
        my ( $host, $uri, $hash, $method ) = ( $1, $2, $3, $4 );
        if($hash and $hash eq '#') {
            $host = '#';
            $uri = '';
        }
        if ($hostRe) {
            if ( ref $hostRe ) {
                ok( $host =~ $hostRe, ' Host match' )
                  or explain( $host, $hostRe );
            }
            else {
                ok( $host eq $hostRe, ' Host match' )
                  or explain( $host, $hostRe );
            }
            count(1);
        }
        if ($uriRe) {
            if ( ref $uriRe ) {
                ok( $uri =~ $uriRe, ' URI match' ) or explain( $uri, $uriRe );
            }
            else {
                ok( $uri eq $uriRe, ' URI match' ) or explain( $uri, $uriRe );
            }
            count(1);
        }
        my %fields = ( $res->[2]->[0] =~
              m#<input.+?name="(.+?)".+?value="(.+?)"#gs );
        my $query = join( '&',
            map { "$_=" . uri_escape( uri_unescape( $fields{$_} ) ) }
              keys(%fields) );
        foreach my $f (@requiredFields) {
            ok( defined $fields{$f}, qq{ Field "$f" is defined} );
            count(1);
        }
        return ( $host, $uri, $query, $method );
    }
    else {
        return ();
    }
}

sub expectAuthenticatedAs {
    my ( $res, $user ) = @_;
    ok( getHeader( $res, 'Lm-Remote-User' ) eq $user, " Authenticated as $user" )
      or explain( $res->[1], "Lm-Remote-User => $user" );
    count(1);
}

sub expectOK {
    my ($res) = @_;
    ok( $res->[0] == 200, ' HTTP code is 200' ) or explain( $res, 200 );
    count(1);
}

sub expectBadRequest {
    my ($res) = @_;
    ok( $res->[0] == 400, ' HTTP code is 400' ) or explain( $res->[0], 400 );
    count(1);
}

sub expectReject {
    my ($res) = @_;
    ok( $res->[0] == 401, ' Response is 401' ) or explain( $res->[0], 401 );
    count(1);
}

sub expectCookie {
    my ( $res, $cookieName ) = @_;
    $cookieName ||= 'lemonldap';
    my $cookies = getCookies($res);
    my $id;
    ok( defined( $id = $cookies->{$cookieName} ), " Get cookie $cookieName" )
      or explain( $res->[1], "Set-Cookie: $cookieName=something" );
    count(1);
    return $id;
}

sub getCookies {
    my ($resp) = @_;
    my @hdrs   = @{ $resp->[1] };
    my $res    = {};
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

sub getHeader {
    my ( $resp, $hname ) = @_;
    my @hdrs = @{ $resp->[1] };
    my $res  = {};
    while ( my $name = shift @hdrs ) {
        my $v = shift @hdrs;
        if ( $name eq $hname ) {
            return $v;
        }
    }
    return undef;
}

sub getRedirection {
    my ($resp) = @_;
    return getHeader( $resp, 'Location' );
}

sub getUser {
    my ($resp) = @_;
    return getHeader( $resp, 'Lm-Remote-User' );
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
    is  => 'rw',
    isa => 'CodeRef',
);

has ini => (
    is      => 'rw',
    default => sub { $defaultIni; },
    trigger => sub {
        my ( $self, $ini ) = @_;
        foreach my $k ( keys %$defaultIni ) {
            $ini->{$k} //= $defaultIni->{$k};
        }
        $self->{ini} = $ini;
        main::ok( $self->{app} = Lemonldap::NG::Portal::Main->run($ini),
            'Portal app' );
        main::count(1);
        $self;
    }
);

sub logout {
    my ( $self, $id ) = @_;
    my $res;
    main::ok(
        $res = $self->_get(
            '/',
            query  => 'logout',
            cookie => "lemonldap=$id",
            accept => 'text/html'
        ),
        'Logout request'
    );
    main::ok( $res->[0] == 200, 'Response is 200' )
      or explain( $res->[0], 200 );
    my $c;
    main::ok(
        ( defined( $c = main::getCookies($res)->{lemonldap} ) and not $c ),
        'Cookie is deleted' )
      or explain( $res->[1], "Set-Cookie => 'lemonldap='" );
    main::ok( $res = $self->_get( '/', cookie => "lemonldap=$id" ),
        'Disconnect request' )
      or explain( $res, '[<code>,<hdrs>,<content>]' );
    main::ok( $res->[0] == 401, 'Response is 401' ) or explain( $res, 401 );
    main::count(5);

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
            'SERVER_PORT'     => '80',
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
            ( $args{query}   ? ( QUERY_STRING => $args{query} )   : () ),
            ( $args{referer} ? ( REFERER      => $args{referer} ) : () ),
            'REMOTE_ADDR' => '127.0.0.1',
            (
                $args{remote_user}
                ? ( 'REMOTE_USER' => $args{remote_user} )
                : ()
            ),
            'REQUEST_METHOD' => 'POST',
            'REQUEST_URI'    => $path . ( $args{query} ? "?$args{query}" : '' ),
            'SCRIPT_NAME'    => '',
            'SERVER_NAME'    => 'auth.example.com',
            'SERVER_PORT'    => '80',
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
