#!/usr/bin/perl

use HTML::Template;
use CGI;

my $tpl_dir = "/var/lib/lemonldap-ng/web/portal/tpl" ;
my $page = CGI->new() ;

my $template = HTML::Template->new( filename => "$tpl_dir/menu.tpl");
$template->param( AUTH_ERROR => "Access forbidden by WebSSO rules");

print $page->header();
print $template->output;
