#!/usr/bin/perl
use Lemonldap::NG::Portal::Error;
use HTML::Template;

my $skin_dir    = "/usr/local/lemonldap-ng/htdocs/portal/skins";

my $portal = Lemonldap::NG::Portal::SharedConf->new(
	# PORTAL CUSTOMIZATION
	# Skin
	#portalSkin => 'pastel',
);

my $skin       = $portal->{portalSkin};
my $portal_url = $portal->{portal};
my $logout_url = "$portal_url?logout=1";

my $template = HTML::Template->new(
   filename => "$skin_dir/$skin/error.tpl",
   die_on_bad_params => 0,
   cache => 0,
   filter => sub{$portal->translate_template(@_)}
);

$template->param( PORTAL_URL => "$portal_url" );
$template->param( LOGOUT_URL => "$logout_url" );
$template->param( SKIN       => "$skin" );

print $portal->header('text/html; charset=utf8');
print $template->output;
