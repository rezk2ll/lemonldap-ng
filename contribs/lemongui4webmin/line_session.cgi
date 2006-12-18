#!/usr/bin/perl
# index.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';
&header($text{'index_title'}, "", undef, 1, 1, 0,
	&help_search_link("lemonldap", "man", "doc", "google"));
	print "<hr>\n";

print "<h3>$text{'index_lines'}</h3>\n";
%lines = %{&get_session_line};

my @attr1 = @{&get_ligne_attr()} ;
#$l =Dumper(@attr) ;
#print "eric $l";


print "<h3>$text{'index_line'}</h3>\n";
#foreach (keys %lines) {
#    print "$_ <br>";

#}

print "<table border=1 bgcolor='orange'>";
my $ligne=&formcolonne(\@attr1,'name') ;
print "$ligne";

foreach (keys %lines) {
my @a;
 push @a,"<a href=/lemonldap/modif_line.cgi?line=$_>$_</a>" ;
my $ctr =$_;
foreach (@attr1) {
     next if  $_->{name}=~/^id/i;
   push @a,$lines{$ctr}->{$_->{name}}||"&nbsp"; 
  #  push @a,$lines{$_}->{cle} ;
  #  push @a,$lines{$_}->{valeur} ;
  #  push @a,$lines{$_}->{primarykey}||'&nbsp;' ;
   }
my $ligne=&formline(\@a,) ;
print "$ligne";

}


print  "</table>";
print "<h3>$text{'index_exp'}</h3>\n";
%exp = %{&get_session_exp};

# Display global category icons
@attr = @{&get_exp_attr()} ;

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
my $table  = tablemaj(@attr1) ;
print "<h3>$text{'create_line'}</h3>\n";

print "<form method=get target= line_create.cgi>";

print $table ;
print "<p><input type=submit>";

print "</form>";
my $table  = tablemaj(@attr) ;
print "<h3>$text{'create_exp'}</h3>\n";

print "<form method=get target= exp_create.cgi>";

print $table ;
print "<p><input type=submit>";
print "</form>";

&footer("/lemonldap/session.cgi", $text{'index'});
