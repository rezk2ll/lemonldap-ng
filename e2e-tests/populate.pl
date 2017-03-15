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
            }
        }
    );

    $portal->setMacros($req);
    $portal->store($req);
}
done_testing( count() );
