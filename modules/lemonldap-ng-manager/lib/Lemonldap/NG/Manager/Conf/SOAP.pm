package Lemonldap::NG::Manager::Conf::SOAP;

use strict;
use SOAP::Lite;

our $VERSION = 0.1;

sub prereq {
    my $self = shift;
    unless ( $self->{proxy} and $self->{uri} ) {
        print STDERR 'No SOAP parameters found (proxy and uri)';
        return 0;
    }
    1;
}

sub _connect {
	my $self = shift;
    $self->{service} ||= SOAP::Lite -> uri($self->{uri})
               -> proxy($self->{proxy});
}

sub _soapCall {
    my $self = shift;
    my $func = shift;
    $self->_connect;
    my $conf = $self->{service}->$func(@_)->result;
    return @$conf;

}

sub available {
    my $self = shift;
    return $self->_soapCall('available',@_);
}

sub lastCfg {
    my $self = shift;
    return $self->_soapCall('lastCfg',@_);
}

sub store {
    my $self = shift;
    return $self->_soapCall('store',@_);
}

sub load {
    my $self = shift;
    return $self->_soapCall('load',@_);
}

1;
__END__
