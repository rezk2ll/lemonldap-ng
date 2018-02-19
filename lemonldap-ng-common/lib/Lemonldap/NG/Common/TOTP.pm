package Lemonldap::NG::Common::TOTP;

use strict;
use Mouse;
use Convert::Base32 'decode_base32';
use Digest::HMAC_SHA1 'hmac_sha1_hex';

our $VERSION = '2.0.0';

sub verifyCode {
    my ( $self, $interval, $range, $secret, $code ) = @_;
    my $s = eval { decode_base32($secret) };
    if ($@) {
        $self->logger->error('Bad characters in TOTP secret');
        return -1;
    }
    for ( 0 .. $range ) {
        if ( $code eq $self->_code( $s, $_, $interval ) ) {
            return 1;
        }
    }
    return 0;
}

sub _code {
    my ( $self, $secret, $r, $interval ) = @_;
    my $hmac = hmac_sha1_hex(
        pack( 'H*',
            sprintf( '%016x', int( ( time + $r * $interval ) / $interval ) ) ),
        $secret,
    );

    return sprintf(
        '%06d',
        (
            hex( substr( $hmac, hex( substr( $hmac, -1 ) ) * 2, 8 ) ) &
              0x7fffffff
        ) % 1000000
    );
}

1;
