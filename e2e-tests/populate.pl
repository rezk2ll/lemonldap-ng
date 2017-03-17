#!/usr/bin/perl

package Test::Request;

use Mouse;

has userData    => ( is => 'rw' );
has sessionInfo => ( is => 'rw' );
has id          => ( is => 'rw' );

package main;
use Test::More;
use strict;
use POSIX qw(mktime strftime);
use lib 'lemonldap-ng-common/blib/lib';
use lib 'lemonldap-ng-handler/blib/lib';
use lib 'lemonldap-ng-portal/blib/lib';
use lib 'lemonldap-ng-manager/blib/lib';
require './lemonldap-ng-portal/t/test-lib.pm';

use constant COUNT => 1000;

my $portal = LLNG::Manager::Test->new(
    {
        ini => {
            configStorage => {
                type    => 'File',
                dirName => 'e2e-tests/conf',
            },
            localSessionStorage => undef,
            localStorage        => undef,
        }
    }
)->p;

my @chars = ( "A" .. "Z", "a" .. "z" );
foreach my $i ( 1 .. COUNT() ) {
    my $string;
    $string .= $chars[ rand @chars ] for 1 .. 8;

    #$string = 'dwho';
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime(time);
    $hour = int( rand($hour) );
    $min  = int( rand(60) );
    $sec  = int( rand(60) );
    my $ipAddr = (
        int( rand(2) ) == 1
        ? join( '.',
            int( rand(256) ),
            int( rand(256) ),
            int( rand(256) ),
            int( rand(256) ) )
        : join(
            ':',

            # Mix routable IPv6 addresses (2000::/3) and local ones (fe:80::/10)
            (
                int( rand(2) ) == 1
                ? sprintf( "%X",      int( rand(8192) + 8192 ) )
                : sprintf( "fe80:%X", int( rand(16384) ) )
            ),
            sprintf( "%X", int( rand(65536) ) ),
            sprintf( "%X", int( rand(65536) ) ),
            sprintf( "%X", int( rand(65536) ) ),
            sprintf( "%X", int( rand(65536) ) ),
            sprintf( "%X", int( rand(65536) ) ),
            sprintf( "%X", int( rand(65536) ) ),
            sprintf( "%X", int( rand(65536) ) )
        )
    );

    # Replace 0 in IPv6 addresses
    if ( $ipAddr =~ ':0:' ) {
        my @t   = ( $ipAddr =~ /\:(?:0\:)+/g );
        my $ind = -1;
        my $len = 0;
        for ( my $i = 0 ; $i < @t ; $i++ ) {
            $ind = $i if ( length( $t[$i] ) > $len );
        }
        $ipAddr =~ s/$t[$ind]/::/;
        $ipAddr =~ s/^0//;
        print STDERR "Found IPv6 :: => $string\n";
    }
    my $req = Test::Request->new(
        {
            sessionInfo => {
                _user     => $string,
                uid       => $string,
                cn        => uc($string),
                sn        => $string,
                mail      => "$string\@badwolf.org",
                _utime    => mktime( $sec, $min, $hour, $mday, $mon, $year ),
                startTime => strftime(
                    "%Y%m%d%H%M%S",
                    $sec,  $min,  $hour, $mday, $mon,
                    $year, $wday, $yday, $isdst
                ),
                ipAddr => $ipAddr,
            }
        }
    );

    $portal->setMacros($req);
    $portal->store($req);
}
done_testing( count() );
