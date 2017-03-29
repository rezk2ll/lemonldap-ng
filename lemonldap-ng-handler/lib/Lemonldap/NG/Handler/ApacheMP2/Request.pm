package Lemonldap::NG::Handler::ApacheMP2::Request;

use strict;
use base 'Plack::Request';
use Plack::Util;
use URI;
use URI::Escape;

# Build Plack::Request (inspired from Plack::Handler::Apache2)
sub new {
    my ( $class, $r ) = @_;

    # Apache populates ENV:
    $r->subprocess_env;
    my $env = {
        %ENV,
        'psgi.version' => [ 1, 1 ],
        'psgi.url_scheme' => ( $ENV{HTTPS} || 'off' ) =~ /^(?:on|1)$/i
        ? 'https'
        : 'http',
        'psgi.input'             => $r,
        'psgi.errors'            => *STDERR,
        'psgi.multithread'       => Plack::Util::FALSE,
        'psgi.multiprocess'      => Plack::Util::TRUE,
        'psgi.run_once'          => Plack::Util::FALSE,
        'psgi.streaming'         => Plack::Util::TRUE,
        'psgi.nonblocking'       => Plack::Util::FALSE,
        'psgix.harakiri'         => Plack::Util::TRUE,
        'psgix.cleanup'          => Plack::Util::TRUE,
        'psgix.cleanup.handlers' => [],
        'psgi.r'                 => $r,
    };
    if ( defined( my $HTTP_AUTHORIZATION = $r->headers_in->{Authorization} ) ) {
        $env->{HTTP_AUTHORIZATION} = $HTTP_AUTHORIZATION;
    }
    my $uri = URI->new( "http://" . $r->hostname . $r->unparsed_uri );
    $env->{PATH_INFO} = uri_unescape( $uri->path );

    my $self = Plack::Request->new($env);
    bless $self, $class;
    return $self;
}

sub datas {
    my($self) = @_;
    return $self->{datas} ||= {};
}

1;
