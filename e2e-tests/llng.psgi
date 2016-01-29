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
    };
    die $@ if ($@);
}

my %_apps;

my %builder = (
    handler => sub {
        require Lemonldap::NG::Handler::PSGI::Server;
        return Lemonldap::NG::Handler::PSGI::Server->run( {} );
    },
    manager => sub {
        require Lemonldap::NG::Manager;
        return Lemonldap::NG::Manager->run( {} );
    },
    auth => sub {
        require CGI::Emulate::PSGI;
        require CGI::Compile;
        return CGI::Emulate::PSGI->handler(
            CGI::Compile->compile('lemonldap-ng-portal/example/index.pl') );
    }
);

sub {
    my $type = $_[0]->{LLTYPE} || 'handler';
    print STDERR Dumper($_[0]);use Data::Dumper;
    return $_apps{$type}->(@_) if ( defined $_apps{$type} );
    if ( defined $builder{$type} ) {
        $_apps{$type} = $builder{$type}->();
        return $_apps{$type}->(@_);
    }
    die "Unknown PSGI type $type";
};

