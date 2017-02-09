package Lemonldap::NG::Handler::ApacheMP2;

use strict;

use Lemonldap::NG::Handler::ApacheMP2::Main;

our $VERSION = '2.0.0';

# PUBLIC METHODS

sub handler {
    shift if ($#_);
    my ($res) = getClass(@_)->run(@_);
    return $res;
}

sub logout {
    shift if ($#_);
    return getClass(@_)->unlog(@_);
}

sub status {
    shift if ($#_);
    return getClass(@_)->getStatus(@_);
}

# Internal method to get class to load
sub getClass {
    my $type  = Lemonldap::NG::Handler::ApacheMP2::Main->checkType(@_);
    my $class = "Lemonldap::NG::Handler::ApacheMP2::$type";
    eval "require $class";
    die $@ if ($@);
    return $class;
}

1;
