#!/usr/bin/env perl -I pl/lib

use Test::More;
use strict;
use 5.10.0;
use IO::String;
use Data::Dumper;

eval { mkdir 'test/notifications' };
`rm -rf test/notifications/*`;
require 'test/test-lib.pm';

# Try to create a notification
my $notif =
'{"date":"2015-05-03","uid":"dwho","reference":"Test","xml":"<title>Test</title>"}';
my $res =
  jsonPostResponse( 'notifications/actives', '', IO::String->new($notif),
    'application/json', length($notif) );

ok( $res->{result}, 'Result is true' );
count(1);

# Test "actives" notification display
displayTests('actives');

# Mark notification as done
$notif = '{"done":1}';
$res   = jsonPutResponse(
    'notifications/actives/dwho_Test',
    '', IO::String->new($notif),
    'application/json', length($notif)
);
ok( $res->{result} == 1, 'Result = 1' );

# Test that notification is not active now
$res = jsonResponse( 'notifications/actives', 'groupBy=substr(uid,1)' );
ok( $res->{result} == 1, 'Result = 1' );
ok( $res->{count} == 0,  'Count = 0' );
count(3);

# Test "done" notifications display
displayTests('done');

# Delete notification
$res = del('notifications/done/20150503_dwho_VGVzdA==.done');
$res = jsonResponse( 'notifications/done', 'groupBy=substr(uid,1)' );
ok( $res->{result} == 1, 'Result = 1' );
ok( $res->{count} == 0,  'Count = 0' );
count(2);

#print STDERR Dumper($res);

`rm -f test/notifications/*`;

done_testing( count() );

sub displayTests {
    my $type = shift;
    $res = jsonResponse( "notifications/$type", 'groupBy=substr(uid,1)' );
    ok( $res->{result} == 1,                 'Result = 1' );
    ok( $res->{count} == 1,                  'Count = 1' );
    ok( $res->{values}->[0]->{value} eq 'd', 'Value is "d"' );
    count(3);

    $res = jsonResponse( "notifications/$type", 'groupBy=uid' );
    ok( $res->{result} == 1,                    'Result = 1' );
    ok( $res->{count} == 1,                     'Count = 1' );
    ok( $res->{values}->[0]->{value} eq 'dwho', 'Value is "dwho"' );
    count(3);

    $res = jsonResponse( "notifications/$type", 'uid=d*&groupBy=uid' );
    ok( $res->{result} == 1,                    'Result = 1' );
    ok( $res->{count} == 1,                     'Count = 1' );
    ok( $res->{values}->[0]->{value} eq 'dwho', 'Value is "dwho"' );
    count(3);

    $res = jsonResponse( "notifications/$type", 'uid=d*' );
    ok( $res->{result} == 1,                  'Result = 1' );
    ok( $res->{count} == 1,                   'Count = 1' );
    ok( $res->{values}->[0]->{uid} eq 'dwho', 'Value is "dwho"' );
    count(3);

    $res = jsonResponse( "notifications/$type", 'uid=dwho' );
    ok( $res->{result} == 1,                  'Result = 1' );
    ok( $res->{count} == 1,                   'Count = 1' );
    ok( $res->{values}->[0]->{uid} eq 'dwho', 'Value is "dwho"' );
    count(3);

    if ( $type eq 'actives' ) {
        $res = jsonResponse( "notifications/$type/dwho_Test", '' );
        ok( $res->{result} == 1,                     'Result = 1' );
        ok( $res->{count} == 1,                      'Count = 1' );
        ok( $res->{notifications}->[0] =~ /^<\?xml/, 'Response is XML' );
        count(3);
    }
}
