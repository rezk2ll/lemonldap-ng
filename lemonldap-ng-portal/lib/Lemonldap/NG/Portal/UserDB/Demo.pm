## @file
# Demo userDB mechanism

## @class
# Demo userDB mechanism class
package Lemonldap::NG::Portal::UserDB::Demo;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_BADCREDENTIALS);

extends 'Lemonldap::NG::Common::Module';

our $VERSION = '2.0.11';

# Sample accounts from Doctor Who characters
our %demoAccounts = (
    'dwho' => {
        uid  => 'dwho',
        cn   => 'Doctor Who',
        mail => 'dwho@badwolf.org',
    },
    'rtyler' => {
        uid  => 'rtyler',
        cn   => 'Rose Tyler',
        mail => 'rtyler@badwolf.org',
    },
    'msmith' => {
        uid  => 'msmith',
        cn   => 'Mickey Smith',
        mail => 'msmith@badwolf.org',
    },
);

our %demoGroups = (
    'timelords'  => [qw(dwho)],
    'earthlings' => [qw(msmith rtyler)],
    'users'      => [qw(dwho msmith rtyler)],
);

# INITIALIZATION

sub init {
    1;
}

# RUNNING METHODS

## @apmethod int getUser()
# Check known accounts
# @return Lemonldap::NG::Portal constant
sub getUser {
    my ( $self, $req, %args ) = @_;

    if ( $args{useMail} ) {
        my ($user) = grep { $demoAccounts{$_}->{mail} eq $req->{user} }
          keys %demoAccounts;
        if ($user) {
            $req->{user} = $user;
            return PE_OK;
        }
    }
    else {
        return PE_OK
          if ( defined $demoAccounts{ $req->user } );
    }

    eval { $self->p->_authentication->setSecurity($req) };
    PE_BADCREDENTIALS;
}

## @apmethod int findUser()
# Search for accounts
# @return Lemonldap::NG::Portal constant
sub findUser {
    my ( $self, $req, %args ) = @_;
    my $plugin =
      $self->p->loadedModules->{"Lemonldap::NG::Portal::Plugins::FindUser"};
    my ( $searching, $excluding ) = $plugin->retreiveFindUserParams($req);
    eval { $self->p->_authentication->setSecurity($req) };
    return PE_OK unless scalar @$searching;

    my $cond = '';
    foreach (@$searching) {
        $cond .= '$' . $_->{key} . " eq '$_->{value}' && " if $_->{value};
    }
    foreach (@$excluding) {
        $cond .= '$' . $_->{key} . " ne '$_->{value}' && " if $_->{value};
    }
    $cond =~ s/&&\s$//;

    $self->logger->debug("Demo UserDB built condition: $cond");
    my @results = map {
        my $uid  = $demoAccounts{$_}->{uid};
        my $cn   = $demoAccounts{$_}->{cn};
        my $mail = $demoAccounts{$_}->{mail};
        my $guy  = $demoAccounts{$_}->{guy} // 'good';
        my $type = $demoAccounts{$_}->{type} // 'character';
        eval "($cond)"
          ? $_
          : ();
    } keys %demoAccounts;

    $self->logger->debug(
        'Demo UserDB number of result(s): ' . scalar @results );
    if ( scalar @results ) {
        my $rank = rand( scalar @results );
        $self->logger->debug("Demo UserDB random rank: $rank");
        $self->userLogger->info(
            "FindUser: Demo UserDB returns $results[$rank]");
        $req->{findUser} = $results[$rank];
    }

    PE_OK;
}

## @apmethod int setSessionInfo()
# Get sample data
# @return Lemonldap::NG::Portal constant
sub setSessionInfo {
    my ( $self, $req ) = @_;

    my %vars = ( %{ $self->conf->{exportedVars} },
        %{ $self->conf->{demoExportedVars} } );
    while ( my ( $k, $v ) = each %vars ) {
        $req->{sessionInfo}->{$k} = $demoAccounts{ $req->{user} }->{$v};
    }

    PE_OK;
}

## @apmethod int setGroups()
# Do nothing
# @return Lemonldap::NG::Portal constant
sub setGroups {
    my ( $self, $req ) = @_;
    my $user    = $req->user;
    my $groups  = $req->sessionInfo->{groups} || '';
    my $hGroups = $req->sessionInfo->{hGroups} || {};
    for my $grp ( keys %demoGroups ) {
        if ( grep { $_ eq $user } @{ $demoGroups{$grp} } ) {
            $hGroups->{$grp} = { 'name' => $grp };
            $groups =
              ($groups)
              ? $groups . $self->conf->{multiValuesSeparator} . $grp
              : $grp;
        }
    }
    $req->sessionInfo->{groups}  = $groups;
    $req->sessionInfo->{hGroups} = $hGroups;
    PE_OK;
}

1;
