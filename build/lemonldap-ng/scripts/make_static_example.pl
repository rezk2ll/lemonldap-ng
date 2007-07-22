#!/usr/bin/perl

use strict;

die "usage: static.pl script.pl index.html" unless (@ARGV);

my $script = $ARGV[0];
my $dir    = `pwd`;
chomp $dir;
our $lib = "$dir/lemonldap-ng-manager/blib/lib/";
$script = "$dir/$script" unless ( $script =~ m#^/# );
my $file = $ARGV[1];
my $lang = $ARGV[2] || "en";
$file =~ s#^.*/##;
$dir = $&;
`mkdir -p $dir` unless ( -d $dir );
chdir $dir;

&scan( $script, $file, '' );

sub scan {
    my ( $script, $filename, $args ) = @_;
    print STDERR "$filename\n";
    my ( $IN, $OUT );
    open $IN, "HTTP_ACCEPT_LANGUAGE=$lang SCRIPT_NAME=__SCRIPTNAME__ SCRIPT_FILENAME=$script perl -I$lib $script '$args'|";
    open $OUT, ">$filename";
    my $ind = 0;
    local ( $_, $1 );
    while (<$IN>) {
        s/\r//g;
        if (/lmQuery/) {
            s/__SCRIPTNAME__\?lmQuery=conf&cfgNum="\+n/conf.xml"/;
            if (s/__SCRIPTNAME__\?lmQuery=([^"']*)js/$1.js/) {
                scan( $script, "$1.js", "lmQuery=$1js" );
            }
            elsif (s/__SCRIPTNAME__\?lmQuery=upload/#/) {
                # Nothing to do here
            }
            elsif (s/__SCRIPTNAME__\?lmQuery=conf/conf.xml/) {
                scan( $script, "conf.xml", "lmQuery=conf&cfgNum=0" );
            }
            elsif (s/__SCRIPTNAME__\?lmQuery=([^"']*)css/style$1.css/) {
                scan( $script, "style$1.css", "lmQuery=$1css" );
            }
            elsif (s/__SCRIPTNAME__\?lmQuery=help&help="\+s/help_"+s+".html"/) {
                # Nothing to do here
            }
            elsif (s/__SCRIPTNAME__\?lmQuery=([^"'&]*)&?[^"']*/$1/) {
                scan( $script, "$1", "lmQuery=$1" );
            }
            s/["']help["']\+s/"help"/;
        }
        elsif (/help\((['"])(\w+)\1/) {
            scan( $script, "help_$2.html", "lmQuery=help&help=$2" );
        }
	# but+=button('$text{saveConf}','saveConf',nodeId);
        elsif (s/(but\+=)button\((['"])([^'"]*)\2,'saveConf.*$/$1'<input type=button value="$3" onclick="alert(\\'This is a demo\\');saveConf;"> &nbsp;';/) {
	    # '<input type=button value="'+text+'" onclick="'+func+'('+"'"+nodeId+"'"+')"> &nbsp; '
            # Nothing to do here
        }
        s#tree.setImagePath\(["'][^"']*["']\);#tree.setImagePath("imgs/")#;
        print $OUT $_ if ($ind);
        $ind++        if /^$/;
    }
}

