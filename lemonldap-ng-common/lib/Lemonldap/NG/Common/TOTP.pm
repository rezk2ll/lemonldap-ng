package Lemonldap::NG::Common::TOTP;

# This module is inspired by Auth::GoogleAuth written by Gryphon Shafer
# <gryphon@cpan.org>

use strict;
use Mouse;
use Convert::Base32 'decode_base32';
use Digest::HMAC_SHA1 'hmac_sha1_hex';

our $VERSION = '2.0.0';

# Verify that TOTP $code match with $secret
sub verifyCode {
    my ( $self, $interval, $range, $digits, $secret, $code ) = @_;
    my $s = eval { decode_base32($secret) };
    if ($@) {
        $self->logger->error('Bad characters in TOTP secret');
        return -1;
    }
    for ( 0 .. $range ) {
        if ( $code eq $self->_code( $s, $_, $interval, $digits ) ) {
            return 1;
        }
    }
    return 0;
}

# Internal subroutine that calculates TOTP code using $secret and $interval
sub _code {
    my ( $self, $secret, $r, $interval, $digits ) = @_;
    $digits ||= 6;
    my $hmac = hmac_sha1_hex(
        pack( 'H*',
            sprintf( '%016x', int( ( time + $r * $interval ) / $interval ) ) ),
        $secret,
    );

    return sprintf(
        '%0' . $digits . 'd',
        (
            hex( substr( $hmac, hex( substr( $hmac, -1 ) ) * 2, 8 ) ) &
              0x7fffffff
        ) % 1000000
    );
}

# Simply generate new base32 secret
sub newSecret {
    my ($self) = @_;
    my @chars = ( 'a' .. 'z', 2 .. 7 );
    return join( '', @chars[ map { int( rand(32) ) } 1 .. 32 ] );
}

1;
