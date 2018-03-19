#!/usr/bin/perl -w

use Authen::OATH;
use Convert::Base32 qw( decode_base32 );

unless ( $ARGV[0] ) {
    print STDERR "Usage $0 <totp-secret>\n";
    exit 1;
}

my $oath = Authen::OATH->new();
my $totp = $oath->totp( decode_base32( $ARGV[0] ) );

print "$totp\n";

1;
