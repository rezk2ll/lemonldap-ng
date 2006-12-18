#!/usr/bin/perl
#update_domain.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';

# Check if lemonlap is installed
&ReadParse();

my $domain = $in{'domain'};

%un_domain= %{&get_un_domain($domain)};
my @tab= @{&get_domain_attr()} ;
my %cle;
foreach (keys %un_domain) {
    $cle{lc($_)} = $un_domain{$_};
}
my $maj=0;
my %majh;
foreach (@tab) {
my $cle1 =$_->{name};
my $cle2="_$cle1";
	if ($in{$cle1}  ne $in{"$cle2"}) 
{ # maj needed 
$maj=1;

}
$majh{$cle1} = $in{$cle1} if $in{$cle1} ;

}
if ($maj)  {
$majh{handler} = $un_domain{handler} ;
$majh{id} = $domain;
 my $c = &get_config;
$c->{domain}->{$domain} = \%majh ;

my $res =&writexml($config{XML_file},$c);
unless ($res)  {
system ("mv  $config{XML_file} $config{XML_file}.bak");
system ("mv  $config{XML_file}.tmp $config{XML_file} ");
}

} 
&redirect("un_domain.cgi?domain=$domain");


