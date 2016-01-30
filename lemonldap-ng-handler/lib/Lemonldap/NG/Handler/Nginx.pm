# PSGI authentication package written for Nginx. It replace
# Lemonldap::NG::Handler::PSGI::Server to manage Nginx behaviour
package Lemonldap::NG::Handler::Nginx;

use strict;
use Mouse;
use Lemonldap::NG::Handler::SharedConf qw(:tsv);

extends 'Lemonldap::NG::Handler::PSGI';

## @method Code-Ref _run()
# Return a subroutine that call _authAndTrace() and tranform redirection
# response code from 302 to 401 (not authenticated) ones. This is required
# because Nginx "auth_request" parameter does not accept it. The Nginx
# configuration file should transform them back to 302 using:
#
#   auth_request_set $lmlocation $upstream_http_location;
#   error_page 401 $lmlocation;
#
#@return subroutine that will be called to manage FastCGI queries
sub _run {
    my $self = shift;
    return sub {
        my $req = $_[0];
        $self->lmLog( 'New request', 'debug' );
        my $res = $self->_authAndTrace(
            Lemonldap::NG::Common::PSGI::Request->new( $_[0] ) );

        # Transform 302 responses in 401 since Nginx refuse it
        if ( $res->[0] == 302 or $res->[0] == 303 ) {
            $res->[0] = 401;
        }

        # TODO: transform headers in $res->[1]
        return $res;
    };
}

## @method PSGI-Response router()
# Transform headers returned by handler main process:
# each "Name: value" is transformed to:
#  - Headername<i>: Name
#  - Headervalue<i>: value
# where <i> is an integer starting from 1
# It can be used in Nginx virtualhost configuration:
#
#    auth_request_set $headername1 $upstream_http_headername1;
#    auth_request_set $headervalue1 $upstream_http_headervalue1;
#    #proxy_set_header $headername1 $headervalue1;
#    # OR
#    #fastcgi_param $fheadername1 $headervalue1;
#
# It add also a header called Lm-Remote-User set to whatToTrace value that can
# be used in Nginx virtualhost configuration to insert user id in logs
#
#    auth_request_set $llremoteuser $upstream_http_lm_remote_user
#
#@param $req Lemonldap::NG::Common::PSGI::Request
sub router {
    my ( $self, $req ) = @_;
    my $hdrs = $req->{respHeaders} || {};
    my @convertedHdrs =
      [ 'Lm-Remote-User', $self->userId, 'Content-Length', 0 ];
    my $i = 0;
    foreach my $k ( keys %$hdrs ) {
        $i++;
        push @convertedHdrs, "Headername$i", $k, "Headervalue$i", $hdrs->{$k};
    }
    return [ 200, \@convertedHdrs, [] ];
}

1;
