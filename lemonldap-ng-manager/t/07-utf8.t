#!/usr/bin/env perl -I pl/lib
#
# Test if an UTF-8 char is well returned

use Test::More;
use JSON::MaybeXS;
use strict;
use utf8;

require 't/test-lib.pm';

my $href = &client->jsonResponse('/confs/1/cfgAuthor');
ok( $href->{value} eq "The LemonLDAP::NG team ©", 'Value is well encoded' );
count(1);

done_testing( count() );
