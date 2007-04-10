# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Manager.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 10;
BEGIN { use_ok('Lemonldap::NG::Manager') }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

$ENV{SCRIPT_NAME}          = "__SCRIPTNAME__";
$ENV{SCRIPT_FILENAME}      = $0;
my $h;
@ARGV = ( "help=groups" );
ok( $h = new Lemonldap::NG::Manager(
    {
	configStorage => {
	    type    => 'File',
	    dirName => "/tmp/",
	},
	dhtmlXTreeImageLocation => "/imgs/",
	applyConfFile           => '__DIR__/manager/apply.conf',

	jsFile => 'example/lemonldap-ng-manager.js',
    }
));
ok( $h->header_public() );
ok( $h->start_html() );
ok( $h->main() );
ok( $h->end_html() );
ok( $h->print_css() );
ok( $h->print_lmjs() );
ok( $h->print_help() );
ok( $h->buildTree() );
