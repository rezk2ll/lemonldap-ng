#!/usr/bin/perl
# un_domain.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';
# Check if lemonlap is installed
&ReadParse();
my $domain = $in{'domain'};
if ($in{'delete'}  and $in{'confirm'} eq 'yes') {
 my $c = &get_config;
my $all_domain = $c->{domain};
my $all_handler= $all_domain->{$domain}{handler} ;
 &sauvefile($config{httpd_conf},'tmp1');
 foreach (keys %{$all_handler} ) {
&delete_handler_httpd($_); 
 }
delete $all_domain->{$domain}; 

$c->{domain} = $all_domain ;
 &restaurefile("$config{httpd_conf}",'tmp1');
my $res =&writexml($config{XML_file},$c);
unless ($res)  {
system ("mv  $config{XML_file} $config{XML_file}.bak");
system ("mv  $config{XML_file}.tmp $config{XML_file} ");
}
}


&redirect("domain.cgi");


