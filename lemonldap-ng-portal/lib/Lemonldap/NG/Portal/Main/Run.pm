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

our $VERSION = '2.0.0';

package Lemonldap::NG::Portal::Main;

use strict;

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
    return $self->do(
        $req,
        [
            'importHandlerDatas', 'checkLogout',
            'controlUrl',         @{ $self->forAuthUser }
        ]
    );
}

sub postAuthenticatedRequest {
    my ( $self, $req ) = @_;
    return $self->do(
        $req,
        [
            'importHandlerDatas', 'checkLogout',
            'restoreArgs',        'controlUrl',
            @{ $self->forAuthUser }
        ]
    );
}

sub logout {
    my ( $self, $req ) = @_;
    return $self->do( $req,
        [ @{ $self->beforeLogout }, 'authLogout', 'deleteSession' ] );
}

# RUNNING METHODS
# ---------------

sub do {
    my ( $self, $req, $steps ) = @_;
    $req->steps($steps);
    my $err = $req->error( $self->process($req) );

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
            return $self->sendJSONresponse( $req,
                { result => 1, message => 'Authenticated' } );
        }
    }
    else {
        if ($err) {
            my ( $tpl, $prms ) = $self->display($req);
            return $self->sendHtml( $req, $tpl, params => $prms );
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
        my ( $tpl, $prms ) = $self->display($req);
        return $self->sendHtml( $req, $tpl, params => $prms );
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
            storageModule        => $self->conf->{persistentStorage},
            storageModuleOptions => $self->conf->{persistentStorageOptions},
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

# Delete an existing session. If "securedCookie" is set to 2, the http session
# will also be removed.
# @param h tied Apache::Session object
# @param preserveCookie do not delete cookie
# @return True if session has been deleted
sub _deleteSession {
    my ( $self, $req, $session, $preserveCookie ) = @_;

    # Invalidate http cookie and session, if set
    if ( $self->{securedCookie} >= 2 ) {

        # Try to find a linked http session (securedCookie == 2)
        if ( my $id2 = $session->data->{_httpSession} ) {
            if ( my $session2 = $self->getApacheSession( $id2, 1 ) ) {
                $session2->remove;
                if ( $session2->error ) {
                    $self->lmLog( "Unable to remove linked session $id2",
                        'debug' );
                    $self->lmLog( $session2->error, 'debug' );
                }
            }
        }

        # Create an obsolete cookie to remove it
        push @{ $req->respHeaders },
          'Set-Cookie' => $self->cookie(
            name    => $self->conf->{cookieName} . 'http',
            value   => 0,
            domain  => $self->conf->{domain},
            path    => "/",
            secure  => 0,
            expires => '-1d',
          ) unless ($preserveCookie);
    }

    $session->remove;

    # Create an obsolete cookie to remove it
    push @{ $req->respHeaders },
      'Set-Cookie' => $self->cookie(
        name    => $self->conf->{cookieName},
        value   => 0,
        domain  => $self->conf->{domain},
        path    => "/",
        secure  => 0,
        expires => '-1d',
        @_,
      ) unless ($preserveCookie);

    # Log
    my $user = $req->{sessionInfo}->{ $self->conf->{whatToTrace} };
    $self->userNotice("User $user has been disconnected") if $user;

    return $session->error ? 0 : 1;
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
