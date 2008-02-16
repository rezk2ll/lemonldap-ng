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
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Erreurs?language=en'           => 'errors-fr.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Erreurs?language=fr'           => 'errors.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocSOAP?language=fr'           => 'soap-fr.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocLA?language=fr'             => 'liberty-alliance-fr.html',
};

my %imgs;

while ( my ( $url, $file ) = each %$docs ) {
    print STDERR "\n# $file\n";
    open DOC, "wget -q -O - $url |";

    #open DOC, '/tmp/doc';

    my $buf;
    my $ind = 0;
    my $div;
    my $pre = 0;
    while (<DOC>) {
        $ind++ if (/<div class="main-content">/);
        next unless ($ind);
        $div++ if (/<div/);
        $div-- if (/<\/div/);
        $ind-- unless ($div);
        s/\r//g;
        utf8::decode($_);
        if(/<pre/) {
            $pre++;
            s#(?<=<pre)<p class="paragraph"/>#<br/><br/>#g;
            print STDERR "Trouvé: $`\n$&\n$'\n\n";
        }
        elsif($pre) {
            s#(?<!<\/pre)<p class="paragraph"/>#<br/><br/>#g;
        }
        $pre++ if(/<pre/);
        s#<p class="paragraph"/>#<br/><br/>#g if($pre);
        $pre-- if(/<\/pre/);
        if(s#(["'])/xwiki/bin/download/NG/Presentation/([\w\.\-]+)\1#$1$2$1#) {
            $imgs{$2} = 1;
        }
        if($file =~ /-fr/) {
            s#/xwiki/bin/view/NG/FAQ#faq-fr.html#g;
            s#/xwiki/bin/view/NG/Presentation#overview-fr.html#g;
            s#/xwiki/bin/view/NG/DocInstallExample#install-fr.html#g;
            s#/xwiki/bin/view/NG/DocInstall#advanced-install.html#g;
            s#/xwiki/bin/view/NG/Erreurs#errors-fr.html#g;
        }
        else {
            s#/xwiki/bin/view/NG/FAQ#faq.html#g;
            s#/xwiki/bin/view/NG/Presentation#overview.html#g;
            s#/xwiki/bin/view/NG/DocInstallExample#install.html#g;
            s#/xwiki/bin/view/NG/DocInstall#advanced-install.html#g;
            s#/xwiki/bin/view/NG/Erreurs#errors.html#g;
        }
        $buf .= $_;
    }
    close DOC;

    open FILE, "|tee /tmp/$file|tidy -u -c -i -wrap 79 >$file";
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

foreach(keys %imgs) {
    `wget -N http://wiki.lemonldap.objectweb.org/xwiki/bin/download/NG/Presentation/$_`;
}
