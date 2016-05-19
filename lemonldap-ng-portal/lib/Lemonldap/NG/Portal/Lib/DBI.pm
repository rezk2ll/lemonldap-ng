##@file
# DBI common functions

##@class
# DBI common functions
package Lemonldap::NG::Portal::Lib::DBI;

use DBI;
use strict;
use Mouse;

extends 'Lemonldap::NG::Portal::Main::Module';

our $VERSION = '2.0.0';

# dbh object: DB connection object
has dbh => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {
        my $conf = $_[0]->{conf};
        my $dbh  = eval {

            #TODO: pb
            DBI->connect_cached(
                $conf->{dbiAuthChain}, $conf->{dbiAuthUser},
                $conf->{dbiAuthPassword}, { RaiseError => 1 }
            );
        };
        if ($@) {
            $_[0]->{p}->lmLog( "DBI connection error: $@", 'error' );
            return 0;
        }
        return $dbh;
    }
);

# Return hashed password for use in SQL statement
# @param password clear password
# @param hash hash mechanism
# @return SQL statement string
sub hash_password {
    my ( $self, $password, $hash ) = @_;
    if ( $hash =~ /^(md5|sha|sha1|encrypt)$/i ) {
        $self->lmLog( "Using " . uc($hash) . " to hash password", 'debug' );
        return uc($hash) . "($password)";
    }
    else {
        $self->lmLog( "No valid password hash, using clear text for password",
            'warn' );
        return $password;
    }

}

# Return hashed password for use in SQL SELECT statement
# Call hash_password unless encrypt hash is choosen
# @param password clear password
# @param hash hash mechanism
# @return SQL statement string
sub hash_password_for_select {
    my ( $self, $password, $hash ) = @_;
    my $passwordCol = $self->conf->{dbiAuthPasswordCol};

    if ( $hash =~ /^encrypt$/i ) {
        return uc($hash) . "($password,$passwordCol)";
    }
    else {
        return $self->hash_password( $password, $hash );
    }
}

# Verify user and password with SQL SELECT
# @param user user
# @param password password
# @return boolean result
sub check_password {
    my ( $self, $user, $password ) = @_;

    # If $user is an object then it's a Lemonldap::NG::Portal::Main::Request
    # object
    if ( ref($user) ) {
        $password = $user->datas->{password};
        $user     = $user->{user};
    }
    my $table       = $self->conf->{dbiAuthTable};
    my $loginCol    = $self->conf->{dbiAuthLoginCol};
    my $passwordCol = $self->conf->{dbiAuthPasswordCol};

    # Password hash
    my $passwordsql =
      $self->hash_password_for_select( "?",
        $self->conf->{dbiAuthPasswordHash} );

    my @rows = ();
    eval {
        my $sth = $self->dbh->prepare(
"SELECT $loginCol FROM $table WHERE $loginCol=? AND $passwordCol=$passwordsql"
        );
        $sth->execute( $user, $password );
        @rows = $sth->fetchrow_array();
    };
    if ($@) {
        $self->lmLog( "DBI error: $@", 'error' );
        return 0;
    }

    if ( @rows == 1 ) {
        $self->lmLog( "One row returned by SQL query", 'debug' );
        return 1;
    }
    else {
        $self->p->userError("Bad password for $user");
        return 0;
    }

}

## @method protected Lemonldap::NG::Portal::_DBI modify_password(string user, string password, string userCol, string passwordCol)
# Modify password with SQL UPDATE
# @param user user
# @param password password
# @param userCol optional user column
# @param passwordCol optional password column
# @return boolean result
sub modify_password {
    my ( $self, $user, $password, $userCol, $passwordCol ) = @_;
    $userCol     ||= $self->conf->{dbiAuthLoginCol};
    $passwordCol ||= $self->conf->{dbiAuthPasswordCol};

    my $table = $self->conf->{dbiAuthTable};

    # Password hash
    my $passwordsql =
      $self->hash_password( "?", $self->conf->{dbiAuthPasswordHash} );

    eval {
        my $sth = $self->dbh->prepare(
            "UPDATE $table SET $passwordCol=$passwordsql WHERE $userCol=?");
        $sth->execute( $password, $user );
    };
    if ($@) {
        $self->lmLog( "DBI password modification error: $@", 'error' );
        return 0;
    }

    return 1;
}

1;
