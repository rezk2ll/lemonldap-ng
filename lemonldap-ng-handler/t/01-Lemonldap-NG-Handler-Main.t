package main;
use strict;
use warnings;
require 't/test.pm';

use Test::More tests => 10;
BEGIN { use_ok('Lemonldap::NG::Handler::Main') }

# get a standard basic configuration in $args hashref
use Cwd 'abs_path';
use File::Basename;
use lib dirname( abs_path $0 );

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
my $h;
$h = 'Lemonldap::NG::Handler::Test';
$ENV{SERVER_NAME} = "test1.example.com";

#open STDERR, '>/dev/null';

my $conf = {
    'cfgNum'        => 1,
    'logLevel'      => 'error',
    'portal'        => 'http://auth.example.com/',
    'globalStorage' => 'Apache::Session::File',
    'post'          => {},
    'locationRules' => {
        'test1.example.com' => {

            # Basic rules
            'default' => 'accept',
            '^/no'    => 'deny',
            'test'    => '$groups =~ /\badmin\b/',

            # Bad ordered rules
            '^/a/a' => 'deny',
            '^/a'   => 'accept',

            # Good ordered rules
            '(?#1 first)^/b/a' => 'deny',
            '(?#2 second)^/b'  => 'accept',
        },
    },
};

ok( $h->init($conf),         'init' );
ok( $h->configReload($conf), 'Load conf' );

ok( $h->tsv->{portal}->() eq 'http://auth.example.com/', 'portal' );

ok( $h->grant( undef, '/s' ), 'basic rule "accept"' );
ok( !$h->grant( undef, '/no' ), 'basic rule "deny"' );
ok( $h->grant( undef, '/a/a' ), 'bad ordered rule 1/2' );
ok( $h->grant( undef, '/a' ),   'bad ordered rule 2/2' );
ok( !$h->grant( undef, '/b/a' ), 'good ordered rule 1/2' );
ok( $h->grant( undef, '/b' ), 'good ordered rule 2/2' );
