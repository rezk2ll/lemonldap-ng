package Lemonldap::NG::Portal::Auth::Kerberos;

use strict;
use Mouse;
use GSSAPI;
use MIME::Base64;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_BADCREDENTIALS
  PE_ERROR
  PE_OK
  PE_SENDRESPONSE
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base';

# INITIALIZATION

sub init {
    my ($self) = @_;
}

sub extractFormInfo {
    my ( $self, $req ) = @_;
    my $auth = $req->env->{HTTP_AUTHORIZATION};
    unless ($auth) {
        $req->response(
            [
                401,
                [ 'WWW-Authenticate' => 'Negotiate' ],
                ['Authentication required']
            ]
        );
        return PE_SENDRESPONSE;
    }
    if ( $auth !~ /^Negotiate (.*)$/ ) {
        $self->userLogger->error('Bad authorization header');
        return PE_BADCREDENTIALS;
    }
    my $data;
    eval { $data = MIME::Base64::decode($1) };
    if ($@) {
        $self->userLogger->error( 'Bad authorization header: ' . $@ );
        return PE_BADCREDENTIALS;
    }
    my $server_context;
    my $status = GSSAPI::Context::accept(
        $server_context,
        GSS_C_NO_CREDENTIAL,
        $data,
        GSS_C_NO_CHANNEL_BINDINGS,
        my $gss_client_name,
        my $out_mech,
        my $gss_output_token,
        my $out_flags,
        my $out_time,
        my $gss_delegated_cred
    );
    unless ($status) {
        $self->logger->error('Unable to accept security context');
        return PE_ERROR;
    }
    my $client_name;
    $status = $gss_client_name->display($client_name);
    unless ($status) {
        $self->logger->error('Unable to display KRB client name');
        foreach ( $status->generic_message(), $status->specific_message() ) {
            $self->logger->error($_);
        }
        return PE_ERROR;
    }
    $req->user($client_name);
    return PE_OK;
}

sub authenticate {
    PE_OK;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    $req->{sessionInfo}->{authenticationLevel} = $self->conf->{SSLAuthnLevel};
    PE_OK;
}

sub getDisplayType {
    return "logo";
}

1;
