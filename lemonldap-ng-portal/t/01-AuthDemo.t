use Test::More;
use strict;

require 't/test-lib.pm';

print STDERR Dumper(&client->_get('/'));

done_testing( count() );
