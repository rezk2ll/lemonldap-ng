#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 6;

#use IO::String;
use strict;
BEGIN { use_ok('Lemonldap::NG::Manager::_Struct') }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $tests = Lemonldap::NG::Manager::_Struct::testStruct();

my $ok =
  [ cookieName => 'lemon', domain => 'example.com', domain => '.example.com', ];
my $nok = [ cookieName => ' lemon', domain => ' example.com', ];

while (@$ok) {
    my ( $k, $v ) = splice @$ok, 0, 2;
    ok( $v =~ $tests->{$k}->{test}, "OK $k" );
}
while (@$nok) {
    my ( $k, $v ) = splice @$nok, 0, 2;
    ok( $v !~ $tests->{$k}->{test}, "NOK $k" );
}
