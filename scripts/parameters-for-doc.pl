#!/usr/bin/perl

use strict;
use JSON;

require './lemonldap-ng-manager/lib/Lemonldap/NG/Manager/Build/Attributes.pm';
require './lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/ReConstants.pm';

my $rmg =
"^(?:(?:$Lemonldap::NG::Common::Conf::ReConstants::virtualHostKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::casAppMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::casSrvMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::oidcOPMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::oidcRPMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::samlIDPMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::samlSPMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::specialNodeKeys))\$";
$rmg = qr/$rmg/;

my $complexNodes = qr/^(?:(?:(?:saml(?:ID|S)|oidc[OR])P|cas(?:App|Srv))MetaData|vhost)Options$/;

my $ignore = qr/^(?:virtualHosts)$/;

open F, 'lemonldap-ng-manager/site/htdocs/static/reverseTree.json';

my $managed = JSON::from_json( join '', <F> );

my $prm = Lemonldap::NG::Manager::Build::Attributes::attributes();

my $ok = '✔';

print <<EOF;
Parameter list
==============


.. tip::

    Click on a column header to sort table. The attribute key
    name can be used directly in ``lemonldap-ng.ini`` or in Perl scripts to
    override configuration parameters (see
    :doc:`configuration location<configlocation>`).

Main parameters
---------------

======================================================= ==================================================================================== ====== ======= ======= =============
Key name                                                Documentation                                                                        Portal Handler Manager ini file only
======================================================= ==================================================================================== ====== ======= ======= =============
EOF

#| Activate auto accept timer | activeTimer |  ✔  | | |

foreach my $k ( sort keys %$prm ) {
    next if $k =~ $ignore;
    next if $k =~ $rmg;
    my $p = $prm->{$k};
    $p->{flags} ||= 'p';
    my $line = "$k". " "x(56-length($k)) 
    . "$p->{documentation}"." "x(85-length($p->{documentation}))
      # Portal flag
      . ( $p->{flags} =~ /p/ ? "$ok      " : '       ')
      # Handler flag
      .( $p->{flags} =~ /h/ ? "$ok       " : '        ')
      # Manager flag
      .( $p->{flags} =~ /m/ ? "$ok       " : '        ')
      # Ini-only flag
      .( ( $managed->{$k} or $k =~ $rmg ) ? '' : ( $k =~ $complexNodes ? '[1]' : $ok ) );
      $line =~ s/\s*$//;
      print "$line\n";
}

print <<EOF;
======================================================= ==================================================================================== ====== ======= ======= =============

*[1]: complex nodes*

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
============================================================================= ==================== ===========================================================
EOF
