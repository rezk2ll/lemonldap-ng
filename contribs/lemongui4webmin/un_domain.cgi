#!/usr/bin/perl
# un_domain.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';

# Check if lemonlap is installed
&ReadParse();

my $domain = $in{'domain'};
&header($text{'index_title'}, "", undef, 1, 1, 0,
	&help_search_link("lemonldap", "man", "doc", "google"));
	print "<hr>\n";
#my $l=Dumper (%in) ;
#print "eric $l" ;



%un_domain= %{&get_un_domain($domain)};
print "<h3>$domain</h3>\n";
print "<form  method=get action=delete_domain.cgi>";
print "<b>$text{confirm}:</b><input type=checkbox name=confirm value=yes>";
print "<input type=hidden name=domain value=$domain>";
print "<input type=submit name=delete value=delete>";
print "</form>";  
#$l =Dumper (%un_domain);
#print "eric1 $l";
my @tab= @{&get_domain_attr()} ;
#$l = Dumper(@tab); 
#print "$l eric2";
print "<form method=get action=update_domain.cgi >" ;
print "<table border=1>";
my %cle;
foreach (keys %un_domain) {
    $cle{lc($_)} = $un_domain{$_};
}
#$l= Dumper (%cle);
#print "eric $l\n";
 
foreach (@tab) {
    my $ligne;
    my %control =%{$_};
    next if $control{name} eq 'id';   
 $control{mxlength}=70;
    $control{length}=60;
    $control{value} = $cle{lc($control{name})} if exists $cle{lc($control{name})} ;
    if ($control{liste}) { $ligne=&formradiomaj(%control);

}  else { $ligne=&formtextmaj(%control) ;}
print "$ligne\n";
#$l = Dumper(%control); 
#print "<p>$l eric3";
 


}
print "</table>";
print "<p>";
print "<input type=hidden name=domain value=$domain>";
print "<input type=submit>";
    print "</form>";
print "<hr>";
print "<h3>Hanlders</h3>\n";

my %hand =%{$un_domain{handler}};
#$l = Dumper(%hand); 
#print "<p>$l eric3";
print "<table border =1>";

foreach (keys %hand){
print "<tr><td><a  href=\"/lemonldap/un_handler.cgi?domain=$domain&handler=$_\" >$_</a></td></tr>";
   
}
print "</table>";
print "<hr>";
print "<h3>Add hanlder</h3>\n";
my @tab= @{&get_handler_attr()} ;
#my $l = Dumper(@tab); 
#print "$l eric";
print "<form method=get action=create_handler.cgi >" ;
print "<table border=1>";

foreach (@tab) {
    my $ligne;
    my %control =%{$_};
    $control{mxlength}=70;
    $control{length}=60;

    if ($control{liste}) { $ligne=&formradio(%control);

}  else { $ligne=&formtext(%control) ;}
print $ligne;
 


}
print "</table>";
print "<p>";
print "<p><b> $text{add_httpd}  $config{httpd_conf}<b></p>" ; 
print "<input type=hidden name=domain value=$domain>";
print "<table>";
    %control='';
$control{name} ="virtualhost_line" ;
$control{value}  = '';  
    $control{mxlength}=80;
    $control{length}=70;
 $ligne=&formtextmaj(%control) ;
print "$ligne";

%control='';
$control{name} ="servername" ;
$control{value}  = '';  
    $control{mxlength}=80;
    $control{length}=70;
 $ligne=&formtextmaj(%control) ;
print $ligne;
%control='';
$control{name} ="perltranshandler" ;
$control{value}  = 'Lemonldap::Handlers::Generic';  
    $control{mxlength}=80;
    $control{length}=70;
 $ligne=&formtextmaj(%control) ;
print $ligne;
%control='';
$control{name} ="lemonldaphandlerid" ;
$control{value}  = 'yes';  
$ligne=&formcasemaj(%control) ;
print $ligne;
print "</table>";
print "<input type=submit>";
print "</form>";



&footer("/lemonldap", $text{'index'});
