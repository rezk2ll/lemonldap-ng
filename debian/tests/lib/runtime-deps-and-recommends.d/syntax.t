#!/usr/bin/perl -w
use strict;

use Test::More;
use Getopt::Std;

sub usage {
    my $exit = shift;
    $exit = 0 if !defined $exit;
    print "Usage: $0 [ package ] ...\n";
    print "\tpackages are read from debian/control if not given as arguments\n";
    exit $exit;
}

my %opts;
getopts('h', \%opts)
    or usage();

usage(0) if $opts{h};

sub getpackages {
    my @p;
    my $c = "debian/control";
    -f $c or BAIL_OUT("no packages listed and $c not found");
    open(C, '<', $c) or BAIL_OUT("opening $c for reading failed:$!");
    while (<C>) {
        chomp;
        /^\s*Package:\s+(\S+)/ and push @p, $1;
    }
    close C or BAIL_OUT("closing $c failed: $!");
    return @p;
}

sub readskip {
    my $skip = "debian/tests/pkg-perl/syntax-skip";
    $skip = "debian/tests/pkg-perl/skip-syntax" if ! -r $skip;
    -r $skip or return ();
    open (S, '<', $skip)
        or BAIL_OUT("$skip exists but can't be read");

    my @ret;
    while (<S>) {
        chomp;
        next if !/\S/;
        next if /^\s*#/;
        push @ret, qr/\Q$_\E/;
    }
    close S;
    return @ret;
}

my @packages = @ARGV ? @ARGV : getpackages();

usage() if !@packages;

plan tests => 4 * scalar @packages;

my @to_skip = readskip();

for my $package (@packages) {
    SKIP: {
        ok(!system(qq(dpkg-query --list "$package" >/dev/null 2>&1)),
            "Package $package is known to dpkg");

        skip "$package not installed", 3 if $?;

        my @status_info = qx{dpkg-query --status "$package"};
        ok(@status_info, "Got status information for package $package");
        skip "$package has Suggestions and no explicit skip list", 2
            if grep /^Suggests:/, @status_info and ! @to_skip;

        my @files = qx{dpkg-query --listfiles "$package" 2>/dev/null};

        ok(@files, "Got file list for package $package");

        skip "nothing to test", 1 if !@files;

        my @pms;
        F: for (@files) {
            chomp;
            next if !/\.pm$/;
            for my $skip_re (@to_skip) {
                note "skipping $_", next F if /$skip_re/;
            }
            my $oninc = 0;
            for my $incdir (@INC) {
                    $oninc++, last if /^\Q$incdir/;
            }
            next if !$oninc;
            push @pms, $_;
        }

        skip "no perl modules to test in $package", 1 if !@pms;

        subtest "all modules in $package pass the syntax check" => sub {
            plan tests => scalar @pms;
            for (@pms) {
                my @out = grep !/syntax OK/, qx($^X -wc $_ 2>&1);
                note(@out) if @out;
                ok(!$?, "$^X -wc $_ exited successfully");
            }
        }
    }
}
