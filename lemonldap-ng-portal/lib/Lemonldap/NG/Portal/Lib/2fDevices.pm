package Lemonldap::NG::Portal::Lib::2fDevices;

use strict;
use Mouse::Role;
use JSON;

requires qw(p conf logger);

our $VERSION = '2.0.15';

sub update2fDevice {
    my ( $self, $req, $info, $type, $key, $value, $update_key, $update_value )
      = @_;

    my $user = $info->{ $self->conf->{whatToTrace} };

    my $_2fDevices = $self->get2fDevices( $req, $info );
    return 0 unless $_2fDevices;

    my @found =
      grep { $_->{type} eq $type and $_->{$key} eq $value } @{$_2fDevices};

    for my $device (@found) {
        $device->{$update_key} = $update_value;
    }

    if (@found) {
        $self->p->updatePersistentSession( $req,
            { _2fDevices => to_json($_2fDevices) }, $user );
        return 1;
    }
    return 0;
}

sub add2fDevice {
    my ( $self, $req, $info, $device ) = @_;

    my $_2fDevices = $self->get2fDevices( $req, $info );

    push @{$_2fDevices}, $device;
    $self->logger->debug(
        "Append 2F Device: { type => $device->{type}, name => $device->{name} }"
    );
    $self->p->updatePersistentSession( $req,
        { _2fDevices => to_json($_2fDevices) } );
    return 1;
}

# $devices must be a arrayref of type+epoch hashrefs:
# [ { type => xxx, epoch => xxx }, { type => xxx, epoch => xxx } ]
sub del2fDevices {
    my ( $self, $req, $info, $devices ) = @_;

    return 0 unless ( ref($devices) eq "ARRAY" );

    my $_2fDevices = $self->get2fDevices( $req, $info );
    return 0 unless $_2fDevices;

    my @updated_2fDevices = @{$_2fDevices};
    my $need_update       = 0;

    for my $device_spec (@$devices) {
        next unless ( ref($device_spec) eq "HASH" );
        my $type  = $device_spec->{type};
        my $epoch = $device_spec->{epoch};
        next unless ( $type and $epoch );

        my $size_before = @updated_2fDevices;
        @updated_2fDevices =
          grep { not( $_->{type} eq $type and $_->{epoch} eq $epoch ) }
          @updated_2fDevices;
        if ( @updated_2fDevices < $size_before ) {
            $need_update = 1;
            $self->logger->debug(
                "Deleted 2F Device: { type => $type, epoch => $epoch }");
        }
    }

    if ($need_update) {
        $self->p->updatePersistentSession( $req,
            { _2fDevices => to_json( [@updated_2fDevices] ) } );
    }
    return 1;
}

sub del2fDevice {
    my ( $self, $req, $info, $type, $epoch ) = @_;

    return $self->del2fDevices( $req, $info,
        [ { type => $type, epoch => $epoch } ] );
}

sub find2fDevicesByKey {
    my ( $self, $req, $info, $type, $key, $value ) = @_;

    my $_2fDevices = $self->get2fDevices( $req, $info );
    return unless $_2fDevices;

    my @found =
      grep { $_->{type} eq $type and $_->{$key} eq $value } @{$_2fDevices};
    return @found;
}

## @method get2fDevices($req, $info)
# Validate logout request
# @param req Request object
# @param info HashRef of session data
# @return undef or ArrayRef of second factors

sub get2fDevices {
    my ( $self, $req, $info ) = @_;

    my $_2fDevices;
    if ( $info->{_2fDevices} ) {
        $_2fDevices =
          eval { from_json( $info->{_2fDevices}, { allow_nonref => 1 } ); };
        if ($@) {
            $self->logger->error("Corrupted session (_2fDevices): $@");
            return;
        }
    }
    else {
        # Return new ArrayRef
        return [];
    }
    if ( ref($_2fDevices) eq "ARRAY" ) {
        return $_2fDevices;
    }
    else {
        return;
    }
}

sub find2fDevicesByType {
    my ( $self, $req, $info, $type ) = @_;

    my $_2fDevices = $self->get2fDevices( $req, $info );
    return unless $_2fDevices;

    return @{$_2fDevices} unless $type;
    my @found = grep { $_->{type} eq $type } @{$_2fDevices};
    return @found;
}
1;
