# Plack app to use with Nginx
#
# This app can replace FastCGI server using Starman, Twiggy, uWSGI-Plugin-PSGI,
# Feersum,...

my %builder = (
    handler => sub {
        require Lemonldap::NG::Handler::Server::Nginx;
        return Lemonldap::NG::Handler::Server::Nginx->run( {} );
    },
    reload => sub {
        require Lemonldap::NG::Handler::Server::Nginx;
        return Lemonldap::NG::Handler::Server::Nginx->reload();
    },
    status => sub {
        require Lemonldap::NG::Handler::Server::Nginx;
        return Lemonldap::NG::Handler::Server::Nginx->status();
    },
    manager => sub {
        require Lemonldap::NG::Manager;
        return Lemonldap::NG::Manager->run( {} );
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
            my $script = $_[0]->{SCRIPT_FILENAME};
            return $_apps{$script}->(@_) if ( $_apps{$script} );
            $_apps{$script} = do $script;
            unless ( $_apps{$script} and ref $_apps{$script} ) {
                die "Unable to load $_[0]->{SCRIPT_FILENAME}";
            }
            return $_apps{$script}->(@_);
          }
    },
);

unless ($>) {
    die "Refuse to run as root. Aborting";
}

# Hook for customFunctions initialization
Lemonldap::NG::Handler::Main->onReload(
    bless( {}, 'Lemonldap::NG::Handler::FastCGI::Loader' ),
    'loadCustomHandlers' );

# Main routine
sub {
    my $type = $_[0]->{LLTYPE} || 'handler';
    return $_apps{$type}->(@_) if ( defined $_apps{$type} );
    if ( defined $builder{$type} ) {
        $_apps{$type} = $builder{$type}->();
        return $_apps{$type}->(@_);
    }
    return [ 500, [], ["Unknown PSGI type $type"] ];
};

