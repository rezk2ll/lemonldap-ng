package Lemonldap::NG::Portal::Password::LDAP;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_PASSWORD_OK PE_LDAPERROR);

extends 'Lemonldap::NG::Portal::Lib::LDAP',
  'Lemonldap::NG::Portal::Password::Base';

our $VERSION = '2.0.0';

sub init {
    my ($self) = @_;
    $self->ldap
      and $self->filter
      and $self->Lemonldap::NG::Portal::Password::Base::init;
}

# Confirmation is done by Lib::LDAP::userModifyPassword
sub confirm {
    return 1;
}

sub modifyPassword {
    my ( $self, $req, $pwd ) = @_;

    # Call the modify password method
    my $code =
      $self->ldap->userModifyPassword( $req->{dn}, $pwd, $self->{oldpassword} );

    unless ( $code == PE_PASSWORD_OK ) {
        $self->ldap->unbind;
        $self->{flags}->{ldapActive} = 0;
        return $code;
    }

    # If password policy and force reset, set reset flag
    if (    $self->{ldapPpolicyControl}
        and $self->{forceReset}
        and $self->{ldapUsePasswordResetAttribute} )
    {
        my $result = $self->ldap->modify(
            $self->{dn},
            replace => {
                $self->{ldapPasswordResetAttribute} =>
                  $self->{ldapPasswordResetAttributeValue}
            }
        );

        unless ( $result->code == 0 ) {
            $self->lmLog(
                "LDAP modify "
                  . $self->{ldapPasswordResetAttribute}
                  . " error: "
                  . $result->code,
                'error'
            );
            $self->ldap->unbind;
            $self->{flags}->{ldapActive} = 0;
            return PE_LDAPERROR;
        }

        $self->lmLog(
            $self->{ldapPasswordResetAttribute}
              . " set to "
              . $self->{ldapPasswordResetAttributeValue},
            'debug'
        );
    }

    return $code;
}

1;
