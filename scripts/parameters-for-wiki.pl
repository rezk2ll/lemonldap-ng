#!/usr/bin/perl

use strict;
use JSON;

require './lemonldap-ng-manager/lib/Lemonldap/NG/Manager/Build/Attributes.pm';
require './lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/ReConstants.pm';

my $rmg =
"^(?:(?:$Lemonldap::NG::Common::Conf::ReConstants::virtualHostKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::casAppMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::casSrvMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::oidcOPMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::oidcRPMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::samlIDPMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::samlSPMetaDataNodeKeys)|(?:$Lemonldap::NG::Common::Conf::ReConstants::specialNodeKeys)|(.*Options))\$";
$rmg = qr/$rmg/;

my $ignore = qr/^(?:virtualHosts)$/;

open F, 'lemonldap-ng-manager/site/htdocs/static/reverseTree.json';

my $managed = JSON::from_json( join '', <F> );

my $prm = Lemonldap::NG::Manager::Build::Attributes::attributes();

my $ok = '✔';

print <<EOF;
====== Parameter list ======

<note tip>
Click on a column header to sort table.
The attribute key name can be used directly in ''lemonldap-ng.ini'' or in Perl scripts to override configuration parameters (see [[configlocation|configuration location]]).
</note>

===== Main parameters =====

<sortable 2>
^  Key name  ^  Documentation  ^  ini file only  ^
EOF

#| Activate auto accept timer | activeTimer |  ✔  | | |

foreach my $k ( sort keys %$prm ) {
    next if $k =~ $ignore;
    print "| $k | $prm->{$k}->{documentation} | "
      . ( ( $managed->{$k} or $k =~ $rmg ) ? '' : $ok ) . " |\n";
}

print <<EOF;

===== Configuration backend parameters =====

^  Full name  ^  Key name  ^  Configuration backend  ^
| DBI connection string | dbiChain | [[sqlconfbackend|CDBI / RDBI]] |
| DBI user | dbiUser | ::: |
| DBI password | dbiPassword | ::: |
| DBI table name | dbiTable | ::: |
| Storage directory | dirName | [[fileconfbackend|File]] |
| LDAP server | ldapServer | [[ldapconfbackend|LDAP]] |
| LDAP port | ldapPort | ::: |
| LDAP base | ldapConfBase | ::: |
| LDAP bind dn | ldapBindDN | ::: |
| LDAP bind password | ldapBindPassword | ::: |
| Certificate authorities file | caFile | ::: |
| Certificate authorities directory | caPath | ::: |
| SOAP server location (URL) | proxy | [[soapconfbackend|SOAP]] |
| [[http://search.cpan.org/perldoc?LWP::UserAgent|LWP::UserAgent]] parameters | proxyOptions | ::: |
EOF
