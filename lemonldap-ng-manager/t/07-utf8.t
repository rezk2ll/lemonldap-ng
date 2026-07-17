# Test if an UTF-8 char is well returned

use warnings;
use Test::More;
use strict;
use utf8;

my $str = "The LemonLDAP::NG team \x{a9}";

require 't/test-lib.pm';

my $href = &client->jsonResponse('/confs/1/cfgAuthor');

#binmode STDERR;

ok( $href->{value} eq $str, 'Value is well encoded' )
  or print STDERR "Expect '$href->{value}' eq '$str'";
count(1);

done_testing( count() );
