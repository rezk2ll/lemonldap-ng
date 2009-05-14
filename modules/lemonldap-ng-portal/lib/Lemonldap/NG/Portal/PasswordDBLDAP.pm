##@file
# LDAP password backend file

##@class
# LDAP password backend class
package Lemonldap::NG::Portal::PasswordDBLDAP;

use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_LDAP 'ldap';    #link protected ldap
use Lemonldap::NG::Portal::UserDBLDAP;      #inherits

our $VERSION = '0.1';

*_formateFilter = *Lemonldap::NG::Portal::UserDBLDAP::formateFilter;
*_search        = *Lemonldap::NG::Portal::UserDBLDAP::search;

## @apmethod int apasswordDBInit()
# Load Net::LDAP::Control::PasswordPolicy if needed
# @return Lemonldap::NG::Portal constant
sub passwordDBInit {
    my $self = shift;
    if ( $self->{ldapPpolicyControl} and not $self->ldap->loadPP()) {
        return PE_LDAPERROR;
    }
    PE_OK;
}

## @apmethod int modifyPassword()
# Modify the password by LDAP mechanism.
# @return Lemonldap::NG::Portal constant
sub modifyPassword {
    my $self = shift;

    # Exit method if no password change requested
    return PE_OK unless ( $self->{newpassword} );

    unless ( $self->ldap ) {
        return PE_LDAPCONNECTFAILED;
    }

    # Set the dn unless done before
    unless ( $self->{dn} ) {
        my $tmp = $self->_subProcess(qw(_formateFilter _search));
        return $tmp if ($tmp);
    }

    # Call the modify password method
    return $self->ldap->userModifyPassword( $self->{dn}, $self->{newpassword}, $self->{confirmpassword}, $self->{oldpassword} );
    PE_OK;
}

1;
