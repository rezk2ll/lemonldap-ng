package Lemonldap::NG::Portal::UserDB::WebID;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_ERROR
  PE_MISSINGREQATTR
  PE_OK
);

extends 'Lemonldap::NG::Common::Module';

our $VERSION = '2.0.0';

# INITIALIZATION

sub init {
    1;
}

# RUNNING METHODS

sub getUser {
    PE_OK;
}

sub setSessionInfo {
    my ( $self, $req ) = @_;
    unless ( $req->datas->{_webid} ) {
        $self->lmLog( 'No webid object found', 'error' );
        return PE_ERROR;
    }

    my %vars = (
        %{ $self->conf->{exportedVars} },
        %{ $self->conf->{webIDExportedVars} }
    );
    while ( my ( $k, $v ) = each %vars ) {
        my $attr = $k;
        my $req;
        $attr =~ s/^!// and $req = 1;
        eval { $req->{sessionInfo}->{$attr} = $req->datas->{_webid}->get($v) };
        $self->lmLog( "Unable to get $v from FOAF document: $@", 'error' )
          if ($@);
        if ( $req and not $req->{sessionInfo}->{$attr} ) {
            $self->p->userNotice(
                "Required attribute $v is missing (user: $req->{user})");
            return PE_MISSINGREQATTR;
        }
    }
    PE_OK;
}

sub setGroups {
    PE_OK;
}

1;
