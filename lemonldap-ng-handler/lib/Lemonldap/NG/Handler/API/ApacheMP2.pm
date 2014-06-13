package Lemonldap::NG::Handler::API::ApacheMP2;

use Exporter 'import';

our $VERSION = '1.4.0';

our %EXPORT_TAGS;

our @EXPORT_OK;

our @EXPORT;



BEGIN{

    %EXPORT_TAGS = (
        webserverCodes => [
            qw( OK REDIRECT FORBIDDEN DONE DECLINED SERVER_ERROR )
        ],
    );
    push( @EXPORT_OK, @{ $EXPORT_TAGS{$_} } ) foreach ( keys %EXPORT_TAGS );
    $EXPORT_TAGS{all} = \@EXPORT_OK;

    # Specific modules and constants for ApacheMP2
    require Apache2::RequestUtil;
    Apache2::RequestUtil->import();
    require Apache2::RequestRec;
    Apache2::RequestRec->import();
    require Apache2::Log;
    require Apache2::ServerUtil;
    Apache2::ServerUtil->import();
    require Apache2::Connection;
    Apache2::Connection->import();
    require Apache2::RequestIO;
    Apache2::RequestIO->import();
    require APR::Table;
    APR::Table->import();
    require Apache2::Const;
    Apache2::Const->import( '-compile', qw(:common :log) );
    eval '
        use constant FORBIDDEN    => Apache2::Const::FORBIDDEN;
        use constant REDIRECT     => Apache2::Const::REDIRECT;
        use constant OK           => Apache2::Const::OK;
        use constant DECLINED     => Apache2::Const::DECLINED;
        use constant DONE         => Apache2::Const::DONE;
        use constant SERVER_ERROR => Apache2::Const::SERVER_ERROR;
    ';

}



## @method void thread_share(string $variable)
# share or not the variable (if authorized by specific module)
# @param $variable the name of the variable to share
sub thread_share {
    my ($class, $variable) = @_;
    eval " require threads::shared;
           require Apache2::RequestUtil;
           Apache2::RequestUtil->import();
           threads::shared::share($variable);
    ";
    print "eval error: $@" if ($@);

}


## @method void set_user(Apache2::RequestRec request, string user)
# sets remote_user
# @param request Apache2::RequestRec current request
# @param user string username
sub set_user {
    my ($class, $r, $user) = @_;
    $r->user($user);
}

## @method string header_in(Apache2::RequestRec request, string header)
# returns request header value
# @param request Apache2::RequestRec current request
# @param header string request header
# @return request header value
sub header_in {
    my ($class, $r, $header) = @_;
    return $r->headers_in->{$header};
}

## @method void set_header_in(Apache2::RequestRec request, hash headers)
# sets or modifies request headers
# @param request Apache2::RequestRec current request
# @param headers hash containing header names => header value
sub set_header_in {
    my ($class, $r, %headers) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $r->headers_in->set( $h => $v );
    }
}

## @method void unset_header_in(Apache2::RequestRec request, array headers)
# removes request headers
# @param request Apache2::RequestRec current request
# @param headers array with header names to remove
sub unset_header_in {
    my ($class, $r, @headers) = @_;
    foreach my $h (@headers) {
        $r->headers_in->unset($h);
    }
} 

## @method void set_header_out(Apache2::RequestRec request, hash headers)
# sets response headers, only on 2xx and 3xx responses
# @param request Apache2::RequestRec current request
# @param headers hash containing header names => header value
sub set_header_out {
    my ($class, $r, %headers) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $r->headers_out->set( $h => $v );
    }
}

## @method void set_err_header_out(Apache2::RequestRec request, hash headers)
# sets response headers, even on 4xx responses
# @param request Apache2::RequestRec current request
# @param headers hash containing header names => header value
sub set_err_header_out {
    my ($class, $r, %headers) = @_;
    while ( my ( $h, $v ) = each %headers ) {
        $r->err_headers_out->set( $h => $v );
    }
}

## @method string hostname(Apache2::RequestRec request)
# returns host, as set by full URI or Host header
# @param request Apache2::RequestRec current request
# @return host string Host value
sub hostname {
    my ($class, $r) = @_;
    return $r->hostname;
}

## @method string remote_ip(Apache2::RequestRec request)
# returns client IP address
# @param request Apache2::RequestRec current request
# @return IP_Addr string client IP
sub remote_ip {
    my ($class, $r) = @_;
    return $r->connection->remote_ip;
}

## @method boolean is_initial_req(Apache2::RequestRec request)
# returns true unless the current request is a subrequest
# @param request Apache2::RequestRec current request
# @return is_initial_req boolean
sub is_initial_req {
    my ($class, $r) = @_;
    return $r->is_initial_req;
}

## @method string args(Apache2::RequestRec request, string args)
# gets the query string
# @param request Apache2::RequestRec current request
# @return args string Query string
sub args  {
    my ($class, $r) = @_;
    return $r->args();
}

## @method string uri(Apache2::RequestRec request)
# returns the path portion of the URI, normalized, i.e. :
# * URL decoded (characters encoded as %XX are decoded,
#   except ? in order not to merge path and query string)
# * references to relative path components "." and ".." are resolved
# * two or more adjacent slashes are merged into a single slash
# @param request Apache2::RequestRec current request
# @return path portion of the URI, normalized
sub uri {
    my ($class, $r) = @_;
    my $uri = $r->uri;
    $uri =~ s#//+#/#g;
    $uri =~ s#\?#%3F#g;
    return $uri;
}

## @method string uri_with_args(Apache2::RequestRec request)
# returns the URI, with arguments and with path portion normalized
# @param request Apache2::RequestRec current request
# @return URI with normalized path portion
sub uri_with_args {
    my ($class, $r) = @_;
    return $class->uri($r) . ( $r->args ? "?" . $r->args : "");
}

## @method string unparsed_uri(Apache2::RequestRec request)
# returns the full original request URI, with arguments
# @param request Apache2::RequestRec current request
# @return full original request URI, with arguments
sub unparsed_uri {
    my ($class, $r) = @_;
    return $r->unparsed_uri;
}

## @method string get_server_port(Apache2::RequestRec request)
# returns the port the server is receiving the current request on
# @param request Apache2::RequestRec current request
# @return port string server port
sub get_server_port {
    my ($class, $r) = @_;
    return $r->get_server_port;
}

sub push_handlers {
    my ($class, $r) = @_;
}

1;
