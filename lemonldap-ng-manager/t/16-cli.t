use Test::More;
use JSON;
use strict;
require 't/test-lib.pm';

my $tests = 14;

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
    my $commonClient =
      Lemonldap::NG::Common::Cli->new( iniFile => 't/lemonldap-ng.ini' );
    my @cmd;
    my $res;

    # Test 'set' command
    @cmd = qw(-yes 1 set notification 1);
    Capture::Tiny::capture_stdout( sub { $client->run(@cmd) } );

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

    # Test 'get' command with key/subkey
    @cmd = qw(get locationRules/test1.example.com);
    $res = Capture::Tiny::capture_stdout( sub { $client->run(@cmd) } );
    ok( $res =~ m#(?:/logout|default)#, '"get key/subkey" OK' )
      or diag "$res";

    # Test 'set' command with key/subkey
    @cmd = qw(-yes 1 set locationRules/test1.example.com/default deny);
    Capture::Tiny::capture_stdout( sub { $client->run(@cmd) } );


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

    # Test 'set' command with force
    @cmd = qw(-yes 1 -force 1 -cfgNum 2 set useSafeJail 0);
    Test::Output::combined_like(
        sub { $client->run(@cmd) },
        qr#cfgNum forced with 2#s,
        '"Force cfgNum" OK'
    );

    # Test 'update-cache' command with force
    @cmd = qw(update-cache);
    Test::Output::combined_like(
        sub { $commonClient->run(@cmd) },
        qr#Cache updated to configuration 3#s,
        '"update-cache" OK'
    );

    # Test 'info' command with force
    @cmd = qw(info);
    Test::Output::combined_like(
        $res = sub { $commonClient->run(@cmd) },
        qr#\bAuthor IP\b#s,
        '"Author IP" OK'
    );
    Test::Output::combined_like(
        $res = sub { $commonClient->run(@cmd) },
        qr#\bLog\b#s,
        '"Log" OK'
    );
    Test::Output::combined_like(
        $res = sub { $commonClient->run(@cmd) },
        qr#\bVersion\b#s,
        '"Version" OK'
    ); 
}

count($tests);
done_testing( count() );
&cleanConfFiles;

sub cleanConfFiles {
    foreach ( 2 .. $tests - 3 ) {
        unlink "t/conf/lmConf-$_.json";
    }
}
