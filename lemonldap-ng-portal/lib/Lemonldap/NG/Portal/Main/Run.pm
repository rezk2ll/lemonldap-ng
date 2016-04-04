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
            @{ $self->afterDatas },
        ]
    );
}

sub authenticatedRequest {
    my ( $self, $req ) = @_;
    return $self->do( $req, [ 'controlUrl', @{ $self->forAuthUser } ] );
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
            return $self->sendJSONresponse(
                $req,
                { result => 1, message => 'Authenticated' },
                headers => $req->respHeaders
            );
        }
    }
    else {
        if ($err) {
            return $self->sendHtml(
                $req,
                $req->template || 'login',
                headers => $req->respHeaders
            );
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
        return [
            302, [ Location => $req->datas->{urldc}, @{ $req->respHeaders } ],
            []
        ];
    }
    else {
        return $self->sendHtml( $req->template || 'menu' );
    }
}

# Try to recover the session corresponding to id and return session datas.
# If $id is set to undef or if $force is true, return a new session.
# @param id session reference
# @param noInfo do not set Apache REMOTE_USER
# @param force Force session creation if it does not exist
# return Lemonldap::NG::Common::Session object
sub getApacheSession {
    my ( $self, $id, $noInfo, $force ) = @_;

    my $as = Lemonldap::NG::Common::Session->new(
        {
            storageModule        => $self->conf->{globalStorage},
            storageModuleOptions => $self->conf->{globalStorageOptions},
            cacheModule          => $self->conf->{localSessionStorage},
            cacheModuleOptions   => $self->conf->{localSessionStorageOptions},
            id                   => $id,
            force                => $force,
            kind                 => "SSO",
        }
    );

    if ( $as->error ) {
        $self->lmLog( $as->error, 'debug' );
        return;
    }

    if ( $id and !$force and !$as->data ) {
        $self->lmLog( "Session $id not found", 'debug' );
        return;
    }

    unless ($noInfo) {
        $self->setApacheUser( $as->data->{ $self->{whatToTrace} } )
          if ($id);
        $self->{id} = $as->id;
    }
    return $as;
}

# Try to recover the persistent session corresponding to uid and return session datas.
sub getPersistentSession {
    my ( $self, $uid ) = @_;

    return unless defined $uid;

    # Compute persistent identifier
    my $pid = $self->_md5hash($uid);

    my $ps = Lemonldap::NG::Common::Session->new(
        {
            storageModule        => $self->{persistentStorage},
            storageModuleOptions => $self->{persistentStorageOptions},
            cacheModule          => $self->{localSessionStorage},
            cacheModuleOptions   => $self->{localSessionStorageOptions},
            id                   => $pid,
            force                => 1,
            kind                 => "Persistent",
        }
    );

    if ( $ps->error ) {
        $self->lmLog( $ps->error, 'debug' );
    }

    # Set _session_uid if not already present
    unless ( defined $ps->data->{_session_uid} ) {
        $ps->update( { '_session_uid' => $uid } );
    }

    # Set _utime if not already present
    unless ( defined $ps->data->{_utime} ) {
        $ps->update( { '_utime' => time } );
    }

    return $ps;
}

# Return md5(s)
sub _md5hash {
    my ( $self, $s ) = @_;
    return substr( Digest::MD5::md5_hex($s), 0, 32 );
}

# Check if an URL's domain name is declared in LL::NG config or is declared as
# trusted domain
sub isTrustedUrl {
    my ( $self, $url ) = @_;
    return $url =~ $self->trustedDomains ? 1 : 0;
}

1;
