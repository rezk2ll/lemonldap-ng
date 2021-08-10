package Lemonldap::NG::Portal::Plugins::NewLocationWarning;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_ERROR
);

our $VERSION = '2.0.13';

extends 'Lemonldap::NG::Portal::Main::Plugin';

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
    return scalar @IPs ? $self->sendMail($req) : PE_OK;
}

sub sendMail {
    my ( $self, $req ) = @_;
    my $mail =
      $req->sessionInfo->{ $self->conf->{newLocationWarningMailAttribute}
          || 'mail' };
    $self->logger->debug("+++++++++++++++++++++++ $mail");
    return PE_OK;
}

1;
