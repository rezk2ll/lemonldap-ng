#!/usr/bin/perl
#update_handler.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';

# Check if lemonlap is installed
&ReadParse();

my $domain = $in{'domain'};
my $handler = $in{'handler'};
my %hand = %{&get_un_handler($domain,$handler)};
my @tab= @{&get_handler_attr()} ;

my %cle;
foreach (keys %hand) {
    $cle{lc($_)} = $hand{$_};
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
$majh{id} = $handler;
 my $c = &get_config;
$c->{domain}->{$domain}->{handler}->{$handler} = \%majh ;

my $res =&writexml($config{XML_file},$c);
unless ($res)  {
system ("mv  $config{XML_file} $config{XML_file}.bak");
system ("mv  $config{XML_file}.tmp $config{XML_file} ");
}

} 

&redirect("un_handler.cgi?domain=$domain&handler=$handler");


