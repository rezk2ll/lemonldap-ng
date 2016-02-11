#!/usr/bin/env perl

use warnings;

BEGIN {
    $pwd = `pwd`;
    chomp $pwd;
    eval qq{
        use lib "$pwd/lemonldap-ng-common/blib/lib";
        use lib "$pwd/lemonldap-ng-handler/blib/lib";
        use lib "$pwd/lemonldap-ng-portal/blib/lib";
        use lib "$pwd/lemonldap-ng-manager/blib/lib";
        use Lemonldap::NG::Handler::SharedConf;
    };
    die $@ if ($@);
}

my %_apps;

my %builder = (
    handler => sub {
        require Lemonldap::NG::Handler::Nginx;
        return Lemonldap::NG::Handler::Nginx->run( {} );
    },
    status => sub {
        require Lemonldap::NG::Handler::Nginx;
        return Lemonldap::NG::Handler::Nginx->status();
    },
    manager => sub {
        require Lemonldap::NG::Manager;
        return Lemonldap::NG::Manager->run( {} );
    },
    auth => sub {
        require CGI::Emulate::PSGI;
        require CGI::Compile;
        return sub {
            my $script = $_[0]->{SCRIPT_NAME};
            return $_apps{$script}->(@_) if ( $_apps{$script} );
            eval {
                $_apps{$script} =
                  CGI::Emulate::PSGI->handler( CGI::Compile->compile($script) );
            };
            if ($@) {
                use Data::Dumper;
                return [
                    500,
                    [ 'Content-Type',              'text/plain' ],
                    [ "Script: $script\n    $@\n". Dumper( \$_[0] ) ]
                ];
            }
            return $_apps{$script}->(@_);
        };
    },
    test => sub {
        require CGI::Emulate::PSGI;
        require CGI::Compile;
        return CGI::Emulate::PSGI->handler(
            CGI::Compile->compile('e2e-tests/conf/site/index.pl') );
    },
);

Lemonldap::NG::Handler::SharedConf->init();

sub {
    my $type = $_[0]->{LLTYPE} || 'handler';
    return $_apps{$type}->(@_) if ( defined $_apps{$type} );
    if ( defined $builder{$type} ) {
        $_apps{$type} = $builder{$type}->();
        return $_apps{$type}->(@_);
    }
    die "Unknown PSGI type $type";
};

