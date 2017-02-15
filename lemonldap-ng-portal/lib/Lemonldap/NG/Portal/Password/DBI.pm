package Lemonldap::NG::Portal::Password::DBI;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_PASSWORD_OK PE_ERROR);

extends 'Lemonldap::NG::Portal::Password::Base',
  'Lemonldap::NG::Portal::Lib::DBI';

our $VERSION = '2.0.0';

sub init {
    $_[0]->Lemonldap::NG::Portal::Password::Base::init
      and $_[0]->Lemonldap::NG::Portal::Lib::DBI::init;
}

sub confirm {
    my ( $self, $req, $pwd ) = @_;
    return $self->check_password( $req->user, $pwd );
}

sub modifyPassword {
    my ( $self, $req, $pwd ) = @_;
    eval {
        $self->dbh->prepare( 'UPDATE '
              . $self->conf->{dbiAuthTable} . ' SET '
              . $self->conf->{dbiAuthPasswordCol} . '='
              . $self->hash_password( "?", $self->conf->{dbiAuthPasswordHash} )
              . ' WHERE '
              . $self->conf->{dbiAuthLoginCol}
              . '=?' )->execute( $pwd, $req->user );
    };
    if ($@) {

        # If connection isn't available, error is displayed by dbh()
        $self->logger->error("DBI password modification error: $@")
          if ( $self->_dbh );
        return PE_ERROR;
    }
    else {
        return PE_PASSWORD_OK;
    }
}

1;
