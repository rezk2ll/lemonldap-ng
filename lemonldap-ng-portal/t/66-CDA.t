use Test::More;
use strict;
use IO::String;

use Lemonldap::NG::Portal::Main::Constants qw(
  PE_FIRSTACCESS
);

require 't/test-lib.pm';

my $res;

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel    => 'error',
            useSafeJail => 1,
            cda         => 1
        }
    }
);

# CDA with unauthentified user
ok(
    $res = $client->_get(
        '/',
        query  => 'url=aHR0cDovL3Rlc3QuZXhhbXBsZS5vcmcv',
        accept => 'text/html',
    ),
    'Unauth CDA request'
);
my ( $host, $url, $query ) = expectForm( $res, undef, undef, 'url' );
ok( $query =~ /\burl=aHR0cDovL3Rlc3QuZXhhbXBsZS5vcmcv\b/, ' check url value' );
count(2);

# Authentification
$query .= '&user=dwho&password=dwho';
ok(
    $res = $client->_post(
        '/'    => IO::String->new($query),
        length => length($query),
        accept => 'text/html',
    ),
    'Post credentials'
);
count(1);

($query) = expectRedirection( $res, qr#^http://test.example.org/\?(lemonldapcda=.*)$# );

clean_sessions();

done_testing( count() );
