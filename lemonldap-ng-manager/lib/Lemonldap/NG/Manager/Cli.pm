package Lemonldap::NG::Manager::Cli;

use strict;
use Mouse;
use 5.14.0;
use Data::Dumper;

extends('Lemonldap::NG::Manager::Cli::Lib');

has cfgNum => (
    is      => 'rw',
    isa     => 'Int',
    trigger => sub {
        $_[0]->{req} =
          Lemonldap::NG::Manager::Cli::Request->new(
            cfgNum => $_[0]->{cfgNum} );
    }
);

has req => ( is => 'ro' );

sub get {
    my ( $self, @values ) = @_;
    $self->cfgNum( $self->lastCfg ) unless ( $self->cfgNum );
    die 'get requires at least one key' unless (@values);
  L: foreach my $key (@values) {
        unless ( $key =~ /^\w+(?:\/[\w\.]+)*$/ ) {
            warn "Unknown key $key";
            next L;
        }
        my $value = $self->mgr->getConfKey( $self->req, $key );
        #$value = Dumper($value);
        #$value =~ s/\$VAR1/$key/;
        #print $value;
        if(ref $value eq 'HASH') {
            print "$key has the following keys:\n";
            print "  $_\n" foreach(sort keys %$value);
        }
        else {
            print "$key = $value\n";
        }
    }
}

sub lastCfg {
    my ($self) = @_;
    return $self->jsonResponse('/confs/latest')->{cfgNum};
}

sub run {
    my $self = shift;
    unless (@_) {
        die 'nothing to do, aborting';
    }
    my $action = shift;
    unless ( $action =~ /^(?:get|set)$/ ) {
        die "unknown action $action";
    }
    $self->$action(@_);
}

package Lemonldap::NG::Manager::Cli::Request;

use Mouse;

has cfgNum => ( is => 'rw' );

has error => ( is => 'rw' );

sub params {
    my ( $self, $key ) = @_;
    return $self->{$key};
}

1;
