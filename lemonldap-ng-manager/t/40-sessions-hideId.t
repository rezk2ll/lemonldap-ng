# Test sessions explorer API

use warnings;
use Test::More;
use JSON;
use strict;
use Lemonldap::NG::Common::Session;

require 't/test-lib.pm';

sub newSession {
    my ( $uid, $ip ) = splice @_;
    my $tmp;
    ok(
        $tmp = Lemonldap::NG::Common::Session->new( {
                storageModule        => 'Apache::Session::File',
                storageModuleOptions => {
                    Directory      => "$main::tmpdir/sessions",
                    LockDirectory  => "$main::tmpdir/sessions",
                    generateModule =>
'Lemonldap::NG::Common::Apache::Session::Generate::SHA256',
                },
            }
        ),
        'Sessions module'
    );
    count(1);
    $tmp->update( {
            ipAddr        => $ip,
            _whatToTrace  => $uid,
            uid           => $uid,
            _utime        => time,
            _session_kind => 'SSO',
        }
    );
    return $tmp->{id};
}

my $client = LLNG::Manager::Test->new(
    ini => {
        displaySessionId => 0,
    }
);

my @realids;
$realids[0] = newSession( 'dwho',  '127.10.0.1' );
$realids[1] = newSession( 'dwho2', '127.2.0.2' );
@realids    = sort @realids;

# "All" query
my $res = $client->jsonResponse("/sessions/global/");
ok( $res->{result} == 1,      'Result code = 1' );
ok( $res->{count} == 2,       'Found 2 sessions' );
ok( @{ $res->{values} } == 2, 'List 2 sessions' );
my @obfuscatedids = sort map { $_->{session} } @{ $res->{values} };
isnt( $realids[0], $obfuscatedids[0], "Obfuscated ID differs from real one" );
count(4);

# Single session access
$res = $client->jsonResponse("/sessions/global/$obfuscatedids[0]");
if ( $res->{uid} eq 'dwho' ) {
    is( $res->{ipAddr}, '127.10.0.1', 'IP found' );
}
else {
    is( $res->{ipAddr}, '127.2.0.2', 'IP found' );
}
is( $res->{_session_id}, '******', "Session ID is obfuscated" );
count(2);

done_testing( count() );
