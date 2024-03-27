use strict;
use Test::More;

our $count = 0;

our @excluded;

sub count {
    my ($i) = @_;
    $count += $i if $i;
    return $count;
}

sub getMods {
    my ($base) = @_;
    my $dir = "lib/$base";
    $dir =~ s#::#/#g;
    my $dh;
    opendir $dh, $dir or die $!;
    return sort map {
        s/^/${base}::/;
        s/\.pm//;
        $_;
    } grep /^[A-Za-z].*\.pm$/, readdir($dh);
}

sub testRequiredMethods {
    my ( $base, $methods, $excluded ) = @_;

    my %ex;
    %ex = map { ( "${base}::$_" => 1 ) } @$excluded if $excluded;
    my @mods = grep { not $ex{$_} } getMods($base);
    unless (@mods) {
        fail "No modules found in $base";
        count(1);
        return;
    }
    foreach my $mod (@mods) {
        subtest "$mod" => sub {
            use_ok($mod);
            my $o;
            ok( $o = $mod->new(), "Able to create $mod object" );
            count(2);
            foreach my $method (@$methods) {
                ok( $o->can($method), "$mod implement $method" );
            }
            done_testing();
        }
    }
}

1;
