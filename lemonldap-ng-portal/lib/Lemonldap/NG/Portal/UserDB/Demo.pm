## @file
# Demo userDB mechanism

## @class
# Demo userDB mechanism class
package Lemonldap::NG::Portal::UserDB::Demo;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_USERNOTFOUND);

extends 'Lemonldap::NG::Common::Module';

our $VERSION = '2.0.0';

# Sample accounts from Doctor Who characters
has demoAccounts => (
    is      => 'rw',
    default => sub {
        {
            'rtyler' => {
                'uid'  => 'rtyler',
                'cn'   => 'Rose Tyler',
                'mail' => 'rtyler@badwolf.org',
            },
            'msmith' => {
                'uid'  => 'msmith',
                'cn'   => 'Mickey Smith',
                'mail' => 'msmith@badwolf.org',
            },
            'dwho' => {
                'uid'  => 'dwho',
                'cn'   => 'Doctor Who',
                'mail' => 'dwho@badwolf.org',
            },
        };
    }
);

# INITIALIZATION

# Check AuthDemo use
sub init {
    my $self = shift;

    unless ( $self->p->getModule( undef, 'auth' ) =~ /Demo/ ) {
        $self->p->error("Use UserDB::Demo only with Auth::Demo");
    }

    1;
}

# RUNNING METHODS

## @apmethod int getUser()
# Check known accounts
# @return Lemonldap::NG::Portal constant
sub getUser {
    my ( $self, $req ) = @_;

    # Search by login
    if ( $req->user ) {
        return PE_OK
          if ( defined $self->demoAccounts->{ $req->user } );
    }

    # Search by mail
    if ( $req->{mail} ) {
        return PE_OK
          if (
            ( $req->{user} ) =
            grep { $self->demoAccounts->{$_}->{mail} eq $req->{mail} }
            keys %{ $self->demoAccounts }
          );
    }

    PE_USERNOTFOUND;
}

## @apmethod int setSessionInfo()
# Get sample data
# @return Lemonldap::NG::Portal constant
sub setSessionInfo {
    my ( $self, $req ) = @_;

    my %vars = ( %{ $self->conf->{exportedVars} },
        %{ $self->conf->{demoExportedVars} } );
    while ( my ( $k, $v ) = each %vars ) {
        $req->{sessionInfo}->{$k} = $self->demoAccounts->{ $req->{user} }->{$v}
          || "";
    }

    PE_OK;
}

## @apmethod int setGroups()
# Do nothing
# @return Lemonldap::NG::Portal constant
sub setGroups {
    PE_OK;
}

1;
