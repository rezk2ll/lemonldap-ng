use Test::More;
use strict;
use IO::String;

BEGIN {
    require 't/test-lib.pm';
}

my $debug = 'error';
my ( $issuer, $sp, $res );
my %handlerOR = ( issuer => [], sp => [] );

ok( $issuer = issuer(), 'Issuer portal' );
$handlerOR{issuer} = \@Lemonldap::NG::Handler::Main::Reload::_onReload;
switch ('sp');

ok( $sp = sp(), 'SP portal' );
$handlerOR{sp} = \@Lemonldap::NG::Handler::Main::Reload::_onReload;

# Simple SP access
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
my $spId = expectCookie($res);

# Logout
ok(
    $res = $sp->_get(
        '/',
        query  => 'logout',
        accept => 'text/html',
        cookie => "lemonldap=$spId"
    ),
    'Ask for logout'
);
count(1);
expectOK($res);

# Test if logout is done
ok(
    $res = $sp->_get(
        '/', cookie => "lemonldap=$spId",
    ),
    'Test if user is reject on IdP'
);
count(1);
expectReject($res);

count(4);
clean_sessions();
done_testing( count() );

# Redefine LWP methods for tests
no warnings 'redefine';

sub LWP::UserAgent::request {
    my ( $self, $req ) = @_;
    ok( $req->uri =~ m#http://auth.idp.com(.*)#, " REST request (uri: $1)" );
    count(1);
    my $url = $1;
    my $res;
    my $s = $req->content;
    if ( $req->method =~ /^post$/i ) {
        my $s = $req->content;
        ok(
            $res = $issuer->_post(
                $url,
                IO::String->new($s),
                length => length($s),
                type   => $req->header('Content-Type'),
            ),
            ' Post request'
        );
        count(1);
        expectOK($res);
        expectCookie($res);
    }
    else {
        ok(
            $res = $issuer->_get(
                $url,
                accept => $req->header('Accept'),
                cookie => $req->header('Cookie')
            ),
            ' Execute request'
        );
        count(1);
        expectOK($res);
    }
    ok( getHeader( $res, 'Content-Type' ) =~ m#^(?:text|application)/json#,
        'Content is JSON' )
      or explain( $res->[1], 'Content-Type => application/json' );
    count(1);
    my $httpResp;
    $httpResp = HTTP::Response->new( $res->[0], 'OK' );

    while ( my $name = shift @{ $res->[1] } ) {
        $httpResp->header( $name, shift( @{ $res->[1] } ) );
    }
    $httpResp->content( join( '', @{ $res->[2] } ) );
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
                restSessionServer => 1,
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
                proxyAuthService => 'http://auth.idp.com',
                proxyUseSoap     => 0,
            },
        }
    );
}
