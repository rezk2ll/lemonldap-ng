package Lemonldap::NG::Common::PSGI::Request;

use strict;
use Mouse;
use JSON;
use URI::Escape;

our $VERSION = '2.0.0';

#       http          ://  server   / path      ? query      # fragment
# m|(?:([^:/?#]+):)?(?://([^/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?|;

has HTTP_ACCEPT          => ( is => 'ro', reader => 'accept' );
has HTTP_ACCEPT_ENCODING => ( is => 'ro', reader => 'encodings' );
has HTTP_ACCEPT_LANGUAGE => ( is => 'ro', reader => 'languages' );
has HTTP_COOKIE          => ( is => 'ro', reader => 'cookies' );
has HTTP_HOST            => ( is => 'ro', reader => 'hostname' );
has REMOTE_ADDR => ( is => 'ro', isa => 'Str', reader => 'remote_ip' );
has REMOTE_PORT    => ( is => 'ro', isa => 'Int', reader => 'port' );
has REQUEST_METHOD => ( is => 'ro', isa => 'Str', reader => 'method' );
has SCRIPT_NAME    => ( is => 'ro', isa => 'Str', reader => 'scriptname' );
has SERVER_PORT    => ( is => 'ro', isa => 'Int', reader => 'get_server_port' );
has PATH_INFO      => (
    is      => 'ro',
    reader  => 'path',
    lazy    => 1,
    default => '',
    trigger => sub {
        $_[0]->{REQUEST_URI} = uri_unescape( $_[0]->{REQUEST_URI} );
        $_[0]->{REQUEST_URI} =~ s|//+|/|;
    },
);
has REQUEST_URI => (
    is      => 'ro',
    reader  => 'uri',
    trigger => sub {
        $_[0]->{unparsed_uri} = $_[0]->{REQUEST_URI};
        $_[0]->{REQUEST_URI}  = uri_unescape( $_[0]->{REQUEST_URI} );
    },
);
has unparsed_uri => ( is => 'rw', isa => 'Str' );

has 'psgi.errors' => ( is => 'rw', reader => 'stderr' );

# Authentication

has REMOTE_USER => (
    is      => 'ro',
    reader  => 'user',
    trigger => sub {
        $_[0]->{userData} = { _whatToTrace => $_[0]->{REMOTE_USER}, };
    },
);
has userData => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

# Query parameters
has _params => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has QUERY_STRING => (
    is      => 'ro',
    reader  => 'query',
    trigger => sub {
        my $self = shift;
        $self->{QUERY_STRING} = uri_unescape( $self->{QUERY_STRING} );
        my @tmp =
          $self->{QUERY_STRING}
          ? split /&/, $self->{QUERY_STRING}
          : ();
        foreach my $s (@tmp) {
            if   ( $s =~ /^(.+?)=(.+)$/ ) { $self->{_params}->{$1} = $2; }
            else                          { $self->{_params}->{$s} = 1; }
        }
    },
);

sub params {
    my ( $self, $key, $value ) = splice @_;
    return $self->_params unless ($key);
    $self->_params->{$key} = $value if ($value);
    return $self->_params->{$key};
}

# POST management
#
# When CONTENT_LENGTH is set, store body in memory in `body` key
has 'psgix.input.buffered' => ( is => 'ro', reader => '_psgixBuffered', );
has 'psgi.input'           => ( is => 'ro', reader => '_psgiInput', );
has body                   => ( is => 'rw', isa    => 'Str', default => '' );
has CONTENT_TYPE => ( is => 'ro', isa => 'Str', reader => 'contentType', );
has CONTENT_LENGTH => (
    is      => 'ro',
    isa     => 'Int',
    reader  => 'contentLength',
    lazy    => 1,
    default => 0,
    trigger => sub {
        my $self = shift;
        if ( $self->method eq 'GET' ) { $self->{body} = undef; }
        elsif ( $self->method =~ /^(?:POST|PUT)$/ ) {
            $self->{body} = '';
            if ( $self->_psgixBuffered ) {
                my $length = $self->{CONTENT_LENGTH};
                while ( $length > 0 ) {
                    my $buffer;
                    $self->_psgiInput->read( $buffer,
                        ( $length < 8192 ) ? $length : 8192 );
                    $length -= length($buffer);
                    $self->{body} .= $buffer;
                }
            }
            else {
                $self->_psgiInput->read( $self->{body},
                    $self->{CONTENT_LENGTH}, 0 );
            }
        }
    }
);
has error => ( is => 'rw', isa => 'Str', default => '' );

# JSON parser
sub jsonBodyToObj {
    my $self = shift;
    unless ( $self->contentType =~ /application\/json/ ) {
        $self->error('Data is not JSON');
        return undef;
    }
    unless ( $self->body ) {
        $self->error('No data');
        return undef;
    }
    return $self->body if ( ref( $self->body ) );
    my $j = eval { decode_json( $self->body ) };
    if ( $@ or $! ) {
        $self->error("$@$!");
        return undef;
    }
    return $self->{body} = $j;
}

1;
