use Test::More tests => 2;

use_ok('Lemonldap::NG::Portal::Main');

eval { Data::Dumper::Dumper( {} ) };
ok( $@, "Portal don't depends on Data::Dumper" );
