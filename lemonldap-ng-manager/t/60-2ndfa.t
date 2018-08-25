# Test sessions explorer API

use Test::More;
use JSON;
use strict;
use Lemonldap::NG::Common::Session;

eval { mkdir 't/sessions' };
`rm -rf t/sessions/*`;
require 't/test-lib.pm';

sub newSession {
    my ( $uid, $ip, $kind, $sfaDevices ) = splice @_;
    my $tmp;
    ok(
        $tmp = Lemonldap::NG::Common::Session->new(
            {
                storageModule        => 'Apache::Session::File',
                storageModuleOptions => {
                    Directory     => 't/sessions',
                    LockDirectory => 't/sessions',
                    generateModule =>
'Lemonldap::NG::Common::Apache::Session::Generate::SHA256',
                },
            }
        ),
        'Sessions module'
    );
    count(1);
    $tmp->update(
        {
            ipAddr        => $ip,
            _whatToTrace  => $uid,
            uid           => $uid,
            _utime        => time,
            _session_kind => $kind,
            _2fDevices    => to_json($sfaDevices),
        }
    );
    return $tmp->{id};
}

my @ids;
my $sfaDevices = [];
my $epoch      = time;

# Single session access
$ids[0] = newSession( 'dwho', '127.10.0.1', 'SSO', $sfaDevices );
my $res = &client->jsonResponse("/sessions/global/$ids[0]");
ok( ( $res->{uid}    and $res->{uid} eq 'dwho' ),          'UID found' );
ok( ( $res->{ipAddr} and $res->{ipAddr} eq '127.10.0.1' ), 'IP found' );
count(2);

# Peristent sesssions creation
$sfaDevices = [];
$ids[1] = newSession( 'msmith', '127.10.0.1', 'Persistent', $sfaDevices );
$sfaDevices = [
    {
        "name"       => "MyU2FKey",
        "type"       => "U2F",
        "_userKey"   => "123456",
        "_keyHandle" => "654321",
        "epoch"      => $epoch
    },
    {
        "name"    => "MyYubikey",
        "type"    => "UBK",
        "_secret" => "123456",
        "epoch"   => $epoch
    }
];
$ids[2] = newSession( 'rtyler', '127.10.0.1', 'Persistent', $sfaDevices );
$sfaDevices = [
    {
        "name"       => "MyU2FKey",
        "type"       => "U2F",
        "_userKey"   => "123456",
        "_keyHandle" => "654321",
        "epoch"      => $epoch
    },
    {
        "name"    => "MyTOTP",
        "type"    => "TOTP",
        "_secret" => "123456",
        "epoch"   => $epoch
    },
    {
        "name"    => "MyYubikey",
        "type"    => "UBK",
        "_secret" => "123456",
        "epoch"   => $epoch
    }
];
$ids[3] = newSession( 'dwho', '127.10.0.1', 'Persistent', $sfaDevices );
$sfaDevices = [
    {
        "name"       => "MyU2FKey",
        "type"       => "U2F",
        "_userKey"   => "123456",
        "_keyHandle" => "654321",
        "epoch"      => $epoch
    },
    {
        "name"    => "MyTOTP",
        "type"    => "TOTP",
        "_secret" => "123456",
        "epoch"   => $epoch
    }
];
$ids[4] = newSession( 'davros', '127.10.0.1', 'Persistent', $sfaDevices );
$sfaDevices = [
    {
        "name"       => "MyU2FKey",
        "type"       => "U2F",
        "_userKey"   => "123456",
        "_keyHandle" => "654321",
        "epoch"      => $epoch
    }
];
$ids[5] = newSession( 'tof', '127.10.0.1', 'Persistent', $sfaDevices );

for ( my $i = 1 ; $i < 6 ; $i++ ) {
    $res = &client->jsonResponse("/sessions/persistent/$ids[$i]");
    ok(
        (
                  $res->{uid}
              and $res->{uid} =~ /^(?:dwho|rtyler|msmith|davros|tof)$/
        ),
        'Persistent sessions with UID found'
    );
}
count(5);

# "All" query
$res = &client->jsonResponse( '/sfa/persistent',
    'groupBy=substr(uid,1)&U2FCheck=1&TOTPCheck=1&UBKCheck=1' );
ok( $res->{result} == 1,      'Result code = 1' );
ok( $res->{count} == 3,       'Found 3 results' ) or print STDERR Dumper($res);
ok( @{ $res->{values} } == 3, 'List 3 results' );
ok( $res->{values}->[0]->{value} && $res->{values}->[0]->{value} eq 'd',
    'Result match "uid=d"' )
  or print STDERR Dumper($res);
ok( $res->{values}->[1]->{value} && $res->{values}->[1]->{value} eq 'r',
    'Result match "uid=r"' )
  or print STDERR Dumper($res);
ok( $res->{values}->[2]->{value} && $res->{values}->[2]->{value} eq 't',
    'Result match "uid=t"' )
  or print STDERR Dumper($res);
ok( $res->{values}->[0]->{count} == 2, 'Found 2 sessions starting with "d"' );
ok( $res->{values}->[1]->{count} == 1, 'Found 1 session starting with "r"' );
ok( $res->{values}->[2]->{count} == 1, 'Found 1 session starting with "t"' );
count(9);

# "Filtered by U2F" query
$res = &client->jsonResponse( '/sfa/persistent',
    'uid=*&groupBy=substr(uid,0)&U2FCheck=2&TOTPCheck=1&UBKCheck=1' );
ok( $res->{result} == 1,      'Result code = 1' );
ok( $res->{count} == 3,       'Found 3 results' ) or print STDERR Dumper($res);
ok( @{ $res->{values} } == 3, 'List 3 results' );
ok( $res->{values}->[0]->{value} && $res->{values}->[0]->{value} eq 'd',
    'Result match "uid=d"' )
  or print STDERR Dumper($res);
ok( $res->{values}->[1]->{value} && $res->{values}->[1]->{value} eq 'r',
    'Result match "uid=r"' )
  or print STDERR Dumper($res);
ok( $res->{values}->[2]->{value} && $res->{values}->[2]->{value} eq 't',
    'Result match "uid=t"' )
  or print STDERR Dumper($res);
ok( $res->{values}->[0]->{count} == 2, 'Found 2 sessions starting with "d"' );
ok( $res->{values}->[1]->{count} == 1, 'Found 1 session starting with "r"' );
ok( $res->{values}->[2]->{count} == 1, 'Found 1 session starting with "t"' );
count(9);

# "Filtered by U2F & TOTP" query
$res = &client->jsonResponse( '/sfa/persistent',
    'uid=*&groupBy=substr(uid,0)&U2FCheck=2&TOTPCheck=2&UBKCheck=1' );
ok( $res->{result} == 1,      'Result code = 1' );
ok( $res->{count} == 1,       'Found 1 result' ) or print STDERR Dumper($res);
ok( @{ $res->{values} } == 1, 'List 1 result' );
ok( $res->{values}->[0]->{value} && $res->{values}->[0]->{value} eq 'd',
    'Result match "uid=d"' )
  or print STDERR Dumper($res);
ok( $res->{values}->[0]->{count} == 2, 'Found 2 sessiond starting with "d"' );
count(5);

# "Filtered by U2F & TOTP & UBK" query
$res = &client->jsonResponse( '/sfa/persistent',
    'uid=*&groupBy=substr(uid,0)&U2FCheck=2&TOTPCheck=2&UBKCheck=2' );
ok( $res->{result} == 1,      'Result code = 1' );
ok( $res->{count} == 1,       'Found 1 result' ) or print STDERR Dumper($res);
ok( @{ $res->{values} } == 1, 'List 1 result' );
ok( $res->{values}->[0]->{value} && $res->{values}->[0]->{value} eq 'd',
    'Result match "uid=d"' )
  or print STDERR Dumper($res);
ok( $res->{values}->[0]->{count} == 1, 'Found 1 session starting with "d"' );
count(5);

# "Filtered by U2F & UBK" query
$res = &client->jsonResponse( '/sfa/persistent',
    'uid=*&groupBy=substr(uid,0)&U2FCheck=2&TOTPCheck=1&UBKCheck=2' );
ok( $res->{result} == 1,      'Result code = 1' );
ok( $res->{count} == 2,       'Found 2 results' ) or print STDERR Dumper($res);
ok( @{ $res->{values} } == 2, 'List 2 results' );
ok( $res->{values}->[0]->{value} && $res->{values}->[0]->{value} eq 'd',
    'Result match "uid=d"' )
  or print STDERR Dumper($res);
ok( $res->{values}->[1]->{value} && $res->{values}->[1]->{value} eq 'r',
    'Result match "uid=r"' )
  or print STDERR Dumper($res);
ok( $res->{values}->[0]->{count} == 1, 'Found 1 session starting with "d"' );
ok( $res->{values}->[1]->{count} == 1, 'Found 1 session starting with "r"' );
count(7);

# Delete 2F devices
foreach ( 1 .. 5 ) {
    ok(
        $res =
          &client->_del( "sfa/persistent/$ids[$_]", "type=U2F&epoch=$epoch" ),
        "Delete U2F from $_"
    );
    ok( $res->[0] == 200, 'Result code is 200' );
    ok( from_json( $res->[2]->[0] )->{result} == 1,
        'Body is JSON and result==1' );
    count(3);
}
foreach ( 2 .. 3 ) {
    ok(
        $res =
          &client->_del( "sfa/persistent/$ids[$_]", "type=UBK&epoch=$epoch" ),
        "Delete UBK from $_"
    );
    ok( $res->[0] == 200, 'Result code is 200' );
    ok( from_json( $res->[2]->[0] )->{result} == 1,
        'Body is JSON and result==1' );
    count(3);
}
foreach ( 3 .. 4 ) {
    ok(
        $res =
          &client->_del( "sfa/persistent/$ids[$_]", "type=TOTP&epoch=$epoch" ),
        "Delete TOTP from $_"
    );
    ok( $res->[0] == 200, 'Result code is 200' );
    ok( from_json( $res->[2]->[0] )->{result} == 1,
        'Body is JSON and result==1' );
    count(3);
}

# Check than all devices have been deleted with "All" query
$res = &client->jsonResponse( '/sfa/persistent',
    'groupBy=substr(uid,1)&U2FCheck=1&TOTPCheck=1&UBKCheck=1' );
ok( $res->{result} == 1,      'Result code = 1' );
ok( $res->{count} == 0,       'Found 0 result' ) or print STDERR Dumper($res);
ok( @{ $res->{values} } == 0, 'List 0 result' );
count(3);

done_testing( count() );

# Remove sessions directory
`rm -rf t/sessions`;
