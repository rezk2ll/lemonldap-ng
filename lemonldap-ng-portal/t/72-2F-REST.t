use lib 'inc';
use Test::More;
use strict;
use IO::String;
use LWP::UserAgent;
use LWP::Protocol::PSGI;
use Plack::Request;

require 't/test-lib.pm';
my $maintests = 4;

LWP::Protocol::PSGI->register(
    sub {
        my $req = Plack::Request->new(@_);
        if ( $req->path_info eq '/init' ) {
            ok( $req->content eq '{"name":"dwho"}', ' Init req gives dwho' )
              or explain( $req->content, '{"name":"dwho"}' );
        }
        elsif ( $req->path_info eq '/vrfy' ) {
            ok( $req->content eq '{"code":"1234"}', ' Code is 1234' )
              or explain( $req->content, '{"code":"1234"}' );
        }
        else {
            fail( ' Bad REST call ' . $req->path_info );
        }
        return [
            200,
            [ 'Content-Type' => 'application/json', 'Content-Length' => 12 ],
            ['{"result":1}']
        ];
    }
);

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel         => 'error',
            rest2fActivation => 1,
            rest2fInitUrl    => 'http://auth.example.com/init',
            rest2fInitArgs   => { name => 'uid' },
            rest2fVerifyUrl  => 'http://auth.example.com/vrfy',
            rest2fVerifyArgs => { code => 'code' },
        }
    }
);
my $res;

# Try to authenticate
# -------------------
ok(
    $res = $client->_post(
        '/',
        IO::String->new('user=dwho&password=dwho'),
        length => 23,
        accept => 'text/html',
    ),
    'Auth query'
);
my ( $host, $url, $query ) =
  expectForm( $res, undef, '/rest2fcheck', 'token', 'code' );
$query =~ s/code=/code=1234/;

ok(
    $res = $client->_post(
        '/rest2fcheck',
        IO::String->new($query),
        length => length($query),
    ),
    'Post code'
);
my $id = expectCookie($res);
$client->logout($id);

#print STDERR Dumper($res);

count($maintests);

clean_sessions();

done_testing( count() );

