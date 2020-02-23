package Lemonldap::NG::Portal::Plugins::BruteForceProtection;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_WAIT);

our $VERSION = '2.0.8';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

use constant afterData => 'run';

sub init {
    my ($self) = @_;
    if ( $self->conf->{disablePersistentStorage} ) {
        $self->logger->error(
'"BruteForceProtection" plugin enabled WITHOUT persistent session storage"'
        );
        return 0;
    }
    unless ( $self->conf->{loginHistoryEnabled} ) {
        $self->logger->error(
            '"BruteForceProtection" plugin enabled WITHOUT "History" plugin');
        return 0;
    }
    unless ( $self->conf->{failedLoginNumber} >
        $self->conf->{bruteForceProtectionMaxFailed} )
    {
        $self->logger->error( 'failedLoginNumber('
              . $self->conf->{failedLoginNumber}
              . ') must be higher than bruteForceProtectionMaxFailed('
              . $self->conf->{bruteForceProtectionMaxFailed}
              . ')' );
        return 0;
    }
    return 1;
}

# RUNNING METHOD
sub run {
    my ( $self, $req ) = @_;
    my $now          = time;
    my @failedLogins = grep {
        ( $now - $_->{_utime} ) < $self->conf->{bruteForceProtectionMaxAge}
          ? $_
          : ()
    } @{ $req->sessionInfo->{_loginHistory}->{failedLogin} };
    my $countFailed = @failedLogins;
    $self->logger->debug(
        " Failed login maxAge = $self->{conf}->{bruteForceProtectionMaxAge}");
    $self->logger->debug(
        " Number of failed login(s) to take into account = $countFailed");

    if ( $self->conf->{bruteForceProtectionIncrementalTempo} ) {
        my @incrementalTempo = split /\s+/,
          $self->conf->{bruteForceProtectionLockTimes}
          || ( 5, 15, 60, 300, 600 );
        $self->logger->warn( 'Number of incremental lock time values ('
              . scalar @incrementalTempo
              . ') is higher than failed logins history ('
              . $self->conf->{failedLoginNumber}
              . ')' )
          if ( scalar @incrementalTempo > $self->conf->{failedLoginNumber} );
        my $lastFailedLoginEpoch = $failedLogins[0]->{_utime} || undef;

        return PE_OK unless $lastFailedLoginEpoch;

        my $delta = $now - $lastFailedLoginEpoch;
        $self->logger->debug(" -> Delta = $delta");
        my $waitingTime = $incrementalTempo[ $countFailed - 1 ]
          || $self->conf->{bruteForceProtectionMaxLockTime};
        $self->logger->debug(" -> Waiting time = $waitingTime");
        unless ( $delta > $waitingTime ) {
            $self->logger->debug("BruteForceProtection enabled");
            return PE_WAIT;
        }
        return PE_OK;
    }

    return PE_OK
      if ( $countFailed <= $self->conf->{bruteForceProtectionMaxFailed} );

    my @lastFailedLoginEpoch = ();
    my $MaxAge               = $self->conf->{bruteForceProtectionMaxAge} + 1;

    # Auth_N-2 failed login epoch
    foreach ( 0 .. $self->conf->{bruteForceProtectionMaxFailed} - 1 ) {
        push @lastFailedLoginEpoch,
          $req->sessionInfo->{_loginHistory}->{failedLogin}->[$_]->{_utime}
          if ( $req->sessionInfo->{_loginHistory}->{failedLogin}->[$_] );
    }

    # If Auth_N-MaxFailed older than MaxAge -> another try allowed
    $MaxAge =
      $lastFailedLoginEpoch[0] -
      $lastFailedLoginEpoch[ $self->conf->{bruteForceProtectionMaxFailed} - 1 ]
      if $self->conf->{bruteForceProtectionMaxFailed};
    $self->logger->debug(" -> MaxAge = $MaxAge");

    return PE_OK
      if ( $MaxAge > $self->conf->{bruteForceProtectionMaxAge} );

    # Delta between the two last failed logins -> Auth_N - Auth_N-1
    my $delta =
      defined $lastFailedLoginEpoch[1] ? $now - $lastFailedLoginEpoch[1] : 0;
    $self->logger->debug(" -> Delta = $delta");

    # Delta between the two last failed logins < Tempo => wait
    return PE_OK
      unless ( $delta <= $self->conf->{bruteForceProtectionTempo} );

    # Account locked
    $self->logger->debug("BruteForceProtection enabled");
    return PE_WAIT;
}

1;
