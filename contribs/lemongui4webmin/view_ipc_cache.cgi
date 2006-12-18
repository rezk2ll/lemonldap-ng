#!/usr/bin/perl
# view_cache .cgi
# Display the icons for various types of lemonldapconfig options

require './lemonldap-lib.pl';
&ReadParse();
# Check if lemonlap is installed

&header($text{'index_title'}, "", undef, 1, 1, 0,
	&help_search_link("lemonldap", "man", "doc", "google"));
	print "<hr>\n";
#$conf = &get_config();
my $key= $in{'key'}||$in{ipckey};
# Display global category icons
print "<h3>$text{'dump_of_cache'}: $key </h3>\n";
my %hashkey ;
my $file_httpd= $config{httpd_conf} ;
open CONF , "< $file_httpd";
my @tab = <CONF> ;
close CONf;
my @tab1 ;
@tab1 = map { /lemonldapipckey(\s+)?(.+)/i } @tab ;
foreach (@tab1)  {
next if /^\s+$/ ;
$hashkey{$_} = 1;
}
my $a= `$config{scripts_IPC}/dump_cache.pl $key` ;
my @ipckey;
@ipckey = ($a=~ /\'ipckey\'\s=>\s\'(\w+)\'/ig) ;
foreach (@ipckey)  {
next if /^\s+$/ ;
$hashkey{$_} = 1;
}

$a=~ s/\n/<br>\n/g;
$a=~  s/\\'/\'/g;
$a=~ s/\s/&nbsp;/g;


print "  $a ";
print "<hr>";

print "<form action=view_ipc_cache.cgi   method=post>\n";
print "<input type=text  name=key size=4 maxlength=4>\n";
print "<select name=ipckey>";
foreach (keys %hashkey ) {
print "<option>$_\n";
}  
print "</select>";


print "<input type=submit  name=view value=$text{'view_ipc_cache'}>\n";
print "</form>";
print "<p>";
print "<hr>";
print "<form action=clean_IPC.cgi   method=post>\n";
print "<input type=submit  name=view value=\"$text{'delete_all_ipc_cache'}\">\n";
print "$text{'ipc_warning'}";
print "</form>";
print "<p>";
print "<hr>";

&footer("/", $text{'index'});

