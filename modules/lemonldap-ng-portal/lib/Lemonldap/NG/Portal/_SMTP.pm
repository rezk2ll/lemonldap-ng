##@file
# SMTP common functions

##@class
# SMTP common functions
package Lemonldap::NG::Portal::_SMTP;

use strict;
use String::Random;
use MIME::Lite;

our $VERSION = '0.1';

## @method string gen_password()
# Generate a complex password based on a regular expression
# @param regexp regular expression
# @return complex password
sub gen_password {
    my $self = shift;
    my $regexp = shift;

    my $random = new String::Random;
    return $random->randregex( $regexp );
}

## @method int test_mail()
# @return boolean result
sub test_mail {
    my $self = shift;

    # TODO check that a mail can be sent
}

## @method int send_password()
# Send password by mail
# @param password password
# @param mail mail
# @return boolean result
sub send_password {
    my $self = shift;
    my $password = shift;
    my $mail = shift;

    $self->{mailBody} =~ s/\$password/$password/g;
    $self->{mailBody} =~ s/\$(\w+)/$self->{sessionInfo}->{$1}/g;
    $self->lmLog( "SMTP From " . $self->{mailFrom},       'debug' );
    $self->lmLog( "SMTP To " . $mail,                     'debug' );
    $self->lmLog( "SMTP Subject " . $self->{mailSubject}, 'debug' );
    $self->lmLog( "SMTP Body " . $self->{mailBody},       'debug' );
    eval {
        my $message = MIME::Lite->new(
            From    => $self->{mailFrom},
            To      => $mail,
            Subject => $self->{mailSubject},
            Type    => "TEXT",
            Data    => $self->{mailBody},
        );
        $self->{SMTPServer}
          ? $message->send( "smtp", $self->{SMTPServer} )
          : $message->send();
    };
    if ($@) {
        $self->lmLog( "Send message failed: $@", 'error' );
        return 0;
    }

    return 1;
}

1;
