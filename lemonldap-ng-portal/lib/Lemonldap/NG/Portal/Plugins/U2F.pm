# U2F second factor authentication
#
# This plugin handle authentications to ask U2F second factor for users that
# have registered their U2F key
package Lemonldap::NG::Portal::Plugins::U2F;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Lib::U2F';

# INTERFACE

sub afterDatas { 'run' }

# INITIALIZATION

has ott => (
    is      => 'rw',
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->conf->{formTimeout} );
        return $ott;
    }
);

sub init {
    my ($self) = @_;
    return 0 unless $self->SUPER::init;
    1;
}

# RUNNING METHODS

# Main method
sub run {
    my($self,$req) = @_;
}

1;
