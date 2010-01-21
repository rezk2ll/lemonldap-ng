#!/usr/bin/perl
use HTML::Template;

my $skin_dir = "__SKINDIR__";

my $portal = Lemonldap::NG::Portal::SharedConf->new(

	# PORTAL CUSTOMIZATION
	# Skin
	#portalSkin => 'pastel',
);

my $skin       = $portal->{portalSkin};
my $portal_url = $portal->{portal};
my $logout_url = "$portal_url?logout=1";

# Which HTTP error?
my $http_error = $portal->param('error');

my $error500 = 1 if ( $http_error eq "500" );
my $error403 = 1 if ( $http_error eq "403" or !$error500 );

my $template = HTML::Template->new(
   filename => "$skin_dir/$skin/error.tpl",
   die_on_bad_params => 0,
   cache => 0,
    filter            => sub { $portal->translate_template(@_) }
);

$template->param( PORTAL_URL => "$portal_url" );
$template->param( LOGOUT_URL => "$logout_url" );
$template->param( SKIN       => "$skin" );
$template->param( ERROR403   => "$error403" );
$template->param( ERROR500   => "$error500" );

print $portal->header('text/html; charset=utf8');
print $template->output;
