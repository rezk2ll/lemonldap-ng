#!/usr/bin/perl
# un_handler.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';

# Check if lemonlap is installed
&ReadParse();

my $domain = $in{'domain'};
my $handler= $in{'handler'};
&header($text{'index_title'}, "", undef, 1, 1, 0,
	&help_search_link("lemonldap", "man", "doc", "google"));
	print "<hr>\n";
print  "$domain -- $handler";
my %hand = %{&get_un_handler($domain,$handler)};

my @tab= @{&get_handler_attr()} ;
print "<form  method=get action=delete_handler.cgi>";
print "<b>$text{confirm}:</b><input type=checkbox name=confirm value=yes>";
print "<input type=hidden name=domain value=$domain>";
print "<input type=hidden name=handler value=$handler>";
print "<input type=submit name=delete value=delete>";
print "</form>";  

print "<form method=get action=update_handler.cgi >" ;
print "<table border=1>";
my %cle;
foreach (keys %hand) {
    $cle{lc($_)} = $hand{$_};
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
print $ligne;
#$l = Dumper(%control); 
#print "<p>$l eric3";
 


}
print "</table>";
print "<p>";
print "<input type=hidden name=domain value=$domain>";
print "<input type=hidden name=handler value=$handler>";

print "<input type=submit>";
    print "</form>";
print "<hr>";
print "<h3>$config{httpd_conf}</h3>\n";
my $c= &find_handler_in_httpd($config{httpd_conf},$handler);


my @httpd =@{&get_param_httpd($c)};

my @htab= @{&get_handler_attr_httpd()} ;
my %hcle;
foreach (@httpd) {
    next if $_->{name} !~ /perlsetvar/i ;
   my $cle = lc($_->{words}->[0] ) ;
   my $value = $_->{words}->[1];   
    $hcle{$cle}= $value;
}

print "<form method=get action=update_handler_httpd.cgi >" ;
print "<table border=1>";
foreach (@htab) {
    my $ligne;
    my %control =%{$_};
    $control{mxlength}=70;
    $control{length}=60;
    $control{value} = $hcle{$control{name}} if exists $hcle{$control{name}} ;
    if ($control{liste}) { $ligne=&formradiomaj(%control);

}  else { $ligne=&formtextmaj(%control) ;}
print "$ligne\n";
#$l = Dumper(%control); 
#print "<p>$l eric3";
 


}
print "</table>";
print "<p>";
print "<input type=hidden name=domain value=$domain>";
print "<input type=hidden name=handler value=$handler>";

print "<input type=submit>";
    print "</form>";
print "<hr>";
print "<h3>$config{httpd_conf} features</h3>\n";
print "<form method=get action=update_handler_httpd_ng.cgi >" ;
print "<input type=hidden name=domain value=$domain>";
print "<input type=hidden name=handler value=$handler>";
print "<table border=1>";
my $lh = "&lt;" .$c->{name}." ".$c->{value}."&gt;";
$control{name} =$c->{line} ;
$control{value}  = $lh;  
    $control{mxlength}=80;
    $control{length}=70;

 $ligne=&formtextfixed(%control) ;
print $ligne;
my @httpdng =@{&get_param_httpd($c)};
foreach (@httpdng) {
    next if $_->{name} eq 'dummy';
    my %control;
my $lh = $_->{name}." ".$_->{value};
$control{name} =$_->{line} ;
$control{value}  = $lh;  
    $control{mxlength}=80;
    $control{length}=70;
my  $ligne=&formtextmaj(%control) ;
print $ligne;


}
my $fin=$c->{eline} ;
my $enplus=$fin;
$lh ="";
$control{name} =$fin;
$control{value}  = $lh;  
    $control{mxlength}=80;
    $control{length}=70;
 $ligne=&formtextmaj(%control) ;
print $ligne;
$fin ++;

my $lh = "&lt;/virtualhost&gt;";
$control{name} =$fin ;
$control{value}  = $lh;  
    $control{mxlength}=80;
    $control{length}=70;

 $ligne=&formtextfixed(%control) ;
print "$ligne\n";


print "</table>";
print "<input type=hidden name=valmax value=$enplus>";
print "<p>";
print "<input type=submit>";

    print "</form>";


 
&footer("/lemonldap", $text{'index'});
