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
my @validatePaths;

LWP::Protocol::PSGI->register(
    builder {
        mount "http://auth.idp.com/" => sub {
            push @validatePaths, $_[0]->{PATH_INFO};
            goto $issuer->app;
        };
        mount "/" => denyLwpRequests;
    },
);

$issuer = register( 'issuer', \&issuer );
my $idpId = loginOnIssuer();

# Unset: the CAS principal
$sp = register( 'sp', sub { sp() } );
is( login(), 'french', 'Unset: user is the CAS principal' );
count(1);
is_deeply( \@validatePaths, ['/cas/serviceValidate'],
    'Unset: ticket validated on /serviceValidate' );
count(1);

# Set: the named attribute
$sp =
  register( 'sp', sub { sp( casSrvMetaDataOptionsUserAttribute => 'mail' ) } );
is( login(), 'fa@badwolf.org', 'Set: user is the named attribute' );
count(1);

# Missing or multi-valued attribute: refused
$sp =
  register( 'sp', sub { sp( casSrvMetaDataOptionsUserAttribute => 'nope' ) } );
expectPortalError( loginRes(), 24, 'Missing attribute refused' );

$sp =
  register( 'sp', sub { sp( casSrvMetaDataOptionsUserAttribute => 'multi' ) } );
expectPortalError( loginRes(), 24, 'Multi-valued attribute refused' );

clean_sessions();
done_testing( count() );

sub loginRes {
    @validatePaths = ();
    my $ticket = getTicket($idpId);
    ok(
        my $res = $sp->_get(
            '/',
            query  => "ticket=$ticket",
            accept => 'text/html',
            cookie => 'llngcasserver=idp',
        ),
        'Query SP with ticket'
    );
    count(1);
    return $res;
}

sub login {
    my $spId = expectCookie( loginRes() );
    return getSession($spId)->data->{_user};
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
                logLevel              => $debug,
                domain                => 'idp.com',
                portal                => 'http://auth.idp.com/',
                authentication        => 'Demo',
                userDB                => 'Same',
                issuerDBCASActivation => 1,
                casAttr               => 'uid',
                casAttributes         =>
                  { uid => 'uid', mail => 'mail', multi => 'multi' },
                casAccessControlPolicy => 'none',
                multiValuesSeparator   => ';',
                macros                 => {
                    mail  => q{'fa@badwolf.org'},
                    multi => '"value1;value2"',
                },
            }
        }
    );
}

sub sp {
    my (%options) = @_;
    return LLNG::Manager::Test->new( {
            ini => {
                logLevel                   => $debug,
                domain                     => 'sp.com',
                portal                     => 'http://auth.sp.com/',
                authentication             => 'CAS',
                userDB                     => 'Same',
                issuerDBCASActivation      => 0,
                multiValuesSeparator       => ';',
                casSrvMetaDataExportedVars => { idp => { uid => 'uid' } },
                casSrvMetaDataOptions      => {
                    idp => {
                        casSrvMetaDataOptionsUrl => 'http://auth.idp.com/cas',
                        %options,
                    }
                },
            },
        }
    );
}
