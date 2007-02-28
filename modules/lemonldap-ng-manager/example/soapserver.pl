#!/usr/bin/perl

use Lemonldap::NG::Manager::SOAPServer;

Lemonldap::NG::Manager::SOAPServer->start(
    configStorage => {
        type    => "File",
        dirName => "/usr/share/doc/lemonldap-ng/examples/conf/"
    }
);

__END__
