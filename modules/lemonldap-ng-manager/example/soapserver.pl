#!/usr/bin/perl

use Lemonldap::NG::Manager::SOAPServer;

Lemonldap::NG::Manager::SOAPServer->start(
    configStorage => {
        type    => "File",
        dirName => "__CONFDIR__"
    }
);

__END__
