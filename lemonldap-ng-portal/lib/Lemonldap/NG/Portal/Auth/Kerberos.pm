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
    my $file;
    unless ( $file = $self->conf->{krbKeyTab} ) {
        $self->error('Keytab not defined');
        return 0;
    }
    $self->keytab("FILE:$file");
    return 1;
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
    $ENV{KRB5_KTNAME} = $self->keytab;
    my $gss_client_name;
    my $status = GSSAPI::Context::accept(
        my $server_context,
        GSS_C_NO_CREDENTIAL,
        $data,
        GSS_C_NO_CHANNEL_BINDINGS,
        $gss_client_name,
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
    $self->userLogger->notice("$client_name authentified by Kerberos");
    $req->user($client_name);
    return PE_OK;
}

sub authenticate {
    PE_OK;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    $req->{sessionInfo}->{authenticationLevel} = $self->conf->{krbAuthnLevel};
    PE_OK;
}

sub getDisplayType {
    return "logo";
}

1;
