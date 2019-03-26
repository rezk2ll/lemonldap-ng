# Test viewer API

use Test::More;
use strict;
use IO::String;
use JSON qw(from_json);

require 't/test-lib.pm';

# Test that key value is sent
my $res = &client->jsonResponse('/view/1/portalDisplayOidcConsents');
ok( $res->{value} eq '$_oidcConnectedRP', 'Key found' );
count(1);

# Test that hidden key values are NOT sent
$res = &client->jsonResponse('/view/1/portalDisplayLogout');
ok( $res->{value} eq '_Hidden_', 'Key is hidden' );
$res = &client->jsonResponse('/view/1/samlIDPMetaDataNodes');
ok( $res->{value} eq '_Hidden_', 'Key is hidden' );
count(2);

# Try to display latest conf
$res = &client->jsonResponse('/view/latest');
ok( $res->{cfgNum} eq '1', 'Browser is allowed' );
count(1);

# Load lemonldap-ng-noBrowser.ini
use_ok('Lemonldap::NG::Manager::Cli::Lib');
my $client2;
ok(
    $client2 = Lemonldap::NG::Manager::Cli::Lib->new(
        iniFile => 't/lemonldap-ng-noBrowser.ini'
    ),
    'Client object'
);

# Try to display latest conf
$res = $client2->jsonResponse('/view/1');
ok( $res->{value} eq '_Hidden_', 'Browser is NOT allowed' );
count(3);

done_testing( count() );

