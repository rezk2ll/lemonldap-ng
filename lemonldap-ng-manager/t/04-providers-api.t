# Test RSA key generation

use Test::More;
use strict;
use JSON;
use IO::String;
require 't/test-lib.pm';

our $_json = JSON->new->allow_nonref;

sub check200 {
    my ( $test, $res ) = splice @_;
    #diag Dumper($res);
    ok( $res->[0] == 200, "$test: Result code is 200" );
    count(1);
    checkJson($test, $res);

}
sub check404 {
    my ( $test, $res ) = splice @_;
    #diag Dumper($res);
    ok( $res->[0] == 404, "$test: Result code is 404" );
    count(1);
    checkJson($test, $res);
}
sub check405 {
    my ( $test, $res ) = splice @_;
    ok( $res->[0] == 405, "$test: Result code is 405" );
    count(1);
    checkJson($test, $res);
}
sub checkJson {
    my ( $test, $res ) = splice @_;
    my $key;
    #diag Dumper($res->[2]->[0]);
    ok( $key = from_json( $res->[2]->[0] ), "$test: Response is JSON" );
    count(1);
}

sub add {
    my ( $test, $type, $obj) = splice @_;
    my $j = $_json->encode($obj);
    my $res;
    #diag Dumper($j);
    ok(
        $res = &client->_post(
            "/v1/providers/$type", '', IO::String->new($j), 'application/json', length($j)
        ),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkAdd {
    my ( $test, $type, $add) = splice @_;
    check200($test, add($test, $type, $add));
}

sub checkAddFailsIfExists {
    my ( $test, $type, $add) = splice @_;
    check405($test, add($test, $type, $add));
}

sub checkAddWithUnknownAttributes {
    my ( $test, $type, $add) = splice @_;
    check405($test, add($test, $type, $add));
}

sub get {
    my ( $test, $type, $confKey) = splice @_;
    my $res;
    ok(
        $res = &client->_get(
            "/v1/providers/$type/$confKey", '', '', 'application/json', 0
        ),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkGet {
    my ( $test, $type, $confKey, $attribute, $expectedValue) = splice @_;
    my $res = get($test, $type, $confKey);
    my $key = from_json($res->[2]->[0]);
    check200($test, $res);
    ok (
        $key->{options}->{$attribute} eq $expectedValue,
        "$test: check if $attribute eq $expectedValue"
    );
    count(1);
}

sub checkGetNotFound {
    my ( $test, $type, $confKey) = splice @_;
    check404($test, get($test, $type, $confKey));
}

sub update {
    my ( $test, $type, $confKey, $obj) = splice @_;
    my $j = $_json->encode($obj);
    #diag Dumper($j);
    my $res;
    ok(
        $res = &client->_patch(
            "/v1/providers/$type/$confKey", '', IO::String->new($j), 'application/json', length($j)
        ),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkUpdate {
    my ( $test, $type, $confKey, $update) = splice @_;
    check200($test, update($test, $type, $confKey, $update));
}

sub checkUpdateNotFound {
    my ( $test, $type, $confKey, $update) = splice @_;
    check404($test, update($test, $type, $confKey, $update));
}

sub checkUpdateFailsIfExists {
    my ( $test, $type, $confKey, $update) = splice @_;
    check405($test, update($test, $type, $confKey, $update));
}

sub checkUpdateWithUnknownAttributes {
    my ( $test, $type, $confKey, $update) = splice @_;
    check405($test, update($test, $type, $confKey, $update));
}

sub replace {
    my ( $test, $type, $confKey, $obj) = splice @_;
    my $j = $_json->encode($obj);
    my $res;
    ok(
        $res = &client->_put(
            "/v1/providers/$type/$confKey", '', IO::String->new($j), 'application/json', length($j)
        ),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkReplace {
    my ( $test, $type, $confKey, $replace) = splice @_;
    check200($test, replace($test, $type, $confKey, $replace));
}

sub checkReplaceAlreadyThere {
    my ( $test, $type, $confKey, $replace) = splice @_;
    check405($test, replace($test, $type, $confKey, $replace));
}

sub checkReplaceNotFound {
    my ( $test, $type, $confKey, $update) = splice @_;
    check404($test, replace($test, $type, $confKey, $update));
}

sub checkReplaceWithUnknownAttribute {
    my ( $test, $type, $confKey, $replace) = splice @_;
    check405($test, replace($test, $type, $confKey, $replace));
}

# TODO
sub checkFindByConfKey {}

sub checkFindByConfKeyNoHits {}

sub checkFindByProviderId {}

sub checkFindByProviderId404 {}

sub deleteProvider {
    my ( $test, $type, $confKey) = splice @_;
    my $res;
    ok(
        $res = &client->_del(
            "/v1/providers/$type/$confKey", '', '', 'application/json', 0
        ),
        "Request succeed"
    );
    count(1);
    return $res;
}
sub checkDelete {
    my ( $test, $type, $confKey) = splice @_;
    check200($test, deleteProvider($test, $type, $confKey));
}

sub checkDeleteNotFound {
    my ( $test, $type, $confKey) = splice @_;
    check404($test, deleteProvider($test, $type, $confKey));
}

my $test;
my $oidcRp = {
    confKey => 'newOidcRp',
    clientId => 'newOidcRpClientId',
    exportedVars => {
        'sub' => "uid",
        family_name => "sn",
        given_name => "givenName"
    },
    extraClaim => {
        phone => 'telephoneNumber',
        email => 'mail'
    },
    options => {
        oidcRPMetaDataOptionsClientSecret => 'secret',
        oidcRPMetaDataOptionsIcon => 'web.png'
    }
};

# $test="Delete after crash";
# checkDelete($test, '/oidc/rp', 'newOidcRp');

$test = "Add should succeed";
checkAdd($test, '/oidc/rp', $oidcRp);
checkGet($test, '/oidc/rp', 'newOidcRp', 'oidcRPMetaDataOptionsIcon', 'web.png');
checkGet($test, '/oidc/rp', 'newOidcRp', 'oidcRPMetaDataOptionsClientSecret', 'secret');

$test = "Check attribute default value was set after add";
checkGet($test, '/oidc/rp', 'newOidcRp', 'oidcRPMetaDataOptionsIDTokenSignAlg', 'HS512');

$test = "Add Should fail on duplicate confKey";
checkAddFailsIfExists($test, '/oidc/rp', $oidcRp);

$test = "Update should succeed";
$oidcRp->{options}->{oidcRPMetaDataOptionsClientSecret} = 'secret2';
checkUpdate($test, '/oidc/rp', 'newOidcRp', $oidcRp);
checkGet($test, '/oidc/rp', 'newOidcRp', 'oidcRPMetaDataOptionsClientSecret', 'secret2');

$test = "Update should fail on non existing options";
$oidcRp->{options}->{playingPossum} = 'elephant';
checkUpdateWithUnknownAttributes($test, '/oidc/rp', 'newOidcRp', $oidcRp);
delete $oidcRp->{options}->{playingPossum};

$test = "Add Should fail on duplicate clientId";
$oidcRp->{confKey} = 'newOidcRp2';
checkAddFailsIfExists($test, '/oidc/rp', $oidcRp);

$test = "Add Should fail on non existing options";
$oidcRp->{confKey} = 'newOidcRp2';
$oidcRp->{clientId} = 'newOidcRpClientId2';
$oidcRp->{options}->{playingPossum} = 'ElephantInTheRoom';
checkAddWithUnknownAttributes($test, '/oidc/rp', $oidcRp);
delete $oidcRp->{options}->{playingPossum};

$test = "2nd add should succeed";
checkAdd($test, '/oidc/rp', $oidcRp);

$test = "Update should fail if client id exists";
$oidcRp->{clientId} = 'newOidcRpClientId';
checkUpdateFailsIfExists($test, '/oidc/rp', 'newOidcRp2', $oidcRp);

$test = "Update should fail if confKey not found";
$oidcRp->{confKey} = 'EasyAsPie';
checkUpdateNotFound($test, '/oidc/rp', 'EasyAsPie', $oidcRp);


# TODO oidcRP checkReplace checkReplaceWithUnknownAttribute checkReplaceNotFound checkReplaceWithUnknownAttribute

$test = "Clean up";
checkDelete($test, '/oidc/rp', 'newOidcRp');
checkDelete($test, '/oidc/rp', 'newOidcRp2');
$test = "Entity should not be found after clean up";
checkDeleteNotFound($test, '/oidc/rp', 'newOidcRp');

# TODO samlSP

done_testing( );
