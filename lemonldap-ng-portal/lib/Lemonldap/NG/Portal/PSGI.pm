##@file
# FastCGI package for Lemonldap::NG portal
#
##@class Lemonldap::NG::Portal::PSGI
# FastCGI class for Lemonldap::NG portal
package Lemonldap::NG::Portal::PSGI;

use strict;
use Mouse;
use Lemonldap::NG::Common::Conf::Constants;
use Lemonldap::NG::Handler::Main::Reload qw/keepConf/;

our $VERSION = '2.0.0';

use constant HANDLER => 'Lemonldap::NG::Handler::PSGI::API';

extends 'Lemonldap::NG::Handler::PSGI::Try';

has localConfig => ( is => 'rw' default => sub { {} } );

sub init {
    my ( $self, $args ) = @_;
    $args ||= {};
    return 0 unless ( $self->SUPER::init($args) );
    $self->localConfig(
        { %{ HANDLER->confAcc->getLocalConf('portal') }, %$args } );
    return $self->checkConf($args);
}

sub checkConf {
    my ( $self, $args ) = @_;
    # If handler configuration has changed, apply it
    if (  !$self->{cfgNum}
        or $self->{cfgNum} ne ( my $conf = HANDLER->lmConf->{cfgNum} ) )
    {

        # Delete keys that will be generated
        foreach my $key (
            qw(persistentStorage samlStorage casStorage captchaStorage oidcStorage)
          )
        {
            delete $self->{$key};
        }

        # Load conf in portal object
        foreach my $key ( keys %$conf ) {
            $self->{$key} = $localConfig->{$key} // $conf->{$key};
        }

        # Initialize session DBs
        unless($self->{globalStorage}) {
            $self->error('globalStorage not defined (perhaps configuration can not be read)');
            return 0;
        }
        foreach my $key (
            qw(persistentStorage samlStorage casStorage captchaStorage oidcStorage)
          )
        {
            unless($self->{$key}) {
                $self->{$key} = $self->{globalStorage};
                $self->{$key.'Options'} = $self->{globalStorageOptions};
            }
        }

        # Initialize cookie domain
        unless($self->{domain}) {
            $self->error('Configuration error: no domain');
            return 0;
        }
        $self->{domain} =~ s/^([^\.])/.$1/;

        # TODO: load authentication/userDB/passwordDB modules
    }
    1;
}

sub addRoutes {

}

1;
