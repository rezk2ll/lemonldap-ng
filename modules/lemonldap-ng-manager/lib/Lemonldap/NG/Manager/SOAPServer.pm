package Lemonldap::NG::Manager::SOAPServer;

use strict;
use SOAP::Transport::HTTP;
use Lemonldap::NG::Manager::Conf;

our $VERSION = "0.1";

my $config;

sub start {
    my ( $args ) = @_;
    unless ($args) {
        print STDERR "parameters are required, I can't start so\n";
        return 0;
    }
    foreach (qw(configStorage)) {
        unless ( $args->{$_} ) {
            print STDERR qq/The "$_" parameter is required\n/;
            return 0;
        }
    }
    Lemonldap::NG::Manager::SOAPServer::Proxy->new( $args );
    $config = Lemonldap::NG::Manager::Conf->new( $args->{configStorage} );
    die "Configuration not loaded" unless $config;
    SOAP::Transport::HTTP::CGI->dispatch_to(__PACKAGE__."::Proxy")->handle;
}

package Lemonldap::NG::Manager::SOAPServer::Proxy;

sub available {
    return $config->available(@_)
}

sub lastCfg {
    return $config->lastCfg(@_)
}

sub store {
    return $config->store(@_)
}

sub load {
    return $config->load(@_)
}

1;
__END__
