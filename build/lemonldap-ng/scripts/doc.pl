#!/usr/bin/perl

use strict;
use XML::Simple;
use utf8;

my $docs = {

    # Overview
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Presentation?language=en' => '1-Overview.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Presentation?language=fr' => '1-Overview-fr.html',

    # FAQ
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/FAQ' => '2-FAQ.html',

    #TOC
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Documentation?language=en' => '3-Table-of-contents.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Documentation?language=fr' => '3-Table-of-contents-fr.html',

    # Install
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocPrereq'                => '3.1-Install-prerequesites.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocInstallTarball'        => '3.2-Install-from-tarball.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocInstallDebianPackages' => '3.3-Install-from-debian-packages.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocInstallRedHatPackages' => '3.3-Install-from-redhat-packages.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocInstallSuSEPackages'   => '3.3-Install-from-suse-packages.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocUpgrade094To10'        => '3.4-Upgrade-from-0.9.4-to-1.0.html',

    # Configuration overview
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocConfigOverwiew'   => '4.1-Configuration-overview.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/RBAC'                => '4.1-RBAC-model.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/ConfigParameterList' => '4.1-Configuration-parameter-list.html',

    # Portal
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/EnhancedMenu'    => '4.2-Configure-portal-menu.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/TemplatesDesign' => '4.2-HTML-templates-customization.html',

    # Configuration backends
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocFileStorage'  => '4.3-File-configuration-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocMySQLStorage' => '4.3-MySQL-configuration-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocLDAPStorage'  => '4.3-LDAP-configuration-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocSOAPStorage'  => '4.3-SOAP-configuration-backend.html',

    # Session backends
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocFileSessionStorage'       => '4.4-File-session-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocMySQLSessionStorage'      => '4.4-MySQL-session-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocPostGreSQLSessionStorage' => '4.4-PostGreSQL-session-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocLDAPSessionStorage'       => '4.4-LDAP-session-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocSOAPSessionStorage'       => '4.4-SOAP-session-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocMemcachedSessionStorage'  => '4.4-Memcached-session-backend.html',

    # Authentication backends
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/AuthLDAP'          => '4.5-LDAP-authentication-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/SSL'               => '4.5-SSL-authentication-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Kerberos'          => '4.5-Apache-and-Kerberos-authentication-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/CAS'               => '4.5-CAS-authentication-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/AuthRemote'        => '4.5-Remote-authentication-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/AuthMulti'         => '4.5-Multiple-authentication-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/AuthProxy'         => '4.5-Proxy-authentication-module.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/AuthSAML'          => '4.5-SAML-authentication-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocLA?language=fr' => '4.5-Liberty-Alliance-authentication-backend-fr.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/AuthOpenID'        => '4.5-OpenID-authentication-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/AuthTwitter'       => '4.5-Twitter-authentication-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/AuthDBI'           => '4.5-DBI-authentication-backend.html',

    # User backends
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/UserDBLDAP'  => '4.6-LDAP-user-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/UserDBNull'  => '4.6-Null-user-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/UserDBMulti' => '4.6-Multiple-user-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/UserDBSAML'  => '4.6-SAML-user-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/UserDBDBI'   => '4.6-DBI-user-backend.html',

    # Password backends
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/PasswordDBLDAP' => '4.7-LDAP-password-backend.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/PasswordDBDBI'  => '4.7-DBI-password-backend.html',

    # LDAP specificities
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocPpolicy' => '4.8-Configure-password-policy.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/LDAPSchema' => '4.8-Configure-LDAP-schema.html',

    # Advanced
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/CDA'                       => '4.9-Cross-domain-authentication.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Notifications'             => '4.9-Notification-system.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/SeveralIndependantPortals' => '4.9-Several-independant-portals.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/ResetPassword'             => '4.9-Reset-password-by-mail.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/MultipleCookies'           => '4.9-Multiple-cookies.html',

    # Applications
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppDokuwiki'            => '5-Appli-Dokuwiki.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppGRR'                 => '5-Appli-GRR.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppGLPI'                => '5-Appli-GLPI.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppPLA'                 => '5-Appli-phpLDAPadmin.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppSympa'               => '5-Appli-Sympa.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppBugzilla'            => '5-Appli-Bugzilla.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppLiferay'             => '5-Appli-Liferay.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppZimbra'              => '5-Appli-Zimbra.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppTomcatValve'         => '5-Appli-Tomcat-Valve.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppBasicAuthentication' => '5-Appli-HTTP-Basic-Authentication.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/DocAppSelfMade'            => '5-Appli-self-made.html',

    # Other
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/Main/Contacts'          => '6-Contacts.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Erreurs?language=en' => '6-Errors.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Erreurs?language=fr' => '6-Errors-fr.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Roadmap'             => '6-Roadmap.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/References'          => '6-References.html',
    'http://wiki.lemonldap.ow2.org/xwiki/bin/view/NG/Accounting'          => '6-Accounting.html',
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

        #$ind-- unless ($div);
        s/\r//g;
        utf8::decode($_);

        # Little xwiki bug
        if (/<\/pre/) {
            $pre = 0;
            while ( s#(?<!<pre>)(.*?)(?:<p[^>]*>\s*</p>|<p[^>]*/>)(.*?)(?=</pre>)#$1<br/><br/>$2#gi ) {
            }
        }
        if ($pre) {
            s#(?:<p[^>]*>\s*</p>|<p[^>]*/>)#<br/><br/>#gi;
        }
        if (/<pre/) {
            $pre = 1;
            while ( s#(?<=<pre>)(.*?)(?:<p[^>]*>\s*</p>|<p[^>]*/>)(.*?)(?=</pre>)#$1<br/><br/>$2#gi ) {
            }
            while ( s#(?<=<pre>)(.*?)(?:<p[^>]*>\s*</p>|<p[^>]*/>)(.*?)(?!</pre>)#$1<br/><br/>$2#gi ) {
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
            s#/xwiki/bin/view/NG/Documentation#3-Table-of-contents-fr.html#g;
            s#/xwiki/bin/view/NG/DocLA#4.5-Configure-Liberty-Alliance-fr.html#g;
            s#/xwiki/bin/view/NG/Erreurs#6-Errors-fr.html#g;
        }

        # EN translation
        else {
            s#/xwiki/bin/view/NG/Presentation#1-Overview.html#g;
            s#/xwiki/bin/view/NG/Documentation#3-Table-of-contents.html#g;
            s#/xwiki/bin/view/NG/DocLA#4.5-Configure-Liberty-Alliance-fr.html#g;    # Only FR
            s#/xwiki/bin/view/NG/Erreurs#6-Errors.html#g;
        }

        # Default lang
        s#/xwiki/bin/view/NG/FAQ#2-FAQ.html#g;
        s#/xwiki/bin/view/NG/DocPrereq#3.1-Install-prerequesites.html#g;
        s#/xwiki/bin/view/NG/DocInstallTarball#3.2-Install-from-tarball.html#g;
        s#/xwiki/bin/view/NG/DocInstallDebianPackages#3.3-Install-from-debian-packages.html#g;
        s#/xwiki/bin/view/NG/DocInstallRedHatPackages#3.3-Install-from-redhat-packages.html#g;
        s#/xwiki/bin/view/NG/DocInstallSuSEPackages#3.3-Install-from-suse-packages.html#g;
        s#/xwiki/bin/view/NG/DocUpgrade094To10#3.4-Upgrade-from-0.9.4-to-1.0.html#g;
        s#/xwiki/bin/view/NG/DocConfigOverwiew#4.1-Configuration-overview.html#g;
        s#/xwiki/bin/view/NG/RBAC#4.1-RBAC-model.html#g;
        s#/xwiki/bin/view/NG/ConfigParameterList#4.1-Configuration-parameter-list.html#g;
        s#/xwiki/bin/view/NG/EnhancedMenu#4.2-Configure-portal-menu.html#g;
        s#/xwiki/bin/view/NG/TemplatesDesign#4.2-HTML-templates-customization.html#g;
        s#/xwiki/bin/view/NG/DocFileStorage#4.3-File-configuration-backend.html#g;
        s#/xwiki/bin/view/NG/DocMySQLStorage#4.3-MySQL-configuration-backend.html#g;
        s#/xwiki/bin/view/NG/DocLDAPStorage#4.3-LDAP-configuration-backend.html#g;
        s#/xwiki/bin/view/NG/DocSOAPStorage#4.3-SOAP-configuration-backend.html#g;
        s#/xwiki/bin/view/NG/DocFileSessionStorage#4.4-File-session-backend.html#g;
        s#/xwiki/bin/view/NG/DocMySQLSessionStorage#4.4-MySQL-session-backend.html#g;
        s#/xwiki/bin/view/NG/DocPostGreSQLSessionStorage#4.4-PostGreSQL-session-backend.html#g;
        s#/xwiki/bin/view/NG/DocLDAPSessionStorage#4.4-LDAP-session-backend.html#g;
        s#/xwiki/bin/view/NG/DocSOAPSessionStorage#4.4-SOAP-session-backend.html#g;
        s#/xwiki/bin/view/NG/DocMemcachedSessionStorage#4.4-Memcached-session-backend.html#g;
        s#/xwiki/bin/view/NG/AuthLDAP#4.5-LDAP-authentication-backend.html#g;
        s#/xwiki/bin/view/NG/SSL#4.5-SSL-authentication-backend.html#g;
        s#/xwiki/bin/view/NG/Kerberos#4.5-Apache-and-Kerberos-authentication-backend.html#g;
        s#/xwiki/bin/view/NG/CAS#4.5-CAS-authentication-backend.html#g;
        s#/xwiki/bin/view/NG/AuthRemote#4.5-Remote-authentication-backend.html#g;
        s#/xwiki/bin/view/NG/AuthMulti#4.5-Multiple-authentication-backend.html#g;
        s#/xwiki/bin/view/NG/AuthProxy#4.5-Proxy-authentication-backend.html#g;
        s#/xwiki/bin/view/NG/AuthSAML#4.5-SAML-authentication-backend.html#g;
        s#/xwiki/bin/view/NG/AuthOpenID#4.5-OpenID-authentication-backend.html#g;
        s#/xwiki/bin/view/NG/AuthTwitter#4.5-Twitter-authentication-backend.html#g;
        s#/xwiki/bin/view/NG/AuthDBI#4.5-DBI-authentication-backend.html#g;
        s#/xwiki/bin/view/NG/UserDBLDAP#4.6-LDAP-user-backend.html#g;
        s#/xwiki/bin/view/NG/UserDBNull#4.6-Null-user-backend.html#g;
        s#/xwiki/bin/view/NG/UserDBMulti#4.6-Multiple-user-backend.html#g;
        s#/xwiki/bin/view/NG/UserDBSAML#4.6-SAML-user-backend.html#g;
        s#/xwiki/bin/view/NG/UserDBDBI#4.6-DBI-user-backend.html#g;
        s#/xwiki/bin/view/NG/PasswordDBLDAP#4.7-LDAP-password-backend.html#g;
        s#/xwiki/bin/view/NG/PasswordDBDBI#4.7-DBI-password-backend.html#g;
        s#/xwiki/bin/view/NG/DocPpolicy#4.8-Configure-password-policy.html#g;
        s#/xwiki/bin/view/NG/LDAPSchema#4.8-Configure-LDAP-schema.html#g;
        s#/xwiki/bin/view/NG/CDA#4.9-Cross-domain-authentication.html#g;
        s#/xwiki/bin/view/NG/Notifications#4.9-Notification-system.html#g;
        s#/xwiki/bin/view/NG/SeveralIndependantPortals#4.9-Several-independant-portals.html#g;
        s#/xwiki/bin/view/NG/ResetPassword#4.9-Reset-password-by-mail.html#g;
        s#/xwiki/bin/view/NG/MultipleCookies#4.9-Multiple-cookies.html#g;
        s#/xwiki/bin/view/NG/DocAppDokuwiki#5-Appli-Dokuwiki.html#g;
        s#/xwiki/bin/view/NG/DocAppGRR#5-Appli-GRR.html#g;
        s#/xwiki/bin/view/NG/DocAppGLPI#5-Appli-GLPI.html#g;
        s#/xwiki/bin/view/NG/DocAppPLA#5-Appli-phpLDAPadmin.html#g;
        s#/xwiki/bin/view/NG/DocAppSympa#5-Appli-Sympa.html#g;
        s#/xwiki/bin/view/NG/DocAppBugzilla#5-Appli-Bugzilla.html#g;
        s#/xwiki/bin/view/NG/DocAppLiferay#5-Appli-Liferay.html#g;
        s#/xwiki/bin/view/NG/DocAppZimbra#5-Appli-Zimbra.html#g;
        s#/xwiki/bin/view/NG/DocAppTomcatValve#5-Appli-Tomcat-Valve.html#g;
        s#/xwiki/bin/view/NG/DocAppBasicAuthentication#5-Appli-HTTP-Basic-Authentication.html#g;
        s#/xwiki/bin/view/NG/DocAppselfMade#5-Appli-self-made.html#g;
        s#/xwiki/bin/view/Main/Contacts#6-Contacts.html#g;
        s#/xwiki/bin/view/NG/Roadmap#6-Roadmap.html#g;
        s#/xwiki/bin/view/NG/References#6-References.html#g;
        s#/xwiki/bin/view/NG/Accounting#6-Accounting.html#g;

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
  <p class="footer">Find the latest version of the documentation on <a href="http://wiki.lemonldap.ow2.org">LemonLDAP::NG Wiki</a> !</p>
</body>
</html>
EOT
