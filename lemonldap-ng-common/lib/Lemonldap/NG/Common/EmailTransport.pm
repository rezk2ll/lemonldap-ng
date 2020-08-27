package Lemonldap::NG::Common::EmailTransport;

use Email::Sender::Transport::SMTP qw();

our $VERSION = '2.0.9';

sub new {
    my ( $class, $conf ) = @_;
    my $transport;
    return undef
      unless ( $conf->{SMTPServer} );
    if (    $conf->{SMTPTLS}
        and $Email::Sender::Transport::SMTP::VERSION < 1.300027 )
    {
        # Try to use Email::Sender::Transport::SMTPS
        eval { require Email::Sender::Transport::SMTPS; };

        # fall back to Email::Sender::Transport::SMTP if not available
        unless ($@) {
            $transport = Email::Sender::Transport::SMTPS->new(
                host => $conf->{SMTPServer},
                ( $conf->{SMTPPort} ? ( port => $conf->{SMTPPort} ) : () ),
                (
                    $conf->{SMTPAuthUser}
                    ? (
                        sasl_username => $conf->{SMTPAuthUser},
                        sasl_password => $conf->{SMTPAuthPass}
                      )
                    : ()
                ),
                ssl => $conf->{SMTPTLS},
            );
            return $transport;
        }
    }
    $transport = Email::Sender::Transport::SMTP->new(
        host => $conf->{SMTPServer},
        ( $conf->{SMTPPort} ? ( port => $conf->{SMTPPort} ) : () ),
        (
            $conf->{SMTPAuthUser}
            ? (
                sasl_username => $conf->{SMTPAuthUser},
                sasl_password => $conf->{SMTPAuthPass}
              )
            : ()
        ),
        ( $conf->{SMTPTLS} ? ( ssl => $conf->{SMTPTLS} ) : () ),
        (
            $conf->{SMTPTLSOpts} ? ( ssl_options => $conf->{SMTPTLSOpts} )
            : ()
        ),
    );
    return $transport;
}

1;
