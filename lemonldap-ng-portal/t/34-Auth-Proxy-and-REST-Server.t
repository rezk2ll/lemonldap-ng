use Test::More;
use strict;
use IO::String;

BEGIN {
    require 't/test-lib.pm';
}

my $debug = 'error';
my ( $issuer, $sp, $res, $spId, $idpId );
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
$spId = expectCookie($res);

# Test other REST queries
switch ('issuer');

# Session content
ok( $res = $issuer->_get("/sessions/global/$idpId"), 'Session content' );
expectOK($res);
ok( $res = eval { JSON::from_json( $res->[2]->[0] ) }, ' GET JSON' )
  or print STDERR $@;
ok( $res->{_session_id} eq $idpId, ' Good ID' )
  or explain( $res, "_session_id => $idpId" );
count(3);

# Session key
ok( $res = $issuer->_get("/sessions/global/$idpId/[_session_id,uid]"),
    'Some session keys' );
expectOK($res);
ok( $res = eval { JSON::from_json( $res->[2]->[0] ) }, ' GET JSON' )
  or print STDERR $@;
ok( $res->{_session_id} eq $idpId, ' Good ID' )
  or explain( $res, "_session_id => $idpId" );
ok( $res->{uid} eq 'dwho', ' Uid is dwho' ) or explain( $res, 'uid => dwho' );
count(4);

# New session
ok(
    $res = $issuer->_post(
        '/sessions/global', IO::String->new('{"uid":"zz","_whatToTrace":"zz"}'),
        length => 32,
        type   => 'application/json'
    ),
    'Create session'
);
expectOK($res);
ok( $res = eval { JSON::from_json( $res->[2]->[0] ) }, ' GET JSON' )
  or print STDERR $@;
my $newId = $res->{session}->{_session_id};

# Verify a key
ok( $res = $issuer->_get("/sessions/global/$newId/uid"), 'Verify uid' );
ok( $res->[2]->[0] eq 'zz', ' Uid is good' );
count(4);

# Update a key
ok(
    $res = $issuer->app->(
        {
            HTTP_ACCEPT            => 'application/json',
            HTTP_ACCEPT_LANGUAGE   => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
            HTTP_HOST              => 'auth.idp.com',
            PATH_INFO              => "/sessions/global/$newId",
            REMOTE_ADDR            => '127.0.0.1',
            REQUEST_METHOD         => 'PUT',
            REQUEST_URI            => "/sessions/global/$newId",
            SCRIPT_NAME            => '',
            SERVER_NAME            => 'auth.example.com',
            SERVER_PORT            => '80',
            SERVER_PROTOCOL        => 'HTTP/1.1',
            'psgix.input.buffered' => 0,
            'psgi.input'           => IO::String->new('{"cn":"CN"}'),
            CONTENT_TYPE           => 'application/json',
            CONTENT_LENGTH         => 11,
        }
    ),
    'Put a new key'
);
expectOK($res);
ok( $res = eval { JSON::from_json( $res->[2]->[0] ) }, ' GET JSON' )
  or print STDERR $@;
ok( $res->{result} == 1, ' Result is 1' );
count(3);

# Verify new key
ok( $res = $issuer->_get("/sessions/global/$newId/cn"), 'Verify cn' );
ok( $res->[2]->[0] eq 'CN', ' CN is good' );
count(2);

# Del new session
ok(
    $res = $issuer->app->(
        {
            HTTP_ACCEPT          => 'application/json',
            HTTP_ACCEPT_LANGUAGE => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
            HTTP_HOST            => 'auth.idp.com',
            PATH_INFO            => "/sessions/global/$newId",
            REMOTE_ADDR          => '127.0.0.1',
            REQUEST_METHOD       => 'DELETE',
            REQUEST_URI          => "/sessions/global/$newId",
            SCRIPT_NAME          => '',
            SERVER_NAME          => 'auth.example.com',
            SERVER_PORT          => '80',
            SERVER_PROTOCOL      => 'HTTP/1.1',
        }
    ),
    'Delete new session'
);
expectOK($res);
ok( $res = eval { JSON::from_json( $res->[2]->[0] ) }, ' GET JSON' )
  or print STDERR $@;
ok( $res->{result} == 1, ' Result is 1' );
count(3);

# Verify that session is deleted
ok( $res = $issuer->_get("/sessions/global/$newId/cn"),
    'New session is deleted' );
ok( $res->[0] == 400, ' Session does not exist' );
count(2);

# Logout
switch ('sp');
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
        $idpId = expectCookie($res);
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
                restConfigServer  => 1,
                whatToTrace       => '_whatToTrace',
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
                whatToTrace      => '_whatToTrace',
            },
        }
    );
}
