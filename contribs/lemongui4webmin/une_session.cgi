#!/usr/bin/perl
# une_session.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';


&ReadParse();

my $session = $in{'session'};

&header($text{'index_title'}, "", undef, 1, 1, 0,
	&help_search_link("lemonldap", "man", "doc", "google"));
	print "<hr>\n";
%une_session= %{&get_une_session($session)};
print "<h3>$session</h3>\n";
#$l =Dumper (%une_session);
#print "eric1 $l";
#exit;
my @tab= @{&get_session_attr()} ;

print "<form method=get target=update_session.cgi >" ;
print "<table border=1>";
my %cle;
foreach (keys %une_session) {
    $cle{lc($_)} = $une_session{$_};
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
print "<input type=submit>";
    print "</form>";
&footer("/lemonldap", $text{'index'});
