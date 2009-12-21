##@file
# DBI password backend file

##@class
# DBI password backend class
package Lemonldap::NG::Portal::PasswordDBDBI;

use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::AuthDBI;    #inherits
use base qw(Lemonldap::NG::Portal::_DBI);
use strict;

our $VERSION = '0.1';

*passwordDBInit = *Lemonldap::NG::Portal::AuthDBI::authInit;

## @apmethod int modifyPassword()
# Modify the password
# @return Lemonldap::NG::Portal constant
sub modifyPassword {
    my $self = shift;

    # Exit if no password change requested
    return PE_OK unless ( $self->{newpassword} );

    # Verify confirmation password matching
    return PE_PASSWORD_MISMATCH
      unless ( $self->{newpassword} eq $self->{confirmpassword} );

    # Connect
    my $dbh =
      $self->dbh( $self->{dbiAuthChain}, $self->{dbiAuthUser},
        $self->{dbiAuthPassword} );
    return PE_ERROR unless $dbh;

    my $user     = $self->{sessionInfo}->{_user};

    # Check old passord
    if ( $self->{oldpassword} ) {

        # Password hash
        my $password = $self->hash_password( $self->{oldpassword}, $self->{dbiAuthPasswordHash} );

        my $result = $self->check_password( $user, $password );

        unless ( $result ) {
            return PE_BADOLDPASSWORD;
        }
    }

    # Modify password
    my $password = $self->hash_password( $self->{newpassword}, $self->{dbiAuthPasswordHash} );

    my $result = $self->modify_password( $user, $password );

    unless ( $result ) {
        return PE_ERROR;
    }

    $self->lmLog( "Password changed for $user", 'debug' );
    PE_PASSWORD_OK;
}

## @apmethod int resetPasswordByMail()
# Reset the password and send a mail.
# @return Lemonldap::NG::Portal constant
sub resetPasswordByMail {
    my $self = shift;

    # TODO

    PE_OK;
}

1;
