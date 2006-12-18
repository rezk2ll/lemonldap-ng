#!/usr/bin/perl
#update_handler_httpd_ng.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';

# Check if lemonlap is installed
&ReadParse();

my $domain = $in{'domain'};
my $handler = $in{'handler'};
#my $c= &find_handler_in_httpd($config{httpd_conf},$handler);
#my @httpd =@{&get_param_httpd($c)};
my %_ligne ;

my $lv ;

foreach (keys %in) {
    next if !/^\d+/;
    my $cle =$_;
    $_ligne{$cle} = $in{$cle} ;
}


my $b = $in{valmax};
$_ligne{$b-1} .="\n$_ligne{$b}" if   $_ligne{$b};
delete $_ligne{$b};

&rewrite_httpd($config{httpd_conf}, \%_ligne);
&redirect("un_handler.cgi?domain=$domain&handler=$handler");


