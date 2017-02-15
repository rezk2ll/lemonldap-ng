use Test::More;
use strict;
use IO::String;
use MIME::Base64;

BEGIN {
    require 't/test-lib.pm';
}

my $maintests = 9;
my $debug     = 'error';
my ( $issuer, $sp, $res );
my %handlerOR = ( issuer => [], sp => [] );

SKIP: {
    eval { require Net::OpenID::Consumer; require Net::OpenID::Server; };
    if ($@) {
        skip 'Net::OpenID::* notfound', $maintests;
    }
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
    expectForm( $res, '#', undef );
    ok( $res->[2]->[0] =~ /name="openid_identifier"/,
        ' Ask for OpenID identity' );

    my $query =
      'openid_identifier=http%3A%2F%2Fauth.idp.com%2Fopenidserver%2Fdwho';

    ok(
        $res = $sp->_post(
            '/', IO::String->new($query),
            length => length($query),
            accept => 'text/html',
        ),
        'Post OpenID identity'
    );
    my $uri;
    ( $uri, $query ) = expectRedirection( $res,
        qr#http://auth.idp.com(/openidserver/?)\?(openid.*)$# );

    # Follow redirection do IdP
    switch ('issuer');
    ok( $res = $issuer->_get( $uri, query => $query, accept => 'text/html' ),
        'Follow redirection to IdP' );
    expectOK($res);
    my ( $host, $tmp );
    ( $host, $tmp, $query ) = expectForm( $res, '#', undef, 'openid.mode' );
    $query .= '&user=dwho&password=dwho';

    # Try to authenticate
    ok(
        $res = $issuer->_post(
            $uri, IO::String->new($query),
            length => length($query),
            accept => 'text/html'
        ),
        'Try to authenticate'
    );
    my $idpId = expectCookie($res);
    ( $host, $tmp, $query ) = expectForm( $res, '#', undef, 'confirm' );

    # Confirm
    ok(
        $res = $issuer->_post(
            $uri, IO::String->new($query),
            length => length($query),
            accept => 'text/html'
        ),
        'Confirm choice'
    );
    ($query) = expectRedirection( $res, qr#^http://auth.sp.com/?\?(.*)# );

    # Push redirection to SP
    switch ('sp');
    ok( $res = $sp->_get( '/', query => $query, accept => 'text/html' ),
        'Follow redirection to SP' );
    my $spId = expectCookie($res);
    expectRedirection( $res, qr#^http://auth.sp.com/?$# );

    #print STDERR Dumper($res);
}

count($maintests);
clean_sessions();
done_testing( count() );

sub switch {
    my $type = shift;
    @Lemonldap::NG::Handler::Main::_onReload = @{
        $handlerOR{$type};
    };
}

no warnings 'redefine';

sub LWP::UserAgent::request {
    my ( $self, $req ) = @_;
    ok( $req->uri =~ m#http://auth.idp.com(.*)#, ' Request from SP to IdP' );
    my $url = $1;
    my ($res);
    count(1);
    if ( $req->method =~ /^post$/i ) {
        my $s = $req->content;
        ok(
            $res = $issuer->_post(
                $url, IO::String->new($s),
                length => length($s),
                type   => $req->header('Content-Type'),
                accept => 'text/plain',
            ),
            '  Execute request'
        );
    }
    else {
        ok( $res = $issuer->_get( $url, accept => 'text/plain', ),
            '  Execute post request' );
    }
    expectOK($res);
    my $httpResp = HTTP::Response->new( $res->[0], 'OK' );

    while ( my $name = shift @{ $res->[1] } ) {
        $httpResp->header( $name, shift( @{ $res->[1] } ) );
    }
    $httpResp->request($req);
    $httpResp->content( join( '', @{ $res->[2] } ) );
    count(1);
    return $httpResp;
}

sub issuer {
    return LLNG::Manager::Test->new(
        {
            ini => {
                logLevel                 => $debug,
                templatesDir             => 'site/htdocs/static',
                domain                   => 'idp.com',
                portal                   => 'http://auth.idp.com',
                authentication           => 'Demo',
                userDB                   => 'Same',
                issuerDBOpenIDActivation => 1,
            }
        }
    );
}

sub sp {
    return LLNG::Manager::Test->new(
        {
            ini => {
                logLevel       => $debug,
                domain         => 'sp.com',
                portal         => 'http://auth.sp.com',
                authentication => 'OpenID',
                userDB         => 'Same',
                openIdSecret   => 'qwerty',
                exportedVars   => {
                    mail => 'email',
                },
                openIdIDPList => '0;',
            },
        }
    );
}
