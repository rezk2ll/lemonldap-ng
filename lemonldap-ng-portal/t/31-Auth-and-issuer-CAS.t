use Test::More;
use strict;
use IO::String;
use MIME::Base64;

BEGIN {
    require 't/test-lib.pm';
}

my $maintests = 13;
my $debug     = 'debug';
my ( $issuer, $sp, $res );
my %handlerOR = ( issuer => [], sp => [] );

SKIP: {
    eval "use AuthCAS";
    if ($@) {
        skip 'AuthCAS not found', $maintests;
    }

    ok( $issuer = issuer(), 'Issuer portal' );
    $handlerOR{issuer} = \@Lemonldap::NG::Handler::Main::Reload::_onReload;
    switch ('sp');

    ok( $sp = sp(), 'SP portal' );
    $handlerOR{sp} = \@Lemonldap::NG::Handler::Main::Reload::_onReload;

    # Simple SP access
    my $res;
    ok(
        $res = $sp->_get(
            '/', accept => 'text/html',
        ),
        'Unauth SP request'
    );
    ok( $res->[0] == 302, 'Return code is 302' ) or explain( $res->[0], 302 );
    ok(
        $sp->getRedirection($res) eq
          'http://auth.idp.com/cas/login?service=http://auth.sp.com/',
        'Redirection points to IdP'
      )
      or explain(
        $res->[1],
        'location => http://auth.idp.com/cas/login?service=http://auth.sp.com/'
      );

    # Query IdP
    switch ('issuer');
    ok(
        $res = $issuer->_get(
            '/cas/login',
            query  => 'service=http://auth.sp.com/',
            accept => 'text/html'
        ),
        'Query CAS server'
    );
    ok( $res->[0] == 200, 'Return code is 200' ) or explain( $res->[0], 200 );

    # Try to authenticate to IdP
    my $body = $res->[2]->[0];
    $body =~ s/^.*?<form.*?>//s;
    $body =~ s#</form>.*$##s;
    my %fields =
      ( $body =~ /<input type="hidden".+?name="(.+?)".+?value="(.*?)"/sg );
    $fields{user} = $fields{password} = 'dwho';
    use URI::Escape;
    my $s = join( '&', map { "$_=" . uri_escape( $fields{$_} ) } keys %fields );
    ok(
        $res = $issuer->_post(
            '/cas/login',
            IO::String->new($s),
            accept => 'text/html',
            length => length($s),
        ),
        'Post authentication'
    );
    ok( $res->[0] == 302, 'Response is 302' ) or explain( $res->[0], 302 );
    my $cookies = $issuer->getCookies($res);
    my $idpId;
    ok( $idpId = $cookies->{lemonldap}, 'Get cookie' )
      or explain( $res, 'Set-Cookie: something' );
    my $url;
    ok( $url = $issuer->getRedirection($res), 'Get location header' )
      or explain( $res->[1], 'Location: http://auth.sp.com/?ticket=...' );
    ok( $url =~ m#(http://auth.sp.com/)\?(ticket=[^&]+)$#,
        'Get ticket in redirection' )
      or explain( $url, 'http://auth.sp.com/?ticket=...' );
    $url = $1;
    my $query = $2;

    # Back to SP
    switch ('sp');
    ok( $res = $sp->_get( $url, query => $query, accept => 'text/html' ),
        'Query SP with ticket' );

    #print STDERR Dumper($res);
}

count($maintests);
clean_sessions();
done_testing( count() );

# Redefine LWP methods for tests
no warnings 'redefine';

sub LWP::UserAgent::request {
    my ( $self, $req ) = @_;
    ok( $req->uri =~ m#http://auth.sp.com(.*)#, 'Request from SP to IdP' );
    my $url = $1;
    my $res;
    my $s = $req->content;
    ok(
        $res = $sp->_post(
            $url, IO::String->new($s),
            length => length($s),
            type   => 'application/xml',
        ),
        'Execute request'
    );
    ok( ( $res->[0] == 200 or $res->[0] == 400 ), 'Response is 200 or 400' )
      or explain( $res->[0], "200 or 400" );
    ok( $issuer->getHeader( $res, 'Content-Type' ) =~ m#^application/xml#,
        'Content is XML' )
      or explain( $res->[1], 'Content-Type => application/xml' );
    my $httpResp = HTTP::Response->new( $res->[0], 'OK' );

    while ( my $name = shift @{ $res->[1] } ) {
        $httpResp->header( $name, shift( @{ $res->[1] } ) );
    }
    $httpResp->content( join( '', @{ $res->[2] } ) );
    count(4);
    return $httpResp;
}

sub switch {
    my $type = shift;
    @Lemonldap::NG::Handler::Main::Reload::_onReload = @{
        $handlerOR{$type};
    };
}

sub issuer {
    return LLNG::Manager::Test->new(
        {
            ini => {
                logLevel               => $debug,
                templatesDir           => 'site/htdocs/static',
                domain                 => 'idp.com',
                portal                 => 'http://auth.idp.com',
                authentication         => 'Demo',
                userDB                 => 'Demo',
                issuerDBCASActivation  => 1,
                casAttr                => 'uid',
                casAttributes          => { cn => 'cn', uid => 'uid', },
                casAccessControlPolicy => 'none',
            }
        }
    );
}

sub sp {
    return LLNG::Manager::Test->new(
        {
            ini => {
                logLevel              => $debug,
                domain                => 'sp.com',
                portal                => 'http://auth.sp.com',
                authentication        => 'CAS',
                userDB                => 'Null',
                issuerDBCASActivation => 0,
                CASurl                => 'http://auth.idp.com/cas',
                CASCAFile             => 't/caFile.pem',
            },
        }
    );
}
