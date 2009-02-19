# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Manager.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
package My::Portal;

use Test::More tests => 2;
BEGIN { use_ok('Lemonldap::NG::Common::CGI') }

our @ISA = ('Lemonldap::NG::Common::CGI');

sub subtest {
    return 'OK1';
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $cgi;

ok( ( $cgi = My::Portal->new() ), 'New CGI' );

use IO::String;

our $buf;

#tie *STDOUT, 'IO::String', $buf;
$ENV{SCRIPT_NAME}     = '/test.pl';
$ENV{SCRIPT_FILENAME} = 't/20-Common-CGI.t';
$ENV{REQUEST_METHOD}  = 'GET';
$ENV{REQUEST_URI}     = '/';
$ENV{QUERY_STRING}    = '';

# Test header_public
ok( $buf = $cgi->header_public('t/20-Common-CGI.t'), 'header_public' );
ok( $buf =~ /Cache-control: public; must-revalidate; max-age=\d+\r?\n/s,
    'Cache-Control' );
ok( $buf =~ /Last-modified: /, 'Last-Modified' );

# Test _sub mechanism
ok( $cgi->_sub('subtest') eq 'OK1', '_sub mechanism 1' );
$cgi->{subtest} = sub { return 'OK2' };
ok( $cgi->_sub('subtest') eq 'OK2', '_sub mechanism 2' );

