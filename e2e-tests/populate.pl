#!/usr/bin/perl

package Test::Request;

use Mouse;

has userData    => ( is => 'rw' );
has sessionInfo => ( is => 'rw' );
has id          => ( is => 'rw' );

package main;
use Test::More;
use strict;
use lib 'lemonldap-ng-common/blib/lib';
use lib 'lemonldap-ng-handler/blib/lib';
use lib 'lemonldap-ng-portal/blib/lib';
use lib 'lemonldap-ng-manager/blib/lib';
require './lemonldap-ng-portal/t/test-lib.pm';

my $portal = LLNG::Manager::Test->new(
    {
        ini => {
            configStorage => {
                type    => 'File',
                dirName => 'e2e-tests/conf',
            },
        }
    }
)->p;

my @chars = ( "A" .. "Z", "a" .. "z" );
foreach my $i ( 1 .. 100000 ) {
    my $string;
    $string .= $chars[ rand @chars ] for 1 .. 8;
    my $req = Test::Request->new(
        {
            sessionInfo => {
                _user => $string,
                uid   => $string,
                cn    => uc($string),
                sn    => $string,
                mail  => "$string\@badwolf.org",
            }
        }
    );

    $portal->setMacros($req);
    $portal->store($req);
}
done_testing( count() );
