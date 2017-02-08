use Test::More;
use strict;
use IO::String;
use MIME::Base64;

BEGIN {
    require 't/test-lib.pm';
}

my $maintests = 14;
my $debug     = 'error';
my ( $issuer, $sp, $res );
my %handlerOR = ( issuer => [], sp => [] );

SKIP: {
    no warnings 'redefine';
    eval q#use AuthCAS#;
    if ($@) {
        skip 'AuthCAS not found', $maintests;
    }

    no warnings 'once';
    *AuthCAS::get_https2 = *mygethttps2;

    ok( $issuer = issuer(), 'Issuer portal' );
    $handlerOR{issuer} = \@Lemonldap::NG::Handler::Main::_onReload;
    switch ('sp');

    ok( $sp = sp(), 'SP portal' );
    $handlerOR{sp} = \@Lemonldap::NG::Handler::Main::_onReload;

    # Simple SP access
    my $res;
    ok(
        $res = $sp->_get(
            '/', accept => 'text/html',
        ),
        'Unauth SP request'
    );
    expectRedirection( $res,
        'http://auth.idp.com/cas/login?service=http://auth.sp.com/' );

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
    expectOK($res);

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
    my ($query) =
      expectRedirection( $res, qr#^http://auth.sp.com/\?(ticket=[^&]+)$# );
    my $idpId = expectCookie($res);

    # Back to SP
    switch ('sp');
    ok( $res = $sp->_get( '/', query => $query, accept => 'text/html' ),
        'Query SP with ticket' );
    my $spId = expectCookie($res);

    # Test authentication
    ok( $res = $sp->_get( '/', cookie => "lemonldap=$spId" ), 'Get / on SP' );
    expectOK($res);
    expectAuthenticatedAs( $res, 'dwho' );

    # Logout initiated by SP
    ok(
        $res = $sp->_get(
            '/',
            query  => 'logout',
            cookie => "lemonldap=$spId",
            accept => 'text/html'
        ),
        'Query SP for logout'
    );
    expectOK($res);
    ok(
        $res->[2]->[0] =~
          m#iframe src="http://auth.idp.com(/cas/logout)\?(.+?)"#s,
        'Found iframe'
    );

    # Query IdP with iframe src
    my $url = $1;
    $query = $2;
    ok(
        getHeader( $res, 'Content-Security-Policy' ) =~
          /child-src auth.idp.com/,
        'Frame is authorizated'
      )
      or explain( $res->[1],
        'Content-Security-Policy => ...child-src auth.idp.com' );

    switch ('issuer');
    ok(
        $res = $issuer->_get(
            $url,
            query  => $query,
            accept => 'text/html',
            cookie => "lemonldap=$idpId"
        ),
        'Get iframe from IdP'
    );
    expectOK($res);
    ok( getHeader( $res, 'Content-Security-Policy' ) !~ /frame-ancestors/,
        ' Frame can be embedded' )
      or explain( $res->[1],
        'Content-Security-Policy does not contain a frame-ancestors' );

    # Verify that user has been disconnected
    ok( $res = $issuer->_get( '/', cookie => "lemonldap=$idpId" ),
        'Query IdP' );
    expectReject($res);

    #switch ('sp');
    #ok( $res = $sp->_get( '/', cookie => "lemonldap=$idpId" ), 'Query IdP' );
    #ok( $res->[0] == 302, 'Return code is 302' ) or explain( $res->[0], 302 );
    #ok(
    #    $sp->getRedirection($res) eq
    #      'http://auth.idp.com/cas/login?service=http://auth.sp.com/',
    #    'Redirection points to IdP'
    #  )
    #  or explain(
    #    $res->[1],
    #    'location => http://auth.idp.com/cas/login?service=http://auth.sp.com/'
    #  );
}

count($maintests);
clean_sessions();
done_testing( count() );

# Redefine LWP methods for tests
sub mygethttps2 {
    my ( $host, $port, $path, $ssl_data ) = @_;
    ok( $path =~ m#^(/[^\?]+)(?:\?(.*))?$#, "Path to push to IdP: $path" );
    $path = $1;
    my $query = $2;
    ok( $res = $issuer->_get( $path, query => $query ), 'Execute request' );
    ok( ( $res->[0] == 200 or $res->[0] == 400 ), 'Response is 200 or 400' )
      or explain( $res->[0], "200 or 400" );
    count(2);
    my @res = map { "$_\n" } split /\r?\n/, join( '', @{ $res->[2] } );
    return ( "200\n", "\n", @res );
}

sub switch {
    my $type = shift;
    @Lemonldap::NG::Handler::Main::_onReload = @{
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
                userDB                 => 'Same',
                issuerDBCASActivation  => 1,
                casAttr                => 'uid',
                casAttributes          => { cn => 'cn', uid => 'uid', },
                casAccessControlPolicy => 'none',
                multiValuesSeparator   => ';',
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
                CAS_url               => 'http://auth.idp.com/cas',
                CAS_CAFile            => 't/caFile.pem',
                multiValuesSeparator  => ';',
            },
        }
    );
}
