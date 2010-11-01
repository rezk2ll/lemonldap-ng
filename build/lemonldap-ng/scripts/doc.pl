#!/usr/bin/perl

#====================================================================
# Offline doc script
#
# Use Dokuwiki offline plugin
#
# This script is part of LemonLDAP::NG project
# Released under GPL licence
#====================================================================

use strict;
use LWP::Simple;
use Tie::File;

my $offline_script_url =
  'http://lemonldap-ng.org/lib/plugins/offline/create.php';
my $offline_zip_url = 'http://lemonldap-ng.org/lib/plugins/offline/offline.zip';
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

# Correct some bad media links
system('find . -name \*.html -exec sed -i "s#/_media#../media#g" {} \;');

# Rewrite index.html
tie my @index, 'Tie::File', 'index.html' or die("Unable to open index.html");

my @links = (
"\t\t<p><a href=\"pages/documentation.html\" class=\"wikilink1\">Documentation</a></p>",
    "\t\t<p><a href=\"pages/contact.html\" class=\"wikilink1\">Contact</a></p>",
"\t\t<p><a href=\"index/alphabetical.html\" class=\"wikilink1\">All pages</a></p>",
);

splice @index, 22, 1, @links;

exit 0;
