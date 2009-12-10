##@file
# DBI password backend file

##@class
# DBI password backend class
package Lemonldap::NG::Portal::PasswordDBDBI;

use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::AuthDBI;      #inherits
use base qw(Lemonldap::NG::Portal::_DBI);

our $VERSION = '0.1';

*passwordDBInit = *Lemonldap::NG::Portal::AuthDBI::authInit;

## @apmethod int modifyPassword()
# @return Lemonldap::NG::Portal constant
sub modifyPassword {
    my $self = shift;

    # Exit if no password change requested
    return PE_OK unless ( $self->{newpassword} );

    # Verify confirmation password matching
    return PE_PASSWORD_MISMATCH unless ( $self->{newpassword} eq $self->{confirmpassword} );

    # Connect
    my $dbh = $self->dbh( $self->{dbiAuthChain}, $self->{dbiAuthUser}, $self->{dbiAuthPassword} );
    return PE_ERROR unless $dbh;

    my $table = $self->{dbiAuthTable};
    my $loginCol = $self->{dbiAuthLoginCol};
    my $passwordCol = $self->{dbiAuthPasswordCol};
    my $user = $self->{sessionInfo}->{_user};
    my $password;
   
    # Check old passord
    if ( $self->{oldpassword} ) {

        # Manage password hash (TODO in _DBI.pm)
        if ( $self->{dbiAuthPasswordHash} =~ /^(md5|sha|sha1)$/i ) {
            $self->lmLog( "Using ".uc($self->{dbiAuthPasswordHash})." to hash password", 'debug' );
            $password = uc($self->{dbiAuthPasswordHash})."('".$self->{oldpassword}."')";
        } else {
            $self->lmLog( "No valid password hash, using clear text for password", 'debug' );
            $password = "'".$self->{oldpassword}."'";
        }

        my $sth = $dbh->prepare("SELECT $loginCol FROM $table WHERE $loginCol='$user' AND $passwordCol=$password");

        $sth->execute();

        my @rows = $sth->fetchrow_array();

        if ($#rows eq 0) {
            $self->lmLog( "One row returned by SQL query", 'debug' );
        } else {
            $self->lmLog( "Bad password for $user", 'error' );
            return PE_BADOLDPASSWORD;
        }
    }

    # Modify password
    # Manage password hash (TODO in _DBI.pm)
    if ( $self->{dbiAuthPasswordHash} =~ /^(md5|sha|sha1)$/i ) {
        $self->lmLog( "Using ".uc($self->{dbiAuthPasswordHash})." to hash password", 'debug' );
        $password = uc($self->{dbiAuthPasswordHash})."('".$self->{newpassword}."')";
    } else {
        $self->lmLog( "No valid password hash, using clear text for password", 'debug' );
        $password = "'".$self->{newpassword}."'";
    }

    eval {
        my $sth = $dbh->prepare("UPDATE $table SET $passwordCol=$password WHERE $loginCol='$user'");
        $sth->execute();
    };
    if ($@) {
        $self->lmLog( "DBI password modification error: $@", 'error' );
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
