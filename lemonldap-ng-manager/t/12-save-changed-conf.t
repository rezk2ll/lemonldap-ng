#!/usr/bin/env perl -I pl/lib

use Test::More;
use 5.10.0;
use strict;
use JSON;
use Data::Dumper;
require 't/test-lib.pm';

my $struct = 't/jsonfiles/12-modified.json';
my $confFiles = [ 't/conf/lmConf-1.js', 't/conf/lmConf-2.js' ];

sub body {
    return IO::File->new( $struct, 'r' );
}

# Delete lmConf-2.js if exists
eval { unlink $confFiles->[1]; };

my ( $res, $resBody );
ok( $res = post( '/confs/', 'cfgNum=1', &body, 'application/json' ),
    "Request succeed" );
ok( $res->[0] == 200, "Result code is 200" );
ok( $resBody = decode_json( $res->[2]->[0] ),
    "Result body contains JSON text" );
ok( $resBody->{result} == 1, "JSON response contains \"result:1\"" )
  or print STDERR Dumper($resBody);
ok( -f $confFiles->[1], 'File is created' );

my @changes = @{&changes};
my @cmsg    = @{ $resBody->{details}->{__changes__} };
ok( @changes == @cmsg, 'Same changes count' );
while ( my $c = shift @{ $resBody->{details}->{__changes__} } ) {
    @changes = grep { $_->{key} ne $c->{key} } @changes;
    @cmsg    = grep { $_->{key} ne $c->{key} } @cmsg;
}
ok( !@changes, 'All changes detected' );

#print STDERR Dumper(\@changes,\@cmsg);

count(7);

unlink $confFiles->[1];
done_testing( count() );

sub changes {
    return [
        {
            'key' => 'portal',
            'new' => 'http://auth2.example.com/',
            'old' => 'http://auth.example.com/'
        },
        {
            'new' => 0,
            'old' => 1,
            'key' => 'portalDisplayLogout'
        },
        {
            'key' =>
              'applicationList, Sample applications, Application Test 1, uri',
            'old' => 'http://test1.example.com/',
            'new' => 'http://testex.example.com/'
        },
        {
            'new' => 'Application Test 3',
            'key' => 'applicationList, Sample applications'
        },
        {
            'key' => 'userDB',
            'new' => 'LDAP',
            'old' => 'Demo'
        },
        {
            'key' => 'passwordDB',
            'new' => 'LDAP',
            'old' => 'Demo'
        },
        {
            'key' => 'openIdSPList',
            'new' => '1;bad.com'
        },
        {
            'key' => 'exportedVars',
            'new' => 'User-Agent'
        },
        {
            'new' => 'Uid',
            'key' => 'exportedVars'
        },
        {
            'key' => 'exportedVars',
            'old' => 'UA'
        },
        {
            'key' =>
              'locationRules, test1.example.com, (?#Logout comment)^/logout',
            'new' => 'logout_sso',
            'old' => undef
        },
        {
            'old' => '^/logout',
            'key' => 'locationRules, test1.example.com'
        },
        {
            'key' => 'locationRules, test3.example.com, ^/logout',
            'new' => 'logout_sso',
            'old' => undef
        },
        {
            'key' => 'locationRules, test3.example.com, default',
            'old' => undef,
            'new' => 'accept'
        },
        {
            'key' => 'locationRules',
            'new' => 'test3.example.com'
        },
        {
            'key' => 'exportedHeaders, test3.example.com, Auth-User',
            'old' => undef,
            'new' => '$uid'
        },
        {
            'new' => 'test3.example.com',
            'key' => 'exportedHeaders'
        },
        {
            'key' => 'locationRules, test.ex.com, default',
            'old' => undef,
            'new' => 'deny'
        },
        {
            'key' => 'locationRules',
            'new' => 'test.ex.com'
        },
        {
            'key' => 'virtualHosts',
            'old' => 'test2.example.com'
        }
    ];
}
