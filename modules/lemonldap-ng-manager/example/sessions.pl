#!/usr/bin/perl

use strict;

use Lemonldap::NG::Manager::Sessions;

our $cgi = Lemonldap::NG::Manager::Sessions->new({

        # REQUIRED PARAMETERS
        jqueryUri     => 'jquery.js',
        imagePath     => '/images/',

        # PROTECTION, choose one of :
        # * protection by manager
        # protection  => 'manager',
        # * specify yourself the rule to apply (same as in the manager)
        # protection  => 'rule: $uid=admin',
        # * all authenticate users are granted
        # protection  => 'authenticate',
        # * nothing : not protected

        # REDIRECTIONS
        # You have to set this to explain to the handler if runs under SSL
        # or not (for redirections after authentications). Default is true.
        https => 0,

        # You can also fix the port (for redirections after authentications)
        #port => 80,

        # IP
        # You can configure sessions explorer to use X-FORWARDED-FOR rather than REMOTRE_ADDR for IP
        #useXForwardedForIP => 1,

        # ACCESS TO CONFIGURATION
        # By default, Lemonldap::NG uses the default storage.conf file to know
        # where to find is configuration
        # (generaly /etc/lemonldap-ng/storage.conf)
        # You can specify by yourself this file :
        #configStorage => { File => '/path/to/my/file' },

        # You can also specify directly the configuration
        # (see Lemonldap::NG::Handler::SharedConf(3))
        #configStorage => {
        #      type => 'File',
        #      directory => '/usr/local/lemonlda-ng/conf/'
        #},

        # OTHERS
        # You can also overload any parameter issued from manager
        # configuration. Example:
        #globalStorage => 'Lemonldap::NG::Common::Apache::Session::SOAP',
        #globalStorageOptions => {
        #    proxy => 'http://auth.example.com/index.pl/sessions',
        #    proxyOptions => {
        #        timeout => 5,
        #    },
        #    # If soapserver is protected by HTTP Basic:
        #    User     => 'http-user',
        #    Password => 'pass',
        #},
});

$cgi->process();
