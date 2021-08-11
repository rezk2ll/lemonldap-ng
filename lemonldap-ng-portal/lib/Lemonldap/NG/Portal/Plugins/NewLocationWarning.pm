package Lemonldap::NG::Portal::Plugins::NewLocationWarning;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_ERROR
);

our $VERSION = '2.0.13';

extends qw(
  Lemonldap::NG::Portal::Lib::SMTP
  Lemonldap::NG::Portal::Main::Plugin
);

# Entrypoint
use constant endAuth => 'check';

sub init {
    my ($self) = @_;

    return 1;
}

sub check {
    my ( $self, $req ) = @_;
    use Data::Dumper;
    my $successLogin = $req->sessionInfo->{_loginHistory}->{successLogin};
    my $failedLogin  = $req->sessionInfo->{_loginHistory}->{failedLogin};
    my $ipSource     = $req->env->{ipAddr};
   
    my @IPsS =
      map { $_->{ipAddr} eq $ipSource ? $_->{ipAddr} : () } @$successLogin;
    my @IPsF =
      map { $_->{ipAddr} eq $ipSource ? $_->{ipAddr} : () } @$failedLogin;
    my @IPs = ( @IPsS, @IPsF );

    $self->logger->debug( '**************** ' . Dumper( \@IPs ) );
    return scalar @IPs ? $self->_sendMail($req) : PE_OK;
}

sub _sendMail {
    my ( $self, $req ) = @_;
    my $epoch = time();
    my $ipSource     = $req->env->{ipAddr};
    my $host = $req->env->{HTTP_HOST};
        $self->logger->debug( "******************************* $host");

    my $mail =
      $req->sessionInfo->{ $self->conf->{newLocationWarningMailAttribute}
          || 'mail' };
    $self->logger->debug("+++++++++++++++++++++++ $mail");

# Build mail content
    my $tr      = $self->translate($req);
    my $subject = $self->conf->{newLocationWarningMailSubject};
    unless ($subject) {
        $subject = 'newLocationWarningMailSubject';
        $tr->( \$subject );
    }
    my $body;
    my $html;
    if ( $self->conf->{newLocationWarningMailBody} ) {

        # We use a specific text message, no html
        $body = $self->conf->{newLocationWarningMailBody};

        # Replace variables in body
        $body =~ s/\$newLocationIP/$ipSource/ge;
        $body =~ s/\$newLocationTime/$epoch/ge;

    }
    else {

        # Use HTML template
        $body = $self->loadMailTemplate(
            $req,
            'mail_new_location_warning',
            filter => $tr,
            params => {
                session_ipAddr => $ipSource,
                newLocationTime => $epoch,
                host         => $host,
            },
        );
        $html = 1;
    }

    $self->logger->info( "Warning, user "
      . $req->data->{mailAddress}
      . " is loggin in from a new location" );

    # Send mail
    unless (
        $self->send_mail(
            $mail, $subject, $body, $html
        )
      )
    {
        $self->logger->debug('Unable to send new location warning mail');

        # Don't return an error here to avoid enumeration
    }

    
    return PE_OK;
}

1;
