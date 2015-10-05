##@file
# AD authentication backend file

##@class
# AD authentication backend class
package Lemonldap::NG::Portal::AuthAD;

use strict;

our $VERSION = '1.4.6';
use Lemonldap::NG::Portal::Simple;
use base qw(Lemonldap::NG::Portal::AuthLDAP);

*_formateFilter = *Lemonldap::NG::Portal::UserDBAD::formateFilter;
*getDisplayType = *Lemonldap::NG::Portal::AuthLDAP::getDisplayType;

## @apmethod int authInit()
# Add specific attributes for search
# @return Lemonldap::NG::Portal constant
sub authInit {
    my $self = shift;

    $self->{ldapExportedVars}->{_AD_pwdLastSet}         = 'pwdLastSet';
    $self->{ldapExportedVars}->{_AD_userAccountControl} = 'userAccountControl';
    $self->{ldapExportedVars}->{_AD_msDS_UACC} =
      'msDS-User-Account-Control-Computed';

    return $self->SUPER::authInit();
}

## @apmethod int authenticate()
# Authenticate user by LDAP mechanism.
# Check AD specific attribute to get password state.
# @return Lemonldap::NG::Portal constant
sub authenticate {
    my $self = shift;

    my $res = $self->SUPER::authenticate;

    unless ( $res == PE_OK ) {

        # Check specific AD attributes
        my $pls = $self->{entry}->get_value('pwdLastSet');
        my $computed =
          $self->{entry}->get_value('msDS-User-Account-Control-Computed');
        my $mask = 0xf00000;    # mask to get the 8 at 6th position
        my $expired_flag =
          0x800000;   # 8 at 6th position for flag UF_PASSWORD_EXPIRED to be set
        if ( ( $computed & $mask ) == $expired_flag ) {
            $self->lmLog( "[AD] Password has expired", 'warn' );
            $res = PE_PP_PASSWORD_EXPIRED;
        }

        # Password must be changed if pwdLastSet 0
        if ( $pls == 0 ) {
            $self->lmLog( "[AD] Password reset. User must change his password",
                'warn' );
            $res = PE_PP_CHANGE_AFTER_RESET;
        }

    }

    # Remember password if password reset needed
    $self->{oldpassword} = $self->{password}
      if ( $res == PE_PP_CHANGE_AFTER_RESET );

    return $res;
}

1;
