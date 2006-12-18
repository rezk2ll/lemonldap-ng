#!/usr/bin/perl
# create_handler.cgi
use Data::Dumper;
require './lemonldap-lib.pl';
&ReadParse();

my $domain = $in{'domain'};
my $c = &get_config;
my $all_domain = $c->{domain};
# Display global category icons
my @tab= @{&get_handler_attr()} ;

my %tmp;
foreach (@tab) {
undef ($in{$_->{name}}) if $in{$_->{name}} eq '';
$tmp{$_->{name}}= $in{$_->{name}} if defined ($in{$_->{name}});



}
my $cle =$tmp{id};
delete $tmp{id};
$all_domain->{$domain}->{handler}->{$cle}  = \%tmp; 
my $l =Dumper($all_domain);
$c->{domain} = $all_domain ;
### write xml ###
my $res =&writexml($config{XML_file},$c);
unless ($res)  {
system ("mv  $config{XML_file} $config{XML_file}.bak");
system ("mv  $config{XML_file}.tmp $config{XML_file} ");
}
### process at httpd.conf
if ($in{'virtualhost_line'}) {
my $ligne="<virtualhost $in{'virtualhost_line'} >\n";
 $ligne.= "ServerName $in{'servername'}\n" if $in{'servername'};
 $ligne.= "perltranshandler $in{'perltranshandler'}\n" if $in{'perltranshandler'};
$ligne.="PerlSetVar lemonldapHandlerID $cle\n" if $in{lemonldaphandlerid} eq 'yes'  ; 
$ligne.="</virtualhost>\n" ;
open ENTRE ,">>$config{httpd_conf}" ;
print ENTRE $ligne;
close ENTRE ;
}

&redirect("un_domain.cgi?domain=$domain");
