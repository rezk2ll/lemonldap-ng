#!/usr/bin/perl
# configcache.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';

# Check if lemonlap is installed

&header($text{'index_title'}, "", undef, 1, 1, 0,
	&help_search_link("lemonldap", "man", "doc", "google"));
	print "<hr>\n";




$exp1 = &get_configcache();
my %exp =%$exp1;
# Display global category icons
print "<h3>$text{'index_config'}</h3>\n";
@attr = @{&get_config_attr()} ;

print "<table border=1 bgcolor='grey'>";
my $ligne=&formcolonne(\@attr,'name') ;
print "$ligne";


foreach (keys %exp) {
my @a;
push @a,"<a href=/lemonldap/modif_exp.cgi?exp=$_>$_</a>" ;
my $ctr=$_;

foreach (@attr) {
     next if  $_->{name}=~/^id/i;
   push @a,$exp{$ctr}->{$_->{name}}||"&nbsp"; 
 }


  
my $ligne=&formline(\@a,) ;
print "$ligne";

}


print  "</table>";



print "<hr>";
my $table  = tablemaj(@attr) ;
print "<h3>$text{'create_line'}</h3>\n";

print "<form method=get target= config_create.cgi>";

print $table ;
print "<p><input type=submit>";

print "</form>";
&footer("/lemonldap", $text{'index'});
