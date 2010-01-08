#!/usr/bin/perl

use strict;
use Lemonldap::NG::Manager;
use HTML::Template;
our $skin_dir='skins';
our $main_dir='__MANAGERDIR__';

my $manager = new Lemonldap::NG::Manager(
    {
        # REQUIRED PARAMETERS
        applyConfFile           => '/etc/lemonldap-ng/apply.conf',
        managerSkin		=> 'default',
	managerCss		=> 'manager.css',
	managerTreeAutoClose	=> 'false',
	managerTreeJqueryCss	=> 'false',

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

        # CUSTOM FUNCTION
        # If you want to create customFunctions in rules, declare them here:
        #customFunctions    => 'function1 function2',
        #customFunctions    => 'Package::func1 Package::func2',
    }
) or Lemonldap::NG::Common::CGI->abort('Unable to start manager');

our $skin = $manager->{managerSkin};

my $template = HTML::Template->new(
    filename          => "$main_dir/$skin_dir/$skin/manager.tpl",
    die_on_bad_params => 0,
    cache             => 0,
    filter            => sub { $manager->translate_template(@_) },
);
$template->param(SCRIPT_NAME => $ENV{SCRIPT_NAME});
$template->param(MENU => $manager->menu());
$template->param(DIR => "$skin_dir/$skin");
$template->param(CFGNUM => $manager->{cfgNum});
$template->param(TREE_AUTOCLOSE => $manager->{managerTreeAutoClose});
$template->param(TREE_JQUERYCSS => $manager->{managerTreeJqueryCss});
$template->param(CSS => $manager->{managerCss});
print $manager->header('text/html; charset=utf-8');
print $template->output;

