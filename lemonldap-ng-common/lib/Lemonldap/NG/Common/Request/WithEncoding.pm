# Based on Plack::Request::WithEncoding

package Lemonldap::NG::Common::Request::WithEncoding;
use strict;
use warnings;
use parent qw/Plack::Request/;
use Encode ();
use Carp   ();
use Hash::MultiValue;

use constant KEY_BASE_NAME => 'plack.request.withencoding';

sub body_parameters {
    my $self = shift;
    $self->env->{ KEY_BASE_NAME . '.body' } ||=
      $self->_decode_parameters( $self->SUPER::body_parameters );
}

sub query_parameters {
    my $self = shift;
    $self->env->{ KEY_BASE_NAME . '.query' } ||=
      $self->_decode_parameters( $self->SUPER::query_parameters );
}

sub parameters {
    my $self = shift;
    $self->env->{ KEY_BASE_NAME . '.merged' } ||= do {
        my $query = $self->query_parameters;
        my $body  = $self->body_parameters;
        Hash::MultiValue->new( $query->flatten, $body->flatten );
    }
}

sub _decode_parameters {
    my ( $self, $stuff ) = @_;

    my $unicode = Encode::find_encoding('UTF-8');

    my @flatten = $stuff->flatten;
    my @decoded;
    while ( my ( $k, $v ) = splice @flatten, 0, 2 ) {
        push @decoded, $unicode->decode($k), $unicode->decode($v);
    }
    return Hash::MultiValue->new(@decoded);
}

1;
