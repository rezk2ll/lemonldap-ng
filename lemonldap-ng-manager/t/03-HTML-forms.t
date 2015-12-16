#!/usr/bin/env perl -I pl/lib

use Test::More;
use strict;
use 5.10.0;

my $formDir = 'site/static/forms';

my $count = 0;
use_ok('Lemonldap::NG::Manager::Tree');
use_ok('Lemonldap::NG::Manager::CTrees');
use_ok('Lemonldap::NG::Manager::Attributes');
$count += 3;

ok( opendir( D, $formDir ), 'Found forms dir' );
my %forms = map { s/\.html$// ? ( $_ => 1 ) : () } readdir D;
close D;

delete $forms{white};
delete $forms{restore};

my ( @types, $attr, $tree, $ctrees );
ok( $tree   = Lemonldap::NG::Manager::Tree::tree(),     'Get tree' );
ok( $ctrees = Lemonldap::NG::Manager::CTrees::cTrees(), 'Get cTrees' );
ok( $attr   = Lemonldap::NG::Manager::Attributes::attributes(),
    'Get attributes' );
$count += 4;

my %types = %{ getTypes( $tree, values(%$ctrees), $attr ) };

foreach (qw(home menuCat menuApp)) {
    ok( $forms{$_}, "Found $_ form" );
    $count++;
    delete $forms{$_};
}

foreach my $type ( keys %types ) {
    delete $types{$type};
    next
      if ( $type =~
/^(?:authParamsText|url|PerlModule|hostname|pcre|lmAttrOrMacro|subContainer|RSAP(?:ublic|rivate)Key)$/
      );
    ok( $forms{$type}, "Found $type" );
    delete $forms{$type};
    $count++;
    if ( $type =~ s/Container$// ) {
        next if ( $type eq 'simpleInput' );
        ok( $forms{$type}, "Found $type" );
        delete $forms{$type};
        $count++;
    }
}
ok( !%forms, "No unused forms" );
$count++;

done_testing($count);

sub getTypes {
    my @trees = @_;
    my $res = { 'text' => 1 };
    foreach my $t (@trees) {
        if ( ref($t) eq 'HASH' ) {
            foreach my $a ( values %$t ) {

                my $tmp = $a->{type};
                $res->{$tmp}++ if ($tmp);
            }
        }
        else {
            _getTypes( $t, $res );
        }
    }
    return $res;
}

sub _getTypes {
    my ( $tree, $res ) = splice @_;
    $tree = [$tree] unless ( ref($tree) );
    foreach my $k (@$tree) {
        if ( ref($k) ) {
            _getTypes( $k->{nodes},      $res ) if ( $k->{nodes} );
            _getTypes( $k->{nodes_cond}, $res ) if ( $k->{nodes_cond} );
            $res->{ $k->{form} }++ if ( $k->{form} );
        }
    }
}
