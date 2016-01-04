#!/usr/bin/env perl -I pl/lib

use Test::More;
use strict;
use Lemonldap::NG::Manager::Constants;

use_ok('Lemonldap::NG::Manager::Build::Attributes');
my $count = 1;

my ( $attrs, $types );
ok( $attrs = Lemonldap::NG::Manager::Build::Attributes::attributes(),
    'Get attributes' );
ok( $types = Lemonldap::NG::Manager::Build::Attributes::types(), 'Get types' );
$count += 2;

foreach my $attr ( keys %$attrs ) {
    ok(
        (
                 ref( $attrs->{$attr}->{test} )
              or ref( $types->{ $attrs->{$attr}->{type} }->{test} )
              or $attrs->{$attr}->{type} =~ /Container$/
        ),
        "Test exists for $attr"
    );
    $count++;
    if ( $attr =~ qr/^$simpleHashKeys$/o ) {
        ok(
            (
                     ref $attrs->{$attr}->{keyTest}
                  or ref $types->{ $attrs->{$attr}->{type} }->{keyTest}
            ),
            "Key test for $attr"
        );
        $count++;
    }
}

done_testing($count);
