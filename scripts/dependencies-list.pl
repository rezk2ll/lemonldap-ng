#!/usr/bin/perl

use strict;
use JSON;
use List::MoreUtils qw(uniq);

my $deps = {};

foreach my $module (qw(common handler portal manager)) {
    local $/ = undef;
    open my $f, '<', "lemonldap-ng-$module/META.json" or die $!;
    my $content = JSON::from_json(<$f>)->{prereqs};
    close $f;
    foreach my $target (qw(build runtime)) {
        foreach (qw(requires recommends)) {
            @{ $deps->{$target}->{$_} } = uniq(
                @{ $deps->{$target}->{$_} },
                ( grep { $_ !~ /^Lemonldap::NG/ } keys %{ $content->{$target}->{$_} } )
            ) if ( $content->{$target}->{$_} );
        }
    }
}

print "Step: build:\n";
print ' '
  . join(
    ' ',
    uniq(
        sort ( @{ $deps->{build}->{requires} },
            @{ $deps->{runtime}->{requires} } )
    )
  ) . "\n\n";

print "Step: runtime:\n";
print ' * required   : ' . join( ' ', sort @{ $deps->{runtime}->{requires} } ) . "\n";
print ' * recommended: ' . join( ' ', sort @{ $deps->{runtime}->{recommends} } ) . "\n";
