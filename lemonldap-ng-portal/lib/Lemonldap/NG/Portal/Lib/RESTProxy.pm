package Lemonldap::NG::Portal::Lib::RESTProxy;

use strict;
use JSON;
use Mouse;
use LWP::UserAgent;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR PE_BADCREDENTIALS);
use Lemonldap::NG::Common::FormEncode;

our $VERSION = '2.0.0';

has ua => (
    is      => 'rw',
    default => sub {
        my $ua = LWP::UserAgent->new;
        $ua->default_header( Accept => 'application/json' );
        return $ua;
    }
);

# INITIALIZATION

sub init {
    my ($self) = @_;
    $self->conf->{remoteCookieName} ||= $self->conf->{cookieName};
    $self->conf->{proxySessionService} ||=
      $self->conf->{proxyAuthService} . '/mysession/';

    unless ( defined $self->conf->{proxyAuthService} ) {
        $self->error("Missing proxyAuthService parameter");
        return 0;
    }
    return 1;
}

no warnings 'once';
*authenticate = \&getUser;

sub getUser {
    my ( $self, $req ) = @_;
    return PE_OK if ( $req->datas->{_proxyQueryDone} );
    $self->lmLog( 'Proxy push auth to ' . $self->conf->{proxyAuthService},
        'debug' );
    my $resp = $self->ua->post( $self->conf->{proxyAuthService},
        { user => $req->{user}, password => $req->datas->{password} } );
    unless ( $resp->is_success ) {
        $self->lmLog(
            'Unable to query authentication service: ' . $resp->status_line,
            'error' );
        return PE_ERROR;
    }
    $self->lmLog( 'Proxy gets a response', 'debug' );
    my $res = eval { JSON::from_json( $resp->content ) };
    if ($@) {
        $self->lmLog("Bad content: $@");
        return PE_ERROR;
    }
    $req->sessionInfo->{_proxyQueryDone}++;
    unless ( $res->{result} ) {
        $self->p->userNotice("Authentication refused for $req->{user}");
        return PE_BADCREDENTIALS;
    }
    $req->sessionInfo->{_proxyCookies} = join '; ',
      map { s/;.*$// } $resp->header('Set-Cookie');
    $self->lmLog(
        'Store cookies in session (' . $req->sessionInfo->{_proxyCookies} . ')',
        'debug'
    );
    PE_OK;
}

sub setSessionInfo {
    my ( $self, $req ) = @_;
    return PE_OK if ( $req->datas->{_setSessionInfoDone} );
    my $q = HTTP::Request->new(
        GET    => $self->conf->{proxySessionService},
        Cookie => $req->sessionInfo->{_proxyCookies}
    );
    my $resp = $self->ua->get($q);
    unless ( $resp->is_success ) {
        $self->lmLog( 'Unable to query session service: ' . $resp->status_line,
            'error' );
        return PE_ERROR;
    }
    $self->lmLog( 'Proxy gets a response', 'debug' );
    my $res = eval { JSON::from_json( $resp->content ) };
    if ($@) {
        $self->lmLog("Bad content: $@");
        return PE_ERROR;
    }
    foreach ( keys %$res ) {
        $req->{sessionInfo}->{$_} ||= $res->{$_} unless (/^_/);
    }
    $req->datas->{_setSessionInfoDone}++;
    PE_OK;
}

1;

