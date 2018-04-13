#!/usr/bin/perl -w
use strict;

use Test::More;
use Getopt::Std;
use CPAN::Meta;
use File::Temp;

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

    $module = read_conffile($conffile);
    return $module if defined $module;
    return getmeta();
}

sub read_conffile {
    my $conffile = shift;
    my $ret;
    if ( -f $conffile ) {
        open(M, "<", $conffile)
            or BAIL_OUT("$conffile exists but can't be read");
        while (<M>) {
            chomp;
            next if /^\s*#/;
            /(\S+)/ and $ret = $1, last;
        }
        close M;
        BAIL_OUT("can't find anything in $conffile")
            if !defined $ret;
    }
    return $ret;
}

sub getmeta {
    my $meta;
    my $dist;
    eval { $meta = CPAN::Meta->load_file('META.json') };
    eval { $meta = CPAN::Meta->load_file('META.yml' ) } if !$meta;
    plan skip_all => "can't guess package from META.json or META.yml"
        if !$meta;

    $dist = $meta->name;

    my $module = $dist;
    $module =~ s,-,::,g;

    my $file = "$dist.pm";
    $file =~ s,-,/,g;

    my $basefile = $file;
    $basefile =~ s,.*/,,;

    ( -f $basefile ) or (-f "lib/$file") or plan skip_all => "$basefile or lib/$file not found";

    return $module;
}

sub getwhitelist {
    my $whitelist = 'debian/tests/pkg-perl/use-whitelist';
    my $ret;
    $ret = read_conffile($whitelist) if ( -f $whitelist );
    $ret;
}

my @modules = @ARGV ? @ARGV : getmodule();

my $whitelist = getwhitelist();

usage() if !@modules;

plan tests => 4 * scalar @modules;

# don't run the command in the source directory, in case
# cwd is on @INC

my $dir;
$dir = $ENV{'AUTOPKGTEST_TMP'};
$dir = $ENV{'ADTTMP'} if !defined $dir;
$dir = File::Temp::tempdir( CLEANUP => 1 ) if !defined $dir;

chdir($dir) or die("can't chdir to $dir");

for my $mod (@modules) {
  for my $envprefix ('', 'env PERL_DL_NONLAZY=1 ') {
    my $cmd = qq($envprefix $^X -w -M"$mod" -e 1 2>&1);
    my @out = qx($cmd);
    note(@out) if @out;
    ok(!$?, "$cmd exited successfully");
    @out = grep { !/$whitelist/ } @out if defined $whitelist;
    ok(!@out, "$cmd produced no (non-whitelisted) output");
  }
}
