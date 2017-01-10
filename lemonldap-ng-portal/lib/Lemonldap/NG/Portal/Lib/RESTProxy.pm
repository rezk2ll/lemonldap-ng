package Lemonldap::NG::Portal::Lib::SOAPProxy;

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

    unless ( defined $self->conf->{proxyAuthService} ) {
        $self->error("Missing proxyAuthService parameter");
        return 0;
    }
    return 1;
}

*authenticate = *getUser;

sub getUser {
    my ( $self, $req ) = @_;
    return PE_OK if ( $req->datas->{_proxyQueryDone} );
    my $resp = $self->ua->post( $self->conf->{proxyAuthService},
        { user => $req->{user}, password => $req->datas->{password} } );
    unless ( $resp->is_success ) {
        $self->lmLog(
            'Unable to query authentication service: ' . $resp->status_line,
            'error' );
        return PE_ERROR;
    }
    my $res = eval { JSON::from_json( $resp->content ) };
    if ($@) {
        $self->lmLog("Bad content: $@");
        return PE_ERROR;
    }
    $req->datas->{_proxyQueryDone}++;
    return ( $res->{result} ? PE_OK : PE_BADCREDENTIALS );
}

sub setSessionInfo {
    my ( $self, $req ) = @_;
    return PE_OK if ( $req->datas->{_setSessionInfoDone} );
    my $soap =
      SOAP::Lite->proxy( $self->conf->{proxyAuthService} )
      ->uri('urn:Lemonldap/NG/Common/PSGI/SOAPService');
    my $r = $soap->getAttributes( $req->datas->{_remoteId} );
    if ( $r->fault ) {
        $self->lmLog(
            "Unable to query authentication service" . $r->fault->{faultstring},
            'error'
        );
    }
    my $res = $r->result();
    if ( $res->{error} ) {
        $self->userError("Unable to get attributes for $self->{user} ");
        return PE_ERROR;
    }
    foreach ( keys %{ $res->{attributes} } ) {
        $req->{sessionInfo}->{$_} ||= $res->{attributes}->{$_}
          unless (/^_/);
    }
    $req->datas->{_setSessionInfoDone}++;
    PE_OK;
}

1;

