package Lemonldap::NG::Portal::UserDB::LDAP;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;
use Lemonldap::NG::Portal::Lib::LDAP;

extends 'Lemonldap::NG::Portal::Main::Module';

has ldap => (
    is      => 'rw',
    builder => sub {
        my $self = $_[0];
        my $ldap;

        # Build object and test LDAP connexion
        if (
            $ldap = Lemonldap::NG::Portal::Lib::LDAP->new(
                { p => $self->{p}, conf => $self->{conf} }
            )
            and my $msg = $ldap->bind
          )
        {
            if ( $msg->code != 0 ) {
                $self->lmLog( "LDAP error: " . $msg->error, 'error' );
            }
            else {
                if ( $self->{conf}->{ldapPpolicyControl}
                    and not $ldap->loadPP() )
                {
                    $self->lmLog( "LDAP password policy error", 'error' );
                }
            }
            $ldap->unbind;
        }
        else {
            $self->lmLog( "LDAP error: $@", 'error' );
        }
        return $ldap;
    }
);

1;
