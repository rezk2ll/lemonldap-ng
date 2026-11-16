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
my ( @validatePaths, $gotEncoding );

LWP::Protocol::PSGI->register(
    builder {
        mount "http://auth.idp.com/" => sub {
            push @validatePaths, $_[0]->{PATH_INFO};
            goto $issuer->app;
        };
        mount "http://redirect.idp.com/" => sub {
            my ($env) = @_;
            return [
                302,
                [
                    Location => "http://auth.idp.com$env->{PATH_INFO}?"
                      . $env->{QUERY_STRING}
                ],
                []
            ];
        };
        mount "http://big.idp.com/" => sub {
            my $res = $issuer->app->(@_);
            push @{ $res->[2] }, '<!-- ' . ( 'x' x 2_000_000 ) . ' -->';
            return $res;
        };
        mount "http://gzip.idp.com/" => sub {
            $gotEncoding = $_[0]->{HTTP_ACCEPT_ENCODING};
            my $res = $issuer->app->(@_);
            push @{ $res->[1] }, 'Content-Encoding' => 'gzip';
            return $res;
        };
        mount "http://slow.idp.com/" => sub {
            my $res  = $issuer->app->(@_);
            my @body = ( @{ $res->[2] }, ('<!-- -->') x 3 );
            $res->[2] = Plack::Util::inline_object(
                getline => sub { sleep 1 if @body < 4; shift @body },
                close   => sub { },
            );
            return $res;
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
my $logs = errorLogs(
    sub { expectPortalError( loginRes(), 24, 'Missing attribute refused' ) } );
like( $logs, qr/CAS attribute nope missing/, 'Missing attribute logged' );
count(1);

$sp =
  register( 'sp', sub { sp( casSrvMetaDataOptionsUserAttribute => 'multi' ) } );
$logs = errorLogs(
    sub {
        expectPortalError( loginRes(), 24, 'Multi-valued attribute refused' );
    }
);
like(
    $logs,
    qr/CAS attribute multi has 2 values/,
    'Multi-valued attribute logged'
);
count(1);

# CAS 3 validation endpoint
$sp = register( 'sp', sub { sp( casSrvMetaDataOptionsValidateP3 => 1 ) } );
is( login(), 'french', 'P3: user is the CAS principal' );
count(1);
is_deeply(
    \@validatePaths,
    ['/cas/p3/serviceValidate'],
    'P3: ticket validated on /p3/serviceValidate'
);
count(1);

$sp = register(
    'sp',
    sub {
        sp(
            casSrvMetaDataOptionsValidateP3    => 1,
            casSrvMetaDataOptionsUserAttribute => 'mail'
        );
    }
);
is( login(), 'fa@badwolf.org', 'P3: user is the named attribute' );
count(1);

# Validation request: no redirect, bounded size and time
$sp = register( 'sp',
    sub { sp( casSrvMetaDataOptionsUrl => 'http://redirect.idp.com/cas' ) } );
expectPortalError( loginRes(), 24, 'Redirected validation refused' );
is_deeply( \@validatePaths, [], 'Redirect not followed' );
count(1);

$sp = register( 'sp',
    sub { sp( casSrvMetaDataOptionsUrl => 'http://big.idp.com/cas' ) } );
expectPortalError( loginRes(), 24, 'Oversized validation response refused' );
is(
    $sp->p->loadedModules->{'Lemonldap::NG::Portal::Auth::CAS'}
      ->validationUa->timeout,
    10, 'Validation timeout is 10 seconds'
);
count(1);

$sp = register( 'sp',
    sub { sp( casSrvMetaDataOptionsUrl => 'http://gzip.idp.com/cas' ) } );
expectPortalError( loginRes(), 24, 'Compressed validation response refused' );
is( $gotEncoding, 'identity', 'Validation asks for an uncompressed response' );
count(1);

$sp = register(
    'sp',
    sub {
        sp(
            _lwpOpts                 => { timeout => 2 },
            casSrvMetaDataOptionsUrl => 'http://slow.idp.com/cas'
        );
    }
);
$logs = errorLogs(
    sub {
        expectPortalError( loginRes(), 24,
            'Validation over the total time refused' );
    }
);
like( $logs, qr/total time over 2s/, 'Total time cap logged' );
count(1);

$sp = register( 'sp', sub { sp() } );

# Logout once the session's server is no longer configured
my $spId = expectCookie( loginRes() );
$sp = register( 'sp', sub { sp( _srv => 'other' ) } );
ok(
    $res = $sp->_get(
        '/',
        query  => 'logout',
        cookie => "lemonldap=$spId",
        accept => 'text/html'
    ),
    'Logout after server removal'
);
count(1);
expectOK($res);
unlike( $res->[2]->[0], qr#/logout\?service=#, 'No CAS logout redirect' );
count(1);
ok( !getSession($spId)->data->{_user}, 'Session deleted' );
count(1);

clean_sessions();
done_testing( count() );

sub errorLogs {
    my ($code) = @_;
    my $logs = '';
    no warnings 'redefine';
    local *Lemonldap::NG::Common::Logger::Std::error =
      sub { $logs .= "$_[1]\n" };
    $code->();
    return $logs;
}

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
    my $srv       = delete $options{_srv} || 'idp';
    my $lwpOpts   = delete $options{_lwpOpts};
    return LLNG::Manager::Test->new( {
            ini => {
                ( $lwpOpts ? ( lwpOpts => $lwpOpts ) : () ),
                logLevel                   => $debug,
                domain                     => 'sp.com',
                portal                     => 'http://auth.sp.com/',
                authentication             => 'CAS',
                userDB                     => 'Same',
                issuerDBCASActivation      => 0,
                multiValuesSeparator       => ';',
                casSrvMetaDataExportedVars => { $srv => { uid => 'uid' } },
                casSrvMetaDataOptions      => {
                    $srv => {
                        casSrvMetaDataOptionsUrl => 'http://auth.idp.com/cas',
                        %options,
                    }
                },
            },
        }
    );
}
