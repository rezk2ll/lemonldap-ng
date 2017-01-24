package Lemonldap::NG::Portal::Lib::Captcha;

use strict;
use GD::SecurityImage use_magick => 1;
use Mouse;
use MIME::Base64;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Common::Module';

has width =>
  ( is => 'rw', default => sub { $_[0]->{conf}->{captchaWidth} || 220 } );
has height =>
  ( is => 'rw', default => sub { $_[0]->{conf}->{captchaHeight} || 40 } );
has lines =>
  ( is => 'rw', default => sub { $_[0]->{conf}->{captchaLines} || 5 } );
has scramble =>
  ( is => 'rw', default => sub { $_[0]->{conf}->{captchaScramble} || 1 } );

has fgColor =>
  ( is => 'rw', default => sub { $_[0]->{conf}->{captchaFg} || '#403030' } );

has bgColor =>
  ( is => 'rw', default => sub { $_[0]->{conf}->{captchaBg} || '#FF644B' } );

# Returns secret + a HTML <img> tag with embedded image
sub getCaptcha {
    my ($self) = @_;
    my $image = GD::SecurityImage->new(
        width    => $self->width,
        heigth   => $self->heigth,
        lines    => $self->lines,
        gd_font  => 'Giant',
        scramble => $self->scramble,
    );
    $image->random;
    $image->create( 'normal', 'default', $self->fgColor, $self->bgColor );
    my ( $imageData, $mimeType, $rdm ) = $image->out( force => 'png' );
    my $img = '<img src="data:image/png;base64,'
      . encode_base64( $imageData, '' ) . '">';
    return ( $rdm, $img );
}

1;
