package Lemonldap::NG::Portal::UserDB::OpenID;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_MISSINGREQATTR
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Common::Module',
  'Lemonldap::NG::Portal::Lib::OpenIDConnect';

# INITIALIZATION

sub init {
    my ($self) = @_;
    unless ( $self->p->getModule( undef, 'auth' ) =~ /^OpenID\b/ ) {
        $self->error(
'UserDBOpenID isn\'t useable unless authentication module is set to OpenID'
        );
        return 0;
    }
    return 1;
}

# RUNNING METHODS

sub getUser {
    PE_OK;
}

sub setSessionInfo {
    my ( $self, $req ) = @_;
    my %vars = (
        %{ $self->conf->{exportedVars} },
        %{ $self->conf->{openIdExportedVars} }
    );
    while ( my ( $k, $v ) = each %vars ) {
        my $attr     = $k;
        my $required = ( $attr =~ s/^!// );
        if ( $v =~ Lemonldap::NG::Common::Regexp::OPENIDSREGATTR() ) {
            my $p = $req->param("openid.sreg.$v");
            if ( $required and not defined $p ) {
                $self->lmLog(
"Required parameter $attr is not provided by OpenID server, aborted",
                    'warn'
                );
                return PE_MISSINGREQATTR;
            }
            $self->{sessionInfo}->{$attr} = $p;
        }
        else {
            $self->lmLog(
"Ignoring attribute $v which is not a valid OpenID SREG attribute",
                'warn'
            );
        }
    }
    PE_OK;
}

# Does nothing
sub setGroups {
    PE_OK;
}

1;
