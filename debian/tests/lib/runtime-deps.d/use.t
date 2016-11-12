#!/usr/bin/perl -w
use strict;

use Test::More;
use Getopt::Std;
use CPAN::Meta;

sub usage {
    my $exit = shift;
    $exit = 0 if !defined $exit;
    print "Usage: $0 [ Some::Module] ...\n";
    print "\tthe perl module is guessed from META.{json,yml} if not given as argument\n";
    exit $exit;
}

my %opts;
getopts('h', \%opts)
    or usage();

usage(0) if $opts{h};

sub getmodule {
    my $module;
    my $conffile = "debian/tests/pkg-perl/use-name";
    $conffile = "debian/tests/pkg-perl/module-name" if ! -e $conffile; # backcompat
    $conffile = "debian/tests/module-name" if ! -e $conffile; # backcompat squared
    if ( -f $conffile ) {
        open(M, "<", $conffile)
            or BAIL_OUT("$conffile exists but can't be read");
        while (<M>) {
            chomp;
            next if /^\s*#/;
            /(\S+)/ and $module = $1, last;
        }
	close M;
        BAIL_OUT("can't find a module name in $conffile")
            if !defined $module;
	return $module;
    }

    my $meta;
    my $dist;
    eval { $meta = CPAN::Meta->load_file('META.json') };
    eval { $meta = CPAN::Meta->load_file('META.yml' ) } if !$meta;
    plan skip_all => "can't guess package from META.json or META.yml"
        if !$meta;

    $dist = $meta->name;

    $module = $dist;
    $module =~ s,-,::,g;

    my $file = "$dist.pm";
    $file =~ s,-,/,g;

    my $basefile = $file;
    $basefile =~ s,.*/,,;

    ( -f $basefile ) or (-f "lib/$file") or plan skip_all => "$basefile or lib/$file not found";

    return $module;
}

my @modules = @ARGV ? @ARGV : getmodule();

usage() if !@modules;

plan tests => 2 * scalar @modules;

for my $mod (@modules) {
    my $cmd = qq($^X -w -M"$mod" -e 1 2>&1);
    my @out = qx($cmd);
    note(@out) if @out;
    ok(!$?, "$cmd exited successfully");
    ok(!@out, "$cmd produced no output");
}
