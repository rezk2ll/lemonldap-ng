# Common tests lib

use JSON::MaybeXS;
use 5.10.0;
use Data::Dumper;

use_ok('Lemonldap::NG::Manager');

my $app;

ok(
    $app = Lemonldap::NG::Manager->run(
        {
            configStorage => { confFile => 't/lemonldap-ng.ini' },
            protection    => 'none',
        }
    ),
    'New app'
);

ok( ref($app) eq 'CODE', 'app is a subroutine' );

our $count = 3;

sub count {
    my $c = shift;
    $count += $c if ($c);
    return $count;
}

sub get {
    my ( $path, $query ) = splice @_;
    $query //= '';
    return $app->(
        {
            'HTTP_ACCEPT'          => 'application/json, text/plain, */*',
            'SCRIPT_NAME'          => '',
            'HTTP_ACCEPT_ENCODING' => 'gzip, deflate',
            'SERVER_NAME'          => '127.0.0.1',
            'QUERY_STRING'         => $query,
            'HTTP_CACHE_CONTROL'   => 'max-age=0',
            'HTTP_ACCEPT_LANGUAGE' => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
            'PATH_INFO'            => $path,
            'REQUEST_METHOD'       => 'GET',
            'REQUEST_URI'          => $path . ( $query ? "?$query" : '' ),
            'SERVER_PORT'          => '8002',
            'SERVER_PROTOCOL'      => 'HTTP/1.1',
            'HTTP_USER_AGENT' =>
              'Mozilla/5.0 (VAX-4000; rv:36.0) Gecko/20350101 Firefox',
            'REMOTE_ADDR' => '127.0.0.1',
            'HTTP_HOST'   => '127.0.0.1:8002'
        }
    );
}

sub post {
    my ( $path, $query, $body, $type, $len ) = splice @_;
    die "$body must be a IO::Handle"
      unless ( ref($body) and $body->can('read') );
    return $app->(
        {
            'HTTP_ACCEPT'          => 'application/json, text/plain, */*',
            'SCRIPT_NAME'          => '',
            'HTTP_ACCEPT_ENCODING' => 'gzip, deflate',
            'SERVER_NAME'          => '127.0.0.1',
            'QUERY_STRING'         => $query,
            'HTTP_CACHE_CONTROL'   => 'max-age=0',
            'HTTP_ACCEPT_LANGUAGE' => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
            'PATH_INFO'            => $path,
            'REQUEST_METHOD'       => 'POST',
            'REQUEST_URI'          => $path . ( $query ? "?$query" : '' ),
            'SERVER_PORT'          => '8002',
            'SERVER_PROTOCOL'      => 'HTTP/1.1',
            'HTTP_USER_AGENT' =>
              'Mozilla/5.0 (VAX-4000; rv:36.0) Gecko/20350101 Firefox',
            'REMOTE_ADDR'          => '127.0.0.1',
            'HTTP_HOST'            => '127.0.0.1:8002',
            'psgix.input.buffered' => 1,
            'psgi.input'           => $body,
            'CONTENT_LENGTH'       => $len // scalar( ( stat $body )[7] ),
            'CONTENT_TYPE'         => $type,
        }
    );
}

sub put {
    my ( $path, $query, $body, $type, $len ) = splice @_;
    die "$body must be a IO::Handle"
      unless ( ref($body) and $body->can('read') );
    return $app->(
        {
            'HTTP_ACCEPT'          => 'application/json, text/plain, */*',
            'SCRIPT_NAME'          => '',
            'HTTP_ACCEPT_ENCODING' => 'gzip, deflate',
            'SERVER_NAME'          => '127.0.0.1',
            'QUERY_STRING'         => $query,
            'HTTP_CACHE_CONTROL'   => 'max-age=0',
            'HTTP_ACCEPT_LANGUAGE' => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
            'PATH_INFO'            => $path,
            'REQUEST_METHOD'       => 'PUT',
            'REQUEST_URI'          => $path . ( $query ? "?$query" : '' ),
            'SERVER_PORT'          => '8002',
            'SERVER_PROTOCOL'      => 'HTTP/1.1',
            'HTTP_USER_AGENT' =>
              'Mozilla/5.0 (VAX-4000; rv:36.0) Gecko/20350101 Firefox',
            'REMOTE_ADDR'          => '127.0.0.1',
            'HTTP_HOST'            => '127.0.0.1:8002',
            'psgix.input.buffered' => 1,
            'psgi.input'           => $body,
            'CONTENT_LENGTH'       => $len // scalar( ( stat $body )[7] ),
            'CONTENT_TYPE'         => $type,
        }
    );
}

sub del {
    my ( $path, $query ) = splice @_;
    return $app->(
        {
            'HTTP_ACCEPT'          => 'application/json, text/plain, */*',
            'SCRIPT_NAME'          => '',
            'HTTP_ACCEPT_ENCODING' => 'gzip, deflate',
            'SERVER_NAME'          => '127.0.0.1',
            'QUERY_STRING'         => $query,
            'HTTP_CACHE_CONTROL'   => 'max-age=0',
            'HTTP_ACCEPT_LANGUAGE' => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
            'PATH_INFO'            => $path,
            'REQUEST_METHOD'       => 'DELETE',
            'REQUEST_URI'          => $path . ( $query ? "?$query" : '' ),
            'SERVER_PORT'          => '8002',
            'SERVER_PROTOCOL'      => 'HTTP/1.1',
            'HTTP_USER_AGENT' =>
              'Mozilla/5.0 (VAX-4000; rv:36.0) Gecko/20350101 Firefox',
            'REMOTE_ADDR' => '127.0.0.1',
            'HTTP_HOST'   => '127.0.0.1:8002',
        }
    );
}

sub jsonResponse {
    my ( $path, $query ) = splice @_;
    my $res;
    ok( $res = get( $path, $query ),
        "Succeed to get $path" . ( $query ? "?$query" : "" ) );
    ok( $res->[0] == 200, "Return code eq 200" );
    my $href;
    ok( $href = decode_json( $res->[2]->[0] ), 'Response is JSON' );
    count(3);
    return $href;
}

sub jsonPostResponse {
    my ( $path, $query, $body, $type, $len ) = splice @_;
    my $res;
    ok(
        $res = post( $path, $query, $body, $type, $len ),
        "Succeed to post to $path" . ( $query ? "?$query" : "" )
    );
    ok( $res->[0] == 200, "Return code eq 200" ) or print STDERR Dumper($res);
    my $href;
    ok( $href = decode_json( $res->[2]->[0] ), 'Response is JSON' );
    count(3);
    return $href;
}

sub jsonPutResponse {
    my ( $path, $query, $body, $type, $len ) = splice @_;
    my $res;
    ok(
        $res = put( $path, $query, $body, $type, $len ),
        "Succeed to post to $path" . ( $query ? "?$query" : "" )
    );
    ok( $res->[0] == 200, "Return code eq 200" ) or print STDERR Dumper($res);
    my $href;
    ok( $href = decode_json( $res->[2]->[0] ), 'Response is JSON' );
    count(3);
    return $href;
}

1;
