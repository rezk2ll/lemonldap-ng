package Lemonldap::NG::Portal::Lib::U2F;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

has crypter => ( is => 'rw' );

has origin => (
    is      => 'rw',
    default => sub {
        my $p = $_[0]->{conf}->{portal};
        $p =~ s#^(https?://[^/]+).*$#$1#;
        return $p;
    }
);

sub init {
    my ($self) = @_;
    eval 'use Crypt::U2F::Server::Simple';
    if ($@) {
        $self->error("Can't load U2F library: $@");
        return 0;
    }
    unless (
        $self->crypter(
            Crypt::U2F::Server::Simple->new(
                appId  => $self->origin,
                origin => $self->origin,
            )
        )
      )
    {
        $self->error( Crypt::U2F::Server::Simple::lastError() );
        return 0;
    }
    return 1;
}

1;
