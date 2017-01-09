use Test::More;
use strict;
use IO::String;

BEGIN {
    require 't/test-lib.pm';
}

my $maintests = 4;
my $debug     = 'error';
my ( $issuer, $sp, $res );
my %handlerOR = ( issuer => [], sp => [] );

SKIP: {
    eval 'use SOAP::Lite';
    if ($@) {
        skip 'SOAP::Lite not found', $maintests;
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
    expectOK($res);

    # Try to auth
    ok(
        $res = $sp->_post(
            '/', IO::String->new('user=dwho&password=dwho'),
            length => 23,
            accept => 'text/html'
        ),
        'Post user/password'
    );
    expectRedirection( $res, 'http://auth.sp.com' );
    expectCookie($res);
}

count($maintests);
clean_sessions();
done_testing( count() );

# Redefine LWP methods for tests
no warnings 'redefine';

sub LWP::UserAgent::request {
    my ( $self, $req ) = @_;
    ok( $req->uri =~ m#http://auth.((?:id|s)p).com(.*)#, 'SOAP request' );
    my $host = $1;
    my $url  = $2;
    my $res;
    my $s = $req->content;
    my $client = ( $host eq 'idp' ? $issuer : $sp );
    ok(
        $res = $client->_post(
            $url,
            IO::String->new($s),
            length => length($s),
            type   => $req->header('Content-Type'),
            custom => {
                HTTP_SOAPACTION => $req->header('Soapaction'),
            },
        ),
        'Execute request'
    );
    expectOK($res);
    ok( getHeader( $res, 'Content-Type' ) =~ m#^(?:text|application)/xml#,
        'Content is XML' )
      or explain( $res->[1], 'Content-Type => application/xml' );
    my $httpResp = HTTP::Response->new( $res->[0], 'OK' );

    while ( my $name = shift @{ $res->[1] } ) {
        $httpResp->header( $name, shift( @{ $res->[1] } ) );
    }
    $httpResp->content( join( '', @{ $res->[2] } ) );
    count(3);
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
                logLevel          => $debug,
                templatesDir      => 'site/htdocs/static',
                domain            => 'idp.com',
                portal            => 'http://auth.idp.com',
                authentication    => 'Demo',
                userDB            => 'Demo',
                soapSessionServer => 1,
            }
        }
    );
}

sub sp {
    return LLNG::Manager::Test->new(
        {
            ini => {
                logLevel         => $debug,
                domain           => 'sp.com',
                portal           => 'http://auth.sp.com',
                authentication   => 'Proxy',
                userDB           => 'Proxy',
                proxyAuthService => 'http://auth.idp.com/sessions',
                proxyUseSoap     => 1,
            },
        }
    );
}
