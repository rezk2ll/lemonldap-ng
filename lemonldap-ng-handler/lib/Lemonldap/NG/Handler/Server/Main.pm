package Lemonldap::NG::Handler::Server::Main;

use strict;

use base 'Lemonldap::NG::Handler::PSGI::Main';

use constant defaultLogger => 'Lemonldap::NG::Common::Logger::Syslog';

# In server mode, headers are not passed to a PSGI application but returned
# to the server

## @method void set_header_in(hash headers)
# sets or modifies request headers
# @param headers hash containing header names => header value
sub set_header_in {
    my ( $class, %headers ) = @_;
    for my $k ( keys %headers ) {
        $Lemonldap::NG::Handler::PSGI::Main::request->{ cgiName($k) } =
          $headers{$k};
    }
    push @{ $Lemonldap::NG::Handler::PSGI::Main::request->{respHeaders} },
      %headers;
}

sub unset_header_in {
    my ( $class, $header ) = @_;
    $Lemonldap::NG::Handler::PSGI::Main::request->{respHeaders} =
      [ grep { $_ ne $header }
          @{ $Lemonldap::NG::Handler::PSGI::Main::request->{respHeaders} } ];
    $header =~ s/-/_/g;
    delete $Lemonldap::NG::Handler::PSGI::Main::request->{ cgiName($header) };
}

# Inheritence is broken in this case with Debian >= jessie
*checkType          = *Lemonldap::NG::Handler::PSGI::Main::checkType;
*setServerSignature = *Lemonldap::NG::Handler::PSGI::Main::setServerSignature;
*thread_share       = *Lemonldap::NG::Handler::PSGI::Main::thread_share;
*newRequest         = *Lemonldap::NG::Handler::PSGI::Main::newRequest;
*set_user           = *Lemonldap::NG::Handler::PSGI::Main::set_user;
*header_in          = *Lemonldap::NG::Handler::PSGI::Main::header_in;
*set_header_out     = *Lemonldap::NG::Handler::PSGI::Main::set_header_out;
*hostname           = *Lemonldap::NG::Handler::PSGI::Main::hostname;
*remote_ip          = *Lemonldap::NG::Handler::PSGI::Main::remote_ip;
*is_initial_req     = *Lemonldap::NG::Handler::PSGI::Main::is_initial_req;
*args               = *Lemonldap::NG::Handler::PSGI::Main::args;
*uri                = *Lemonldap::NG::Handler::PSGI::Main::uri;
*uri_with_args      = *Lemonldap::NG::Handler::PSGI::Main::uri_with_args;
*unparsed_uri       = *Lemonldap::NG::Handler::PSGI::Main::unparsed_uri;
*get_server_port    = *Lemonldap::NG::Handler::PSGI::Main::get_server_port;
*method             = *Lemonldap::NG::Handler::PSGI::Main::method;
*print              = *Lemonldap::NG::Handler::PSGI::Main::print;
*cgiName            = *Lemonldap::NG::Handler::PSGI::Main::cgiName;
*addToHtmlHead      = *Lemonldap::NG::Handler::PSGI::Main::addToHtmlHead;
1;
