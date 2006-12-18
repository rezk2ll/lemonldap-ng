#!/usr/bin/perl
# un_domain.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';
# Check if lemonlap is installed
&ReadParse();
my $domain = $in{'domain'};
my $handler = $in{'handler'};
if ($in{'delete'}  and $in{'confirm'} eq 'yes') {
 my $c = &get_config;
my $all_domain = $c->{domain};
delete $all_domain->{$domain}->{handler}->{$handler}; 
$c->{domain} = $all_domain ;
my $res =&writexml($config{XML_file},$c);
unless ($res)  {
system ("mv  $config{XML_file} $config{XML_file}.bak");
system ("mv  $config{XML_file}.tmp $config{XML_file} ");
}
}
###  delete info about httpd 
&delete_handler_httpd($handler);


&redirect("domain.cgi?domain=$domain");


