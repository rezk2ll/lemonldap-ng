# Auth-basic authentication with Lemonldap::NG rights management

# This specific handler is intended to be called directly by Apache

package Lemonldap::NG::Handler::AuthBasic;

use strict;
use Lemonldap::NG::Handler::ApacheMP2;
use Lemonldap::NG::Handler::Lib::AuthBasic;

BEGIN {
    our @ISA = ('Lemonldap::NG::Handler::Main');
}

our $VERSION = '2.0.0';

# PUBLIC METHODS

sub handler {
    my $class;
    $class = $#_ ? shift : __PACKAGE__;
    my ($res) = $class->run(@_);
    return $res;
}

# For an obscur reason, inheritance isn't possible with ApacheMP2.pm.

*FORBIDDEN         = *Lemonldap::NG::Handler::ApacheMP2::FORBIDDEN;
*HTTP_UNAUTHORIZED = *Lemonldap::NG::Handler::ApacheMP2::HTTP_UNAUTHORIZED;
*REDIRECT          = *Lemonldap::NG::Handler::ApacheMP2::REDIRECT;
*OK                = *Lemonldap::NG::Handler::ApacheMP2::OK;
*DECLINED          = *Lemonldap::NG::Handler::ApacheMP2::DECLINED;
*DONE              = *Lemonldap::NG::Handler::ApacheMP2::DONE;
*SERVER_ERROR      = *Lemonldap::NG::Handler::ApacheMP2::SERVER_ERROR;
*AUTH_REQUIRED     = *Lemonldap::NG::Handler::ApacheMP2::AUTH_REQUIRED;
*MAINTENANCE       = *Lemonldap::NG::Handler::ApacheMP2::MAINTENANCE;

*_lmLog             = *Lemonldap::NG::Handler::ApacheMP2::_lmLog;
*addToHtmlHead      = *Lemonldap::NG::Handler::ApacheMP2::addToHtmlHead;
*args               = *Lemonldap::NG::Handler::ApacheMP2::args;
*flatten_bb         = *Lemonldap::NG::Handler::ApacheMP2::flatten_bb;
*get_server_port    = *Lemonldap::NG::Handler::ApacheMP2::get_server_port;
*header_in          = *Lemonldap::NG::Handler::ApacheMP2::header_in;
*hostname           = *Lemonldap::NG::Handler::ApacheMP2::hostname;
*is_initial_req     = *Lemonldap::NG::Handler::ApacheMP2::is_initial_req;
*method             = *Lemonldap::NG::Handler::ApacheMP2::method;
*newRequest         = *Lemonldap::NG::Handler::ApacheMP2::newRequest;
*print              = *Lemonldap::NG::Handler::ApacheMP2::print;
*redirectFilter     = *Lemonldap::NG::Handler::ApacheMP2::redirectFilter;
*remote_ip          = *Lemonldap::NG::Handler::ApacheMP2::remote_ip;
*set_header_in      = *Lemonldap::NG::Handler::ApacheMP2::set_header_in;
*set_header_out     = *Lemonldap::NG::Handler::ApacheMP2::set_header_out;
*set_user           = *Lemonldap::NG::Handler::ApacheMP2::set_user;
*setPostParams      = *Lemonldap::NG::Handler::ApacheMP2::setPostParams;
*setServerSignature = *Lemonldap::NG::Handler::ApacheMP2::setServerSignature;
*thread_share       = *Lemonldap::NG::Handler::ApacheMP2::thread_share;
*unparsed_uri       = *Lemonldap::NG::Handler::ApacheMP2::unparsed_uri;
*unset_header_in    = *Lemonldap::NG::Handler::ApacheMP2::unset_header_in;
*uri                = *Lemonldap::NG::Handler::ApacheMP2::uri;
*uri_with_args      = *Lemonldap::NG::Handler::ApacheMP2::uri_with_args;
*unparsed_uri       = *Lemonldap::NG::Handler::ApacheMP2::unparsed_uri;

__PACKAGE__->init();

1;
