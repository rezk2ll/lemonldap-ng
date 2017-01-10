package Lemonldap::NG::Portal::Lib::RESTProxy;

use strict;
use JSON;
use Mouse;
use LWP::UserAgent;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR PE_BADCREDENTIALS);
use Lemonldap::NG::Common::FormEncode;

our $VERSION = '2.0.0';

has ua => ( is => 'rw' );

# INITIALIZATION

sub init {
    my ($self) = @_;
    $self->conf->{remoteCookieName} ||= $self->conf->{cookieName};
    $self->conf->{proxySessionService} ||=
      $self->conf->{proxyAuthService} . '/mysession';
    $self->conf->{proxySessionService} =~ s#/*$##;
    $self->ua( LWP::UserAgent->new );
    $self->ua->default_header( Accept => 'application/json' );

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
      map { s/;.*$//; $_ } $resp->header('Set-Cookie');
    $self->lmLog(
        'Store remote cookies in session ('
          . $req->sessionInfo->{_proxyCookies} . ')',
        'debug'
    );
    PE_OK;
}

sub setSessionInfo {
    my ( $self, $req ) = @_;
    return PE_OK if ( $req->datas->{_setSessionInfoDone} );
    my $q = HTTP::Request->new(
        GET => $self->conf->{proxySessionService} . '/global',
        [
            Cookie => $req->sessionInfo->{_proxyCookies},
            Accept => 'application/json'
        ]
    );
    my $resp = $self->ua->request($q);
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

sub authLogout {
    my ( $self, $req ) = @_;
    $self->lmLog( 'Proxy ask logout to '. $self->conf->{proxyAuthService},'debug');
    my $q = HTTP::Request->new(
        GET => $self->conf->{proxyAuthService} . '?logout=1',
        [
            Cookie => $req->sessionInfo->{_proxyCookies},
            Accept => 'application/json'
        ]
    );
    my $resp = $self->ua->request($q);
    return PE_OK;
}

1;

