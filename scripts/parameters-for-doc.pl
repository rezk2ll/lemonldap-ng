#!/usr/bin/perl

use strict;
use JSON;

require './lemonldap-ng-manager/lib/Lemonldap/NG/Manager/Build/Attributes.pm';
require './lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/ReConstants.pm';

my $complexNodes =
  qr/^(?:(?:(?:saml(?:ID|S)|oidc[OR])P|cas(?:App|Srv))MetaData|vhost)Options$/;

my $ignore = qr/^cfg[A-Z]/;

open my $rt, 'lemonldap-ng-manager/site/htdocs/static/reverseTree.json';
my $managed = JSON::from_json( join '', <$rt> );
close $rt;

open my $translation_file,
  'lemonldap-ng-manager/site/htdocs/static/languages/en.json';
my $trKeys = JSON::decode_json( join '', <$translation_file> );
close $translation_file;

$trKeys->{__confKey__} = "*configuration key*";

my $prm = Lemonldap::NG::Manager::Build::Attributes::attributes();

my $ok = '✔';

print <<EOF;
Parameter list
==============

Main parameters
---------------

EOF

foreach my $k ( sort keys %$prm ) {
    next if $k =~ $ignore;
    my $p = $prm->{$k};
    $p->{flags} ||= 'p';
    my $is_portal     = $p->{flags} =~ /p/;
    my $is_handler    = $p->{flags} =~ /h/;
    my $is_manager    = $p->{flags} =~ /m/;
    my $documentation = $p->{documentation};
    my $path          = join( " » ",
        map { $trKeys->{$_} || $_ } split( "/", $managed->{$k} ), $k );
    my $ini_only = not( $managed->{$k} or $k =~ $complexNodes );

    print "$k\n";
    print "    :Location: $path\n" if !$ini_only;
    print "    :Description: $documentation\n" if $documentation;
    print "    :Used by portal: yes\n"  if $is_portal;
    print "    :Used by manager: yes\n" if $is_manager;
    print "    :Used by handler: yes\n" if $is_handler;
    print "    :Ini only: yes\n"        if $ini_only;
    print "\n";
}

print <<EOF;

Configuration backend parameters
--------------------------------

============================================================================= ==================== ===========================================================
Full name                                                                     Key name             Configuration backend
============================================================================= ==================== ===========================================================
Configuration load timeout                                                    confTimeout          all backends (default: 10)
DBI connection string                                                         dbiChain             :doc:`CDBI / RDBI<sqlconfbackend>`
DBI user                                                                      dbiUser
DBI password                                                                  dbiPassword
DBI table name                                                                dbiTable
Directory                                                                     dirName              :doc:`File<fileconfbackend>` / :doc:`YAML<yamlconfbackend>`
LDAP server                                                                   ldapServer           :doc:`LDAP<ldapconfbackend>`
LDAP port                                                                     ldapPort
LDAP base                                                                     ldapConfBase
LDAP bind dn                                                                  ldapBindDN
LDAP bind password                                                            ldapBindPassword
LDAP ObjectClass                                                              ldapObjectClass
LDAP ID attribute                                                             ldapAttributeId
LDAP content attribute                                                        ldapAttributeContent
Certificate authorities file                                                  caFile
Certificate authorities directory                                             caPath
MongoDB database                                                              dbName               :doc:`MongoDB<mongodbconfbackend>`
MongoDB collection                                                            collectionName
Pretty print                                                                  prettyPrint          :doc:`File<fileconfbackend>`
REST base URL                                                                 baseUrl              :doc:`REST<restconfbackend>`
REST realm                                                                    realm
REST user                                                                     user
REST password                                                                 password
SOAP server location (URL)                                                    proxy                :doc:`SOAP<soapconfbackend>`
`LWP::UserAgent <http://search.cpan.org/perldoc?LWP::UserAgent>`__ parameters proxyOptions
SOAP user                                                                     User
SOAP password                                                                 Password
Overlay real configuration backend                                            overlayRealtype      :doc:`Overlay<overlayconfbackend>`
Overlay directory                                                             overlayDirectory     :doc:`Overlay<overlayconfbackend>`
Overlay write authorization                                                   overlayWrite         :doc:`Overlay<overlayconfbackend>`

============================================================================= ==================== ===========================================================
EOF
