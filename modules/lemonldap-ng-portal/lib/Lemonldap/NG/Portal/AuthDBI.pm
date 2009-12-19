##@file
# DBI authentication backend file

##@class
# LDAP authentication backend class
package Lemonldap::NG::Portal::AuthDBI;

use Lemonldap::NG::Portal::Simple;
use base qw(Lemonldap::NG::Portal::_WebForm Lemonldap::NG::Portal::_DBI);

our $VERSION = '0.1';

## @apmethod int authInit()
# Check DBI paramaters
#@return Lemonldap::NG::Portal constant
sub authInit {
    my $self = shift;
    unless ($self->{dbiAuthChain}
        and $self->{dbiAuthTable}
        and $self->{dbiAuthUser}
        and $self->{dbiAuthPassword}
        and $self->{dbiAuthLoginCol}
        and $self->{dbiAuthPasswordCol} )
    {
        $self->lmLog( "Missing configuration parameters for DBI authentication",
            'error' );
        return PE_ERROR;
    }

    PE_OK;
}

## @apmethod int authenticate()
# Find row in DBI backend with user and password criterions
#@return Lemonldap::NG::Portal constant
sub authenticate {
    my $self = shift;

    # Connect
    my $dbh =
      $self->dbh( $self->{dbiAuthChain}, $self->{dbiAuthUser},
        $self->{dbiAuthPassword} );
    return PE_ERROR unless $dbh;

    # Check credentials
    my $table       = $self->{dbiAuthTable};
    my $loginCol    = $self->{dbiAuthLoginCol};
    my $passwordCol = $self->{dbiAuthPasswordCol};
    my $user        = $self->{user};
    my $password    = $self->{password};
    $user     =~ s/'/''/g;
    $password =~ s/'/''/g;

    # Manage password hash
    if ( $self->{dbiAuthPasswordHash} =~ /^(md5|sha|sha1)$/i ) {
        $self->lmLog(
            "Using " . uc( $self->{dbiAuthPasswordHash} ) . " to hash password",
            'debug'
        );
        $password = uc( $self->{dbiAuthPasswordHash} ) . "('$password')";
    }
    else {
        $self->lmLog( "No valid password hash, using clear text for password",
            'debug' );
        $password = "'$password'";
    }

    my @rows = ();
    eval {
        my $sth = $dbh->prepare(
"SELECT $loginCol FROM $table WHERE $loginCol='$user' AND $passwordCol=$password"
        );

        $sth->execute();

        @rows = $sth->fetchrow_array();
    };
    if ($@) {
        $self->lmLog( "DBI error: $@", 'error' );
        return PE_ERROR;
    }

    if ( @rows == 1 ) {
        $self->lmLog( "One row returned by SQL query", 'debug' );
        return PE_OK;
    }
    else {
        $self->lmLog( "Bad password for $user", 'error' );
        return PE_BADCREDENTIALS;
    }
}

1;
