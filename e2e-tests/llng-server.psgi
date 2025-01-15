$ENV{LLNG_DEFAULTCONFFILE} = 'e2e-tests/conf/lemonldap-ng.ini';

use lib 'lemonldap-ng-common/blib/lib';
use lib 'lemonldap-ng-handler/blib/lib';
use lib 'lemonldap-ng-portal/blib/lib';
use lib 'lemonldap-ng-manager/blib/lib';

our (
  $sourceServer
);

$sourceServer ||= $ENV{SOURCE_SERVER} || 'nginx';
my $class = (
      $sourceServer eq 'nginx'   ? 'Lemonldap::NG::Handler::Server::Nginx'
    : $sourceServer eq 'traefik' ? 'Lemonldap::NG::Handler::Server::Traefik'
    :                              die("Unknown server $sourceServer")
);

my %builder = (
    handler => sub {
        eval "require $class";
        return $class->run( {} );
    },
    reload => sub {
        eval "require $class";
        return $class->reload();
    },
    manager => sub {
        require Lemonldap::NG::Manager;
        return Lemonldap::NG::Manager->run( {} );
    },
    portal => sub {
        require Lemonldap::NG::Portal;
        return Lemonldap::NG::Portal->run( {} );
    },
    cgi => sub {
        require CGI::Emulate::PSGI;
        require CGI::Compile;
        return sub {
            my $script = $_[0]->{SCRIPT_FILENAME};
            return $_apps{$script}->(@_) if ( $_apps{$script} );
            $_apps{$script} =
              CGI::Emulate::PSGI->handler( CGI::Compile->compile($script) );
            return $_apps{$script}->(@_);
        };
    },
    psgi => sub {
        return sub {

            # Fix PATH_INFO when using Nginx with default uwsgi_params
            # See #2031
            ( $_[0]->{PATH_INFO} ) =
              $_[0]->{REQUEST_URI} =~ /^(?:\Q$_[0]->{SCRIPT_NAME}\E)?([^?]*)/;

            my $script = $_[0]->{SCRIPT_FILENAME};
            return $_apps{$script}->(@_) if ( $_apps{$script} );
            $_apps{$script} = do $script;
            unless ( $_apps{$script} and ref $_apps{$script} ) {
                my $errmsg = $@ || $! || "unknown error";
                die("Unable to load $_[0]->{SCRIPT_FILENAME}: $errmsg");
            }
            return $_apps{$script}->(@_);
        }
    },
);

sub {
    my $type = $_[0]->{LLTYPE} || 'handler';
    return $_apps{$type}->(@_) if ( defined $_apps{$type} );
    if ( defined $builder{$type} ) {
        $_apps{$type} = $builder{$type}->();
        return $_apps{$type}->(@_);
    }
    die "Unknown PSGI type $type";
};
