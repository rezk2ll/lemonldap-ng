##@file
# LDAP authentication backend file

##@class
# LDAP authentication backend class
package Lemonldap::NG::Portal::AuthLDAP;

use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_LDAP 'ldap';    #link protected ldap
use Lemonldap::NG::Portal::_WebForm;
use Lemonldap::NG::Portal::UserDBLDAP;    #inherits

our $VERSION = '0.2';
use base qw(Lemonldap::NG::Portal::_WebForm);

*_formateFilter = *Lemonldap::NG::Portal::UserDBLDAP::formateFilter;
*_search        = *Lemonldap::NG::Portal::UserDBLDAP::search;

## @method int authenticate()
# Authenticate user by LDAP mechanism.
# @return Lemonldap::NG::Portal constant
sub authenticate {
    my $self = shift;
    unless ( $self->ldap ) {
        return PE_LDAPCONNECTFAILED;
    }

    # Set the dn unless done before
    unless ( $self->{dn} ) {
        my $tmp = $self->_subProcess(qw(_formateFilter _search));
        return $tmp if ($tmp);
    }

    # Check if we use Ppolicy control
    if ( $self->{ldapPpolicyControl} ) {

        # require Perl module
        eval 'require Net::LDAP::Control::PasswordPolicy';
        if ($@) {
            $self->lmLog(
                "Module Net::LDAP::Control::PasswordPolicy not found in @INC",
                'error' );
            return PE_LDAPERROR;
        }
        no strict 'subs';

        # Create Control object
        my $pp = Net::LDAP::Control::PasswordPolicy->new();

        # Bind with user credentials
        my $mesg = $self->ldap->bind(
            $self->{dn},
            password => $self->{password},
            control  => [$pp]
        );

        # Get server control response
        my ($resp) = $mesg->control("1.3.6.1.4.1.42.2.27.8.5.1");

        # Get expiration warning and graces
        $self->{ppolicy}->{time_before_expiration} =
          $resp->time_before_expiration;
        $self->{ppolicy}->{grace_authentications_remaining} =
          $resp->grace_authentications_remaining;

        # Get bind response
        return PE_OK if ( $mesg->code == 0 );

        if ( defined $resp ) {
            my $pp_error = $resp->pp_error;
            if ( defined $pp_error ) {
                return [
                    PE_PP_PASSWORD_EXPIRED,
                    PE_PP_ACCOUNT_LOCKED,
                    PE_PP_CHANGE_AFTER_RESET,
                    PE_PP_PASSWORD_MOD_NOT_ALLOWED,
                    PE_PP_MUST_SUPPLY_OLD_PASSWORD,
                    PE_PP_INSUFFICIENT_PASSWORD_QUALITY,
                    PE_PP_PASSWORD_TOO_SHORT,
                    PE_PP_PASSWORD_TOO_YOUNG,
                    PE_PP_PASSWORD_IN_HISTORY,
                ]->[$pp_error];
            }
            else {
                $self->_sub('userError',"Bad password for $self->{user}");
                return PE_BADCREDENTIALS;
            }
        }
        else {
            return PE_LDAPERROR;
        }
    }
    else {
        my $mesg =
          $self->ldap->bind( $self->{dn}, password => $self->{password} );
        if ( $mesg->code != 0 ) {
            $self->_sub('userError',"Bad password for $self->{user}");
            return PE_BADCREDENTIALS;
        }
    }
    $self->{sessionInfo}->{authenticationLevel} = 2;
    $self->_sub('userNotice', "Good authentication for "
          . $self->{sessionInfo}->{ $self->{whatToTrace} } );
    PE_OK;
}

1;
