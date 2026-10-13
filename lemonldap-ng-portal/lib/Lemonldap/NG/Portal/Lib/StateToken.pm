package Lemonldap::NG::Portal::Lib::StateToken;

use strict;
use Mouse;
use JSON qw(from_json to_json);
use Crypt::URandom;

our $VERSION = '2.23.0';

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
'Local storage not defined, token will be stored into global storage'
                );
                return undef;
            }
        }
    }
);

sub init {
    return 1;
}

sub _getToken {
    my ( $self, $id, $keep ) = @_;
    unless ($id) {
        $self->logger->error('getState called without id');
        return undef;
    }
    $self->logger->debug("Trying to load token $id");

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
        $self->cache->remove($id) unless $keep;
        $data = from_json( $data, { allow_nonref => 1 } );
        return $data->{_type} eq 'token' ? $data : undef;
    }
    else {

        # Get token session
        my $tsession = $self->p->getApacheSession( $id, kind => 'TOKEN' );
        unless ($tsession) {
            $self->logger->notice("Bad (or expired) token $id");
            return undef;
        }
        my $h = $tsession->{data};
        $tsession->remove unless $keep;
        return $h;
    }
}

sub storeState {
    my ( $self, $data ) = @_;
    my $infos;

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

    # Store data
    $infos->{storedData} = $data;

    if ( $self->cache ) {
        my $id =
          $infos->{_utime} . '_' . unpack( 'S', Crypt::URandom::urandom(2) );
        $self->cache->set( $id, to_json($infos), $self->timeout . ' s' );
        $self->logger->debug("Token $id created");
        return $id;
    }
    else {

        # Create a new session
        my $tsession =
          $self->p->getApacheSession( undef, info => $infos, kind => 'TOKEN' );
        if ( $tsession->{id} ) {
            $self->logger->debug("Token $tsession->{id} created");
            return $tsession->id;
        }
        else {
            $self->logger->error("NO token created");
            return undef;
        }
    }
}

sub getState {
    my ( $self, $id, $keep ) = @_;
    my $data = $self->_getToken( $id, $keep );

    return
         ref $data eq 'HASH'
      && $data->{storedData}
      && $data->{storedData} ne 'null' ? $data->{storedData}
      : $data                          ? $data
      :                                  undef;
}

sub updateState {
    my ( $self, $id, %hash ) = @_;
    my ( $data, $h );

    if ( $self->cache ) {
        unless ( $data = $self->cache->get($id) ) {
            $self->logger->notice("Bad (or expired) token $id");
            return undef;
        }
        $h = from_json( $data, { allow_nonref => 1 } );
        $h->{storedData}->{$_} = $hash{$_} foreach ( keys %hash );
        $self->cache->set( $id, to_json($h),
            ( $h->{tokenTimeoutTimestamp} - time ) . ' s' );
        return $id;
    }
    else {
        if (
            my $tsession = $self->p->getApacheSession(
                $id, kind => "TOKEN",
            )
          )
        {
            $h = $tsession->{data};
            $h->{storedData}->{$_} = $hash{$_} foreach ( keys %hash );
            return $self->p->getApacheSession(
                $id,
                kind => "TOKEN",
                info => $h
            ) ? $id : undef;
        }
        else {
            $self->logger->notice("Bad (or expired) token $id");
            return undef;
        }
    }
}

sub setToken {
    my ( $self, $req, $info ) = @_;
    $self->logger->debug('Prepare token');
    $req->token( $self->storeState($info) );
}

1;
