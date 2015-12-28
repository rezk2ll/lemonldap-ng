#!/usr/bin/env perl -I pl/lib

use Test::More;
use strict;
use 5.10.0;

require 't/test-lib.pm';

my $res;

ok( $res = get('/'), 'Succeed to get /' );
my %hdrs = @{ $res->[1] };
ok( $res->[0] == 200, 'Return a 200 code' )
  or print STDERR "Received" . Dumper($res);
ok( $hdrs{'Content-Type'} =~ /text\/html$/i, 'Content is declared as HTML' );
ok( $res->[2]->[0] =~ /<html/si,             'It contains a html tag' );

count(4);

done_testing( count() );

