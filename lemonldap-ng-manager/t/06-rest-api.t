#!/usr/bin/env perl

use Test::More;
use 5.10.0;
use strict;
use JSON;
use IO::String;
require 't/test-lib.pm';

my $res;
ok(
    $res =
      post( '/confs/newRSAKey', '',
        IO::String->new(''), 'application/json', 0, ),
    "Request succeed"
);
ok( $res->[0] == 200, "Result code is 200" );
my $key;
ok( $key = decode_json( $res->[2]->[0] ), 'Response is JSON' );
count(3);

ok(
    $res = post(
        '/confs/newRSAKey', '', IO::String->new('{"password":"hello"}'),
        'application/json', 20,
    ),
    "Request succeed"
);
ok( $res->[0] == 200, "Result code is 200" );
ok( $key = decode_json( $res->[2]->[0] ), 'Response is JSON' );
count(3);
#print STDERR Dumper($key);use Data::Dumper;

done_testing( count() );
