##@file
# DBI password backend file

##@class
# DBI password backend class
package Lemonldap::NG::Portal::PasswordDBDBI;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::AuthDBI;    #inherits
use base qw(Lemonldap::NG::Portal::_DBI );
#use Lemonldap::NG::Portal::_SMTP;     #inherits

our $VERSION = '0.1';

## @apmethod int passwordDBInit()
# Load SMTP functions and call DBI authInit()
# @return Lemonldap::NG::Portal constant
sub passwordDBInit {
    my $self = shift;
    eval { use base qw(Lemonldap::NG::Portal::_SMTP) };
    if ($@) {
        $self->lmLog( "Unable to load SMTP functions ($@)", 'error' );
        return PE_ERROR;
    }
    unless ( $self->{dbiPasswordMailCol} )
    {
        $self->lmLog( "Missing configuration parameters for DBI password reset",
            'error' );
        return PE_ERROR;
    }
    return $self->Lemonldap::NG::Portal::AuthDBI::authInit();
}

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

    # Exit method if no mail
    return PE_OK unless ( $self->{mail} );

    # Find mail in database
    my $dbh =
      $self->dbh( $self->{dbiAuthChain}, $self->{dbiAuthUser},
        $self->{dbiAuthPassword} );
    return PE_ERROR unless $dbh;

    my $table = $self->{dbiAuthTable};
    my $mail = $self->{mail};
    my $mailCol = $self->{dbiPasswordMailCol};
    $mail =~ s/'/''/g;
    my $sth;

    eval {
        $sth = $dbh->prepare("SELECT * FROM $table WHERE $mailCol='$mail'");
        $sth->execute();
    };
    if ($@) {
        $self->lmLog( "DBI error: $@", 'error' );
        return PE_ERROR;
    }

    unless ( $sth->fetchrow_hashref() ) {
        $self->lmLog( "Mail $mail not found", 'notice' );
	return PE_BADCREDENTIALS;
    }

    $self->lmLog( "Reset password request for " . $self->{mail}, 'debug' );
    
    # Generate a complex password
    my $password = $self->gen_password( $self->{randomPasswordRegexp} );

    $self->lmLog( "Generated password: " . $password, 'debug' );

    # Modify password
    my $hpassword = $self->hash_password( $password, $self->{dbiAuthPasswordHash} );
    my $result = $self->modify_password( $self->{mail}, $hpassword, $self->{dbiPasswordMailCol} );

    return PE_ERROR unless $result;

    # Send new password by mail
    $result = $self->send_password( $password, $self->{mail} );

    return PE_ERROR unless $result;

    PE_PASSWORD_OK;
}

1;
