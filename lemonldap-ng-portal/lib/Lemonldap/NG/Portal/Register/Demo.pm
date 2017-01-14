package Lemonldap::NG::Portal::Register::Demo;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

our $VERSION = '2.0.0';

sub init {
    1;
}

# Compute a login from register infos
# @result Lemonldap::NG::Portal constant
sub computeLogin {
    my ($self) = @_;

    # Get first letter of firstname and lastname
    my $login =
      substr( lc $self->{registerInfo}->{firstname}, 0, 1 )
      . lc $self->{registerInfo}->{lastname};

    $self->{registerInfo}->{login} = $login;

    return PE_OK;
}

## @method int createUser
# Do nothing
# @result Lemonldap::NG::Portal constant
sub createUser {
    my ($self) = @_;

    return PE_OK;
}

## @method int registerDBFinish
# Do nothing
# @result Lemonldap::NG::Portal constant
sub registerDBFinish {
    my ($self) = @_;

    return PE_OK;
}

1;

