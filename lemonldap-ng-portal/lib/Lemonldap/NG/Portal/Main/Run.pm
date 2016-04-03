##@class Lemonldap::NG::Portal::Main::Run
# Serve request part of Lemonldap::NG portal
#
# Parts of this file:
#  - response handler
#  - main entry points
#  - running methods
#  - utilities
#
package Lemonldap::NG::Portal::Main::Run;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;
use Lemonldap::NG::Portal::Main::Request;

extends 'Lemonldap::NG::Portal::Main::Process';

use constant HANDLER => 'Lemonldap::NG::Handler::PSGI::API';

our $VERSION = '2.0.0';

# List constants
sub authProcess { qw(extractFormInfo getUser authenticate) }

sub sessionDatas {
    qw(setSessionInfo setMacros setGroups setPersistentSessionInfo
      setLocalGroups store buildCookie);
}

# RESPONSE HANDLER
# ----------------
#
# - check if conf has changed
# - replace Lemonldap::NG::Common::PSGI::Request request by
#   Lemonldap::NG::Portal::Main::Request
# - launch Lemonldap::NG::Common::PSGI::Request::handler()
sub handler {
    my ( $self, $req ) = @_;
    unless ($self->conf->{cfgNum}
        and $self->conf->{cfgNum} eq HANDLER->lmConf->{cfgNum} )
    {
        $self->reloadConf();
    }
    bless $req, 'Lemonldap::NG::Portal::Main::Request';
    return $self->Lemonldap::NG::Common::PSGI::Router::handler($req);
}

# MAIN ENTRY POINTS (declared in Lemonldap::NG::Portal::Main::Init)
# -----------------
#
# Entry points:
#  - "/test": - authenticated() for already authenticated users
#             - pleaseAuth() for others
#  - "/":     - login() ~first access
#             - postLogin(), same for POST requests
#             - authenticatedRequest() for authenticated users

sub authenticated {
    my ( $self, $req ) = @_;
    return $self->sendJSONresponse( $req, { status => 1 } );
}

sub pleaseAuth {
    my ( $self, $req ) = @_;
    return $self->sendJSONresponse( $req, { status => 0 } );
}

sub login {
    my ( $self, $req ) = @_;
    return $self->do(
        $req,
        [
            'controlUrl',  @{ $self->beforeAuth },
            &authProcess,  @{ $self->betweenAuthAndDatas },
            &sessionDatas, @{ $self->afterDatas },
        ]
    );
}

sub postLogin {
    my ( $self, $req ) = @_;
    return $self->do(
        $req,
        [
            'restoreArgs',                   'controlUrl',
            @{ $self->beforeAuth },          &authProcess,
            @{ $self->betweenAuthAndDatas }, &sessionDatas,
            @{ $self->afterdatas },
        ]
    );
}

sub authenticatedRequest {
    my ( $self, $req ) = @_;
    return $self->do( $req, $self->forAuthUser );
}

# RUNNING METHODS
# ---------------

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
            return $self->sendHtml( $req, $req->template || 'login' );
        }
        else {
            return $self->autoRedirect($req);
        }
    }
}

# Utilities
# ---------

sub getModule {
    my ( $self, $req, $type ) = @_;
    if (
        my $mod = {
            auth     => '_authentication',
            user     => '_userDB',
            password => '_passwordDB'
        }->{$type}
      )
    {
        if ( $self->$mod->can('name') ) {
            return $self->$mod->can('name');
        }
        else {
            return ref( $self->$mod );
        }
    }
    elsif ( $type eq 'issuer' ) {
        return $req->{_activeIssuerDB};
    }
    else {
        die "Unknown type $type";
    }
}

sub autoRedirect {
    my ( $self, $req ) = @_;

    # Set redirection URL if needed
    $req->datas->{urldc} ||= $self->conf->{portal} if ( $req->mustRedirect );

    # Redirection should be made if urldc defined
    if ( $req->datas->{urldc} ) {
        return [ 302, [ Location => $req->datas->{urldc} ], [] ];
    }
    else {
        return $self->sendHtml( $req->template || 'menu' );
    }
}

# Check if an URL's domain name is declared in LL::NG config or is declared as
# trusted domain
sub isTrustedUrl {
    my ( $self, $url ) = @_;
    return $url =~ $self->trustedDomains ? 1 : 0;
}

1;
