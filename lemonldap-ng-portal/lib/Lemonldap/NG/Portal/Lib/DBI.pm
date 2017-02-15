##@file
# DBI common functions

##@class
# DBI common functions
package Lemonldap::NG::Portal::Lib::DBI;

use DBI;
use strict;
use Mouse;

extends 'Lemonldap::NG::Common::Module';

our $VERSION = '2.0.0';

# PROPERTIES

# _dbh object: DB connection object
has _dbh => (
    is      => 'rw',
    lazy    => 1,
    builder => 'dbh',
);

sub dbh {
    my $conf = $_[0]->{conf};
    $_[0]->{_dbh} = eval {
        DBI->connect_cached(
            $conf->{dbiAuthChain}, $conf->{dbiAuthUser},
            $conf->{dbiAuthPassword}, { RaiseError => 1 }
        );
    };
    if ($@) {
        $_[0]->{p}->logger->error("DBI connection error: $@");
        return 0;
    }
    return $_[0]->{_dbh};
}

# INITIALIZATION

# All DBI modules have just to verify that DBI connection is available
sub init {
    my ($self) = @_;
    return $self->_dbh;
}

# RUNNING METHODS

# Return hashed password for use in SQL statement
# @param password clear password
# @param hash hash mechanism
# @return SQL statement string
sub hash_password {
    my ( $self, $password, $hash ) = @_;
    if ( $hash =~ /^(md5|sha|sha1|encrypt)$/i ) {
        $self->logger->debug( "Using " . uc($hash) . " to hash password" );
        return uc($hash) . "($password)";
    }
    else {
        $self->logger->notice(
            "No valid password hash, using clear text for password");
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

        # If connection isn't available, error is displayed by dbh()
        $self->logger->error("DBI error: $@") if ( $self->_dbh );
        return 0;
    }

    if ( @rows == 1 ) {
        $self->logger->debug("One row returned by SQL query");
        return 1;
    }
    else {
        $self->userLogger->warn("Bad password for $user");
        return 0;
    }

}

1;
