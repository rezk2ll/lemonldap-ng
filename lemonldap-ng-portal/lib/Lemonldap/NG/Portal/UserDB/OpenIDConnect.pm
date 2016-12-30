package Lemonldap::NG::Portal::UserDB::OpenIDConnect;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_BADCREDENTIALS
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Common::Module', 'Lemonldap::NG::Portal::Lib::OpenIDConnect';

# INITIALIZATION

sub init {
    my ($self) = @_;
}

# RUNNING METHODS

# Does nothing
sub getUser {
    my ( $self, $req ) = @_;
    my $op   = $req->datas->{_oidcOPCurrent};

    my $access_token = $req->datas->{access_token};

    my $userinfo_content = $self->getUserInfo( $op, $access_token );

    unless ($userinfo_content) {
        $self->lmLog( "No User Info content", 'warn' );
        return PE_OK;
    }

    $self->lmLog( "UserInfo received: $userinfo_content", 'debug' );

    $req->datas->{OpenIDConnect_user_info} =
      $self->decodeJSON($userinfo_content);

    # Check that received sub is the same than current user
    unless ( $req->datas->{OpenIDConnect_user_info}->{sub} eq $req->{user} ) {
        $self->lmLog( "Received sub do not match current user", 'error' );
        return PE_BADCREDENTIALS;
    }

    return PE_OK;
}

# Get all required attributes
sub setSessionInfo {
    my ( $self, $req ) = @_;
    my $op   = $req->datas->{_oidcOPCurrent};

    my %vars = (
        %{ $self->conf->{exportedVars} },
        %{ $self->conf->{oidcOPMetaDataExportedVars}->{$op} }
    );

    while ( my ( $k, $v ) = each %vars ) {
        $req->{sessionInfo}->{$k} =
          $req->datas->{OpenIDConnect_user_info}->{$v}
          || "";
    }

    PE_OK;
}

# Does nothing
sub setGroups {
    PE_OK;
}

1;
__END__
