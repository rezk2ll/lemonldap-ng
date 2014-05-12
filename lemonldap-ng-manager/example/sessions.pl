#!/usr/bin/perl

use strict;
use Lemonldap::NG::Manager;
use Lemonldap::NG::Manager::Sessions;
use HTML::Template;

my $cgi = Lemonldap::NG::Manager::Sessions->new(
    {

        # SESSION EXPLORER CUSTOMIZATION
        #managerSkin		=> 'default',

        # ACCESS TO CONFIGURATION

        # By default, Lemonldap::NG uses the default storage.conf file to know
        # where to find is configuration
        # (generaly /etc/lemonldap-ng/storage.conf)
        # You can specify by yourself this file :
        #configStorage => { type => 'File', dirName => '/path/to/my/file' },

        # You can also specify directly the configuration
        # (see Lemonldap::NG::Handler::SharedConf(3))
        #configStorage => {
        #      type => 'File',
        #      directory => '/usr/local/lemonlda-ng/conf/'
        #},
    }
) or Lemonldap::NG::Common::CGI->abort('Unable to start sessions explorer');

my $skin = $cgi->{managerSkin} or $cgi->abort('managerSkin is not defined');
my $css = 'tree.css';
my $css_theme = 'ui-lightness';
my $skin_dir  = 'skins';
my $main_dir  = $cgi->getApacheHtdocsPath;

my $template = HTML::Template->new(
    filename          => "$main_dir/$skin_dir/$skin/sessions.tpl",
    die_on_bad_params => 0,
    cache             => 0,
    filter            => sub { $cgi->translate_template(@_) },
);
$template->param( SCRIPT_NAME => $ENV{SCRIPT_NAME} );
$template->param( TREE        => $cgi->tree() );
$template->param( DIR         => "$skin_dir/$skin" );
$template->param( CSS         => $css );
$template->param( CSS_THEME   => $css_theme );
$template->param( VERSION     => $Lemonldap::NG::Manager::VERSION );
$template->param( LANG        => shift $cgi->{lang} );
print $cgi->header('text/html; charset=utf-8');
print $template->output;

