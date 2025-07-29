package Lemonldap::NG::Portal::Lib::Key;
use Mouse::Role;

=pod

=head1 NAME
Lemonldap::NG::Portal::Lib::Key - A role for private key management in Portal plugins

=cut

requires qw(conf);

sub get_private_key {
    my ( $self, $key_id ) = @_;

    my $key_config = $self->_get_key_config($key_id);

    if ($key_config) {
        return {
            private     => $key_config->{keyPrivate},
            public      => $key_config->{keyPublic},
            external_id => ( $key_config->{keyId} || $key_id ),
            password    => ( $key_config->{keyPrivatePwd} // '' ),
        };
    }

    return;
}

sub get_public_key {
    my ( $self, $key_id ) = @_;

    my $key_config = $self->_get_key_config($key_id);

    if ($key_config) {
        return {
            public      => $key_config->{keyPublic},
            external_id => ( $key_config->{keyId} || $key_id ),
        };
    }

    return;
}

sub _get_key_config {
    my ( $self, $key_id ) = @_;

    return unless $key_id;
    if ( $self->conf->{'keys'}->{$key_id} ) {
        return $self->conf->{'keys'}->{$key_id};
    }

    if ( $key_id eq "default-saml-sig" ) {
        if ( $self->conf->{samlServicePrivateKeySig} ) {
            return {
                keyPrivate    => $self->conf->{samlServicePrivateKeySig},
                keyPrivatePwd =>
                  ( $self->conf->{samlServicePrivateKeySigPwd} // '' ),
                keyPublic => $self->conf->{samlServicePublicKeySig},
                keyId     => "default-saml-sig",
            };
        }
    }

    if ( $key_id eq "default-saml-enc" ) {
        if ( $self->conf->{samlServicePrivateKeyEnc} ) {
            return {
                keyPrivate    => $self->conf->{samlServicePrivateKeyEnc},
                keyPrivatePwd =>
                  ( $self->conf->{samlServicePrivateKeyEncPwd} // '' ),
                keyPublic => $self->conf->{samlServicePublicKeyEnc},
                keyId     => "default-saml-enc",
            };
        }
    }

    if ( $key_id eq "default-oidc-sig" ) {
        if ( $self->conf->{oidcServicePrivateKeySig} ) {
            return {
                keyPrivate    => $self->conf->{oidcServicePrivateKeySig},
                keyPrivatePwd => '',
                keyPublic     => $self->conf->{oidcServicePublicKeySig},
                keyId         => $self->conf->{oidcServiceKeyIdSig},
            };
        }
    }

    return;
}

1;
