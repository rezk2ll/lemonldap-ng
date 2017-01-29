package Lemonldap::NG::Portal::Lib::OneTimeToken;

use strict;
use Mouse;

extends 'Lemonldap::NG::Common::Module';

has timeout => (
    is      => 'rw',
    default => sub {
        $_[0]->{conf}->{timeout};
    }
);

sub createToken {
    my ( $self, $infos ) = @_;

    # Create a new session
    my $tsession = $self->p->getApacheSession();

    # Set _utime for session autoremove
    # Use default session timeout and register session timeout to compute it
    my $time = time();

    # Set _utime to remove token after $self->timeout
    $infos->{_utime} = $time + ( $self->timeout - $self->conf->{timeout} );

    # Store expiration timestamp for further use
    $infos->{tokenTimeoutTimestamp} = $time + $self->timeout;

    # Store start timestamp for further use
    $infos->{tokenSessionStartTimestamp} = $time;

    # Store type
    $infos->{_type} ||= "token";

    # Update session
    $tsession->update($infos);

    return $tsession->id;
}

sub getToken {
    my ( $self, $id ) = @_;
    unless ($id) {
        $self->lmLog( 'getToken called without id', 'error' );
        return undef;
    }

    # Get token session
    my $tsession = $self->p->getApacheSession($id);
    unless ($tsession) {
        $self->lmLog( "Bad (or expired) token $id", 'notice' );
        return undef;
    }
    my %h = %{ $tsession->{data} };
    $tsession->remove;
    return \%h;
}

sub setToken {
    my ( $self, $req, $info ) = @_;
    $self->lmLog( 'Prepare token', 'debug' );
    $req->token( $self->createToken($info) );
}

1;
