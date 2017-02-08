package Lemonldap::NG::Handler::ApacheMP2;

use strict;

use Lemonldap::NG::Handler::ApacheMP2::Main;

our $VERSION = '2.0.0';

# PUBLIC METHODS

sub handler {
    shift if($#_);
    my $type = Lemonldap::NG::Handler::ApacheMP2::Main->checkType(@_);
    my $class = "Lemonldap::NG::Handler::ApacheMP2::$type";
    eval "require $class";
    die $@ if($@);
    my ($res) = $class->run(@_);
    return $res;
}

1;
