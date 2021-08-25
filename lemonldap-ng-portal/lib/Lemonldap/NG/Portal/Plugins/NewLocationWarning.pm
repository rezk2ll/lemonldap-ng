package Lemonldap::NG::Portal::Plugins::NewLocationWarning;

use strict;
use Mouse;
use POSIX qw(strftime);
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

our $VERSION = '2.0.14';

extends qw(
  Lemonldap::NG::Portal::Lib::SMTP
  Lemonldap::NG::Portal::Main::Plugin
);

# Entrypoint
use constant aroundSub => { storeHistory => 'check' };

sub init {
    my ($self) = @_;

    if ( $self->conf->{disablePersistentStorage} ) {
        $self->logger->error(
'"NewLocationWarning" plugin enabled WITHOUT persistent session storage"'
        );
        return 0;
    }
    unless ( $self->conf->{loginHistoryEnabled} ) {
        $self->logger->error(
            '"NewLocationWarning" plugin enabled WITHOUT "History" plugin');
        return 0;
    }
    return 1;
}

sub check {
    my ( $self, $sub, $req ) = @_;
    my $successLogin = $req->sessionInfo->{_loginHistory}->{successLogin};
    my $failedLogin  = $req->sessionInfo->{_loginHistory}->{failedLogin};
    my $sourceIP     = $req->env->{ipAddr};
    $self->logger->debug("Source IP: $sourceIP");

    my %knownIPs = map { $_->{ipAddr} => 1 } ( @$successLogin, @$failedLogin );

    if ( $knownIPs{$sourceIP} ) {
        $self->logger->debug('Known location');
        return $sub->($req);
    }
    else {
        $self->logger->warn("New location found: $sourceIP");
        $self->_sendMail($req);
        return $sub->($req);
    }
}

sub _sendMail {
    my ( $self, $req ) = @_;
    my $date     = strftime( '%F %X', localtime );
    my $sourceIP = $req->env->{ipAddr};
    my $host     = $req->env->{HTTP_HOST};
    my $ua       = $req->env->{HTTP_USER_AGENT};
    my $mail =
      $req->sessionInfo->{ $self->conf->{newLocationWarningMailAttribute}
          || 'mail' };

    # Build mail content
    my $tr      = $self->translate($req);
    my $subject = $self->conf->{newLocationWarningMailSubject};
    unless ($subject) {
        $self->logger->debug('Use default warning subject');
        $subject = 'newLocationWarningMailSubject';
        $tr->( \$subject );
    }
    my ( $body, $html );
    if ( $self->conf->{newLocationWarningMailBody} ) {

        # We use a specific text message, no html
        $self->logger->debug('Use specific warning body message');
        $body = $self->conf->{newLocationWarningMailBody};

        # Replace variables in body
        $body =~ s/\$newLocationUserAgent/$ua/ge;
        $body =~ s/\$newLocationIP/$sourceIP/ge;
        $body =~ s/\$newLocationDate/$date/ge;
        $body =~ s/\$newLocationHost/$host/ge;
    }
    else {

        # Use HTML template
        $body = $self->loadMailTemplate(
            $req,
            'mail_new_location_warning',
            filter => $tr,
            params => {
                session_ipAddr => $sourceIP,
                date           => $date,
                host           => $host,
                ua             => $ua
            },
        );
        $html = 1;
    }
    if ( $mail && $subject && $body ) {
        $self->logger->warn("User $mail is signing in from a new location");

        # Send mail
        $self->logger->debug('Unable to send new location warning mail')
          unless ( $self->send_mail( $mail, $subject, $body, $html ) );
    }
    else {
        $self->logger->error(
            'Unable to send new location warning mail: missing parameter(s)');
    }
    return PE_OK;
}

1;
