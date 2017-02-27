use Test::More;
use strict;
use IO::String;

BEGIN {
    require 't/test-lib.pm';
}

my $debug = 'error';
my ( $issuer, $sp, $res, $spId );
my %handlerOR = ( issuer => [], sp => [] );

ok( $issuer = issuer(), 'Issuer portal' );
$handlerOR{issuer} = \@Lemonldap::NG::Handler::Main::_onReload;
switch ('sp');

ok( $sp = sp(), 'SP portal' );
$handlerOR{sp} = \@Lemonldap::NG::Handler::Main::_onReload;
count(2);

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
count(2);
expectRedirection( $res, 'http://auth.sp.com' );
$spId = expectCookie($res);

# Test other REST queries
switch ('issuer');

# Session content
ok( $res = $issuer->_get("/sessions/global/$spId"), 'Session content' );
expectOK($res);
ok( $res = eval { JSON::from_json( $res->[2]->[0] ) }, ' GET JSON' )
  or print STDERR $@;
ok( $res->{_session_id} eq $spId, ' Good ID' )
  or explain( $res, "_session_id => $spId" );
count(3);

# Session key
ok( $res = $issuer->_get("/sessions/global/$spId/[_session_id,uid]"),
    'Some session keys' );
expectOK($res);
ok( $res = eval { JSON::from_json( $res->[2]->[0] ) }, ' GET JSON' )
  or print STDERR $@;
ok( $res->{_session_id} eq $spId, ' Good ID' )
  or explain( $res, "_session_id => $spId" );
ok( $res->{uid} eq 'dwho', ' Uid is dwho' ) or explain( $res, 'uid => dwho' );
count(4);

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

# Test if user is reject on IdP
ok(
    $res = $sp->_get(
        '/', cookie => "lemonldap=$spId",
    ),
    'Test if user is reject on IdP'
);
count(1);
expectReject($res);

clean_sessions();
done_testing( count() );

# Redefine LWP methods for tests
no warnings 'redefine';

sub LWP::UserAgent::request {
    my ( $self, $req ) = @_;
    ok(
        $req->uri =~ m#http://auth.idp.com(.*)#,
        ' @ REST request (' . $req->method . " $1)"
    );
    count(1);
    my $url = $1;
    my $res;
    my $s = $req->content;
    if ( $req->method =~ /^(post|put)$/i ) {
        my $mth = '_' . lc($1);
        my $s   = $req->content;
        ok(
            $res = $issuer->$mth(
                $url,
                IO::String->new($s),
                length => length($s),
                type   => $req->header('Content-Type'),
            ),
            ' Post request'
        );
        count(1);
        expectOK($res);
    }
    elsif ( $req->method =~ /^(get|delete)$/i ) {
        my $mth = '_' . lc($1);
        ok(
            $res = $issuer->$mth(
                $url,
                accept => $req->header('Accept'),
                cookie => $req->header('Cookie')
            ),
            ' Execute request'
        );
        ok( ( $res->[0] == 200 or $res->[0] == 400 ),
            ' Response is 200 or 400' )
          or explain( $res->[0], '200 or 400' );
        count(2);
    }
    my $httpResp;
    $httpResp = HTTP::Response->new( $res->[0], 'OK' );

    while ( my $name = shift @{ $res->[1] } ) {
        $httpResp->header( $name, shift( @{ $res->[1] } ) );
    }
    $httpResp->content( join( '', @{ $res->[2] } ) );
    pass(' @ END OF REST REQUEST');
    count(1);
    return $httpResp;
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
                logLevel          => $debug,
                templatesDir      => 'site/htdocs/static',
                domain            => 'idp.com',
                portal            => 'http://auth.idp.com',
                authentication    => 'Demo',
                userDB            => 'Same',
                restSessionServer => 1,
                restConfigServer  => 1,
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
                authentication => 'Demo',
                userDB         => 'Same',
                globalStorage => 'Lemonldap::NG::Common::Apache::Session::REST',
                globalStorageOptions => {
                    baseUrl => 'http://auth.idp.com/sessions/global/'
                },
                persistentStorage => 'Apache::Session::File',
                persistentStorageOptions => {
                    Directory => 't/sessions',
                    LockDirectory => 't/sessions/lock',
                },
            },
        }
    );
}
