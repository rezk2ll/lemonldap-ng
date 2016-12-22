use Test::More;
use strict;
use IO::String;
use MIME::Base64;

BEGIN {
    require 't/test-lib.pm';
}

my $maintests = 24;
my $debug     = 'error';
my ( $issuer, $sp, $res );
my %handlerOR = ( issuer => [], sp => [] );

SKIP: {
    no warnings 'redefine';
    eval q#use AuthCAS#;
    if ($@) {
        print STDERR $@;
        skip 'AuthCAS not found', $maintests;
    }

    no warnings 'once';
    *AuthCAS::get_https2 = *mygethttps2;

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
    my $query = $2;

    # Back to SP
    switch ('sp');
    ok( $res = $sp->_get( '/', query => $query, accept => 'text/html' ),
        'Query SP with ticket' );
    $cookies = $sp->getCookies($res);
    my $spId;
    ok( $spId = $cookies->{lemonldap}, 'Get cookie' )
      or explain( $res, 'Set-Cookie: something' );

    # Test authentication
    ok( $res = $sp->_get( '/', cookie => "lemonldap=$spId" ), 'Get / on SP' );
    ok( $res->[0] == 200, 'User is authentified' ) or explain( $res->[0], 200 );
    ok( $sp->getUser($res) eq 'dwho', 'User is identified as dwho' )
      or explain( $res->[1], 'Lm-Remote-User: dwho' );

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
    ok( $res->[0] == 200, 'Response is 200' ) or explain( $res->[0], 200 );
    ok(
        $res->[2]->[0] =~
          m#iframe src="http://auth.idp.com(/cas/logout)\?(.+?)"#s,
        'Found iframe'
    );

    #print STDERR Dumper($res);

    # Query IdP with iframe src
    $url   = $1;
    $query = $2;
    switch ('issuer');
    ok(
        $res = $issuer->_get(
            $1,
            query  => $query,
            accept => 'text/html',
            cookie => "lemonldap=$idpId"
        ),
        'Get iframe from IdP'
    );

    # Verify that user has been disconnected
    ok( $res = $issuer->_get( '/', cookie => "lemonldap=$idpId" ),
        'Query IdP' );
    ok( $res->[0] == 401, 'User has been disconnected' )
      or explain( $res->[0], 401 );

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
                CASurl                => 'http://auth.idp.com/cas',
                CASCAFile             => 't/caFile.pem',
                multiValuesSeparator  => ';',
            },
        }
    );
}
