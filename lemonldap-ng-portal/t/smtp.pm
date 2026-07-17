package main;

my ( $mail, $mail_envelope, $mail_subject, $mime );

sub mime {
    return $mime;
}

sub mail {
    return $mail;
}

sub clear_mail {
    $mail          = undef;
    $mail_envelope = undef;
    $mail_subject  = undef;
}

sub envelope {
    return $mail_envelope;
}

sub subject {
    my $subject = ( $mail_subject =~ /=\?utf-8\?B\?(.+?)\?=/ )[0];
    return decode_base64($subject);
}

package Email::Sender::Transport::LLNG::Test;

use Mouse;
use Encode;
use Lemonldap::NG::Portal::Lib::SMTP;
$Lemonldap::NG::Portal::Lib::SMTP::transport = __PACKAGE__->new();

extends 'Email::Sender::Transport';

sub send_email {
    my ( $self, $email, $envelope ) = @_;
    $mime          = $email->cast('MIME::Entity');
    $mail          = decode( 'UTF-8', $email->get_body );
    $mail_subject  = decode( 'UTF-8', $email->get_header("Subject") );
    $mail_envelope = $envelope;
    return $self->success;
}

1;
