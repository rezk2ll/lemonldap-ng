package Lemonldap::NG::Portal::UserDB::Remote;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Common::Module', 'Lemonldap::NG::Portal::Lib::Remote';

# RUNNING METHODS

*getUser = *Lemonldap::NG::Portal::Lib::Remote::checkRemoteId;

sub setSessionInfo {
    my ( $self, $req ) = @_;
    delete $req->datas->{rSessionInfo}->{_session_id};
    $req->{sessionInfo} = $req->datas->{rSessionInfo};
    PE_OK;
}

sub setGroups {
    PE_OK;
}

1;
