#!/usr/bin/perl
#update_handler.cgi
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
require './lemonldap-lib.pl';

# Check if lemonlap is installed
&ReadParse();
my $domain = $in{'domain'};
my $handler = $in{'handler'};
my $c= &find_handler_in_httpd($config{httpd_conf},$handler);
my @httpd =@{&get_param_httpd($c)};
my @htab= @{&get_handler_attr_httpd()} ;
my %hcle;
my %_ligne ;
foreach (@httpd) {
    next if $_->{name} !~ /perlsetvar/i ;
    $_ligne{$_->{'line'}} = '' ;
    $_ligne{debut}= $_->{'line'}   unless $_ligne{debut} ;
   my $cle = lc($_->{words}->[0] ) ;
   my $value = $_->{words}->[1];   
    $hcle{$cle}= $value;
}
unless ($_ligne{debut}) { $_ligne{debut} = $httpd[0]->{eline} +1  ;}
my %cle;
foreach (@htab) {
    $cle{lc($_->{name})} =1;
}
my $maj;
foreach (keys %in) {
    next unless /^_/ ;
my $cle1 = $_;
my ($cle2) = $cle1=~/_(.+)/;  
   if ($in{$cle1} ne $in{$cle2} ) {
       $maj =1;
}
}   
## supress blank
foreach (keys %in) {
    delete $in{$_} if $in{$_} =~ /^$/;
    delete $in{$_} unless $cle{lc($_)} ;
}
#add ID handler 
    $in{lemonldaphandlerid} =$handler;
# now add ligne in %_ligne 
    my $debut = $_ligne{debut} ;
my $lv ;
foreach (keys %in) {
    my $cle =$_;
$lv.= "perlsetvar $cle $in{$_}\n" ;
}
$_ligne{$debut} = $lv;
&rewrite_httpd($config{httpd_conf}, \%_ligne);
&redirect("un_handler.cgi?domain=$domain&handler=$handler");


