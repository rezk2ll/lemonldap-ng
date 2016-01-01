package Lemonldap::NG::Manager::Cli::Lib;

use JSON::MaybeXS;
use 5.10.0;
use Mouse;
use Lemonldap::NG::Manager;

has iniFile => ( is => 'ro', isa => 'Str', required => 1 );

has app => (
    is       => 'ro',
    isa => 'CodeRef',
    builder  => sub {
        return Lemonldap::NG::Manager->run(
            {
                configStorage => { confFile => $_[0]->{iniFile} },
                protection    => 'none',
            }
        );
    }
);

sub get {
    my ( $self, $path, $query ) = splice @_;
    $query //= '';
    return $self->app->(
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
    my ( $self, $path, $query, $body, $type, $len ) = splice @_;
    die "$body must be a IO::Handle"
      unless ( ref($body) and $body->can('read') );
    return $self->app->(
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
    my ( $self, $path, $query, $body, $type, $len ) = splice @_;
    die "$body must be a IO::Handle"
      unless ( ref($body) and $body->can('read') );
    return $self->app->(
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
    my ( $self, $path, $query ) = splice @_;
    return $self->app->(
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
    my ( $self, $path, $query ) = splice @_;
    my $res = $self->get( $path, $query )
      or die "Manager lib has refused my get, aborting";
    die "Manager lib does not return a 200 code, aborting"
      unless ( $res->[0] == 200 );
    my $href = decode_json( $res->[2]->[0] ) or die 'Response is not JSON';
    return $href;
}

sub jsonPostResponse {
    my ( $self, $path, $query, $body, $type, $len ) = splice @_;
    my $res = $self->post( $path, $query, $body, $type, $len )
      or die "Manager lib has refused my post, aborting";
    die "Manager lib does not return a 200 code, aborting"
      unless ( $res->[0] == 200 );
    my $href = decode_json( $res->[2]->[0] ) or die 'Response is not JSON';
    return $href;
}

sub jsonPutResponse {
    my ( $self, $path, $query, $body, $type, $len ) = splice @_;
    my $res = $self->put( $path, $query, $body, $type, $len )
      or die "Manager lib has refused my put, aborting";
    die "Manager lib does not return a 200 code, aborting"
      unless ( $res->[0] == 200 );
    my $href = decode_json( $res->[2]->[0] ) or die 'Response is not JSON';
    return $href;
}

1;
