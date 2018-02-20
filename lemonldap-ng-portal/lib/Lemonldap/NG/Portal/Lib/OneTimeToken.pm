package Lemonldap::NG::Portal::Lib::OneTimeToken;

use strict;
use Mouse;
use JSON qw(from_json to_json);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Common::Module';

has timeout => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        $_[0]->{conf}->{timeout};
    }
);

has cache => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $c = $_[0]->{conf};
        if ( !$c->{tokenUseGlobalStorage} ) {
            if ( $c->{localSessionStorage} ) {
                eval "use $c->{localSessionStorage}";
                if ($@) {
                    $_[0]->{p}->logger->error($@);
                    return undef;
                }
                return $c->{localSessionStorage}
                  ->new( $c->{localSessionStorageOptions} );
            }
            else {
                $_[0]->{p}->logger->error(
'Local storage not defined, token will be store in global storage'
                );
                return undef;
            }
        }
    },
);

sub createToken {
    my ( $self, $infos ) = @_;

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

    if ( $self->cache ) {
        my $id = $infos->{_utime} . '_' . int( rand(10000) );

        # Dereference $infos
        my %h = %$infos;
        $self->cache->set( $id, to_json( \%h ), $self->timeout . ' s' );
        return $id;
    }
    else {

        # Create a new session
        my $tsession = $self->p->getApacheSession( undef, info => $infos );
        return $tsession->id;
    }
}

sub getToken {
    my ( $self, $id, $keep ) = @_;
    unless ($id) {
        $self->logger->error('getToken called without id');
        return undef;
    }

    if ( $self->cache ) {
        my $data;
        my @t = split /_/, $id;
        if ( $t[0] > time ) {
            $self->logger->notice("Expired token $id");
            $self->cache->remove($id);
            return undef;
        }
        unless ( $data = $self->cache->get($id) ) {
            $self->logger->notice("Bad (or expired) token $id");
            return undef;
        }
        $self->cache->remove($id) unless($keep);
        return from_json( $data, { allow_nonref => 1 } );
    }
    else {

        # Get token session
        my $tsession = $self->p->getApacheSession($id);
        unless ($tsession) {
            $self->logger->notice("Bad (or expired) token $id");
            return undef;
        }
        my %h = %{ $tsession->{data} };
        $tsession->remove;
        return \%h;
    }
}

sub setToken {
    my ( $self, $req, $info ) = @_;
    $self->logger->debug('Prepare token');
    $req->token( $self->createToken($info) );
}

1;
