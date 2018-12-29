# Base library for tests

use strict;
use Data::Dumper;
use 5.10.0;
use_ok('Lemonldap::NG::Manager::Cli::Lib');

our $client;

ok(
    $client =
      Lemonldap::NG::Manager::Cli::Lib->new( iniFile => 't/lemonldap-ng.ini' ),
    'Client object'
);

sub client {
    return $client;
}

our $count = 2;

sub count {
    my $c = shift;
    $count += $c if ($c);
    return $count;
}

sub clean_sessions {
    opendir D, 't/sessions' or die $!;
    foreach ( grep { /^[^\.]/ } readdir(D) ) {
        unlink "t/sessions/$_", "t/sessions/lock/Apache-Session-$_.lock";
    }
    foreach my $dir (qw(t/sessions/lock t/sessions/saml/lock t/sessions/saml)) {
        if ( -d $dir ) {
            opendir D, $dir or die $!;
            foreach ( grep { /^[^\.]/ } readdir(D) ) {
                unlink "$dir/$_";
            }
        }
    }
    my $cache = getCache();
    $cache->clear;
}

sub getCache {
    require Cache::FileCache;
    return Cache::FileCache->new(
        {
            namespace   => 'lemonldap-ng-session',
            cache_root  => 't/',
            cache_depth => 0,
        }
    );
}

1;
