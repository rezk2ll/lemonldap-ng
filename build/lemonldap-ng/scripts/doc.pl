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
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocInstallDebianPackages'      => 'debian-packages-install.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Erreurs?language=fr'           => 'errors-fr.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Erreurs?language=en'           => 'errors.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocSOAP?language=fr'           => 'soap-fr.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocLA?language=fr'             => 'liberty-alliance-fr.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocPpolicy'                    => 'password-policy.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/LDAPSchema'                    => 'advanced-access-rules.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocAppSympa'                   => 'sympa.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocAppTomcatValve'             => 'tomcat-valve.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocAppDokuwiki'                => 'dokuwiki.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/DocAppPLA'                     => 'phpldapadmin.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Roadmap'                       => 'roadmap.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/References'                    => 'references.html',
    'http://wiki.lemonldap.objectweb.org/xwiki/bin/view/Main/Contacts'                    => 'contacts.html',
};

my %imgs;

sub css() {
    return <<EOT;
    <style type="text/css">
    body{
      background: #ddd;
      font-family: sans-serif;
      font-size: 11pt;
      padding: 0 50px;
    }
    div.main-content{
      padding: 10px;
      background: #fff;
      border: 2px #ccc solid;
    }
    a{
      text-decoration: none;
    }
    p.footer{
      text-align: center;
      margin: 5px 0 0 0;
    }
    .heading-1{
      text-align: center;
      color: orange;
      font-variant: small-caps;
      font-size: 20pt;
    }
    .heading-1-1{
      color: orange;
      font-size: 14pt;
      border-bottom: 2px #ccc solid;
    }
    pre{
      background: #eee;
      border: 2px #ccc solid;
      padding: 5px;
      border-left: 10px #ccc solid;
    }
    ul.star li{
      list-style-type: square;
    }
    </style>
EOT
}
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

        # Unfined bug...
        $ind = 0 if (m#<div id="col-b"#);
        next unless ($ind);
        my @t = ( $_ =~ /<div/i );
        $div += @t;
        @t = ( $_ =~ /<\/div/i );
        $div -= @t;
        $ind-- unless ($div);
        s/\r//g;
        utf8::decode($_);

        # Little xwiki bug
        if (/<\/pre/) {
            $pre = 0;
            while (s#(?<!<pre>)(.*?)(?:<p[^>]*>\s*</p>|<p[^>]*/>)(.*?)(?=</pre>)#$1<br/><br/>$2#gi) {
            }
        }
        if ($pre) {
            s#(?:<p[^>]*>\s*</p>|<p[^>]*/>)#<br/><br/>#gi;
        }
        if (/<pre/) {
            $pre = 1;
            while (s#(?<=<pre>)(.*?)(?:<p[^>]*>\s*</p>|<p[^>]*/>)(.*?)(?=</pre>)#$1<br/><br/>$2#gi) {
            }
            while (s#(?<=<pre>)(.*?)(?:<p[^>]*>\s*</p>|<p[^>]*/>)(.*?)(?!</pre>)#$1<br/><br/>$2#gi) {
            }
        }
        if (m#(["'])/xwiki/bin/download/([\/\w\.\-]+)\1#) {
            $imgs{$2} = 1;
            s#(["'])/xwiki/bin/download/(?:[\/\w\.\-]+)/([\w\.\-]+)\1#$1$2$1#;
        }
        if (s#(["'])/xwiki/bin/download/([\/\w\.\-]+)\1#$1$2$1#) {
            $imgs{$2} = 1;
        }
        if ( $file =~ /-fr/ ) {
            s#/xwiki/bin/view/NG/FAQ#faq-fr.html#g;
            s#/xwiki/bin/view/NG/Presentation#overview-fr.html#g;
            s#/xwiki/bin/view/NG/DocInstallExample#install-fr.html#g;
            s#/xwiki/bin/view/NG/DocInstall#advanced-install.html#g;
            s#/xwiki/bin/view/NG/Erreurs#errors-fr.html#g;
            s#/xwiki/bin/view/NG/DocSOAP#soap-fr.html#g;
        }
        else {
            s#/xwiki/bin/view/NG/FAQ#faq.html#g;
            s#/xwiki/bin/view/NG/Presentation#overview.html#g;
            s#/xwiki/bin/view/NG/DocInstallExample#install.html#g;
            s#/xwiki/bin/view/NG/DocInstall#advanced-install.html#g;
            s#/xwiki/bin/view/NG/Erreurs#errors.html#g;
            s#/xwiki/bin/view/NG/DocSOAP#soap-fr.html#g;
        }
        $buf .= $_;
    }
    close DOC;

    open FILE, "|tidy -q -u -c -i -wrap 79 >$file";
    print FILE '<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "XHTML 1.0 Strict"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="fr" xml:lang="fr">
<head>
<title>Lemonldap::NG documentation: ' . $file . '</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
' . &css . '
</head>
<body>
';
    print FILE "$buf";
    print FILE '<p class="footer"><a href="index.html">Index</a></p>';
    print FILE "</body></html>";
    close FILE;
}

foreach ( keys %imgs ) {
    `wget -N http://wiki.lemonldap.objectweb.org/xwiki/bin/download/$_`;
}

# Create index.html
open INDEX, ">index.html";
print INDEX <<EOT;
<!DOCTYPE html PUBLIC "XHTML 1.0 Strict"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="fr" xml:lang="fr">
<head>
<title>Lemonldap::NG documentation: index</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
EOT
print INDEX &css;
print INDEX <<EOT;
</head>
<body>
  <div class="main-content">
    <h2 class="heading-1">LemonLDAP::NG documentation</h2>
    <ul class="star">
EOT
foreach my $file (
    sort {
        my ( $f, $s ) = ( $a, $b );
        $f =~ s/-(\w{2}\.html)$/.zzz$1/;
        $s =~ s/-(\w{2}\.html)$/.zzz$1/;
        return $f cmp $s;
    } values %$docs
  )
{
    my $name = $file;
    next if ( $name eq 'index.html' );
    $name =~ s/\.html//;
    $name =~ s/-fr/ (FR)/g;
    $name =~ s/-/ /g;
    print INDEX '      <li><a href="' . $file . '">' . ucfirst($name) . '</a></li>' . "\n";
}
print INDEX <<EOT;
    </ul>
  </div>
  <p class="footer">Find the latest version of the documentation on <a href="http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation">LemonLDAP::NG Wiki</a> !</p>
</body>
</html>
EOT
