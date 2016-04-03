use Test::More;
use strict;

require 't/test-lib.pm';

print STDERR Dumper(&client);

done_testing( count() );
