# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Handler-Vhost.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

package My::Package;

use Test::More tests => 2;

BEGIN {
    use_ok('Lemonldap::NG::Handler::Initialization::LocalInit');
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

ok(
    Lemonldap::NG::Handler::Initialization::LocalInit->localInit({
        status => 1,
        hideSignature => 0,
    }),
    'localInit method'
);

__END__
ok(
    my (
        $localStorage, $localStorageOptions,
        $statusPipe,   $statusOut
      )
      = $localinit->localInit(
        {
            localStorage        => 'Cache::FileCache',
            localStorageOptions => { 'namespace' => 'lemonldap-ng-sessions', },
            status              => 1,
        }
      ),
    'LocalInit methods: localInit'
);

ok(
    (
              $localStorage eq 'Cache::FileCache'
          and $localStorageOptions->{'namespace'} eq 'lemonldap-ng-sessions'
    ),
    'LocalInit methods: localInit values'
);

ok( $localinit->statusProcess == 0, 'LocalInit methods: statusProcess' );

ok( $statusPipe->isa('IO::Pipe::End'), 'status pipe: In pipe' );

ok( $statusOut->isa('IO::Pipe::End'), 'status pipe: Out pipe' );

ok( print( $statusPipe "uid => / OK\nuid => / OK\nuid => /no REJECT\n" ),
    'status pipe: New requests' );

ok( print( $statusPipe "STATUS\n" ), 'status pipe: Status request' );

ok( &read, 'status pipe: Status result' );

ok( close($statusOut), 'status pipe: close out pipe' );

ok( close($statusPipe), 'status pipe: close in pipe' );

sub read {
    my $ok = 0;

    #open LOG, '>/tmp/log';
    while (<$statusOut>) {

        #print LOG $_;
        $ok++ if (/^OK\s+:\s*2\s*\(2\.00\s*\/\s*mn\)$/);
        $ok++ if (/^REJECT\s+:\s*1\s*\(1\.00\s*\/\s*mn\)$/);
        if (/^END$/) {
            $ok++;
            last;
        }
    }

    #print LOG "$ok\n";
    #close LOG;
    return ( $ok == 3 );
}

