#!/usr/bin/perl

use strict;
use LWP::UserAgent;
use Time::HiRes qw(time);

use constant NB => 5;

my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->requests_redirectable( [] );

my ( $request, @get, @post, @menu, @cookies, @handler );

# Fake request to be sure that all is compiled
$request = new HTTP::Request( 'GET', 'http://127.0.0.1/' );
$ua->request( $request, \&cb_content );

$request = new HTTP::Request( 'GET', 'http://127.0.0.1:19876/' );
$request->header( Host => 'auth.example.com' );
for ( my $i = 0 ; $i < NB ; $i++ ) {
    my $time = time();
    $ua->request( $request, \&cb_content );
    my $time2 = time() - $time;
    push @get, $time2;
}

$request = new HTTP::Request( 'POST', 'http://127.0.0.1:19876/' );
$request->header( Host             => 'auth.example.com' );
$request->header( 'Content-Lenght' => '42' );
$request->header( 'Content-Type'   => 'application/x-www-form-urlencoded' );

$request->content('url=&user=dwho&password=dwho');
for ( my $i = 0 ; $i < NB ; $i++ ) {
    my $time     = time();
    my $response = $ua->request( $request, \&cb_content );
    my $time2    = time() - $time;
    if ( my $r = $response->code != 302 ) {
        print STDERR "$r\n" . $response->content . "\n";
        print STDERR "Headers :\n";
        $response->scan( sub { print $_[0] . ": " . $_[1] . "\n"; } );
        next;
    }
    $response->scan(
        sub {
            if ( $_[0] eq 'Set-Cookie' ) {
                my $c = $_[1];
                $c =~ s/;.*$//;
                push @cookies, $c;
            }
        }
    );
    push @post, $time2;
}

for ( my $i = 0 ; $i < NB ; $i++ ) {
    $request = new HTTP::Request( 'GET', 'http://127.0.0.1:19876/' );
    $request->header( Host => 'auth.example.com' );
    my $cookie = shift @cookies;
    $request->header( "Cookie", $cookie );
    my $time     = time();
    my $response = $ua->request( $request, \&cb_content );
    my $time2    = time() - $time;
    push @menu, $time2;
    $request = new HTTP::Request( 'GET', 'http://127.0.0.1:19876/' );
    $request->header( Host => 'test1.example.com' );
    $request->header( "Cookie", $cookie );

    for ( my $j = 0 ; $j < 5 ; $j++ ) {
        $time     = time();
        $response = $ua->request( $request, \&cb_content );
        $time2    = time() - $time;
        push @{ $handler[$i] }, $time2;
    }
}

#close LOG;

print "Result
+-----+-----------+----------+---------+-----------------------------------------+
| Req | Auth form | Post req |  Menu   |    5 access to test1.example.com        |
+-----+-----------+----------+---------+-----------------------------------------+
";

#  1  |  0.17408  |  0.03393 | 0.04451 | 0.02144 0.00719 0.00717 0.00717 0.00709
for ( my $i = 0 ; $i < NB ; $i++ ) {
    printf
      "| %-3d |  %3.5f  |  %3.5f | %3.5f | %3.5f %3.5f %3.5f %3.5f %3.5f |\n",
      $i + 1, $get[$i], $post[$i], $menu[$i], @{ $handler[$i] };
}

print
"+-----+-----------+----------+---------+-----------------------------------------+\n";

sub cb_content {

    #print LOG shift;
}

