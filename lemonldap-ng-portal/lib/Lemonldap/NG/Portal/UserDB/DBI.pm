package Lemonldap::NG::Portal::UserDB::DBI;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR PE_BADCREDENTIALS);

extends 'Lemonldap::NG::Portal::Lib::DBI';

our $VERSION = '2.0.11';

# PROPERTIES

has exportedVars => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {
        my $conf = $_[0]->{conf};
        return { %{ $conf->{exportedVars} }, %{ $conf->{dbiExportedVars} } };
    }
);

# RUNNING METHODS

sub getUser {
    my ( $self, $req, %args ) = @_;
    my $table = $self->table;
    my $pivot = $args{useMail} ? $self->mailField : $self->pivot;
    my $user  = $req->{user};
    my $sth;
    eval {
        $sth = $self->dbh->prepare("SELECT * FROM $table WHERE $pivot=?");
        $sth->execute($user);
    };
    if ($@) {

        # If connection isn't available, error is displayed by dbh()
        $self->logger->error("DBI error: $@") if ( $self->_dbh );
        eval { $self->p->_authentication->setSecurity($req) };
        return PE_ERROR;
    }
    unless ( $req->data->{dbientry} = $sth->fetchrow_hashref() ) {
        $self->userLogger->warn("User $user not found");
        eval { $self->p->_authentication->setSecurity($req) };
        return PE_BADCREDENTIALS;
    }
    PE_OK;
}

sub findUser {
    my ( $self, $req, %args ) = @_;
    my $plugin =
      $self->p->loadedModules->{"Lemonldap::NG::Portal::Plugins::FindUser"};
    my ( $searching, $excluding ) = $plugin->retreiveFindUserParams($req);
    return PE_OK unless scalar @$searching;

    my $table   = $self->table;
    my $pivot   = $args{useMail} ? $self->mailField : $self->pivot;
    my $request = 'SELECT $pivot FROM $table WHERE ';
    my @args;
    my $sth;
    foreach (@$searching) {
        if ( $_->{value} ) {
            $request .= '$' . $_->{key} . '=? AND ';
            push @args, $_->{value};
        }
    }
    foreach (@$excluding) {
        if ( $_->{value} ) {
            $request .= '$' . $_->{key} . '!=? AND ';
            push @args, $_->{value};
        }
    }
    $request =~ s/AND\s$//;

    $self->logger->debug("DBI UserDB built condition: $request");
    eval {
        $sth = $self->dbh->prepare(eval "$request");
        $sth->execute(@args);
    };
    eval { $self->p->_authentication->setSecurity($req) };

    if ($@) {

        # If connection isn't available, error is displayed by dbh()
        $self->logger->error("DBI error: $@") if ( $self->_dbh );
        return PE_ERROR;
    }
    if ( my $results = $sth->fetchrow_arrayref() ) {
        my $rank = rand( scalar @$results );
        $self->logger->debug(
            'DBI UserDB number of result(s): ' . scalar @$results );
        $self->logger->debug("Demo UserDB random rank: $rank");
        $req->{findUser} = $results->[$rank];
    }

    PE_OK;
}

sub setSessionInfo {
    my ( $self, $req ) = @_;

    # Set _user unless already defined
    $req->{sessionInfo}->{_user} ||= $req->user;

    foreach my $var ( keys %{ $self->exportedVars } ) {
        my $attr = $self->exportedVars->{$var};
        $req->{sessionInfo}->{$var} = $req->data->{dbientry}->{$attr}
          if ( defined $req->data->{dbientry}->{$attr} );
    }
    PE_OK;
}

sub setGroups {
    PE_OK;
}

1;
