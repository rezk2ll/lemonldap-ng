package Lemonldap::NG::Portal::Captcha::SecurityImage;

use strict;
use Mouse;
use MIME::Base64;
use GD;

our $VERSION = '2.0.15';

extends 'Lemonldap::NG::Portal::Main::Plugin';

has width => (
    is      => 'rw',
    lazy    => 1,
    default => sub { $_[0]->{conf}->{captchaWidth} || 220 }
);
has height => (
    is      => 'rw',
    lazy    => 1,
    default => sub { $_[0]->{conf}->{captchaHeight} || 60 }
);
has lines => (
    is      => 'rw',
    lazy    => 1,
    default => sub { $_[0]->{conf}->{captchaLines} || 4 }
);
has scramble => (
    is      => 'rw',
    lazy    => 1,
    default => sub { $_[0]->{conf}->{captchaScramble} || 1 }
);
has fgColor => (
    is      => 'rw',
    lazy    => 1,
    default => sub { $_[0]->{conf}->{captchaFg} || '#403030' }
);
has bgColor => (
    is      => 'rw',
    lazy    => 1,
    default => sub { $_[0]->{conf}->{captchaBg} || '#FF644B' }
);
has rndmax => (
    is      => 'rw',
    lazy    => 1,
    default => sub { $_[0]->{conf}->{captcha_size} || 6 }
);
has timeout => (
    is      => 'rw',
    lazy    => 1,
    default => sub { $_[0]->{conf}->{formTimeout} }
);

has ott => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott = $_[0]->{p}->loadModule('::Lib::OneTimeToken');
        $ott->timeout( $_[0]->timeout );
        return $ott;
    }
);

sub init {
    my ($self) = @_;
    $self->addUnauthRoute( renewcaptcha => '_sendCaptcha', ['GET'] );
    return 1;
}

# Internal methods
sub _getCaptcha {
    my ($self) = @_;

    # Random numeric challenge (same charset as the historical default)
    my $rdm = join '', map { int rand 10 } 1 .. $self->rndmax;

    my $imageData = $self->_render($rdm);
    my $img       = 'data:image/png;base64,' . encode_base64( $imageData, '' );
    my $token     = $self->ott->createToken( { captcha => $rdm } );
    return ( $token, $img );
}

# Convert a '#RRGGBB' string to an (R, G, B) triplet, or fall back to @default
sub _hex2rgb {
    my ( $self, $hex, @default ) = @_;
    return ( hex $1, hex $2, hex $3 )
      if $hex
      and $hex =~ /^#?([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$/;
    return @default;
}

# Render the challenge string as a PNG using GD only (no GD::SecurityImage)
sub _render {
    my ( $self, $string ) = @_;
    my $w        = $self->width;
    my $h        = $self->height;
    my $scramble = $self->scramble;
    my @bg       = $self->_hex2rgb( $self->bgColor, 0xFF, 0x64, 0x4B );
    my @fg       = $self->_hex2rgb( $self->fgColor, 0x40, 0x30, 0x30 );

    my $image = GD::Image->new( $w, $h, 1 );
    $image->filledRectangle( 0, 0, $w - 1, $h - 1, $image->colorAllocate(@bg) );

    my $font = GD::gdGiantFont();
    my ( $fw, $fh ) = ( $font->width, $font->height );
    my $n  = length $string;
    my $cw = int( $w / ( $n + 1 ) );
    my $x0 = int( ( $w - $cw * $n ) / 2 );

    for my $i ( 0 .. $n - 1 ) {
        my $char = substr $string, $i, 1;

        # Draw the digit on a small buffer, slightly emboldened
        my $glyph = GD::Image->new( $fw, $fh, 1 );
        $glyph->filledRectangle( 0, 0, $fw - 1, $fh - 1,
            $glyph->colorAllocate(@bg) );
        my $fgcol = $glyph->colorAllocate(@fg);
        $glyph->string( $font, 0, 0, $char, $fgcol );
        $glyph->string( $font, 1, 0, $char, $fgcol );

        # Scale the digit, centered, into a full-height cell tile whose
        # background matches the canvas so it can be rotated seamlessly
        my $tile = GD::Image->new( $cw, $h, 1 );
        $tile->filledRectangle( 0, 0, $cw - 1, $h - 1,
            $tile->colorAllocate(@bg) );
        my $dh = int( $h * 0.6 ) + ( $scramble ? int( rand $h * 0.2 ) : 0 );
        my $dw = int( $cw * 0.85 );
        $tile->copyResampled(
            $glyph, int( ( $cw - $dw ) / 2 ),
            int( ( $h - $dh ) / 2 ),
            0, 0, $dw, $dh, $fw, $fh
        );

        # Place it, rotated and vertically jittered when scrambling
        my $angle = $scramble ? int( rand 81 ) - 40 : 0;
        my $cx    = $x0 + $cw * $i + int( $cw / 2 );
        my $cy    = int( $h / 2 ) +
          ( $scramble ? int( rand $h * 0.2 ) - int( $h * 0.1 ) : 0 );
        $image->copyRotated( $tile, $cx, $cy, 0, 0, $cw, $h, $angle );
    }

    # Speckle noise
    for ( 1 .. int( $w * $h * 0.04 ) ) {
        my @c =
          rand() < 0.5
          ? map { $_ - 20 + int rand 40 } @fg
          : map { $_ - 20 + int rand 40 } @bg;
        $image->setPixel( int( rand $w ), int( rand $h ),
            $image->colorAllocate(@c) );
    }

    # Noise lines, mixing darker and lighter tones, over the glyphs
    for ( 1 .. $self->lines * 2 ) {
        my @c =
          rand() < 0.5
          ? map { $_ - 30 + int rand 40 } @fg
          : map { $_ + int rand 40 } @bg;
        $image->setThickness(1);
        $image->line(
            int( rand $w ), int( rand $h ),
            int( rand $w ), int( rand $h ),
            $image->colorAllocate(@c)
        );
    }

    return $image->png;
}

sub _sendCaptcha {
    my ( $self, $req ) = @_;
    $self->logger->info("User request for captcha renew");
    my ( $token, $image ) = $self->_getCaptcha($req);

    return $self->p->sendJSONresponse( $req,
        { newtoken => $token, newimage => $image } );
}

sub _validate_captcha_token {
    my ( $self, $token, $value ) = @_;
    my $s = $self->ott->getToken($token);
    unless ($s) {
        $self->logger->warn("Captcha token $token isn't valid");
        return 0;
    }
    unless ( $s->{captcha} eq $value ) {
        $self->logger->notice('Bad captcha response');
        return 0;
    }
    $self->logger->debug('Good captcha response');
    return 1;
}

sub _get_captcha_html {
    my ( $self, $req, $src ) = @_;

    my $sp = $self->p->staticPrefix;
    $sp =~ s/\/*$/\//;

    return $self->loadTemplate(
        $req,
        'captcha',
        params => {
            STATIC_PREFIX => $sp,
            CAPTCHA_SRC   => $src,
            CAPTCHA_SIZE  => $self->rndmax,
        }
    );
}

# New API
sub check_captcha {
    my ( $self, $req ) = @_;
    my $token = $req->param('token');
    unless ($token) {
        $self->logger->warn("No token provided for Captcha::SecurityImage");
        return 0;
    }

    my $value = $req->param('captcha');
    unless ($value) {
        $self->logger->warn("No response provided for Captcha::SecurityImage");
        return 0;
    }

    return $self->_validate_captcha_token( $token, $value );
}

sub init_captcha {
    my ( $self, $req ) = @_;

    my ( $token, $image ) = $self->_getCaptcha;
    $self->logger->debug('Prepare captcha');
    $req->token($token);
    $req->captchaHtml( $self->_get_captcha_html( $req, $image ) );

    # DEPRECATED: Compatibility with old templates
    $req->captcha($image);
}

# #######
# Old API
# TODO: Remove this in 3.0
# #######

sub validateCaptcha {
    my ( $self, $token, $value ) = @_;
    return $self->_validate_captcha_token( $token, $value );
}

sub setCaptcha {
    my ( $self, $req ) = @_;
    $self->init_captcha($req);
}

sub sendCaptcha {
    my ( $self, $req ) = @_;
    return $self->_sendCaptcha($req);
}

sub getCaptcha {
    my ( $self, $req ) = @_;
    return $self->_getCaptcha($req);
}

1;
