use Test::More;
use JSON;
use strict;
require 't/test-lib.pm';

my $tests = 9;

use_ok('Lemonldap::NG::Common::Cli');
use_ok('Lemonldap::NG::Manager::Cli');
&cleanConfFiles;

SKIP: {
    eval 'use Test::Output;';
    if ($@) {
        skip 'Test::Output is missing, skipping', $tests - 2;
    }
    my $client =
      Lemonldap::NG::Manager::Cli->new( iniFile => 't/lemonldap-ng.ini' );
    my @cmd;
    my $res;

    # Test 'set' command
    @cmd = qw(-yes 1 set notification 1);
    $res = Capture::Tiny::capture_stdout( sub { $client->run(@cmd) } );

    # Test 'get' command
    @cmd = qw(get notification);
    $res = Capture::Tiny::capture_stdout( sub { $client->run(@cmd) } );
    ok( $res =~ /^notification\s+=\s+1$/, '"get notification" OK' )
      or diag " $res";

    # Test 'addKey' command
    @cmd = qw(-yes 1 addKey locationRules/test1.example.com ^/reject deny);
    Test::Output::combined_like(
        sub { $client->run(@cmd) },
        qr#'\^/reject' => 'deny'#s,
        '"addKey" OK'
    );

    # Test 'delKey' command
    @cmd = qw(-yes 1 delKey locationRules/test1.example.com ^/reject);
    Test::Output::combined_unlike(
        sub { $client->run(@cmd) },
        qr#'\^/reject' => 'deny'#s,
        '"delKey" OK'
    );

    # Test 'get' command
    @cmd = qw(get locationRules/test1.example.com);
    $res = Capture::Tiny::capture_stdout( sub { $client->run(@cmd) } );
    ok( $res =~ m#(?:/logout|default)#, '"get key/subkey" OK' )
      or diag "$res";

    # Test 'save' command
    @cmd = ('save');
    $res = Capture::Tiny::capture_stdout( sub { $client->run(@cmd) } );
    ok( $res =~ /^\s*(\{.*\})\s*$/s, '"save" result looks like JSON' );
    eval { JSON::from_json($res) };
    ok( not($@), ' result is JSON' ) or diag "error: $@";

    # Test 'restore' command
    close STDIN;
    open STDIN, '<', \$res;
    @cmd = ( 'restore', '-' );
    Test::Output::combined_like( sub { $client->run(@cmd) },
        qr/"cfgNum"\s*:\s*"3"/s, 'New config: 3' );
}

count($tests);
done_testing( count() );
&cleanConfFiles;

sub cleanConfFiles {
    foreach ( 2 .. $tests - 3 ) {
        unlink "t/conf/lmConf-$_.json";
    }
}
