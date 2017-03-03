# Token server plugin for underlying requests
#
# This plugin handle /tokenfor path to give to applications tokens to query
# other web applications on behalf of the connected user (second apps are
# protected by specific handler).
#
# 0) Administrator set "sTokenScopes" parameter in the manager. Each entry is
#    a couple of key/value where:
#    - key is the name of the list
#    - value is a comma separated list of virtualHosts authorizated for this
#      key
#    Token header are also added for App-1 (application that wants to query
#    others on behalf of the connected user)
# 1) App 1 received a token in headers (header is generated using
#    "token($_session_id,'ref')" where ref is a key of "sTokenScopes"
#    configuration parameter).
# 2) It send it to this plugin (request to /tokenfor)
# 3) run() method verify that token is available and return a service token that
#    can be used to request a fixed list of servers. This list is the value of
#    "tokenScope"->{$ref}
# 4) App-1 queries App-2, App-3,... with this token set in "X-Llng-Token" header
# 5) App-2 handler verifies that token is valid for this vhost and accept or
#    not the query

package Lemonldap::NG::Portal::Plugins::ServiceTokenServer;

use strict;
use Mouse;

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

has tokenScopes => (
    is      => 'rw',
    default => sub {
        my $ts = $_[0]->conf->{sTokenScopes} || {};
        my %h = map {
            my $v = $ts->{$_};
            $v =~ s/[, ]+/:/g;
            ( $_ => $v );
        } keys %$ts;
        return \%h;
    }
);

sub init {
    my ($self) = @_;
    $self->addUnauthRoute( tokenfor => 'run', ['POST'] );
    return 1;
}

sub run {
    my ( $self, $req ) = @_;

    # 1. Recover request token
    my $reqToken;
    if ( $req->content_type =~ /json/ ) {
        my $j;
        eval { $j = from_json( $req->content ) };
        if ($@) {
            return $self->p->sendError( $req, 'Bad request', 403 );
        }
        $reqToken = $j->{token};
    }
    else {
        $reqToken = $req->param('token');
    }
    unless ($reqToken) {
        return $self->p->sendError( $req, 'Missing token', 403 );
    }

    # 2. Uncipher request token
    my $s = $self->conf->{cipher}->decrypt($reqToken)
      or return $self->p->sendError( $req, 'Bad token', 403 );

    # 3. Verify time
    my ( $t, $_session_id, $ref ) = split /:/, $s;
    unless ( $t <= time and $t > time - 15 ) {
        return $self->p->sendError( $req, 'Token expired', 403 );
    }
    unless ( $self->tokenScopes->{$ref} ) {
        return $self->p->sendError( $req, 'Bad reference', 403 );
    }
    my $respToken = $self->conf->{cipher}
      ->encrypt( join ':', time, $_session_id, $self->tokenScopes->{$ref} );
    return $self->p->sendJSONresponse( $req, { sToken => $respToken } );
}

1;
