#!/usr/bin/perl

#====================================================================
# Offline doc script
#
# Use Dokuwiki exportsite plugin
# https://www.dokuwiki.org/plugin:siteexport
#
# This script is part of LemonLDAP::NG project
# Released under GPL license
#====================================================================

use strict;
use LWP::Simple;
use Tie::File;

my $version = "2.0";
my $offline_zip_url = "http://lemonldap-ng.org/documentation/$version/start?depth=0&depthType=1.0&disableCache=1&do=siteexport&ens=documentation%3A$version%3Astart&exportLinkedPages=1&exportbody=1&renderer=&template=bootstrap3&disableplugin[]=acl&disableplugin[]=config&disableplugin[]=extension&disableplugin[]=oddeven&disableplugin[]=siteexport&disableplugin[]=usermanager";
my $rc;

# Get offline archive
$rc = getstore( $offline_zip_url, 'siteexport.zip' );
exit 1 if ( is_error($rc) );

# Remove old doc
system('rm -rf pages/documentation/current/*');

# Unzip archive
system("unzip -o siteexport.zip -d pages/documentation/current/");
system("rm -f siteexport.zip");

# Remove some files
system('rm -rf pages/documentation/current/screenshots');
system('rm -rf pages/documentation/current/_export');

# Remove external logos and replace them by a default image
system('rm -rf pages/documentation/current/applications/*png pages/documentation/current/applications/*gif pages/documentation/current/applications/*jpeg');
system('find . -name \*.html -exec sed -i "s#applications/[^\"]*\.\(png\|jpeg\|gif\)#icons/kmultiple.png#g" {} \;');

# Remove background image
system('sed -i "s#/lib/tpl/bootstrap3/images/background.jpeg##g" pages/documentation/current/lib/exe/css*');

# Remove alternate and canonical head links fo fix lintian privacy-breach-generic errors
system('find . -name \*.html -exec sed -i "/<link rel=\"alternate\"/d" {} \;');
system('find . -name \*.html -exec sed -i "/<link rel=\"canonical\"/d" {} \;');
system('find . -name \*.html -exec sed -i "/oss\.maxcdn\.com/d" {} \;');

# Remove embedded jQuery
open F, 'pages/documentation/current/lib/exe/js.php.t.bootstrap3.js';
my $buf;
while (<F>) {
    last if (m#^/\*.*jQuery#);
    $buf .= $_;
}
close F;
open F, ">pages/documentation/current/lib/exe/js.php.t.bootstrap3.js";
print F $buf;
close F;

# Unminify CSS (to avoid "src is missing" warning
open F, 'pages/documentation/current/lib/exe/css.php.t.bootstrap3.css';
$buf = join '', map {
    s/([;\}\{])/$1\n/g;
    $_;
} <F>;
close F;
open F, '>pages/documentation/current/lib/exe/css.php.t.bootstrap3.css';
print F $buf;
close F;

# Replace links in HTML files
my $cssbootstrap = '<!-- //if:usedebianlibs
  <link rel="stylesheet" type="text/css" href="/javascript/bootstrap/css/bootstrap.min.css" />
//elsif:useexternallibs
  <link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"></script>
//elsif:cssminified
  <link rel="stylesheet" type="text/css" href="/static/bwr/bootstrap/dist/css/bootstrap.min.css" />
//else -->
  <link rel="stylesheet" type="text/css" href="/static/bwr/bootstrap/dist/css/bootstrap.css" />
<!-- //endif -->';
my $jquery = '<!-- //if:usedebianlibs
<script type="text/javascript" src="/javascript/jquery/jquery.min.js"></script>
//elsif:useexternallibs
<script type="text/javascript" src="http://code.jquery.com/jquery-2.2.0.min.js"></script>
//elsif:jsminified
<script type="text/javascript" src="/static/bwr/jquery/dist/jquery.min.js"></script>
//else -->
<script type="text/javascript" src="/static/bwr/jquery/dist/jquery.js"></script>
<!-- //endif -->';
my $jqueryui = '<!-- //if:usedebianlibs
  <script type="text/javascript" src="/javascript/jquery-ui/jquery-ui.min.js"></script>
//elsif:useexternallibs
  <script type="text/javascript" src="http://code.jquery.com/ui/1.10.4/jquery-ui.min.js"></script>
//elsif:jsminified
  <script type="text/javascript" src="/lib/scripts/jquery-ui.min.js"></script>
//else -->
  <script type="text/javascript" src="/lib/scripts/jquery-ui.js"></script>
<!-- //endif -->';

open CMD, "find . -name '*.html'|";
my @list = map { chomp; $_ } <CMD>;
close CMD;

for my $file (@list) {
    open F, $file;
    my $buf = join '', map {
s#<link.*,href=".*bootstrap\.min\.css.*$"#$cssbootstrap#;
s#src=".*bootstrap.min.js"#src="/javascript/bootstrap/js/bootstrap.min.js"#;
        s#(<link.*?lib/exe/css.php.t.bootstrap3.css"/>)#$1
$cssbootstrap#;
        s#(<script.*?bootstrap3.js"></script>)#$1
$jquery
$jqueryui#;
        $_;
    } <F>;
    open F, ">$file";
    print F $buf;
    close F;
}

# Put content in a container
system('find . -name \*.html -exec sed -i "s#<div class=\"dokuwiki export\">#<div class=\"dokuwiki export container\">#" {} \;');

# Responsive images
system('find . -name \*.html -exec sed -i "s#<img class=\"mediacenter\">#<img class=\"mediacenter img-responsive\">#" {} \;');

# Tables
system('find . -name \*.html -exec sed -i "s#<table class=\"inline\">#<table class=\"inline table table-bordered table-striped\">#" {} \;');

# Link duplicates files
system(q@find . -type f -printf "%s %p\n"|sort -n|perl -a -ne 'if($F[0]==$lf&&`md5sum $F[1]|cut -f1 -d" "` eq `md5sum $ln|cut -f1 -d" "`){print "ln -srf $ln $F[1]\n"}else{$lf=$F[0];$ln=$F[1]}'|sh@);

exit 0;
