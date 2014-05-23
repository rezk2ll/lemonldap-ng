package Lemonldap::NG::Handler::Main::Headers;

use strict;

use Lemonldap::NG::Handler::Main qw( :apache );    # for importing MP function
use Lemonldap::NG::Handler::Main::Logger;

our $VERSION = '1.4.0';

BEGIN {

    if ( MP() == 2 ) {
        require Apache2::Log;
        require Apache2::RequestUtil;
        Apache2::RequestUtil->import();
        require Apache2::RequestRec;
        Apache2::RequestRec->import();
        require Apache2::ServerUtil;
        Apache2::ServerUtil->import();
        require Apache2::Connection;
        Apache2::Connection->import();
        require Apache2::RequestIO;
        Apache2::RequestIO->import();
        require APR::Table;
        APR::Table->import();
        require Apache2::URI;
        Apache2::URI->import();
        require Apache2::Const;
        Apache2::Const->import( '-compile', qw(:common :log) );
    }
    elsif ( MP() == 1 ) {
        require Apache;
        require Apache::Log;
        require Apache::Constants;
        Apache::Constants->import(':common');
        Apache::Constants->import(':response');
    }

}

## @rmethod void sendHeaders()
# Launch function compiled by forgeHeadersInit() for the current virtual host
sub sendHeaders {
    my ( $class, $apacheRequest, $forgeHeaders ) = splice @_;
    my $vhost = $apacheRequest->hostname;
    if ( defined( $forgeHeaders->{$vhost} ) ) {
        Lemonldap::NG::Handler::API->set_header_in( $apacheRequest, &{ $forgeHeaders->{$vhost} } );
    }
}

## @rmethod void cleanHeaders()
# Unset HTTP headers for the current virtual host, when sendHeaders is skipped
sub cleanHeaders {
    my ( $class, $apacheRequest, $forgeHeaders, $headerList ) = splice @_;
    my $vhost = $apacheRequest->hostname;
    if ( defined( $forgeHeaders->{$vhost} ) ) {
        Lemonldap::NG::Handler::API->unset_header_in( $apacheRequest, @{ $headerList->{$vhost} } );
    }
}

1;
