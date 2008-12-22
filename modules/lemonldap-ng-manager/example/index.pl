#!/usr/bin/perl

use Lemonldap::NG::Manager;

my $h = new Lemonldap::NG::Manager(
    {
        dhtmlXTreeImageLocation => "/imgs/",
        applyConfFile           => '__APPLYCONFFILE__',
        cssFile => 'theme/default.css',
        textareaW               => 50,
        textareaH               => 2,
        inputSize               => 30,

        # jsFile => /path/to/lemonldap-ng-manager.js,
    }
) or die "Unable to start";

$h->doall();
