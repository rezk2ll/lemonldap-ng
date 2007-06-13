#!/usr/bin/perl

use strict;
use XML::Simple;
use utf8;

my $docs = {
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/FAQ?language=fr'               => 'faq-fr.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/FAQ?language=en'               => 'faq.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation?language=en'      => 'overview.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation?language=fr'      => 'overview-fr.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocInstallExample?language=en' => 'install.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocInstallExample?language=fr' => 'install-fr.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocInstall?language=en'        => 'advanced-install.html',
};

while ( my ( $url, $file ) = each %$docs ) {
    print STDERR "\n# $file\n";
    open DOC, "wget -q -O - $url |";

    #open DOC, '/tmp/doc';

    my $buf;
    my $ind = 0;
    my $div;
    while (<DOC>) {
        $ind++ if (/<div class="main-content">/);
        next unless ($ind);
        $div++ if (/<div/);
        $div-- if (/<\/div/);
        $ind-- unless ($div);
        s/\r//g;
        utf8::decode($_);
        $buf .= $_;
    }
    close DOC;

    open FILE, "|tidy -u -c -i -wrap 79 >$file";
    print FILE '<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "XHTML 1.0 Strict"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="fr" xml:lang="fr">
<head>
<title>FAQ LEMONLDAP::NG</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
';
    print FILE "$buf</body></html>";
    close FILE;
}
