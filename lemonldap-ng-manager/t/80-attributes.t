use strict;
use Test::More;

my $knownExceptions = qr/^(?:remoteCookieName)$/;

ok( open( F, 'lib/Lemonldap/NG/Manager/Build/Attributes.pm' ),
    'open attributes file' );
my $count = 1;

while ( <F> !~ /sub\s+attributes/ ) { 1 }

my %h;

while (<F>) {
    next unless /^\s{8}["']?(\w+)/;
    my $attr = $1;
    $h{$attr}++;
    ok( $h{$attr} == 1, "$attr is uniq" );
    $count++;
}
close F;

use_ok('Lemonldap::NG::Manager::Build::Tree');
my $tree;
ok( $tree = Lemonldap::NG::Manager::Build::Tree::tree(), 'Get tree' );
$count += 2;

scanTree($tree);

done_testing($count);

my %h2;

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
        }
    }

}
