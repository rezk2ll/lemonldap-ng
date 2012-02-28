#!/usr/bin/perl

use Test::More;
use Test::Weaken qw(leaks);
use Lemonldap::NG::Portal;

my $p;

my $tester = Test::Weaken::leaks(
        {   constructor => sub {Lemonldap::NG::Portal::SharedConf->new()},
            destructor  => sub {my $p = shift;undef $p;undef $Lemonldap::NG::Portal::SharedConf::confCached},
        }
    );
    if ($tester) {
        my $unfreed_proberefs = $tester->unfreed_proberefs();
        my $unfreed_count     = @{$unfreed_proberefs};
        printf "Test 2: %d of %d original references were not freed\n",
            $tester->unfreed_count(), $tester->probe_count()
            or Carp::croak("Cannot print to STDOUT: $ERRNO");
        print "These are the probe references to the unfreed objects:\n"
            or Carp::croak("Cannot print to STDOUT: $ERRNO");
        for my $ix ( 0 .. $#{$unfreed_proberefs} ) {
            print Data::Dumper->Dump( [ $unfreed_proberefs->[$ix] ],
                ["unfreed_$ix"] )
                or Carp::croak("Cannot print to STDOUT: $ERRNO");
        }
    }
ok(!$tester);
