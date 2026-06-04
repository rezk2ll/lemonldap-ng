use warnings;

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Common.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More;
BEGIN { use_ok('Lemonldap::NG::Common::Safelib') }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# dateToTime (#3606: fractional seconds in LDAP dates must be accepted)
is( Lemonldap::NG::Common::Safelib::dateToTime("20260429150831"),
    1777475311, 'dateToTime without timezone (GMT default)' );
is( Lemonldap::NG::Common::Safelib::dateToTime("20260429150831Z"),
    1777475311, 'dateToTime with Z timezone' );
is( Lemonldap::NG::Common::Safelib::dateToTime("20260429150831+0200"),
    1777468111, 'dateToTime with differential timezone' );
is( Lemonldap::NG::Common::Safelib::dateToTime("20260429150831.119Z"),
    1777475311, 'dateToTime with fractional seconds and Z timezone' );
is( Lemonldap::NG::Common::Safelib::dateToTime("20260429150831.119+0200"),
    1777468111,
    'dateToTime with fractional seconds and differential timezone' );
is( Lemonldap::NG::Common::Safelib::dateToTime(""),
    undef, 'dateToTime with empty date returns undef' );

done_testing();
