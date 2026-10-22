# Test Providers API

use warnings;
use Test::More;
use strict;
use JSON;
use IO::String;
require 't/test-lib.pm';

our $_json = JSON->new->allow_nonref;

sub check201 {
    my ( $test, $res ) = splice @_;

    #diag Dumper($res);
    is( $res->[0], "201", "$test: Result code is 201" )
      or diag explain $res->[2];
    count(1);
    checkJson( $test, $res );
}

sub check204 {
    my ( $test, $res ) = splice @_;

    #diag Dumper($res);
    is( $res->[0], "204", "$test: Result code is 204" )
      or diag explain $res->[2];
    count(1);
    is( $res->[2]->[0], undef, "204 code returns no content" );
}

sub check200 {
    my ( $test, $res ) = splice @_;

    #diag Dumper($res);
    is( $res->[0], "200", "$test: Result code is 200" )
      or diag explain $res->[2];
    count(1);
    checkJson( $test, $res );

}

sub check409 {
    my ( $test, $res ) = splice @_;

    #diag Dumper($res);
    is( $res->[0], "409", "$test: Result code is 409" )
      or diag explain $res->[2];
    count(1);
    checkJson( $test, $res );
}

sub check404 {
    my ( $test, $res ) = splice @_;

    #diag Dumper($res);
    is( $res->[0], "404", "$test: Result code is 404" )
      or diag explain $res->[2];
    count(1);
    checkJson( $test, $res );
}

sub check400 {
    my ( $test, $res ) = splice @_;
    is( $res->[0], "400", "$test: Result code is 400" )
      or diag explain $res->[2];
    count(1);
    count(1);
    checkJson( $test, $res );
}

sub checkJson {
    my ( $test, $res ) = splice @_;
    my $key;

    #diag Dumper($res->[2]->[0]);
    ok( $key = from_json( $res->[2]->[0] ), "$test: Response is JSON" );
    count(1);
}

sub add {
    my ( $test, $type, $obj ) = splice @_;
    my $j = $_json->encode($obj);
    my $res;

    #diag Dumper($j);
    ok(
        $res = &client->_post(
            "/api/v1/providers/$type", '',
            IO::String->new($j),       'application/json',
            length($j)
        ),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkAdd {
    my ( $test, $type, $add ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check201( $test, add( $test, $type, $add ) );
    checkConfStored( $test, $cfgNum,
        "[API] POST /api/v1/providers/$type ($add->{confKey})" );
}

sub checkAddFailsIfExists {
    my ( $test, $type, $add ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check409( $test, add( $test, $type, $add ) );
    checkConfNotStored( $test, $cfgNum );
}

sub checkAddWithUnknownAttributes {
    my ( $test, $type, $add ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check400( $test, add( $test, $type, $add ) );
    checkConfNotStored( $test, $cfgNum );
}

sub get {
    my ( $test, $type, $confKey ) = splice @_;
    my $res;
    ok( $res = &client->_get( "/api/v1/providers/$type/$confKey", '' ),
        "$test: Request succeed" );
    count(1);
    return $res;
}

sub checkGet {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ( $test, $type, $confKey, $attrPath, $expectedValue ) = splice @_;
    my $res = get( $test, $type, $confKey );
    check200( $test, $res );
    my @path = split '/', $attrPath;
    my $key  = from_json( $res->[2]->[0] );
    for (@path) {
        if ( ref($key) eq 'ARRAY' ) {
            if ( exists $key->[$_] ) {
                if ( defined $key->[$_] ) {
                    $key = $key->[$_];
                }
                else {
                    $key = "_undef";
                }
            }
            else {
                $key = "_missing";
            }
        }
        else {
            if ( exists $key->{$_} ) {
                if ( defined $key->{$_} ) {
                    $key = $key->{$_};
                }
                else {
                    $key = "_undef";
                }
            }
            else {
                $key = "_missing";
            }
        }
    }
    is( $key, $expectedValue,
"$test: check if $attrPath value \"$key\" matches expected value \"$expectedValue\""
    );
    count(1);
}

sub checkGetNotFound {
    my ( $test, $type, $confKey ) = splice @_;
    check404( $test, get( $test, $type, $confKey ) );
}

sub update {
    my ( $test, $type, $confKey, $obj ) = splice @_;
    my $j = $_json->encode($obj);

    #diag Dumper($j);
    my $res;
    ok(
        $res = &client->_patch(
            "/api/v1/providers/$type/$confKey", '',
            IO::String->new($j),                'application/json',
            length($j)
        ),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkUpdate {
    my ( $test, $type, $confKey, $update ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check204( $test, update( $test, $type, $confKey, $update ) );
    checkConfStored( $test, $cfgNum,
        "[API] PATCH /api/v1/providers/$type/$confKey" );
}

sub checkUpdateNotFound {
    my ( $test, $type, $confKey, $update ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check404( $test, update( $test, $type, $confKey, $update ) );
    checkConfNotStored( $test, $cfgNum );
}

sub checkUpdateFailsIfExists {
    my ( $test, $type, $confKey, $update ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check409( $test, update( $test, $type, $confKey, $update ) );
    checkConfNotStored( $test, $cfgNum );
}

sub checkUpdateWithUnknownAttributes {
    my ( $test, $type, $confKey, $update ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check400( $test, update( $test, $type, $confKey, $update ) );
    checkConfNotStored( $test, $cfgNum );
}

sub replace {
    my ( $test, $type, $confKey, $obj ) = splice @_;
    my $j = $_json->encode($obj);
    my $res;
    ok(
        $res = &client->_put(
            "/api/v1/providers/$type/$confKey", '',
            IO::String->new($j),                'application/json',
            length($j)
        ),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkReplace {
    my ( $test, $type, $confKey, $replace ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check204( $test, replace( $test, $type, $confKey, $replace ) );
    checkConfStored( $test, $cfgNum,
        "[API] PUT /api/v1/providers/$type/$confKey" );
}

sub checkReplaceAlreadyThere {
    my ( $test, $type, $confKey, $replace ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check400( $test, replace( $test, $type, $confKey, $replace ) );
    checkConfNotStored( $test, $cfgNum );
}

sub checkReplaceNotFound {
    my ( $test, $type, $confKey, $update ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check404( $test, replace( $test, $type, $confKey, $update ) );
    checkConfNotStored( $test, $cfgNum );
}

sub checkReplaceWithInvalidAttribute {
    my ( $test, $type, $confKey, $replace ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check400( $test, replace( $test, $type, $confKey, $replace ) );
    checkConfNotStored( $test, $cfgNum );
}

sub findByConfKey {
    my ( $test, $type, $confKey ) = splice @_;
    my $res;
    ok(
        $res = &client->_get(
            "/api/v1/providers/$type/findByConfKey",
            "pattern=$confKey"
        ),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkFindByConfKeyError {
    my ( $test, $type, $pattern ) = splice @_;
    my $res = findByConfKey( $test, $type, $pattern );
    check400( $test, $res );
}

sub checkFindByConfKey {
    my ( $test, $type, $confKey, $expectedHits ) = splice @_;
    my $res = findByConfKey( $test, $type, $confKey );
    check200( $test, $res );
    my $hits    = from_json( $res->[2]->[0] );
    my $counter = @{$hits};
    ok(
        $counter eq $expectedHits,
"$test: check if nb of hits returned ($counter) matches expectation ($expectedHits)"
    );
    count(1);
}

sub findByProviderId {
    my ( $test, $type, $providerIdName, $providerId ) = splice @_;
    my $res;
    ok(
        $res = &client->_get(
            "/api/v1/providers/$type/findBy" . ucfirst $providerIdName,
            "$providerIdName=$providerId"
        ),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkFindByProviderId {
    my ( $test, $type, $providerIdName, $providerId ) = splice @_;
    my $res = findByProviderId( $test, $type, $providerIdName, $providerId );
    check200( $test, $res );
    my $result = from_json( $res->[2]->[0] );
    my $gotProviderId;
    if ( $providerIdName eq 'entityId' ) {
        if ( $result->{metadata} ) {
            ($gotProviderId) =
              $result->{metadata} =~ m/entityID=['"](.+?)['"]/i;
        }
        $gotProviderId ||= $result->{options}->{federationEntityID};

    }
    elsif ( $providerIdName eq 'serviceUrl' ) {
        $gotProviderId = shift @{ $result->{options}->{service} };
    }
    else {
        $gotProviderId = $result->{$providerIdName};
    }
    ok(
        $gotProviderId eq $providerId,
"$test: Check $providerIdName value returned \"$gotProviderId\" matched expected value \"$providerId\""
    );
    count(1);
}

sub checkFindByProviderIdNotFound {
    my ( $test, $type, $providerIdName, $providerId ) = splice @_;
    check404( $test,
        findByProviderId( $test, $type, $providerIdName, $providerId ) );
}

sub deleteProvider {
    my ( $test, $type, $confKey ) = splice @_;
    my $res;
    ok(
        $res = &client->_del(
            "/api/v1/providers/$type/$confKey",
            '', '', 'application/json', 0
        ),
        "$test: Request succeed"
    );
    count(1);
    return $res;
}

sub checkDelete {
    my ( $test, $type, $confKey ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check204( $test, deleteProvider( $test, $type, $confKey ) );
    checkConfStored( $test, $cfgNum,
        "[API] DELETE /api/v1/providers/$type/$confKey" );
}

sub checkDeleteNotFound {
    my ( $test, $type, $confKey ) = splice @_;
    my $cfgNum = lastConf()->{cfgNum};
    check404( $test, deleteProvider( $test, $type, $confKey ) );
    checkConfNotStored( $test, $cfgNum );
}

my $test;

my $oidcRp = {
    confKey      => 'myOidcRp1',
    clientId     => 'myOidcClient0',
    exportedVars => {
        'sub'       => "uid",
        family_name => "sn",
        given_name  => "givenName"
    },
    macros => {
        given_name => '$cn',
    },
    redirectUris => [ "http://url/1", "http://url/2", ],
    extraClaims  => {
        phone => 'telephoneNumber',
        email => 'mail',
    },
    options => {
        clientSecret           => 'secret',
        icon                   => 'web.png',
        postLogoutRedirectUris =>
          [ "http://url/logout1", "http://url/logout2" ],
    },
    scopeRules => {
        "myscope" => 1,
    },
};

$test = "OidcRp - Add should succeed";
checkAdd( $test, 'oidc/rp', $oidcRp );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'options/icon',     'web.png' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'options/clientId', 'myOidcClient0' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'options/redirectUris/0',
    'http://url/1' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'scopeRules/myscope',   '1' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'options/clientSecret', 'secret' );

$test = "OidcRp - Check attribute default value was set after add";
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'options/IDTokenSignAlg', 'RS256' );

$test = "OidcRp - Add should fail on duplicate confKey";
checkAddFailsIfExists( $test, 'oidc/rp', $oidcRp );

$test =
  "OidcRp - Update should succeed, keep existing values, drop undefined ones";
$oidcRp->{options}->{clientId}       = 'myOidcClient1';
$oidcRp->{options}->{clientSecret}   = 'secret2';
$oidcRp->{options}->{IDTokenSignAlg} = 'RS512';
delete $oidcRp->{options}->{icon};
delete $oidcRp->{extraClaims};
delete $oidcRp->{exportedVars};
delete $oidcRp->{clientId};
$oidcRp->{macros}->{given_name} = undef;
$oidcRp->{macros}->{cn}         = '$cn';
$oidcRp->{exportedVars}->{cn}   = 'cn';
checkUpdate( $test, 'oidc/rp', 'myOidcRp1', $oidcRp );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'options/clientSecret', 'secret2' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'options/clientId', 'myOidcClient1' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'options/IDTokenSignAlg', 'RS512' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'options/icon',           'web.png' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'exportedVars/cn',        'cn' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'exportedVars/family_name', 'sn' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'macros/cn',                '$cn' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'macros/given_name', "_missing" );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'extraClaims/phone',
    'telephoneNumber' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'options/redirectUris/1',
    'http://url/2' );
checkGet( $test, 'oidc/rp', 'myOidcRp1', 'options/postLogoutRedirectUris/1',
    'http://url/logout2' );

$test = "OidcRp - Update should fail on non existing options";
$oidcRp->{options}->{playingPossum} = 'elephant';
checkUpdateWithUnknownAttributes( $test, 'oidc/rp', 'myOidcRp1', $oidcRp );
delete $oidcRp->{options}->{playingPossum};

$test               = "OidcRp - Add should fail on duplicate clientId";
$oidcRp->{clientId} = "myOidcClient1";
$oidcRp->{confKey}  = 'myOidcRp2';
checkAddFailsIfExists( $test, 'oidc/rp', $oidcRp );

$test               = "OidcRp - Add should fail on non existing options";
$oidcRp->{confKey}  = 'myOidcRp2';
$oidcRp->{clientId} = 'myOidcClient2';
$oidcRp->{options}->{playingPossum} = 'ElephantInTheRoom';
checkAddWithUnknownAttributes( $test, 'oidc/rp', $oidcRp );
delete $oidcRp->{options}->{playingPossum};

$test = "OidcRp - 2nd add should succeed";
checkAdd( $test, 'oidc/rp', $oidcRp );

$test = "OidcRp - Update should fail if client id exists";
$oidcRp->{clientId} = 'myOidcClient1';
checkUpdateFailsIfExists( $test, 'oidc/rp', 'myOidcRp2', $oidcRp );

$test = "OidcRp - Update should fail if confKey not found";
$oidcRp->{confKey} = 'myOidcRp3';
checkUpdateNotFound( $test, 'oidc/rp', 'myOidcRp3', $oidcRp );

$test                   = "OidcRp - Replace should succeed";
$oidcRp->{confKey}      = 'myOidcRp2';
$oidcRp->{clientId}     = 'myOidcClient2';
$oidcRp->{redirectUris} = ["http://url/3"];
$oidcRp->{options}->{postLogoutRedirectUris} = [];
delete $oidcRp->{options}->{icon};
delete $oidcRp->{options}->{IDTokenSignAlg};
checkReplace( $test, 'oidc/rp', 'myOidcRp2', $oidcRp );

$test = "OidcRp - Check attribute default value was set after replace";
checkGet( $test, 'oidc/rp', 'myOidcRp2', 'options/IDTokenSignAlg', 'RS256' );
checkGet( $test, 'oidc/rp', 'myOidcRp2', 'options/redirectUris/0',
    'http://url/3' );
checkGet( $test, 'oidc/rp', 'myOidcRp2', 'options/postLogoutRedirectUris/0',
    '_missing' );

$test = "OidcRp - Replace should fail on non existing or invalid options";
$oidcRp->{options}->{playingPossum} = 'elephant';
checkReplaceWithInvalidAttribute( $test, 'oidc/rp', 'myOidcRp2', $oidcRp );
delete $oidcRp->{options}->{playingPossum};
$oidcRp->{options}->{IDTokenExpiration} = "XXX";
checkReplaceWithInvalidAttribute( $test, 'oidc/rp', 'myOidcRp2', $oidcRp );

$test = "OidcRp - Replace should fail if confKey not found";
$oidcRp->{confKey} = 'myOidcRp3';
checkReplaceNotFound( $test, 'oidc/rp', 'myOidcRp3', $oidcRp );

$test = "OidcRp - FindByConfKey should find 2 hits";
checkFindByConfKey( $test, 'oidc/rp', '*', 2 );

$test = "OidcRp - FindByConfKey should find 2 hits";
checkFindByConfKey( $test, 'oidc/rp', 'myOidcRp*', 2 );

$test = "OidcRp - FindByConfKey should find 1 hit";
checkFindByConfKey( $test, 'oidc/rp', 'myOidcRp1', 1 );

$test = "OidcRp - FindByConfKey should find 0 hits";
checkFindByConfKey( $test, 'oidc/rp', 'myOidcRp3', 0 );

$test = "OidcRp - FindByConfKey should err on invalid patterns";
checkFindByConfKeyError( $test, 'oidc/rp', '' );
checkFindByConfKeyError( $test, 'oidc/rp', '$' );

$test = "OidcRp - FindByClientId should find one entry";
checkFindByProviderId( $test, 'oidc/rp', 'clientId', 'myOidcClient1' );

$test = "OidcRp - FindByClientId should find nothing";
checkFindByProviderIdNotFound( $test, 'oidc/rp', 'clientId', 'myOidcClient3' );

$test = "OidcRp - Clean up";
checkDelete( $test, 'oidc/rp', 'myOidcRp1' );
checkDelete( $test, 'oidc/rp', 'myOidcRp2' );
$test = "OidcRp - Entity should not be found after clean up";
checkDeleteNotFound( $test, 'oidc/rp', 'myOidcRp1' );

my $oidcOp = {
    confKey  => 'myOidcOp1',
    metadata => to_json( {
            issuer                 => 'https://op1.example.com',
            authorization_endpoint => 'https://op1.example.com/authorize',
            token_endpoint         => 'https://op1.example.com/token',
            jwks_uri               => 'https://op1.example.com/jwks',
        }
    ),
    jwks         => to_json( { keys => [] } ),
    exportedVars => {
        mail => 'email',
        uid  => 'sub',
    },
    options => {
        clientId     => 'twake',
        clientSecret => 'secret',
        displayName  => 'Example',
    },
};

$test = "OidcOp - Add should succeed";
checkAdd( $test, 'oidc/op', $oidcOp );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'options/clientId',     'twake' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'options/clientSecret', 'secret' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'exportedVars/mail',    'email' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'metadata', $oidcOp->{metadata} );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'jwks',     $oidcOp->{jwks} );

$test = "OidcOp - Check attribute default value was set after add";
checkGet( $test, 'oidc/op', 'myOidcOp1', 'options/scope',   'openid profile' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'exportedVars/sn', 'family_name' );

$test = "OidcOp - Add should fail on duplicate confKey";
checkAddFailsIfExists( $test, 'oidc/op', $oidcOp );

$test = "OidcOp - Add should fail without metadata";
checkAddWithUnknownAttributes( $test, 'oidc/op', { confKey => 'myOidcOp2' } );

$test = "OidcOp - Add should fail on metadata that is not a JSON object";
checkAddWithUnknownAttributes( $test, 'oidc/op',
    { confKey => 'myOidcOp2', metadata => 'not json' } );
checkAddWithUnknownAttributes( $test, 'oidc/op',
    { confKey => 'myOidcOp2', metadata => { issuer => 'x' } } );

$test = "OidcOp - Add should fail on non existing options";
checkAddWithUnknownAttributes(
    $test,
    'oidc/op',
    {
        confKey  => 'myOidcOp2',
        metadata => $oidcOp->{metadata},
        options  => { playingPossum => 'elephant' }
    }
);

$test = "OidcOp - Add should fail on options that are not an object";
checkAddWithUnknownAttributes( $test, 'oidc/op',
    { confKey => 'myOidcOp2', metadata => $oidcOp->{metadata}, options => 'x' }
);

$test = "OidcOp - Add should fail on extra auth params that are not an object";
checkAddWithUnknownAttributes(
    $test,
    'oidc/op',
    {
        confKey  => 'myOidcOp2',
        metadata => $oidcOp->{metadata},
        options  => { authEndpointExtraParams => 'x' }
    }
);

$test = "OidcOp - Add should fail on invalid confKey";
checkAddWithUnknownAttributes( $test, 'oidc/op',
    { confKey => 'my Op', metadata => $oidcOp->{metadata} } );

$test = "OidcOp - Update should succeed and keep existing values";
checkUpdate(
    $test,
    'oidc/op',
    'myOidcOp1',
    {
        options      => { clientSecret => 'secret2', displayName => undef },
        exportedVars => { cn           => 'name',    uid         => undef },
    }
);
checkGet( $test, 'oidc/op', 'myOidcOp1', 'options/clientSecret', 'secret2' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'options/clientId',     'twake' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'options/displayName',  '_missing' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'exportedVars/cn',      'name' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'exportedVars/mail',    'email' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'exportedVars/uid',     '_missing' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'metadata', $oidcOp->{metadata} );

$test = "OidcOp - Update should store extra auth params";
checkUpdate( $test, 'oidc/op', 'myOidcOp1',
    { options => { authEndpointExtraParams => { kc_idp_hint => 'corp' } } } );
checkGet( $test, 'oidc/op', 'myOidcOp1',
    'options/authEndpointExtraParams/kc_idp_hint', 'corp' );

$test = "OidcOp - Update with a null jwks should remove it";
checkUpdate( $test, 'oidc/op', 'myOidcOp1', { jwks => undef } );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'jwks',     '_undef' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'metadata', $oidcOp->{metadata} );

$test = "OidcOp - Update should fail on non existing options";
checkUpdateWithUnknownAttributes( $test, 'oidc/op', 'myOidcOp1',
    { options => { playingPossum => 'elephant' } } );

$test = "OidcOp - Update should fail if confKey not found";
checkUpdateNotFound( $test, 'oidc/op', 'myOidcOp3', { options => {} } );

$test = "OidcOp - Replace should succeed and reset what is left out";
checkUpdate( $test, 'oidc/op', 'myOidcOp1', { jwks => $oidcOp->{jwks} } );
checkReplace(
    $test,
    'oidc/op',
    'myOidcOp1',
    {
        metadata => $oidcOp->{metadata},
        options  => { clientId => 'twake2' },
    }
);
checkGet( $test, 'oidc/op', 'myOidcOp1', 'options/clientId',     'twake2' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'options/clientSecret', '_missing' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'options/scope', 'openid profile' );
checkGet( $test, 'oidc/op', 'myOidcOp1',
    'options/authEndpointExtraParams/kc_idp_hint', '_missing' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'exportedVars/cn',  'name' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'exportedVars/uid', 'sub' );
checkGet( $test, 'oidc/op', 'myOidcOp1', 'jwks',             '_undef' );

$test = "OidcOp - Replace should fail without metadata";
checkReplaceWithInvalidAttribute( $test, 'oidc/op', 'myOidcOp1',
    { options => {} } );

$test = "OidcOp - Replace should fail if confKey not found";
checkReplaceNotFound( $test, 'oidc/op', 'myOidcOp3',
    { metadata => $oidcOp->{metadata} } );

$test = "OidcOp - 2nd add should succeed";
$oidcOp->{confKey} = 'myOidcOp2';
checkAdd( $test, 'oidc/op', $oidcOp );

$test = "OidcOp - FindByConfKey should find 2 hits";
checkFindByConfKey( $test, 'oidc/op', 'myOidcOp*', 2 );

$test = "OidcOp - FindByConfKey should find 1 hit";
checkFindByConfKey( $test, 'oidc/op', 'myOidcOp2', 1 );

$test = "OidcOp - FindByConfKey should err on invalid patterns";
checkFindByConfKeyError( $test, 'oidc/op', '' );

$test = "OidcOp - Clean up";
checkDelete( $test, 'oidc/op', 'myOidcOp1' );
checkDelete( $test, 'oidc/op', 'myOidcOp2' );
ok( !exists lastConf()->{oidcOPMetaDataJSON}->{myOidcOp1},
    "$test: discovery document removed" );
count(1);
$test = "OidcOp - Entity should not be found after clean up";
checkDeleteNotFound( $test, 'oidc/op', 'myOidcOp1' );
checkGetNotFound( $test, 'oidc/op', 'myOidcOp1' );

my $metadata1 =
"<?xml version=\"1.0\"?><md:EntityDescriptor xmlns:md=\"urn:oasis:names:tc:SAML:2.0:metadata\" validUntil=\"2019-09-25T16:44:38Z\" cacheDuration=\"PT604800S\" entityID=\"https://myapp.domain.com/saml/metadata\"><md:SPSSODescriptor AuthnRequestsSigned=\"false\" WantAssertionsSigned=\"false\" protocolSupportEnumeration=\"urn:oasis:names:tc:SAML:2.0:protocol\"><md:SingleLogoutService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect\" Location=\"https://myapp.domain.com/saml/sls\" /><md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified</md:NameIDFormat><md:AssertionConsumerService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST\" Location=\"https://myapp.domain.com/saml/acs\" index=\"1\" /></md:SPSSODescriptor></md:EntityDescriptor>";

my $metadata2 =
"<?xml version=\"1.0\"?><md:EntityDescriptor xmlns:md=\"urn:oasis:names:tc:SAML:2.0:metadata\" validUntil=\"2019-09-25T16:44:38Z\" cacheDuration=\"PT604800S\" entityID=\"https://myapp2.domain.com/saml/metadata\"><md:SPSSODescriptor AuthnRequestsSigned=\"false\" WantAssertionsSigned=\"false\" protocolSupportEnumeration=\"urn:oasis:names:tc:SAML:2.0:protocol\"><md:SingleLogoutService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect\" Location=\"https://myapp2.domain.com/saml/sls\" /><md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified</md:NameIDFormat><md:AssertionConsumerService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST\" Location=\"https://myapp2.domain.com/saml/acs\" index=\"1\" /></md:SPSSODescriptor></md:EntityDescriptor>";

my $samlSp = {
    confKey            => 'mySamlSp1',
    metadata           => $metadata1,
    exportedAttributes => {
        family_name => {
            format       => "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
            friendlyName => "surname",
            mandatory    => "false",
            name         => "sn"
        },
        cn => {
            friendlyName => "commonname",
            mandatory    => "true",
            name         => "uid"
        },
        uid => {
            mandatory => "true",
            name      => "uid"
        },
        phone => {
            mandatory => "false",
            format => "urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified",
            name   => "telephoneNumber"
        },
        function => {
            name      => "title",
            mandatory => "false",
            format    => "urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
        },
        given_name => {
            mandatory => "false",
            name      => "givenName"
        }
    },
    macros => {
        given_name => '$givenName',
    },
    options => {
        checkSLOMessageSignature   => 0,
        encryptionMode             => "assertion",
        sessionNotOnOrAfterTimeout => 36000
    }
};

my $fedSamlSp = {
    confKey            => 'myFedSamlSp1',
    exportedAttributes => {
        given_name => {
            mandatory => "false",
            name      => "givenName"
        }
    },
    macros => {
        given_name => '$givenName',
    },
    options => {
        checkSLOMessageSignature => 0,
        encryptionMode           => "assertion",
        federationEntityID       => "https://myapp.domain.com/saml/metadata",
    }
};

$test = "SamlSp -  Add should succeed";
checkAdd( $test, 'saml/sp', $samlSp );
checkGet( $test, 'saml/sp', 'mySamlSp1',
    'options/encryptionMode', 'assertion' );
checkGet( $test, 'saml/sp', 'mySamlSp1',
    'options/sessionNotOnOrAfterTimeout', 36000 );

$test = "SamlSp -  Check attribute default value was set after add";
checkGet( $test, 'saml/sp', 'mySamlSp1', 'options/notOnOrAfterTimeout', 72000 );

$test = "SamlSp -  Add should fail on duplicate confKey";
checkAddFailsIfExists( $test, 'saml/sp', $samlSp );

$test =
  "SamlSp -  Update should succeed, keep existing values, drop undefined ones";
$samlSp->{options}->{checkSLOMessageSignature} = 1;
$samlSp->{options}->{encryptionMode}           = 'nameid';
delete $samlSp->{options}->{sessionNotOnOrAfterTimeout};
delete $samlSp->{exportedAttributes};
$samlSp->{macros}->{family_name}                    = '$sn';
$samlSp->{exportedAttributes}->{cn}->{name}         = "cn";
$samlSp->{exportedAttributes}->{cn}->{friendlyName} = "common_name";
$samlSp->{exportedAttributes}->{cn}->{mandatory}    = "false";
$samlSp->{exportedAttributes}->{family_name}        = undef;

checkUpdate( $test, 'saml/sp', 'mySamlSp1', $samlSp );
checkGet( $test, 'saml/sp', 'mySamlSp1',
    'options/checkSLOMessageSignature', 1 );
checkGet( $test, 'saml/sp', 'mySamlSp1',
    'options/sessionNotOnOrAfterTimeout', 36000 );
checkGet( $test, 'saml/sp', 'mySamlSp1', 'exportedAttributes/cn/friendlyName',
    'common_name' );
checkGet( $test, 'saml/sp', 'mySamlSp1', 'exportedAttributes/cn/mandatory',
    'false' );
checkGet( $test, 'saml/sp', 'mySamlSp1', 'exportedAttributes/cn/mandatory',
    'false' );
checkGet( $test, 'saml/sp', 'mySamlSp1', 'exportedAttributes/cn/name', 'uid' );
checkGet( $test, 'saml/sp', 'mySamlSp1', 'exportedAttributes/family_name',
    '_missing' );
checkGet( $test, 'saml/sp', 'mySamlSp1', 'exportedAttributes/given_name/name',
    'givenName' );
checkGet( $test, 'saml/sp', 'mySamlSp1', 'macros/family_name', '$sn' );
checkGet( $test, 'saml/sp', 'mySamlSp1', 'macros/given_name',  '$givenName' );

$test = "SamlSp -  Update should fail on non existing options";
$samlSp->{options}->{playingPossum} = 'elephant';
checkUpdateWithUnknownAttributes( $test, 'saml/sp', 'mySamlSp1', $samlSp );
delete $samlSp->{options}->{playingPossum};

$test = "SamlSp -  Add should fail on duplicate entityId";
$samlSp->{confKey} = 'mySamlSp2';
checkAddFailsIfExists( $test, 'saml/sp', $samlSp );

$test               = "SamlSp -  Add should fail on non existing options";
$samlSp->{confKey}  = 'mySamlSp2';
$samlSp->{metadata} = $metadata2;
$samlSp->{options}->{playingPossum} = 'ElephantInTheRoom';
checkAddWithUnknownAttributes( $test, 'saml/sp', $samlSp );
delete $samlSp->{options}->{playingPossum};

$test = "SamlSp -  2nd add should succeed";
checkAdd( $test, 'saml/sp', $samlSp );

$test = "SamlSp -  Update should fail if client id exists";
$samlSp->{metadata} = $metadata1;
checkUpdateFailsIfExists( $test, 'saml/sp', 'mySamlSp2', $samlSp );

$test = "SamlSp -  Update should fail if confKey not found";
$samlSp->{confKey} = 'mySamlSp3';
checkUpdateNotFound( $test, 'saml/sp', 'mySamlSp3', $samlSp );

$test               = "SamlSp -  Replace should succeed";
$samlSp->{confKey}  = 'mySamlSp2';
$samlSp->{metadata} = $metadata2;
delete $samlSp->{options}->{encryptionMode};
checkReplace( $test, 'saml/sp', 'mySamlSp2', $samlSp );

$test = "SamlSp -  Check attribute default value was set after replace";
checkGet( $test, 'saml/sp', 'mySamlSp2', 'options/encryptionMode', 'none' );

$test = "SamlSp -  Replace should fail on non existing options";
$samlSp->{options}->{playingPossum} = 'elephant';
checkReplaceWithInvalidAttribute( $test, 'saml/sp', 'mySamlSp2', $samlSp );
delete $samlSp->{options}->{playingPossum};
$samlSp->{options}->{notOnOrAfterTimeout} = "XXX";
checkReplaceWithInvalidAttribute( $test, 'saml/sp', 'mySamlSp2', $samlSp );

$test = "SamlSp -  Replace should fail if confKey not found";
$samlSp->{confKey} = 'mySamlSp3';
checkReplaceNotFound( $test, 'saml/sp', 'mySamlSp3', $samlSp );

$test = "SamlSp -  FindByConfKey should find 2 hits";
checkFindByConfKey( $test, 'saml/sp', '*', 2 );

$test = "SamlSp -  FindByConfKey should find 2 hits";
checkFindByConfKey( $test, 'saml/sp', 'mySamlSp*', 2 );

$test = "SamlSp -  FindByConfKey should find 1 hit";
checkFindByConfKey( $test, 'saml/sp', 'mySamlSp1', 1 );

$test = "SamlSp -  FindByConfKey should find 1 hit";
checkFindByConfKey( $test, 'saml/sp', '*Sp1', 1 );

$test = "SamlSp -  FindByConfKey should find 0 hits";
checkFindByConfKey( $test, 'saml/sp', 'mySamlSp3', 0 );

$test = "SamlSp -  FindByConfKey should err on invalid patterns";
checkFindByConfKeyError( $test, 'saml/sp', '' );
checkFindByConfKeyError( $test, 'saml/sp', '$' );

$test = "SamlSp -  FindByEntityId should find one entry";
checkFindByProviderId( $test, 'saml/sp', 'entityId',
    'https://myapp.domain.com/saml/metadata' );

$test = "SamlSp -  FindByEntityId should find nothing";
checkFindByProviderIdNotFound( $test, 'saml/sp', 'entityId',
    'https://myapp3.domain.com/saml/metadata' );

$test = "FederatedSalmSp - Add";
checkAddFailsIfExists( $test, 'saml/sp', $fedSamlSp );
$fedSamlSp->{options}->{federationEntityID} = "http://fed.example.com/";
checkAdd( $test, 'saml/sp', $fedSamlSp );
checkGet( $test, 'saml/sp', 'myFedSamlSp1',
    'options/encryptionMode', 'assertion' );
checkGet( $test, 'saml/sp', 'myFedSamlSp1',
    'options/federationEntityID', 'http://fed.example.com/' );
checkFindByProviderId( $test, 'saml/sp', 'entityId',
    'http://fed.example.com/' );

$test = "SamlSp -  Clean up";
checkDelete( $test, 'saml/sp', 'mySamlSp1' );
checkDelete( $test, 'saml/sp', 'mySamlSp2' );
$test = "SamlSp -  Entity should not be found after clean up";
checkDeleteNotFound( $test, 'saml/sp', 'mySamlSp1' );

my $casApp = {
    confKey      => 'myCasApp1',
    exportedVars => {
        "cn"   => "cn",
        "uid"  => "uid",
        "mail" => "mail"
    },
    macros => {
        given_name => '$firstName',
    },
    options => {
        service => [
            'http://mycasapp.example.com', 'http://mycasapp2.example.com/test'
        ],
        rule          => '$uid eq \'dwho\'',
        userAttribute => 'uid'
    }
};

$test = "CasApp - Add should succeed";
checkAdd( $test, 'cas/app', $casApp );
checkGet( $test, 'cas/app', 'myCasApp1', 'options/service/0',
    'http://mycasapp.example.com' );
checkGet( $test, 'cas/app', 'myCasApp1', 'options/userAttribute', 'uid' );
checkGet( $test, 'cas/app', 'myCasApp1', 'options/rule', '$uid eq \'dwho\'' );

$test = "CasApp - Add should fail on duplicate confKey";
checkAddFailsIfExists( $test, 'cas/app', $casApp );

$test =
  "CasApp - Update should succeed, keep existing values, drop undefined ones";
$casApp->{options}->{service}       = ['http://mycasapp.acme.com'];
$casApp->{options}->{userAttribute} = 'cn';
delete $casApp->{options}->{rule};
delete $casApp->{macros};
delete $casApp->{exportedVars};
$casApp->{macros}->{given_name} = undef;
$casApp->{macros}->{cn}         = '$cn';
$casApp->{exportedVars}->{cn}   = 'uid';
checkUpdate( $test, 'cas/app', 'myCasApp1', $casApp );
checkGet( $test, 'cas/app', 'myCasApp1', 'options/service/0',
    'http://mycasapp.acme.com' );
checkGet( $test, 'cas/app', 'myCasApp1', 'options/userAttribute', 'cn' );
checkGet( $test, 'cas/app', 'myCasApp1', 'options/rule', '$uid eq \'dwho\'' );
checkGet( $test, 'cas/app', 'myCasApp1', 'exportedVars/cn',   'uid' );
checkGet( $test, 'cas/app', 'myCasApp1', 'exportedVars/uid',  'uid' );
checkGet( $test, 'cas/app', 'myCasApp1', 'macros/cn',         '$cn' );
checkGet( $test, 'cas/app', 'myCasApp1', 'macros/given_name', "_missing" );

$test = "CasApp - Update should fail on non existing options";
$casApp->{options}->{playingPossum} = 'elephant';
checkUpdateWithUnknownAttributes( $test, 'cas/app', 'myCasApp1', $casApp );
delete $casApp->{options}->{playingPossum};

$test = "CasApp - Add should fail on non existing options";
$casApp->{confKey} = 'myCasApp2';
$casApp->{options}->{service}       = ['http://mycasapp.skynet.com'];
$casApp->{options}->{playingPossum} = 'ElephantInTheRoom';
checkAddWithUnknownAttributes( $test, 'cas/app', $casApp );
delete $casApp->{options}->{playingPossum};

$test = "CasApp - Add should fail because service host already exists";
$casApp->{options}->{service} = ['http://mycasapp.acme.com/ignoredbyissuer'];
checkAddFailsIfExists( $test, 'cas/app', $casApp );

$test = "CasApp - 2nd add should succeed";
$casApp->{options}->{service} = ['http://mycasapp.skynet.com'];
checkAdd( $test, 'cas/app', $casApp );

$test = "CasApp - Update should fail if confKey not found";
$casApp->{confKey} = 'myCasApp3';
checkUpdateNotFound( $test, 'cas/app', 'myCasApp3', $casApp );

$test = "CasApp - Replace should succeed";
$casApp->{confKey} = 'myCasApp2';
checkGet( $test, 'cas/app', 'myCasApp2', 'options/userAttribute', 'cn' );
$casApp->{options}->{userAttribute} = 'uid';
checkReplace( $test, 'cas/app', 'myCasApp2', $casApp );
checkGet( $test, 'cas/app', 'myCasApp2', 'options/userAttribute', 'uid' );

$test = "CasApp - Replace should fail on non existing or invalid options";
$casApp->{options}->{playingPossum} = 'elephant';
checkReplaceWithInvalidAttribute( $test, 'cas/app', 'myCasApp2', $casApp );
delete $casApp->{options}->{playingPossum};
$casApp->{options}->{service} = ["XXX"];
checkReplaceWithInvalidAttribute( $test, 'cas/app', 'myCasApp2', $casApp );

$test = "CasApp - Replace should fail if service is not an array";
$casApp->{options}->{service} = "http://cas.url.string";
check409( $test, update( $test, 'cas/app', 'myCasApp2', $casApp ) );

$test = "CasApp - Replace should fail if confKey not found";
$casApp->{confKey} = 'myCasApp3';
checkReplaceNotFound( $test, 'cas/app', 'myCasApp3', $casApp );

$test = "CasApp - FindByConfKey should find 2 hits";
checkFindByConfKey( $test, 'cas/app', '*', 2 );

$test = "CasApp - FindByConfKey should find 2 hits";
checkFindByConfKey( $test, 'cas/app', 'myCasApp*', 2 );

$test = "CasApp - FindByConfKey should find 1 hit";
checkFindByConfKey( $test, 'cas/app', 'myCasApp1', 1 );

$test = "CasApp - FindByConfKey should find 0 hits";
checkFindByConfKey( $test, 'cas/app', 'myCasApp3', 0 );

$test = "CasApp - FindByConfKey should err on invalid patterns";
checkFindByConfKeyError( $test, 'cas/app', '' );
checkFindByConfKeyError( $test, 'cas/app', '$' );

$test = "CasApp - FindByServiceUrl should find one entry";
checkFindByProviderId( $test, 'cas/app', 'serviceUrl',
    'http://mycasapp.acme.com' );

$test = "CasApp - FindByServiceUrl should find nothing";
checkFindByProviderIdNotFound( $test, 'cas/app', 'serviceUrl',
    'http://mycasapp.corporation.com' );

$test = "CasApp - Clean up";
checkDelete( $test, 'cas/app', 'myCasApp1' );
checkDelete( $test, 'cas/app', 'myCasApp2' );
$test = "CasApp - Entity should not be found after clean up";
checkDeleteNotFound( $test, 'cas/app', 'myCasApp1' );

$test = "OidcRp - Author is the web server user (basic auth)";
checkAdd(
    $test,
    'oidc/rp',
    {
        confKey      => 'myOidcRpBasic',
        clientId     => 'myOidcClientBasic',
        redirectUris => ['https://rp.example.com/cb'],
    }
);
my $cfgNum = lastConf()->{cfgNum};
my $res    = &client->app->(
    {
        'HTTP_ACCEPT'     => 'application/json, text/plain, */*',
        'SCRIPT_NAME'     => '',
        'SERVER_NAME'     => '127.0.0.1',
        'QUERY_STRING'    => '',
        'PATH_INFO'       => '/api/v1/providers/oidc/rp/myOidcRpBasic',
        'REQUEST_METHOD'  => 'DELETE',
        'REQUEST_URI'     => '/api/v1/providers/oidc/rp/myOidcRpBasic',
        'SERVER_PORT'     => '8002',
        'SERVER_PROTOCOL' => 'HTTP/1.1',
        'REMOTE_ADDR'     => '10.1.2.3',
        'REMOTE_USER'     => 'apiuser',
        'HTTP_HOST'       => '127.0.0.1:8002',
    }
);
check204( $test, $res );
checkConfStored( $test, $cfgNum,
    '[API] DELETE /api/v1/providers/oidc/rp/myOidcRpBasic',
    'apiuser', '10.1.2.3' );

# Clean up generated conf files, except for "lmConf-1.json"
unlink grep { $_ ne "$main::tmpdir/conf/lmConf-1.json" }
  glob "$main::tmpdir/conf/lmConf-*.json";

done_testing();
