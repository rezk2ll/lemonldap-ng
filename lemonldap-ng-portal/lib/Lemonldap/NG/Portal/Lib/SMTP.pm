##@file
# SMTP common functions

##@class
# SMTP common functions
package Lemonldap::NG::Portal::Lib::SMTP;

use strict;
use Mouse;
use String::Random;
use MIME::Lite;
use MIME::Base64;
use Encode;

our $VERSION = '2.0.0';

# PROPERTIES

has random => (
    is      => 'rw',
    default => sub {
        return String::Random->new;
    }
);
has charset => (
    is      => 'rw',
    default => sub { return $_[0]->{conf}->{mailCharset} || 'utf-8' }
);

# Generate a complex password based on a regular expression
# @param regexp regular expression
sub gen_password {
    my ( $self, $regexp ) = @_;
    return $self->random->randregex($regexp);
}

# Send mail
# @param mail recipient address
# @param subject mail subject
# @param body mail body
# @param html optional set content type to HTML
# @return boolean result
sub send_mail {
    my ( $self, $mail, $subject, $body, $html ) = @_;
    $self->lmLog( "send_mail called to send \"$subject\" to $mail", 'debug' );

    # Encode the body with the given charset
    $body    = encode( $self->charset, $body );
    $subject = encode( $self->charset, $subject );

    # Debug messages
    $self->lmLog( "SMTP From " . $self->conf->{mailFrom}, 'debug' );
    $self->lmLog( "SMTP To " . $mail,                     'debug' );
    $self->lmLog( "SMTP Subject " . $subject,             'debug' );
    $self->lmLog( "SMTP Body " . $body,                   'debug' );
    $self->lmLog( "SMTP HTML flag " . ( $html ? "on" : "off" ), 'debug' );
    $self->lmLog( "SMTP Reply-To " . $self->conf->{mailReplyTo}, 'debug' )
      if $self->conf->{mailReplyTo};

    # Encode the subject
    $subject = encode_base64( $subject, '' );
    $subject =~ s/\s//gs;
    $subject = '=?' . $self->charset . "?B?$subject?=";

    # Detect included images (cid)
    my %cid = ( $body =~ m/"cid:([^:]+):([^"]+)"/g );

    # Replace cid in body
    $body =~ s/"cid:([^:]+):([^"]+)"/"cid:$1"/g;

    eval {

        # Create message
        my $message;

        # HTML case
        if ($html) {
            $message = MIME::Lite->new(
                From => $self->conf->{mailFrom},
                To   => $mail,
                (
                    $self->conf->{mailReplyTo}
                    ? ( "Reply-To" => $self->conf->{mailReplyTo} )
                    : ()
                ),
                Subject => $subject,
                Type    => 'multipart/related',
            );

            # Attach HTML message
            $message->attach(
                Type => 'text/html; charset=' . $self->charset,
                Data => qq{$body},
            );

            # Attach included images
            foreach ( keys %cid ) {
                $message->attach(
                    Type => "image/" . ( $cid{$_} =~ m/\.(\w+)/ )[0],
                    Id => $_,
                    Path => $self->p->{templateDir} . "/" . $cid{$_},
                );
            }
        }

        # Plain text case
        else {
            $message = MIME::Lite->new(
                From       => $self->conf->{mailFrom},
                To         => $mail,
                "Reply-To" => $self->conf->{mailReplyTo},
                Subject    => $subject,
                Type       => 'TEXT',
                Data       => $body,
            );

            # Manage content type and charset
            $message->attr( "content-type"         => "text/plain" );
            $message->attr( "content-type.charset" => $self->charset );

        }

        # Send the mail
        $self->conf->{SMTPServer}
          ? $message->send(
            "smtp", $self->conf->{SMTPServer},
            AuthUser => $self->conf->{SMTPAuthUser},
            AuthPass => $self->conf->{SMTPAuthPass}
          )
          : $message->send();
    };
    if ($@) {
        $self->lmLog( "Send message failed: $@", 'error' );
        return 0;
    }

    return 1;
}

## @method string getMailSession(string user)
# Check if a mail session exists
# @param user the value of the user key in session
# @return the first session id found or nothing if no session
sub getMailSession {
    my ( $self, $user ) = @_;

    my $moduleOptions = $self->conf->{globalStorageOptions} || {};
    $moduleOptions->{backend} = $self->conf->{globalStorage};
    my $module = "Lemonldap::NG::Common::Apache::Session";

    # Search on mail sessions
    my $sessions = $module->searchOn( $moduleOptions, "user", $user );

    # Browse found sessions to check if it's a mail session
    foreach my $id ( keys %$sessions ) {
        my $mailSession = $self->p->getApacheSession($id);
        next unless ($mailSession);
        return $mailSession if ( $mailSession->data->{_type} =~ /^mail$/ );
    }

    # No mail session found, return empty string
    return "";
}

## @method string getRegisterSession(string mail)
# Check if a register session exists
# @param mail the value of the mail key in session
# @return the first session id found or nothing if no session
sub getRegisterSession {
    my ( $self, $mail ) = @_;

    my $moduleOptions = $self->conf->{globalStorageOptions} || {};
    $moduleOptions->{backend} = $self->conf->{globalStorage};
    my $module = "Lemonldap::NG::Common::Apache::Session";

    # Search on register sessions
    my $sessions = $module->searchOn( $moduleOptions, "mail", $mail );

    # Browse found sessions to check if it's a register session
    foreach my $id ( keys %$sessions ) {
        my $registerSession = $self->p->getApacheSession($id);
        next unless ($registerSession);
        return $id if ( $registerSession->data->{_type} =~ /^register$/ );
    }

    # No register session found, return empty string
    return "";
}

1;
