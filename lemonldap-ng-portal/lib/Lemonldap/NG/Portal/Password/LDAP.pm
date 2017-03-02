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

# Confirmation is done by Lib::Net::LDAP::userModifyPassword
sub confirm {
    return 1;
}

sub modifyPassword {
    my ( $self, $req, $pwd ) = @_;

    # Call the modify password method
    my $code =
      $self->ldap->userModifyPassword( $req->{dn}, $pwd, $req->datas->{oldpassword} );

    unless ( $code == PE_PASSWORD_OK ) {
        $self->ldap->unbind;
        $self->{flags}->{ldapActive} = 0;
        return $code;
    }

    # If password policy and force reset, set reset flag
    if (    $self->conf->{ldapPpolicyControl}
        and $req->datas->{forceReset}
        and $self->conf->{ldapUsePasswordResetAttribute} )
    {
        my $result = $self->ldap->modify(
            $req->{dn},
            replace => {
                $self->conf->{ldapPasswordResetAttribute} =>
                  $self->conf->{ldapPasswordResetAttributeValue}
            }
        );

        unless ( $result->code == 0 ) {
            $self->logger->error( "LDAP modify "
                  . $self->{ldapPasswordResetAttribute}
                  . " error: "
                  . $result->code );
            $self->ldap->unbind;
            $self->{flags}->{ldapActive} = 0;
            return PE_LDAPERROR;
        }

        $self->logger->debug( $self->conf->{ldapPasswordResetAttribute}
              . " set to "
              . $self->conf->{ldapPasswordResetAttributeValue} );
    }

    return $code;
}

1;
