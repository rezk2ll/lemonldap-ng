package Lemonldap::NG::Portal::Plugins::BrutForceProtection;

use Data::Dumper;
use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_INFO PE_OK);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin',
  'Lemonldap::NG::Portal::Lib::OtherSessions';

# INITIALIZATION

use constant afterData => 'run';

sub init {1}

# RUNNING METHOD

sub run {
    my ( $self, $req ) = @_;

    my $countFailed = 0;
    my $lastFailedLoginEpoch = 0;
    
    # Last failed login epoch before this authentication -> Auth_N-1
    if ( defined $req->sessionInfo->{_loginHistory}->{failedLogin} ){ 
        $countFailed = @{ $req->sessionInfo->{_loginHistory}->{failedLogin} };
    }
    if ( defined $req->sessionInfo->{_loginHistory}->{failedLogin}->[1] ){ 
        $lastFailedLoginEpoch = $req->sessionInfo->{_loginHistory}->{failedLogin}->[1]->{_utime}
    }

    # If Auth. N-1 older than 10 minutes -> another try allowed
    if ( ( time - $lastFailedLoginEpoch ) > 600 ) {
        $lastFailedLoginEpoch = 0;
    }

    # Delta between the two last failed logins -> Auth_N - Auth_N-1
    my $delta = time - $lastFailedLoginEpoch;

    $self->logger->debug( " successLogin -> " . Dumper( $req->sessionInfo->{_loginHistory}->{successLogin} ) );
    $self->logger->debug( " failedLogin -> " . Dumper( $req->sessionInfo->{_loginHistory}->{failedLogin} ) );
    $self->logger->debug(" Number of failedLogin -> $countFailed");
    $self->logger->debug(" Last failedLogin epoch -> $lastFailedLoginEpoch");
    $self->logger->debug( " Local time = " . localtime );
    $self->logger->debug(" Delta Auth_N - Auth_N-1 = $delta");

# If Delta between the two last failed logins < 10s and more than 2 failedLogins => waiting = failedLogins * 10s
    if ( $countFailed > 2 and ( $delta < 10 ) ) {

        sleep $countFailed * 10;

    }

    return PE_OK;
}

1;
