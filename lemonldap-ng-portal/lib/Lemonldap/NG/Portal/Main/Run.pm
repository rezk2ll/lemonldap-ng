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
# - replace Lemonldap::NG::Common::PSGI::Request request by
#   Lemonldap::NG::Portal::Main::Request
# - launch Lemonldap::NG::Common::PSGI::Request::handler()
sub handler {
    my ( $self, $req ) = @_;
    bless $req, 'Lemonldap::NG::Portal::Main::Request';
    $req->init();
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
            'controlUrl',        @{ $self->beforeAuth },
            $self->authProcess,  @{ $self->betweenAuthAndDatas },
            $self->sessionDatas, @{ $self->afterDatas },
        ]
    );
}

sub postLogin {
    my ( $self, $req ) = @_;
    return $self->do(
        $req,
        [
            'restoreArgs',                   'controlUrl',
            @{ $self->beforeAuth },          $self->authProcess,
            @{ $self->betweenAuthAndDatas }, $self->sessionDatas,
            @{ $self->afterDatas },
        ]
    );
}

sub authenticatedRequest {
    my ( $self, $req ) = @_;
    return $self->do(
        $req,
        [
            'importHandlerDatas', 'controlUrl',
            'checkLogout',        @{ $self->forAuthUser }
        ]
    );
}

sub postAuthenticatedRequest {
    my ( $self, $req ) = @_;
    return $self->do(
        $req,
        [
            'importHandlerDatas', 'restoreArgs',
            'controlUrl',         'checkLogout',
            @{ $self->forAuthUser }
        ]
    );
}

sub logout {
    my ( $self, $req ) = @_;
    return $self->do(
        $req,
        [
            'controlUrl', @{ $self->beforeLogout },
            'authLogout', 'deleteSession'
        ]
    );
}

# RUNNING METHODS
# ---------------

sub do {
    my ( $self, $req, $steps ) = @_;
    $req->steps($steps);
    my $err = $req->error( $self->process($req) );

    # TODO: updateStatus
    if ( !$self->conf->{noAjaxHook} and $req->wantJSON ) {
        if ( $err > 0 and !%{ $req->sessionInfo } ) {
            return [
                401,
                [
                    'WWW-Authenticate' => "SSO " . $self->conf->{portal},
                    'Access-Control-Allow-Origin' => '*'
                ],
                []
            ];
        }
        elsif ( $err > 0 ) {
            return $self->sendJSONresponse(
                $req,
                { result => 0, error => $err },
                code => 400
            );
        }
        else {
            return $self->sendJSONresponse(
                $req,
                {
                    result => 1,
                    code   => $err
                }
            );
        }
    }
    else {
        if ( $err and $err != PE_LOGOUT_OK and $err != PE_REDIRECT ) {
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
        if ( my $sub = $self->$mod->can('name') ) {
            return $sub->( $self->$mod, $req, $type );
        }
        else {
            my $s = ref( $self->$mod );
            $s =~
s/^Lemonldap::NG::Portal::(?:(?:Issuer|UserDB|Auth|Password)::)?//;
            return $s;
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
    $req->{urldc} ||= $self->conf->{portal} if ( $req->mustRedirect );

    # Redirection should be made if urldc defined
    if ( $req->{urldc} and not $req->param('lmError') ) {
        if ( $self->_jsRedirect->() ) {
            $req->error(PE_REDIRECT);
            $req->datas->{redirectFormMethod} = "get";
        }
        else {
            return [ 302, [ Location => $req->{urldc}, @{ $req->respHeaders } ],
                [] ];
        }
    }
    my ( $tpl, $prms ) = $self->display($req);
    return $self->sendHtml( $req, $tpl, params => $prms );
}

# Try to recover the session corresponding to id and return session datas.
# If $id is set to undef or if $force is true, return a new session.
# @param id session reference
# @param noInfo do not set Apache REMOTE_USER
# @param force Force session creation if it does not exist
# return Lemonldap::NG::Common::Session object
sub getApacheSession {
    my ( $self, $id, $noInfo, $force ) = @_;

    if ($id) {
        $self->lmLog( "Try to get session $id", 'debug' );
    }
    else {
        $self->lmLog( "Try to get a new session", 'debug' );
    }

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
        $self->lmLog( $as->error, 'error' );
        return;
    }

    if ( $id and !$force and !$as->data ) {
        $self->lmLog( "Session $id not found", 'debug' );
        return;
    }

    my $now = time;
    if (
        $id
        and (
            $now - $as->data->{_utime} > $self->conf->{timeout}
            or (    $self->conf->{timeoutActivity}
                and $as->data->{_lastSeen}
                and $now - $as->data->{_lastSeen} >
                $self->conf->{timeoutActivity} )
        )
      )
    {
        $self->lmLog( "Session $id expired", 'debug' );
        return;
    }

    unless ($noInfo) {
        $self->{id} = $as->id;
    }

    $self->lmLog( "Return session " . $as->id, 'debug' );

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

# Update persistent session.
# Call updateSession() and store %$infos in a persistent session.
# Note that if the session does not exists, it will be created.
# @param infos hash reference of information to update
# @param uid optional Unhashed persistent session ID
# @param id optional SSO session ID
# @return nothing
sub updatePersistentSession {
    my ( $self, $req, $infos, $uid, $id ) = @_;

    # Return if no infos to update
    return () unless ( ref $infos eq 'HASH' and %$infos );

    # Update current session
    $self->updateSession( $req, $infos, $id );

    $uid ||= $req->{sessionInfo}->{ $self->conf->{whatToTrace} };
    return () unless ($uid);

    my $persistentSession = $self->getPersistentSession($uid);

    $persistentSession->update($infos);

    if ( $persistentSession->error ) {
        $self->lmLog(
            "Cannot update persistent session " . $self->_md5hash($uid),
            'error' );
        $self->lmLog( $persistentSession->error, 'error' );
    }
}

# Update session stored.
# If no id is given, try to get it from cookie.
# If the session is available, update datas with $info.
# Note that outdated session data may remain some time on
# server local cache, if there are several LL::NG servers.
# @param infos hash reference of information to update
# @param id Session ID
# @return nothing
sub updateSession {
    my ( $self, $req, $infos, $id ) = @_;

    # Return if no infos to update
    return () unless ( ref $infos eq 'HASH' and %$infos );

    # Recover session ID unless given
    $id ||= $req->{id};

    if ($id) {

        # Update sessionInfo data
        ## sessionInfo updated if $id defined : quite strange !!
        ## See http://jira.ow2.org/browse/LEMONLDAP-430
        foreach ( keys %$infos ) {
            $self->lmLog( "Update sessionInfo $_ with " . $infos->{$_},
                'debug' );
            $req->{sessionInfo}->{$_} = $infos->{$_};
        }

        # Update session in global storage
        if ( my $apacheSession = $self->getApacheSession( $id, 1 ) ) {

            # Store updateTime
            $infos->{updateTime} = strftime( "%Y%m%d%H%M%S", localtime() );

            # Store/update session values
            $apacheSession->update($infos);

            if ( $apacheSession->error ) {
                $self->lmLog( "Cannot update session $id", 'error' );
                $self->lmLog( $apacheSession->error,       'error' );
            }
        }
    }
}

# Delete an existing session. If "securedCookie" is set to 2, the http session
# will also be removed.
# @param h tied Apache::Session object
# @param preserveCookie do not delete cookie
# @return True if session has been deleted
sub _deleteSession {
    my ( $self, $req, $session, $preserveCookie ) = @_;

    # Invalidate http cookie and session, if set
    if ( $self->conf->{securedCookie} >= 2 ) {

        # Try to find a linked http session (securedCookie == 2)
        if ( $self->conf->{securedCookie} == 2
            and my $id2 = $session->data->{_httpSession} )
        {
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
    return $url =~ $self->trustedDomainsRe ? 1 : 0;
}

1;
