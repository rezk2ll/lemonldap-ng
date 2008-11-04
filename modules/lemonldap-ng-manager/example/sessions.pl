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
        configStorage => $Lemonldap::NG::Conf::configStorage,
        https         => 1,
        jqueryUri     => 'jquery.js',
        imagePath     => 'images/',
});

$cgi->process();
