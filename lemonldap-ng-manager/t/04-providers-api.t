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
    diag Dumper($res);
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
        $res = &client->_get("/v1/providers/$type/$confKey", ''),
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

sub findByConfKey {
    my ( $test, $type, $confKey) = splice @_;
    my $res;
    ok(
        $res = &client->_get("/v1/providers/$type/findByConfKey", "pattern=$confKey"),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkFindByConfKey {
    my ( $test, $type, $confKey, $expectedHits, $attribute, $expectedValues) = splice @_;
    my $res  = findByConfKey($test, $type, $confKey);
    check200($test, $res);
    my $hits = from_json($res->[2]->[0]);
    my $hit;
    my $counter = 0;
    foreach $hit (@{$hits}) {
        my $expected = grep {/^$hit->{options}->{$attribute}$/} @{$expectedValues};
        $counter++;
        ok (
            $expected,
            "$test: check if $attribute value \"$hit->{options}->{$attribute}\" matches one of expectedValues: " . $_json->encode($expectedValues)
        );
        count(1);
    }
    ok (
        $counter eq $expectedHits,
        "$test: check if returned nb of hits ($counter) matches $expectedHits"
    );
    count(1);
}

sub findByProviderId {
    my ( $test, $type, $providerIdName, $providerId) = splice @_;
    my $res;
    ok(
        $res = &client->_get("/v1/providers/$type/findBy" . ucfirst $providerIdName, "$providerIdName=$providerId"),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkFindByProviderId {
    my ( $test, $type, $providerIdName, $providerId) = splice @_;
    my $res = findByProviderId($test, $type, $providerIdName, $providerId);
    check200($test, $res);
    my $result = from_json($res->[2]->[0]);
    ok(
        $result->{$providerIdName} eq $providerId,
        "$test: Check $providerIdName value returned \"$result->{$providerIdName}\" matched expected value \"$providerId\""
    );
    count(1);
}

sub checkFindByProviderIdNotFound {
    my ( $test, $type, $providerIdName, $providerId) = splice @_;
    my $res = findByProviderId($test, $type, $providerIdName, $providerId);
    check200($test, $res);
    my $result = from_json($res->[2]->[0]);
    ok(
        !defined $result->{$providerIdName},
        "$test: Check object is empty"
    );
    count(1);
}

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
    confKey => 'myOidcRp1',
    clientId => 'myOidcClient1',
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

$test = "Add should succeed";
checkAdd($test, 'oidc/rp', $oidcRp);
checkGet($test, 'oidc/rp', 'myOidcRp1', 'oidcRPMetaDataOptionsIcon', 'web.png');
checkGet($test, 'oidc/rp', 'myOidcRp1', 'oidcRPMetaDataOptionsClientSecret', 'secret');

$test = "Check attribute default value was set after add";
checkGet($test, 'oidc/rp', 'myOidcRp1', 'oidcRPMetaDataOptionsIDTokenSignAlg', 'HS512');

$test = "Add Should fail on duplicate confKey";
checkAddFailsIfExists($test, 'oidc/rp', $oidcRp);

$test = "Update should succeed";
$oidcRp->{options}->{oidcRPMetaDataOptionsClientSecret} = 'secret2';
$oidcRp->{options}->{oidcRPMetaDataOptionsIDTokenSignAlg} = 'RS512';
checkUpdate($test, 'oidc/rp', 'myOidcRp1', $oidcRp);
checkGet($test, 'oidc/rp', 'myOidcRp1', 'oidcRPMetaDataOptionsClientSecret', 'secret2');
checkGet($test, 'oidc/rp', 'myOidcRp1', 'oidcRPMetaDataOptionsIDTokenSignAlg', 'RS512');

$test = "Update should fail on non existing options";
$oidcRp->{options}->{playingPossum} = 'elephant';
checkUpdateWithUnknownAttributes($test, 'oidc/rp', 'myOidcRp1', $oidcRp);
delete $oidcRp->{options}->{playingPossum};

$test = "Add Should fail on duplicate clientId";
$oidcRp->{confKey} = 'myOidcRp2';
checkAddFailsIfExists($test, 'oidc/rp', $oidcRp);

$test = "Add Should fail on non existing options";
$oidcRp->{confKey} = 'myOidcRp2';
$oidcRp->{clientId} = 'myOidcClient2';
$oidcRp->{options}->{playingPossum} = 'ElephantInTheRoom';
checkAddWithUnknownAttributes($test, 'oidc/rp', $oidcRp);
delete $oidcRp->{options}->{playingPossum};

$test = "2nd add should succeed";
checkAdd($test, 'oidc/rp', $oidcRp);

$test = "Update should fail if client id exists";
$oidcRp->{clientId} = 'myOidcClient1';
checkUpdateFailsIfExists($test, 'oidc/rp', 'myOidcRp2', $oidcRp);

$test = "Update should fail if confKey not found";
$oidcRp->{confKey} = 'myOidcRp3';
checkUpdateNotFound($test, 'oidc/rp', 'myOidcRp3', $oidcRp);

$test = "Replace should succeed";
$oidcRp->{confKey} = 'myOidcRp2';
$oidcRp->{clientId} = 'myOidcClient2';
delete $oidcRp->{options}->{oidcRPMetaDataOptionsIcon};
delete $oidcRp->{options}->{oidcRPMetaDataOptionsIDTokenSignAlg};
checkReplace($test, 'oidc/rp', 'myOidcRp2', $oidcRp);

$test = "Check attribute default value was set after replace";
checkGet($test, 'oidc/rp', 'myOidcRp2', 'oidcRPMetaDataOptionsIDTokenSignAlg', 'HS512');

$test = "Replace should fail on non existing options";
$oidcRp->{options}->{playingPossum} = 'elephant';
checkReplaceWithUnknownAttribute($test, 'oidc/rp', 'myOidcRp2', $oidcRp);
delete $oidcRp->{options}->{playingPossum};

$test = "Replace should fail if confKey not found";
$oidcRp->{confKey} = 'myOidcRp3';
checkReplaceNotFound($test, 'oidc/rp', 'myOidcRp3', $oidcRp);

$test = "FindByConfKey should find 2 hits";
checkFindByConfKey($test, 'oidc/rp', '^myOidcRp.$', 2, 'oidcRPMetaDataOptionsClientID', ['myOidcClient1','myOidcClient2']);

$test = "FindByConfKey should find 1 hit";
checkFindByConfKey($test, 'oidc/rp', 'myOidcRp1', 1, 'oidcRPMetaDataOptionsClientID', ['myOidcClient1']);

$test = "FindByConfKey should find 0 hits";
checkFindByConfKey($test, 'oidc/rp', 'myOidcRp3', 0);

$test = "FindByClientId should find one entry";
checkFindByProviderId($test, 'oidc/rp', 'clientId', 'myOidcClient1');

$test = "FindByClientId should find nothing";
checkFindByProviderIdNotFound($test, 'oidc/rp', 'clientId', 'myOidcClient3');

$test = "Clean up";
checkDelete($test, 'oidc/rp', 'myOidcRp1');
checkDelete($test, 'oidc/rp', 'myOidcRp2');
$test = "Entity should not be found after clean up";
checkDeleteNotFound($test, 'oidc/rp', 'myOidcRp1');


# Clean up generated conf files, except for "lmConf-1.json"
unlink grep { $_ ne "t/conf/lmConf-1.json" } glob "t/conf/lmConf-*.json";

done_testing( );
