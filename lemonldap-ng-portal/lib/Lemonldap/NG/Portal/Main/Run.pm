##@class Lemonldap::NG::Portal::Main::Run
# Serve request part of Lemonldap::NG portal
#
# Methods:
#  - handler():    verify that portal configuration is the same that the
#                  underlying handler configuration before launching
#                  Lemonldap::NG::Common::PSGI::Router::handler() (which parse
#                  routes)
#
# Entry points:
#  - "/test": * authenticated() for already authenticated users
#             * pleaseAuth() for others
#  - "/":     * login() ~first access
#             * postLogin(), same for POST requests
#             * authenticatedRequest() for authenticated users
package Lemonldap::NG::Portal::Main::Run;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;
use Lemonldap::NG::Portal::Main::Request;

our $VERSION = '2.0.0';

sub handler {
    my ( $self, $req ) = shift;
    unless ($self->conf->{cfgNum}
        and $self->conf->{cfgNum} eq HANDLER->lmConf->{cfgNum} )
    {
        $self->reloadConf();
    }
    bless $req, 'Lemonldap::NG::Portal::Main::Request';
    return $self->SUPER::handler($req);
}

# CORE REST API

# Methods that handle /test
sub authenticated {
    my ( $self, $req ) = @_;
    return $self->sendJSONresponse( $req, { status => 1 } );
}

sub pleaseAuth {
    my ( $self, $req ) = @_;
    return $self->sendJSONresponse( $req, { status => 0 } );
}

# MAIN ENTRY POINTS

# List constants
sub authProcess { qw(extractFormInfo getUser authenticate) }

sub sessionDatas {
    qw(setSessionInfo setMacros setGroups setPersistentSessionInfo
      setLocalGroups grantSession store buildCookie);
}

sub login {
    my ( $self, $req ) = @_;
    return $req->do(
        $req,
        [
            'rememberArgs', @{ $self->beforeAuth },
            &authProcess,   @{ $self->betweenAuthAndDatas },
            &sessionDatas,  @{ $self->afterdatas },
        ]
    );
}

sub postLogin {
    my ( $self, $req ) = @_;
    return $req->do(
        $req,
        [
            'restoreArgs', @{ $self->beforeAuth },
            &authProcess,  @{ $self->betweenAuthAndDatas },
            &sessionDatas, @{ $self->afterdatas },
        ]
    );
}

sub authenticatedRequest {
    my ( $self, $req ) = @_;
    return $req->do( $req, $self->forAuthUser );
}

sub do {
    my ( $self, $req, $steps ) = @_;
    $req->steps($steps);
    my $err = $self->process($req);

    # TODO: updateStatus
    if ( !$self->conf->{noAjaxHook} and $req->wantJSON ) {
        if ( $err > 0 ) {
            return [
                401,
                [
                    'WWW-Authenticate' => "SSO " . $self->conf->{portal},
                    'Access-Control-Allow-Origin' => '*'
                ],
                []
            ];
        }
        else {
            return $self->senfJSONresponse(
                { result => 1, message => 'Authenticated' } );
        }
    }
    else {
        if ($err) {
            return $self->sendHtml( $req, 'login.tpl' );
        }
        else {
            return $self->autoRedirect($req);
        }
    }
}

sub process {
    my ( $self, $req ) = @_;

    #$req->error(PE_OK);
    my $err = PE_OK;
    while ( my $sub = shift @{ $req->steps } ) {
        last if ( $err = $self->$sub($req) );
    }
    return $err;
}

# TODO in run
#  - mustRedirect

1;
