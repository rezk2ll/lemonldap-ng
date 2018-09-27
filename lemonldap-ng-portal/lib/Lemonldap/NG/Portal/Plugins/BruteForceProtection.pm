package Lemonldap::NG::Portal::Plugins::BruteForceProtection;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_WAIT);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

use constant afterData => 'run';

sub init {1}

# RUNNING METHOD

sub run {
    my ( $self, $req ) = @_;

    my $countFailed          = 0;
    my @lastFailedLoginEpoch = ();

    # Auth_N-2 failed login epoch
    if ( defined $req->sessionInfo->{_loginHistory}->{failedLogin} ) {
        $countFailed = @{ $req->sessionInfo->{_loginHistory}->{failedLogin} };
    }

    $self->logger->debug( " Number of failedLogin = $countFailed" );
    return PE_OK if ( $countFailed < 3 );

    foreach ( 0 .. 2 ) {
        if ( defined $req->sessionInfo->{_loginHistory}->{failedLogin}->[$_] )
        {
            push @lastFailedLoginEpoch,
                $req->sessionInfo->{_loginHistory}->{failedLogin}->[$_]
                ->{_utime};
        }
    }

    # If Auth_N-2 older than 5 minutes -> another try allowed
    return PE_OK
        if ( ( $lastFailedLoginEpoch[0] - $lastFailedLoginEpoch[2] ) > 300 );

    # Delta between the two last failed logins -> Auth_N - Auth_N-1
    my $delta = time - $lastFailedLoginEpoch[1];

    $self->logger->debug( " Local time = " . time );
    $self->logger->debug(" Delta time - lastFailedLoginN-1 = $delta");

    # Delta between the two last failed logins < 30s => wait
    return PE_OK unless ( $delta < 31 );
    
    # Account locked
    shift @{ $req->sessionInfo->{_loginHistory}->{failedLogin} };
    return PE_WAIT;
}

1;
