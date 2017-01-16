# Status plugin
#
# this plugin adds /portalStatus entrypoint which display session count
# by category

package Lemonldap::NG::Portal::Plugins::Status;

use strict;
use Mouse;
use MIME::Base64;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

sub init {
    my ($self) = @_;
    $self->addUnauthRoute( portalStatus => 'status', ['GET'] );
    $self->addAuthRoute( portalStatus => 'status', ['GET'] );
    return 1;
}

sub status {
    my ( $self, $req ) = @_;
    my $res = {};
    foreach my $type (qw(global persistent cas saml oidc)) {
        if ( $self->conf->{"${type}Storage"} ) {
            my %modOpts = (
                %{ $self->conf->{"${type}StorageOptions"} },
                backend => $self->conf->{"${type}Storage"}
            );
            my $sessions = Lemonldap::NG::Common::Apache::Session->searchOn(
                \%modOpts,
                _session_kind => 'SSO',
                '_session_id'
            );
            if (%$sessions) {
                my @s = keys %$sessions;
                $res->{$type} = @s;
            }
        }
    }
    return $self->p->sendJSONresponse($req,$res);
}

1;
