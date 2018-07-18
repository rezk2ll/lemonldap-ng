package Lemonldap::NG::Portal::CDC;

use strict;
use Mouse;
use MIME::Base64;
use Lemonldap::NG::Common::FormEncode;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# PROPERTIES

has cdc_name         => ( is => 'rw' );
has cdc_domain       => ( is => 'rw' );
has httpOnly         => ( is => 'rw' );
has cookieExpiration => ( is => 'rw' );
has oldStyleUrl      => ( is => 'rw' );
has cdc_values       => ( is => 'rw' );

# INITIALIZATION

sub init {
    my ($self) = @_;
    my $conf = $self->conf;
    $self->cdc_name( $conf->{samlCommonDomainCookieName} || '_saml_idp' );
    $self->cdc_domain( $conf->{samlCommonDomainCookieDomain} );
    $self->logger->debug( "[CDC] Cookie name: " . $self->cdc_name );
    $self->logger->debug( "[CDC] Domain name: "
          . ( $self->cdc_domain ? $self->cdc_domain : '<host name>' ) );

    foreach (qw(httpOnly cookieExpiration oldStyleUrl)) {
        $self->$_( $conf->{$_} );
    }
    $self->addAuthRoute( cdc => 'run' );
    $self->addUnauthRoute( cdc => 'run' );
    return 1;
}

sub run {
    my ( $self, $req ) = @_;
    my $cdc_idp    = "";

    # Default values
    my $cdc_domain = $self->cdc_domain || $req->hostname;

    # Request parameter
    my $action = $req->param('action') || "";    # What we do
    my $idp = $req->param('idp');                # IDP ID in write mode

    # TODO: Control URL
    #my $control_url = $self->_sub('controlUrlOrigin');
    #unless ( $control_url == PE_OK ) {
    #    $self->logger->error( "[CDC] Bad URL");
    #    return $control_url;
    #}

    # Get cookie
    my $cdc_cookie = $req->cookies->{ $self->cdc_name } // '';

    if ($cdc_cookie) {
        $self->logger->debug("[CDC] Cookie found with value $cdc_cookie");
    }

    # Write request
    # Called in an iFrame
    # Get or build common domain cookie
    # Append IDP to common domain cookie
    if ( $action eq 'write' ) {

        $self->logger->debug("[CDC] Write request detected");

        # Check IDP value
        unless ($idp) {
            return $self->sendError( $req, "[CDC] No IDP given", 400 );
        }

        # Add IDP value
        $self->logger->debug("[CDC] Will add IDP $idp to IDP list");

        my $encoded_idp = encode_base64( $idp, '' );

        # Remove IDP value if already present
        $cdc_cookie =~ s/$encoded_idp(\s+)?//g;

        # Add a space separator
        $cdc_cookie .= ( $cdc_cookie ? " " : "" );
        $cdc_cookie .= $encoded_idp;

        $self->logger->debug(
            "[CDC] Build cookie $self->{cdc_name} with value $cdc_cookie");

        # Build cookie
        $req->addCookie(
            $self->p->cookie(
                name   => $self->cdc_name,
                value  => $cdc_cookie,
                domain => $cdc_domain,
                secure => 1
            )
        );
    }

    # Read request
    # Get last IDP from domain cookie
    # Return on SP with idp as parameter

    elsif ( $action eq 'read' ) {

        $self->logger->debug("[CDC] Read request detected");

        # Get last IDP from cookie
        if ($cdc_cookie) {
            $cdc_idp = decode_base64( ( split /\s+/, $cdc_cookie )[-1] );
            $self->logger->debug("[CDC] Get value $cdc_idp");
        }
        else {
            $self->logger->debug("[CDC] No cookie, set a default value");
            $cdc_idp = 'notfound';
        }
    }

    # Redirect if needed
    if ( my $url = $req->param('url') ) {

        # Decode URL
        if ( $url =~ m#[^A-Za-z0-9\+/=]# ) {
            return $self->sendError( $req, "Bad URL", 400 );
        }
        my $urldc = decode_base64($url);

        # Add CDC IDP in return URL if needed
        # olStyleUrl can be set to 1 to use & instead of ;
        $urldc .= (
            $cdc_idp
            ? (
                (
                    $urldc =~ /\?/
                    ? ( $self->{oldStyleUrl} ? '&' : ';' )
                    : '?'
                )
                . build_urlencoded( idp => $cdc_idp )
              )
            : ''
        );

        # Redirect
        return [ 302, [ Location => $urldc, @{ $req->respHeaders } ], [] ];

    }

    if ($cdc_cookie) {

        # Parse cookie to display it if not redirected
        my @cdc_values =
          map( decode_base64($_), ( split( /\s+/, $cdc_cookie ) ) );
        $self->{cdc_values} = \@cdc_values;
    }

    return [
        200,
        [
            'Content-Type'   => 'text/plain',
            'Content-Length' => 2,
            @{ $req->respHeaders }
        ],
        ['OK']
    ];

}

1;
