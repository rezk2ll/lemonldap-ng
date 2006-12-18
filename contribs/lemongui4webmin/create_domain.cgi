#!/usr/bin/perl
# create_domain.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';
&ReadParse();
my $domain = $in{'domain'};
my $c = &get_config;
my $all_domain = $c->{domain};
# Display global category icons
my @tab= @{&get_domain_attr()} ;
my %tmp;
foreach (@tab) {
undef ($in{$_->{name}}) if $in{$_->{name}} eq '';
$tmp{$_->{name}}= $in{$_->{name}} if defined ($in{$_->{name}});



}
my $cle =$tmp{id};
delete $tmp{id};
$all_domain->{$cle}  = \%tmp; 
my $l =Dumper($all_domain);
$c->{domain} = $all_domain ;
### write xml ###
my $res =&writexml($config{XML_file},$c);
unless ($res)  {
system ("mv  $config{XML_file} $config{XML_file}.bak");
system ("mv  $config{XML_file}.tmp $config{XML_file} ");
}
&redirect("domain.cgi");


