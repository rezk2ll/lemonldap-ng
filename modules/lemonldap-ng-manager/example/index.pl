#!/usr/bin/perl

use Lemonldap::NG::Manager;

my $h = new Lemonldap::NG::Manager(
    {
        # REQUIRED PARAMETERS
        dhtmlXTreeImageLocation => "/imgs/",
        applyConfFile           => '__APPLYCONFFILE__',
        cssFile => 'theme/default.css',
        textareaW               => 50,
        textareaH               => 2,
        inputSize               => 30,

        # OPTIONAL PARAMETERS

        ## PROTECTION, choose one of :
        # * protection by manager
        # protection  => 'manager',
        # * specify yourself the rule to apply (same as in the manager)
        # protection  => 'rule: $uid=admin',
        # * all authenticate users are granted
        # protection  => 'authenticate',
        # * nothing : not protected

        #jsFile => /path/to/lemonldap-ng-manager.js,

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
) or die "Unable to start";

$h->doall();
