#!/usr/bin/env perl
#
# Verify that all attributes are positionned in tree and that all leaf
# correspond to an attribute. Verify also that attributes and leafs are uniq

use strict;
use Test::More;

my $knownExceptions = qr/^(?:remoteCookieName)$/;

my @notManagedAttributes = qw(
  samlSPMetaDataOptions samlIDPMetaDataOptions
  oidcRPMetaDataOptions oidcOPMetaDataOptions
  cfgAuthor cfgAuthorIP cfgNum cfgDate cfgLog
  vhostOptions staticPrefix multiValuesSeparator
  protection redirectFormMethod infoFormMethod
  activeTimer confirmFormMethod
);

ok( open( F, 'lib/Lemonldap/NG/Manager/Build/Attributes.pm' ),
    'open attributes file' );
my $count = 1;

while ( <F> !~ /sub\s+attributes/ ) { 1 }

my ( %h, %h2 );

while (<F>) {
    next unless /^\s{8}["']?(\w+)/;
    my $attr = $1;
    $h{$attr}++;
    ok( $h{$attr} == 1, "$attr is uniq" );
    $count++;
}
close F;

use_ok('Lemonldap::NG::Manager::Build::Tree');
use_ok('Lemonldap::NG::Manager::Build::CTrees');
my $tree;
ok( $tree = Lemonldap::NG::Manager::Build::Tree::tree(), 'Get tree' );
$count += 3;

scanTree($tree);
ok( $tree = Lemonldap::NG::Manager::Build::CTrees::cTrees(),
    'Get conditional tree' );
$count++;
foreach my $t ( values %$tree ) {
    scanTree($t);
}

foreach ( keys %h2 ) {
    s/^\*//;
    ok( delete( $h{$_} ), "Leaf $_ exists in attributes" );
    $count++;
}
foreach (@notManagedAttributes) {
    ok( delete( $h{$_} ), "Unmanaged attribute '$_' is declared" );
    $count++;
}

done_testing($count);

sub scanTree {
    my $tree = shift;
    if ( ref $tree ) {
        ok( ref($tree) eq 'ARRAY', 'Tree is an array' );
        $count++;
        foreach my $leaf (@$tree) {
            if ( ref $leaf ) {
                my $name;
                ok( $name = $leaf->{title}, "Node has a name" );
                ok( $name =~ /^\w+$/, "Name is a string" );
                ok( ref($leaf) eq 'HASH' );
                ok(
                    (
                             exists( $leaf->{nodes} )
                          or exists( $leaf->{nodes_cond} )
                          or exists( $leaf->{group} )
                    ),
                    "Node $name has leafs"
                );
                $count += 4;
                foreach my $n (qw(nodes nodes_cond group)) {
                    scanTree( $leaf->{$n} ) if ( exists $leaf->{$n} );
                }
            }
            elsif ( $leaf !~ $knownExceptions ) {
                ok( $leaf =~ /^\*?\w+/, "Leaf is an attribute name ($leaf)" );
                $h2{$leaf}++;
                ok( $h2{$leaf} == 1, "$leaf is uniq" );
                $count += 2;
            }
            else {
                $h2{$leaf}++;
            }
        }
    }
}
