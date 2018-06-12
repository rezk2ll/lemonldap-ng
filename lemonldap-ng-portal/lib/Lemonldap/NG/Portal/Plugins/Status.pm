# Status plugin
#
# this plugin adds /portalStatus entrypoint which display session count
# by category

package Lemonldap::NG::Portal::Plugins::Status;

use strict;
use Mouse;
use JSON qw(from_json);
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
    if ( my $p = $self->p->HANDLER->tsv->{statusPipe} ) {
        $p->print("STATUS json=1\n");
        my $buf;
        $p = $self->p->HANDLER->tsv->{statusOut};
        while ( $p->getline ) {
            last if (/^END$/);
            $buf .= $_;
        }
        if ($buf) {
            eval { $res = from_json( $buf, { allow_nonref => 1 } ) };
            if ($@) {
                $self->logger->error("JSON error: $@");
                $self->logger->error("JSON: $buf");
            }
            foreach (qw(total average)) {
                if ( $res->{$_} ) {
                    foreach my $k ( keys %{ $res->{$_} } ) {
                        delete $res->{$_}->{$k} unless ( $k =~ /^PORTAL/ );
                    }
                }
            }
        }
    }
    foreach my $type (qw(global persistent cas saml oidc)) {
        if ( $self->conf->{"${type}Storage"} ) {
            my %modOpts = (
                %{ $self->conf->{"${type}StorageOptions"} },
                backend => $self->conf->{"${type}Storage"}
            );
            eval {
                my $sessions = Lemonldap::NG::Common::Apache::Session->searchOn(
                    \%modOpts,
                    _session_kind => 'SSO',
                    '_session_id'
                );
                if (%$sessions) {
                    my @s = keys %$sessions;
                    $res->{storage}->{$type} = @s;
                }
            };
        }
    }
    return $self->p->sendJSONresponse( $req, $res );
}

1;
