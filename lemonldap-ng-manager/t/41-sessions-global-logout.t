# Test sessions explorer API

use warnings;
use Test::More;
use IO::String;
use JSON;
use strict;
use Lemonldap::NG::Common::Session;

eval { mkdir 't/sessions' };
`rm -rf t/sessions/*`;
require 't/test-lib.pm';

sub newSession {
    my ( $uid, $ip ) = splice @_;
    my $tmp;
    ok(
        $tmp = Lemonldap::NG::Common::Session->new(
            {
                storageModule        => 'Apache::Session::File',
                storageModuleOptions => {
                    Directory      => 't/sessions',
                    LockDirectory  => 't/sessions',
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
            _session_kind => 'SSO'
        }
    );
    return $tmp->{id};
}

# Single session access
my @ids;
$ids[0] = newSession( 'dwho', '127.10.0.1' );
$ids[1] = newSession( 'dwho', '127.2.0.2' );
$ids[2] = newSession( 'foo',  '127.3.0.3' );
$ids[3] = newSession( 'foo',  '127.3.0.3' );

# Delete sessions using globalLogout
foreach ( $ids[0], $ids[2] ) {
    my $res;
    ok(
        $res = &client->_post(
            "/sessions/glogout/global/$_", undef,
            IO::String->new(),             'text/plain',
            0
        ),
        "Call global logout on session $_"
    );
    ok( $res->[0] == 200, 'Result code is 200' );
    ok( from_json( $res->[2]->[0] )->{result} == 1,
        'Body is JSON and result==1' );
    ok( from_json( $res->[2]->[0] )->{count} == 2, '2 sessions deleted' );
    count(4);
}

opendir D, 't/sessions' or die 'Unknown dir';
my @files = grep { not /(?:^\.|.lock$)/ } readdir D;
ok( @files == 0, "Session directory is empty" );
count(1);

done_testing( count() );

# Remove sessions directory
`rm -rf t/sessions`;
