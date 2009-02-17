# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Portal.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

package My::Portal;
use strict;
use Test::More tests => 11;
BEGIN { use_ok( 'Lemonldap::NG::Portal::Simple', ':all' ) }

#use Lemonldap::NG::Portal::Simple;

our @ISA = 'Lemonldap::NG::Portal::Simple';
my ( $url, $result, $logout );
$logout = 0;
my %h = (

    # Bad character
    'XX%00' => PE_BADURL,

    # No url required
    '' => PE_OK,

    # http://test.example.com/
    'aHR0cDovL3Rlc3QuZXhhbXBsZS5jb20v' => PE_OK,

    # http://test.example.com
    'aHR0cDovL3Rlc3QuZXhhbXBsZS5jb20v' => PE_OK,

    # http://test.example.com:8000
    'aHR0cDovL3Rlc3QuZXhhbXBsZS5jb206ODAwMA==' => PE_OK,

    # http://test.example.com:8000/test
    'aHR0cDovL3Rlc3QuZXhhbXBsZS5jb206ODAwMC90ZXN0' => PE_OK,

    # http://test.example.com:8000V
    'aHR0cDovL3Rlc3QuZXhhbXBsZS5jb206ODAwMFY=' => PE_BADURL,

    # http://t.example.com/test
    'aHR0cDovL3QuZXhhbXBsZS5jb20vdGVzdA==' => PE_OK,

    # http://t.ex.com/test
    'aHR0cDovL3QuZXguY29tL3Rlc3Q=' => PE_BADURL,

    # http://test.example.com/%00
    'aHR0cDovL3Rlc3QuZXhhbXBsZS5jb20vJTAw' => PE_BADURL,
);

sub param {
    shift;
    my $p = shift;
    if ( $p and $p eq 'url' ) {
        return $url;
    }
    else {
        return $logout;
    }
}

my $p;

# CGI Environment
$ENV{SCRIPT_NAME}     = '/test.pl';
$ENV{SCRIPT_FILENAME} = '/tmp/test.pl';
$ENV{REQUEST_METHOD}  = 'GET';
$ENV{REQUEST_URI}     = "/test.pl";
$ENV{QUERY_STRING}    = "";

ok(
    $p = My::Portal->new(
        {
            globalStorage  => 'Apache::Session::File',
            domain         => 'example.com',
            authentication => 'LDAP test=1',
            domain         => 'example.com',
        }
    ),
    'Portal object'
);

$p->{reVHosts} = '(?:test\.example\.com)';

while ( ( $url, $result ) = each %h ) {

    ok( $p->controlUrlOrigin() == $result, "URL control $url" );

    #print ($p->controlUrlOrigin() == $result ? "OK" : "NOK");
    #print " $url\n";
}
