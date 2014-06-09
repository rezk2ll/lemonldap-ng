package Lemonldap::NG::Handler::API::CGI;

our $VERSION = '1.4.0';

## @method void set_user(Apache2::RequestRec request, string user)
# sets remote_user
# @param request Apache2::RequestRec current request
# @param user string username
sub set_user {
    my ( $class, $r, $user ) = @_;
    $ENV{REMOTE_USER} = $user;
}

## @method string header_in(Apache2::RequestRec request, string header)
# returns request header value
# @param request Apache2::RequestRec current request
# @param header string request header
# @return request header value
sub header_in {
    my ( $class, $r, $header ) = @_;
    return $ENV{ cgiName($header) };
}

## @method void set_header_in(Apache2::RequestRec request, hash headers)
# sets or modifies request headers
# @param request Apache2::RequestRec current request
# @param headers hash containing header names => header value
sub set_header_in {
    my ( $class, $r, %headers ) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $ENV{ cgiName($h) } = $v;
    }
}

## @method void unset_header_in(Apache2::RequestRec request, array headers)
# removes request headers
# @param request Apache2::RequestRec current request
# @param headers array with header names to remove
sub unset_header_in {
    my ( $class, $r, @headers ) = @_;
    foreach my $h (@headers) {
        $ENV{ cgiName($h) } = undef;
    }
}

## @method void set_header_out(Apache2::RequestRec request, hash headers)
# sets response headers, only on 2xx and 3xx responses
# @param request Apache2::RequestRec current request
# @param headers hash containing header names => header value
sub set_header_out {
    my ( $class, $r, %headers ) = @_;
    while ( my ( $h, $v ) = each %headers ) {

        # TODO
    }
}

## @method void set_err_header_out(Apache2::RequestRec request, hash headers)
# sets response headers, even on 4xx responses
# @param request Apache2::RequestRec current request
# @param headers hash containing header names => header value
sub set_err_header_out {
    my ( $class, $r, %headers ) = @_;
    while ( my ( $h, $v ) = each %headers ) {

        # TODO
    }
}

## @method string hostname(Apache2::RequestRec request)
# returns host, as set by full URI or Host header
# @param request Apache2::RequestRec current request
# @return host string Host value
sub hostname {
    my ($class, $r) = @_;
    return $ENV{SERVER_NAME};
}

## @method string remote_ip(Apache2::RequestRec request)
# returns client IP address
# @param request Apache2::RequestRec current request
# @return IP_Addr string client IP
sub remote_ip {
    my ($class, $r) = @_;
    return $ENV{REMOTE_ADDR};
}

## @method boolean is_initial_req(Apache2::RequestRec request)
# always returns true
# @param request Apache2::RequestRec current request
# @return is_initial_req boolean
sub is_initial_req {
    my ($class, $r) = @_;
    return 1;
}

## @method string args(Apache2::RequestRec request, string args)
# gets or sets the query string
# @param request Apache2::RequestRec current request
# @param optional args string new query string
# @return args string Query string
sub args  {
    my ($class, $r, $args) = @_;
    $ENV{QUERY_STRING} = $args if ($args);
    return $ENV{QUERY_STRING};
}

## @method string uri(Apache2::RequestRec request)
# returns the path portion of the URI, normalized, i.e. :
# * URL decoded (characters encoded as %XX are decoded)
# * references to relative path components "." and ".." are resolved
# * two or more adjacent slashes are merged into a single slash
# @param request Apache2::RequestRec current request
# @return path portion of the URI, normalized
sub uri {
    my ($class, $r) = @_;
    my $uri = $ENV{SCRIPT_NAME};
    $uri =~ s#//+#/#g;
    return $uri;
}

## @method string uri_with_args(Apache2::RequestRec request)
# returns the URI, with arguments and with path portion normalized
# @param request Apache2::RequestRec current request
# @return URI with normalized path portion
sub uri_with_args {
    my ($class, $r) = @_;
    return $class->uri($r) . ( $ENV{QUERY_STRING} ? "?$ENV{QUERY_STRING}" : "");
}

## @method string unparsed_uri(Apache2::RequestRec request)
# returns the full original request URI, with arguments
# @param request Apache2::RequestRec current request
# @return full original request URI, with arguments
sub unparsed_uri {
    my ($class, $r) = @_;
    return $ENV{REQUEST_URI};
}

## @method string get_server_port(Apache2::RequestRec request)
# returns the port the server is receiving the current request on
# @param request Apache2::RequestRec current request
# @return port string server port
sub get_server_port {
    my ($class, $r) = @_;
    return $ENV{SERVER_PORT};
}

sub push_handlers {
    my ($class, $r) = @_;
}

sub cgiName {
    my $h = uc(shift);
    $h =~ s/-/_/g;
    return "HTTP_$h";
}

1;
