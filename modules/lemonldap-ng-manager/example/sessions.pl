#!/usr/bin/perl

use strict;

use Lemonldap::NG::Manager::Sessions;

our $cgi = Lemonldap::NG::Manager::Sessions->new({
        https         => 0,
        jqueryUri     => 'jquery.js',
        imagePath     => '/images/',
        ## PROTECTION, choose one of :

        ## * protection by manager
        # protection  => 'manager',

        ## * specify yourself the rule to apply (same as in the manager)
        # protection  => 'rule: $uid=admin',

        ## * all authenticate users are granted
        # protection  => 'authenticate',

        ## * nothing : not protected
});

$cgi->process();
