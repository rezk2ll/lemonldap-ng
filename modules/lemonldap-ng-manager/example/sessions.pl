#!/usr/bin/perl

use strict;

use Lemonldap::NG::Manager::Sessions;

our $cgi = Lemonldap::NG::Manager::Sessions->new({
        localStorage        => "Cache::FileCache",
        localStorageOptions => {
            'namespace'          => 'MyNamespace',
            'default_expires_in' => 600,
            'directory_umask'    => '007',
            'cache_root'         => '/tmp',
            'cache_depth'        => 5,
        },
	# Use configStorage with Debian
        #configStorage => $Lemonldap::NG::Conf::configStorage,
        configStorage => {
            type    => 'File',
            dirName => "__CONFDIR__",
        },
        https         => 0,
        jqueryUri     => 'jquery.js',
        imagePath     => '/images/',
        ## PROTECTION, choose one of :

        ## * protection by manager
        # protection  => 'manager',

        ## * specify yourself the rule to apply (same as in the manager)
        # protection  => 'rule: $uid=admin',

        ## * all authenticate users are granted
        # protection  => 'authenticate

        ## * nothing : not protected
});

$cgi->process();
