package Lemonldap::NG::Handler::PSGI::API::Server;

use strict;

use base 'Lemonldap::NG::Handler::PSGI::API';

# In server mode, headers are not passed to a PSGI application but returned
# to the server

## @method void set_header_in(hash headers)
# sets or modifies request headers
# @param headers hash containing header names => header value
sub set_header_in {
    my ( $class, %headers ) = @_;
    for my $k ( keys %headers ) {
        $Lemonldap::NG::Handler::PSGI::API::request->{ cgiName($k) } =
          $headers{$k};
    }
    push @{ $Lemonldap::NG::Handler::PSGI::API::request->{respHeaders} },
      %headers;
}

sub unset_header_in {
    my ( $class, $header ) = @_;
    $Lemonldap::NG::Handler::PSGI::API::request->{respHeaders} =
      [ grep { $_ ne $header }
          @{ $Lemonldap::NG::Handler::PSGI::API::request->{respHeaders} } ];
    $header =~ s/-/_/g;
    delete $Lemonldap::NG::Handler::PSGI::API::request->{ cgiName($header) };
}

# Inheritence is broken in this case with Debian >= jessie
*setServerSignature = *Lemonldap::NG::Handler::PSGI::API::setServerSignature;
*thread_share       = *Lemonldap::NG::Handler::PSGI::API::thread_share;
*newRequest         = *Lemonldap::NG::Handler::PSGI::API::newRequest;
*set_user           = *Lemonldap::NG::Handler::PSGI::API::set_user;
*header_in          = *Lemonldap::NG::Handler::PSGI::API::header_in;
*set_header_out     = *Lemonldap::NG::Handler::PSGI::API::set_header_out;
*hostname           = *Lemonldap::NG::Handler::PSGI::API::hostname;
*remote_ip          = *Lemonldap::NG::Handler::PSGI::API::remote_ip;
*is_initial_req     = *Lemonldap::NG::Handler::PSGI::API::is_initial_req;
*args               = *Lemonldap::NG::Handler::PSGI::API::args;
*uri                = *Lemonldap::NG::Handler::PSGI::API::uri;
*uri_with_args      = *Lemonldap::NG::Handler::PSGI::API::uri_with_args;
*unparsed_uri       = *Lemonldap::NG::Handler::PSGI::API::unparsed_uri;
*get_server_port    = *Lemonldap::NG::Handler::PSGI::API::get_server_port;
*method             = *Lemonldap::NG::Handler::PSGI::API::method;
*print              = *Lemonldap::NG::Handler::PSGI::API::print;
*cgiName            = *Lemonldap::NG::Handler::PSGI::API::cgiName;
*addToHtmlHead      = *Lemonldap::NG::Handler::PSGI::API::addToHtmlHead;
1;
