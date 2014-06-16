package Lemonldap::NG::Handler::Main::Headers;

use strict;

use Lemonldap::NG::Handler::API qw( :httpCodes );    # for importing MP function
use Lemonldap::NG::Handler::Main::Logger;

our $VERSION = '1.4.0';


## @rmethod void sendHeaders()
# Launch function compiled by forgeHeadersInit() for the current virtual host
sub sendHeaders {
    my ( $class, $apacheRequest, $forgeHeaders ) = splice @_;
    my $vhost = Lemonldap::NG::Handler::API->hostname($apacheRequest);
    if ( defined( $forgeHeaders->{$vhost} ) ) {
        Lemonldap::NG::Handler::API->set_header_in( $apacheRequest,
            &{ $forgeHeaders->{$vhost} } );
    }
}

## @rmethod void cleanHeaders()
# Unset HTTP headers for the current virtual host, when sendHeaders is skipped
sub cleanHeaders {
    my ( $class, $apacheRequest, $forgeHeaders, $headerList ) = splice @_;
    my $vhost = Lemonldap::NG::Handler::API->hostname($apacheRequest);
    if ( defined( $forgeHeaders->{$vhost} ) ) {
        Lemonldap::NG::Handler::API->unset_header_in( $apacheRequest,
            @{ $headerList->{$vhost} } );
    }
}

1;
