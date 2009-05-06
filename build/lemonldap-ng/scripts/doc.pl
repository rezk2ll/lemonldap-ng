#!/usr/bin/perl

use strict;
use XML::Simple;
use utf8;

my $docs = {
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Presentation?language=en'      => '1-Overview.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Presentation?language=fr'      => '1-Overview-fr.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/FAQ?language=en'               => '2-FAQ.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/FAQ?language=fr'               => '2-FAQ-fr.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Documentation?language=en'     => '3-Table-of-contents.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Documentation?language=fr'     => '3-Table-of-contents-fr.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocPrereq'                     => '3.1-Install-prerequesites.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocInstallTarball'             => '3.2-Install-from-tarball.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocInstallDebianPackages'      => '3.3-Install-from-debian-packages.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocInstallRedHatPackages'      => '3.3-Install-from-redhat-packages.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocMySQLStorage'               => '3.4-Install-of-MySQL-storage.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocInstallExample?language=en' => '3.5-Install-of-example.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocInstallExample?language=fr' => '3.5-Install-of-example-fr.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocConfigOverwiew'             => '4.1-Configuration-overview.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/ConfigParameterList'           => '4.1-Configuration-parameter-list.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/EnhancedMenu'                  => '4.1-Configure-portal-menu.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/TemplatesDesign'               => '4.1-HTML-templates-customization.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/RBAC'                          => '4.1-RBAC-model.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocPpolicy'                    => '4.2-Configure-password-policy.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/LDAPSchema'                    => '4.2-Configure-LDAP-schema.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocSOAP?language=fr'           => '4.3-Configure-SOAP-fr.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocLA?language=fr'             => '4.3-Configure-Liberty-Alliance-fr.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Notifications'                 => '4.4-Configure-and-use-notification-system.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/AuthRemote'                    => '4.5-Chain-portals.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppSympa'                   => '5-Appli-Sympa.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppTomcatValve'             => '5-Appli-Tomcat-Valve.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppDokuwiki'                => '5-Appli-Dokuwiki.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppPLA'                     => '5-Appli-phpLDAPadmin.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppBasicAuthentication'     => '5-Appli-HTTP-Basic-Authentication.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/Main/Contacts'                    => '6-Contacts.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Erreurs?language=en'           => '6-Errors.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Erreurs?language=fr'           => '6-Errors-fr.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Roadmap'                       => '6-Roadmap.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/References'                    => '6-References.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Accounting'                    => '6.1-Accounting.html',
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
        #if (s#(["'])/xwiki/bin/download/([\/\w\.\-]+)\1#$1$2$1#) {
        #    $imgs{$2} = 1;
        #}
	## Resolve internal links
	# FR translation
        if ( $file =~ /-fr\.html/ ) {
            s#/xwiki/bin/view/NG/Presentation#1-Overview-fr.html#g;
            s#/xwiki/bin/view/NG/FAQ#2-FAQ-fr.html#g;
            s#/xwiki/bin/view/NG/Documentation#3-Table-of-contents-fr.html#g;
            s#/xwiki/bin/view/NG/DocInstallExample#3.5-Install-of-example-fr.html#g;
            s#/xwiki/bin/view/NG/DocSOAP#4.3-Configure-SOAP-fr.html#g;
            s#/xwiki/bin/view/NG/DocLA#4.3-Configure-Liberty-Alliance-fr.html#g;
            s#/xwiki/bin/view/NG/Erreurs#6-Errors-fr.html#g;
        }
	# EN translation
        else {
            s#/xwiki/bin/view/NG/Presentation#1-Overview.html#g;
            s#/xwiki/bin/view/NG/FAQ#2-FAQ.html#g;
            s#/xwiki/bin/view/NG/Documentation#3-Table-of-contents.html#g;
            s#/xwiki/bin/view/NG/DocInstallExample#3.5-Install-of-example.html#g;
            s#/xwiki/bin/view/NG/DocSOAP#4.3-Configure-SOAP-fr.html#g;                  # Only FR
            s#/xwiki/bin/view/NG/DocLA#4.3-Configure-Liberty-Alliance-fr.html#g;        # Only FR
            s#/xwiki/bin/view/NG/Erreurs#6-Errors.html#g;
        }
	# Default lang
	s#/xwiki/bin/view/NG/DocPrereq#3.1-Install-prerequesites.html#g;
	s#/xwiki/bin/view/NG/DocInstallTarball#3.2-Install-from-tarball.html#g;
	s#/xwiki/bin/view/NG/DocInstallDebianPackages#3.3-Install-from-debian-packages.html#g;
	s#/xwiki/bin/view/NG/DocInstallRedHatPackages#3.3-Install-from-redhat-packages.html#g;
	s#/xwiki/bin/view/NG/DocMySQLStorage#3.4-Install-of-MySQL-storage.html#g;
	s#/xwiki/bin/view/NG/DocConfigOverwiew#4.1-Configuration-overview.html#g;
	s#/xwiki/bin/view/NG/ConfigParameterList#4.1-Configuration-parameter-list.html#g;
	s#/xwiki/bin/view/NG/EnhancedMenu#4.1-Configure-portal-menu.html#g;
	s#/xwiki/bin/view/NG/TemplatesDesign#4.1-HTML-templates-customization.html#g;
	s#/xwiki/bin/view/NG/RBAC#4.1-RBAC-model.html#g;
	s#/xwiki/bin/view/NG/DocPpolicy#4.2-Configure-password-policy.html#g;
	s#/xwiki/bin/view/NG/LDAPSchema#4.2-Configure-LDAP-schema.html#g;
	s#/xwiki/bin/view/NG/DocAppSympa#5-Appli-Sympa.html#g;
	s#/xwiki/bin/view/NG/DocAppTomcatValve#5-Appli-Tomcat-Valve.html#g;
	s#/xwiki/bin/view/NG/DocAppDokuwiki#5-Appli-Dokuwiki.html#g;
	s#/xwiki/bin/view/NG/DocAppPLA#5-Appli-phpLDAPadmin.html#g;
	s#/xwiki/bin/view/NG/DocAppBasicAuthentication#5-Appli-HTTP-Basic-Authentication.html#g;
	s#/xwiki/bin/view/Main/Contacts#6-Contacts.html#g;
	s#/xwiki/bin/view/NG/Roadmap#6-Roadmap.html#g;
	s#/xwiki/bin/view/NG/References#6-References.html#g;
	# Remove pages not yet created
	s#<li><a class=\"wikicreatelink\".*##g;
	
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
     sleep 1;
    `wget -N http://wiki.lemonldap.ow2.org/xwiki/bin/download/$_`;
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
    $name =~ s/-fr$/ (FR)/g;
    $name =~ s/-/ /g;
    print INDEX '      <li><a href="' . $file . '">' . ucfirst($name) . '</a></li>' . "\n";
}
print INDEX <<EOT;
    </ul>
  </div>
  <p class="footer">Find the latest version of the documentation on <a href="http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Presentation">LemonLDAP::NG Wiki</a> !</p>
</body>
</html>
EOT
