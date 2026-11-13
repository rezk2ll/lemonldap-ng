use warnings;
use Test::More;
use strict;
use IO::String;
use LWP::UserAgent;
use LWP::Protocol::PSGI;
use URI::Escape;
use Plack::Builder;

BEGIN {
    require 't/test-lib.pm';
}

my $debug = 'error';
my ( $issuer, $sp, $res );

LWP::Protocol::PSGI->register(
    builder {
        mount "http://auth.idp.com/" => sub { goto $issuer->app };
        mount "/"                    => denyLwpRequests;
    },
);

$issuer = register( 'issuer', \&issuer );

# Option off: behaviour unchanged
$sp  = register( 'sp', sub { sp( strict => 0 ) } );
$res = spGet('');
expectForm( $res, undef, undef, 'idp' );
like( $res->[2]->[0], qr/val="idp2"/, 'Off: server list displayed' );
count(1);

$sp  = register( 'sp', sub { sp( strict => 0, single => 1 ) } );
$res = spGet('');
expectRedirection( $res, qr#^http://auth\.idp\.com/cas/login\?# );

$sp  = register( 'sp', sub { sp( strict => 0, rule => 1 ) } );
$res = spGet('');
expectRedirection( $res, qr#^http://auth\.idp2\.com/cas/login\?# );

# Option on
$sp = register( 'sp', sub { sp( strict => 1, rule => 1 ) } );
expectPortalError( spGet(''),            107, 'On: missing server refused' );
expectPortalError( spGet('idp=unknown'), 107, 'On: unknown server refused' );

$res = spGet('idp=idp');
is( expectCookie( $res, 'llngcasserver' ), 'idp', 'On: server cookie set' );
count(1);
expectRedirection( $res, qr#^http://auth\.idp\.com/cas/login\?# );

# Ticket return reads the server cookie
my $idpId  = loginOnIssuer();
my $ticket = getTicket($idpId);
ok(
    $res = $sp->_get(
        '/',
        query  => "ticket=$ticket",
        accept => 'text/html',
        cookie => 'llngcasserver=idp',
    ),
    'On: query SP with ticket'
);
count(1);
my $spId = expectCookie($res);
is( getSession($spId)->data->{_casSrv}, 'idp', 'On: known server accepted' );
count(1);

# Session upgrade goes back to the session's server
ok(
    $res = $sp->_get(
        '/upgradesession',
        accept => 'text/html',
        cookie => "lemonldap=$spId",
    ),
    'Ask to upgrade session'
);
count(1);
my ( $host, $url, $query ) =
  expectForm( $res, undef, '/upgradesession', 'confirm' );
ok(
    $res = $sp->_post(
        '/upgradesession', $query,
        accept => 'text/html',
        cookie => "lemonldap=$spId",
    ),
    'Confirm session upgrade'
);
count(1);
expectRedirection( $res, qr#^http://auth\.idp\.com/cas/login\?# );

$sp = register( 'sp', sub { sp( strict => 1, single => 1 ) } );
expectPortalError( spGet(''), 107, 'On: single server not auto-selected' );

clean_sessions();
done_testing( count() );

sub spGet {
    my ($query) = @_;
    my $res;
    ok( $res = $sp->_get( '/', query => $query, accept => 'text/html' ),
        "SP request ($query)" );
    count(1);
    return $res;
}

sub loginOnIssuer {
    my $s = 'user=french&password=french';
    ok(
        my $res = $issuer->_post(
            '/', IO::String->new($s),
            accept => 'text/html',
            length => length($s),
        ),
        'Authenticate on CAS server'
    );
    count(1);
    return expectCookie($res);
}

sub getTicket {
    my ($id) = @_;
    ok(
        my $res = $issuer->_get(
            '/cas/login',
            query  => 'service=' . uri_escape('http://auth.sp.com/'),
            accept => 'text/html',
            cookie => "lemonldap=$id",
        ),
        'Get a service ticket'
    );
    count(1);
    my ($ticket) =
      expectRedirection( $res, qr#^http://auth\.sp\.com/\?ticket=([^&]+)$# );
    return $ticket;
}

sub issuer {
    return LLNG::Manager::Test->new( {
            ini => {
                logLevel               => $debug,
                domain                 => 'idp.com',
                portal                 => 'http://auth.idp.com/',
                authentication         => 'Demo',
                userDB                 => 'Same',
                issuerDBCASActivation  => 1,
                casAttr                => 'uid',
                casAttributes          => { uid => 'uid' },
                casAccessControlPolicy => 'none',
            }
        }
    );
}

sub sp {
    my (%args) = @_;
    my @srvs = $args{single} ? ('idp') : ( 'idp', 'idp2' );
    return LLNG::Manager::Test->new( {
            ini => {
                logLevel                   => $debug,
                domain                     => 'sp.com',
                portal                     => 'http://auth.sp.com/',
                authentication             => 'CAS',
                userDB                     => 'Same',
                issuerDBCASActivation      => 0,
                upgradeSession             => 1,
                casStrictSrvSelection      => $args{strict},
                casSrvMetaDataExportedVars =>
                  { map { $_ => { uid => 'uid' } } @srvs },
                casSrvMetaDataOptions => {
                    map {
                        $_ => {
                            casSrvMetaDataOptionsUrl =>
                              "http://auth.$_.com/cas",
                            (
                                  ( $args{rule} and $_ eq 'idp2' )
                                ? ( casSrvMetaDataOptionsResolutionRule => '1' )
                                : ()
                            )
                        }
                    } @srvs
                },
            },
        }
    );
}
