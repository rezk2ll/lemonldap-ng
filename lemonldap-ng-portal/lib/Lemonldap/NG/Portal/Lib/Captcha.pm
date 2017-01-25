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
has rndmax =>
  ( is => 'rw', default => sub { $_[0]->{conf}->{captcha_size} || 6 } );
has timeout => ( is => 'rw', default => sub { $_[0]->{conf}->{formTimeout} } );

has ott => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott = Lemonldap::NG::Portal::Lib::OneTimeToken->new(
            { timeout => $_[0]->timeout } );
        return $ott;
    }
);

# Returns secret + a HTML image src content
sub getCaptcha {
    my ($self) = @_;
    my $image = GD::SecurityImage->new(
        width    => $self->width,
        heigth   => $self->heigth,
        lines    => $self->lines,
        gd_font  => 'Giant',
        scramble => $self->scramble,
        rndmax   => $self->rndmax,
    );
    $image->random;
    $image->create( 'normal', 'default', $self->fgColor, $self->bgColor );
    my ( $imageData, $mimeType, $rdm ) = $image->out( force => 'png' );
    my $img = 'data:image/png;base64,' . encode_base64( $imageData, '' );
    my $token = $self->ott->createToken( { captcha => $rdm } );
    return ( $token, $img );
}

sub validateCaptcha {
    my ( $self, $token, $value ) = @_;
    my $s = $self->ott->getToken($token);
    unless ($s) {
        $self->lmLog( "Captcha token $token isn't valid", 'warn' );
        return 0;
    }
    unless ( $s->{captcha} == $value ) {
        $self->lmLog( 'Bad captcha response', 'notice' );
        return 0;
    }
    $self->lmLog( 'Good captcha response', 'debug' );
    return 1;
}

1;
