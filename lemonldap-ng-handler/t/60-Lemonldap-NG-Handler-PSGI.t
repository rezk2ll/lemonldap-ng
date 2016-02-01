#!/usr/bin/env perl -I pl/lib

use Test::More;
use JSON;
use strict;

require 't/test-psgi-lib.pm';

done_testing( count() );
