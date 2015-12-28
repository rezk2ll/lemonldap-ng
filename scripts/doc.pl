#!/usr/bin/perl

#====================================================================
# Offline doc script
#
# Use Dokuwiki offline plugin
#
# This script is part of LemonLDAP::NG project
# Released under GPL license
#====================================================================

use strict;
use LWP::Simple;
use Tie::File;

my $offline_script_url =
  'http://lemonldap-ng.org/lib/plugins/offline/create.php';
my $offline_zip_url = 'http://lemonldap-ng.org/lib/plugins/offline/offline.zip';
my $remove_versions = [qw/latest 1.0 1.1 1.2 1.3 1.4/];
my $rc;

# Launch remote offline script
$rc = getprint($offline_script_url);
exit 1 if ( is_error($rc) );

# Get offline archive
$rc = getstore( $offline_zip_url, 'offline.zip' );
exit 1 if ( is_error($rc) );

# Unzip archive
system("unzip -o offline.zip");
system("rm -f offline.zip");

# Move offline contents in current directory
system("cp -rf offline/* .");
system("rm -rf offline");

# Keep only the latest
system("rm -rf pages/wiki pages/playground");
foreach my $version (@$remove_versions) {
    system("rm -rf pages/documentation/$version");
}
system('find . -name \*.html -exec sed -i "s#/latest/#/current/#g" {} \;');

# Rewrite documentation.html
tie my @documentation, 'Tie::File', 'pages/documentation.html'
  or die("Unable to open pages/documentation.html");

splice @documentation, 61, 27;

# Correct some bad media links
system('find . -name \*.html -exec sed -i "s#/_media#../media#g" {} \;');

# Remove unused pages
system("rm -rf pages/default_sidebar.html");
system("rm -rf pages/start.html");

# Rewrite index.html
tie my @index, 'Tie::File', 'index.html' or die("Unable to open index.html");

my @links = (
"\t\t<p><a href=\"pages/documentation.html\" class=\"wikilink1\">Documentation</a></p>",
    "\t\t<p><a href=\"pages/contact.html\" class=\"wikilink1\">Contact</a></p>",
"\t\t<p><a href=\"index/alphabetical.html\" class=\"wikilink1\">All pages</a></p>",
);

splice @index, 21, 2, @links;

# Remove external logos
system('rm -rf media/applications/ media/logos/');

# Remove Facebook iframe (See http://jira.ow2.org/browse/LEMONLDAP-674)
system('sed -i "/<iframe/d" pages/contact.html');

# Remove background image
system('sed -i "s#/lib/tpl/bootstrap3/images/background.jpg##g" css/*');

# Download missing images
system('mkdir -p lib/bootstrap3/images && cd lib/bootstrap3/images && wget -l 1 -nd -r http://lemonldap-ng.org/lib/tpl/bootstrap3/images/ && rm -f index* && cd -');

# Link duplicates files
system(q@find . -type f -printf "%s %p\n"|sort -n|perl -a -ne 'if($F[0]==$lf&&`md5sum $F[1]|cut -f1 -d" "` eq `md5sum $ln|cut -f1 -d" "`){print "ln -srf $ln $F[1]\n"}else{$lf=$F[0];$ln=$F[1]}'|sh@);

exit 0;
