#!perl -w
use constant HAS_LEAKTRACE => eval { require Test::LeakTrace };
use Test::More HAS_LEAKTRACE
  ? ( tests => 4 )
  : ( skip_all => 'require Test::LeakTrace' );
use Test::LeakTrace;

require 't/test-lib.pm';
require Lemonldap::NG::Common::Conf;
require Lemonldap::NG::Common::Conf::Backends::File;

my $ini = { logLevel => 'error', useSafejail => 0 };
foreach my $k ( keys %{$LLNG::Manager::Test::defaultIni} ) {
    $ini->{$k} //= $LLNG::Manager::Test::defaultIni->{$k};
}

# Test without initialization
leaks_cmp_ok {
    my $o = Lemonldap::NG::Common::PSGI::Cli::Lib->new;
    my $p = Lemonldap::NG::Portal::Main->new();
}
'<', 1;

# Test local config
leaks_cmp_ok {
    Lemonldap::NG::Common::Conf->new( $ini->{configStorage} )
      ->getLocalConf('portal');
}
'<', 1;

TODO: {
    local $TODO = "Not yet fully cleaned";

    # Test with initialization
    Lemonldap::NG::Handler::PSGI::Main->init($ini);
    Lemonldap::NG::Handler::PSGI::Main->checkConf(1);
    leaks_cmp_ok {
        my $p = Lemonldap::NG::Portal::Main->new();
        $p->init($ini);
        $p                                       = undef;
        @Lemonldap::NG::Handler::Main::_onReload = ();

        #$ini = undef;
        diag "After onReload clean\n";
    }
    '<', 1;
}
