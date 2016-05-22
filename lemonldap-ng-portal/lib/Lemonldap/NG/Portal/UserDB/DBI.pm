package Lemonldap::NG::Portal::UserDB::DBI;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR PE_BADCREDENTIALS);

extends 'Lemonldap::NG::Portal::Lib::DBI';

our $VERSION = '2.0.0';

has table => (
    is      => 'rw',
    builder => sub {
        my $conf = $_[0]->{conf};
        return $conf->{dbiUserTable} || $conf->{dbiAuthTable};
    }
);

has pivot => (
    is      => 'rw',
    builder => sub {
        my $conf = $_[0]->{conf};
        return $conf->{userPivot} || $conf->{dbiAuthLoginCol};
    }
);

has exportedVars => (
    is      => 'rw',
    builder => sub {
        my $conf = $_[0]->{conf};
        return { %{ $conf->{exportedVars} }, %{ $conf->{dbiExportedVars} } };
    }
);

sub init {
    my $self = shift;
    return $self->dbh;
}

sub getUser {
    my ( $self, $req ) = @_;
    my $table = $self->table;
    my $pivot = $self->pivot;
    my $user  = $req->{user};
    my $sth;
    eval {
        $sth = $self->dbh->prepare("SELECT * FROM $table WHERE $pivot=?");
        $sth->execute($user);
    };
    if ($@) {
        $self->lmLog( "DBI error: $@", 'error' );
        return PE_ERROR;
    }
    unless ( $req->datas->{entry} = $sth->fetchrow_hashref() ) {
        $self->p->userNotice("User $user not found");
        return PE_BADCREDENTIALS;
    }
    PE_OK;
}

sub setSessionInfo {
    my ( $self, $req ) = @_;

    # Set _user unless already defined
    $req->{sessionInfo}->{_user} ||= $req->user;

    foreach my $var ( keys %{ $self->exportedVars } ) {
        my $attr = $self->exportedVars->{$var};
        $req->{sessionInfo}->{$var} = $req->datas->{entry}->{$attr}
          if ( defined $self->{entry}->{$attr} );
    }
    PE_OK;
}

sub setGroups {
    PE_OK;
}

1;
