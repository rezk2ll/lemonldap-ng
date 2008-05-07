#!/usr/bin/perl

use Lemonldap::NG::Manager;

my $h = new Lemonldap::NG::Manager(
    {
        configStorage => {
            type    => 'File',
            dirName => "__CONFDIR__",
        },
        dhtmlXTreeImageLocation => "/imgs/",
        applyConfFile           => '__DIR__/manager/apply.conf',
        cssFile => 'theme/default.css',
        textareaW               => 50,
        textareaH               => 2,
        inputSize               => 10,

        # jsFile => /path/to/lemonldap-ng-manager.js,
    }
) or die "Unable to start";

$h->doall();
