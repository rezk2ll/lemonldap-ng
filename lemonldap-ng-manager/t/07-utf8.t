#!/usr/bin/env perl -I pl/lib
#
# Test if an UTF-8 char is well returned

use Test::More;
use JSON::MaybeXS;
use strict;

require 't/test-lib.pm';

my $href = &client->jsonResponse('/confs/1/cfgAuthor');
 print STDERR Dumper($href);use Data::Dumper;

done_testing( count() );
