package Lemonldap::NG::Portal::UserDB::Facebook;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_MISSINGREQATTR);

extends 'Lemonldap::NG::Portal::Main::Module';

our $VERSION = '2.0.0';

has vars => (
    is      => 'rw',
    builder => sub {
        return {
            %{ $_[0]->conf->{exportedVars} },
            %{ $_[0]->conf->{facebookExportedVars} }
        };
    }
);

sub init {
    my ($self) = @_;
    unless ( $self->p->getModule('auth') =~ /^Facebook/ ) {
        $self->lmLog(
"UserDBFacebook isn't useable unless authentication module is set to Facebook",
            'error'
        );
        return 0;
    }
    return 1;
}

sub getUser {

    # All is done by Auth::Facebook
    PE_OK;
}

sub setSessionInfo {
    my ( $self, $req ) = @_;

    foreach my $k ( keys %{ $self->vars } ) {
        my $v        = $self->{vars}->{$k};
        my $attr     = $k;
        my $required = ( $attr =~ s/^!// ) ? 1 : 0;
        $req->{sessionInfo}->{$attr} = $req->datas->{_facebookDatas}->{$v};
        if ( $required and not( defined $self->{sessionInfo}->{$attr} ) ) {
            $self->lmLog(
"Required parameter $v is not provided by Facebook server, aborted",
                'warn'
            );

            $req->mustRedirect(0);
            return PE_MISSINGREQATTR;
        }
    }
    PE_OK;
}

sub setGroups {
    PE_OK;
}

1;
