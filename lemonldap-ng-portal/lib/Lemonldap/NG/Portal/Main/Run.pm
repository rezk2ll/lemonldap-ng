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
    qw(setAuthSessionInfo setSessionInfo setMacros setGroups setPersistentSessionInfo
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
#  - "/ping": - authenticated() for already authenticated users
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

sub refresh {
    my ( $self, $req ) = @_;
    $req->mustRedirect(1);
    my %datas = %{ $req->userData };
    $req->user( $datas{ $self->conf->{whatToTrace} } );
    $req->id( $datas{_session_id} );
    $self->userLogger->notice( 'Refresh request for ' . $req->user );
    foreach ( keys %datas ) {
        delete $datas{$_} unless ( /^_/ or /^(?:startTime)$/ );
    }
    return $self->do(
        $req,
        [
            'getUser',
            @{ $self->betweenAuthAndDatas },
            'setAuthSessionInfo',
            'setSessionInfo',
            'setMacros',
            'setGroups',
            'setLocalGroups',
            sub {
                $req->sessionInfo->{$_} = $datas{$_} foreach ( keys %datas );
                return PE_OK;
            },
            'store',
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
    if ( $err == PE_SENDRESPONSE ) {
        return $req->response;
    }
    if ( !$self->conf->{noAjaxHook} and $req->wantJSON ) {
        $self->logger->debug('Processing to JSON response');
        if ( ( $err > 0 and !$req->id ) or $err eq PE_SESSIONNOTGRANTED ) {
            return [
                401,
                [
                    'WWW-Authenticate' => "SSO " . $self->conf->{portal},
                    'Access-Control-Allow-Origin' => '*'
                ],
                [qq'{"result":0,"error":$err"}']
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
        if (
                $err
            and $err != PE_LOGOUT_OK
            and (
                $err != PE_REDIRECT
                or (    $err == PE_REDIRECT
                    and $req->datas->{redirectFormMethod}
                    and $req->datas->{redirectFormMethod} eq 'post' )
                or ( $err == PE_REDIRECT and $req->info )
            )
          )
        {
            my ( $tpl, $prms ) = $self->display($req);
            $self->logger->debug("Calling sendHtml with template $tpl");
            return $self->sendHtml( $req, $tpl, params => $prms );
        }
        else {
            $self->logger->debug('Calling autoredirect');
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
            return [ 302,
                [ Location => $req->{urldc}, @{ $req->respHeaders } ], [] ];
        }
    }
    my ( $tpl, $prms ) = $self->display($req);
    $self->logger->debug("Calling sendHtml with template $tpl");
    return $self->sendHtml( $req, $tpl, params => $prms );
}

# Try to recover the session corresponding to id and return session datas.
# If $id is set to undef or if $args{force} is true, return a new session.
sub getApacheSession {
    my ( $self, $id, %args ) = @_;
    $args{kind} ||= "SSO";

    if ($id) {
        $self->logger->debug("Try to get $args{kind} session $id");
    }
    else {
        $self->logger->debug("Try to get a new $args{kind} session");
    }

    my $as = Lemonldap::NG::Common::Session->new(
        {
            storageModule        => $self->conf->{globalStorage},
            storageModuleOptions => $self->conf->{globalStorageOptions},
            cacheModule          => $self->conf->{localSessionStorage},
            cacheModuleOptions   => $self->conf->{localSessionStorageOptions},
            id                   => $id,
            force                => $args{force},
            kind                 => $args{kind},
        }
    );

    if ( my $err = $as->error ) {
        $self->lmLog( $err,
            ( $err =~ /Object does not exist/ ? 'notice' : 'error' ) );
        return;
    }

    if ( $id and !$args{force} and !$as->data ) {
        $self->logger->debug("Session $args{kind} $id not found");
        return;
    }

    my $now = time;
    if (
            $id
        and defined $as->data->{_utime}
        and (
            $now - $as->data->{_utime} > $self->conf->{timeout}
            or (    $self->conf->{timeoutActivity}
                and $as->data->{_lastSeen}
                and $now - $as->data->{_lastSeen} >
                $self->conf->{timeoutActivity} )
        )
      )
    {
        $self->logger->debug("Session $args{kind} $id expired");
        return;
    }

    $self->logger->debug( "Return $args{kind} session " . $as->id );

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
        $self->logger->debug( $ps->error );
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

    $uid ||= $req->{sessionInfo}->{ $self->conf->{whatToTrace} }
      || $req->userData->{ $self->conf->{whatToTrace} };
    unless ($uid) {
        $self->logger->debug('No uid found, skipping updatePersistentSession');
        return ();
    }
    $self->logger->debug("Update $uid persistent session");

    my $persistentSession = $self->getPersistentSession($uid);

    $persistentSession->update($infos);

    if ( $persistentSession->error ) {
        $self->logger->error(
            "Cannot update persistent session " . $self->_md5hash($uid) );
        $self->logger->error( $persistentSession->error );
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
            $self->logger->debug(
                "Update sessionInfo $_ with " . $infos->{$_} );
            $req->{sessionInfo}->{$_} = $infos->{$_};
        }

        # Update session in global storage
        if ( my $apacheSession = $self->getApacheSession($id) ) {

            # Store updateTime
            $infos->{updateTime} = strftime( "%Y%m%d%H%M%S", localtime() );

            # Store/update session values
            $apacheSession->update($infos);

            if ( $apacheSession->error ) {
                $self->logger->error("Cannot update session $id");
                $self->logger->error( $apacheSession->error );
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
            if ( my $session2 = $self->getApacheSession($id2) ) {
                $session2->remove;
                if ( $session2->error ) {
                    $self->logger->debug(
                        "Unable to remove linked session $id2");
                    $self->logger->debug( $session2->error );
                }
            }
        }

        # Create an obsolete cookie to remove it
        $req->addCookie(
            $self->cookie(
                name    => $self->conf->{cookieName} . 'http',
                value   => 0,
                domain  => $self->conf->{domain},
                secure  => 0,
                expires => '-1d',
            )
        ) unless ($preserveCookie);
    }

    HANDLER->localUnlog( $session->id );
    $session->remove;

    # Create an obsolete cookie to remove it
    $req->addCookie(
        $self->cookie(
            name    => $self->conf->{cookieName},
            value   => 0,
            domain  => $self->conf->{domain},
            secure  => 0,
            expires => '-1d',
        )
    ) unless ($preserveCookie);

    # Log
    my $user = $req->{sessionInfo}->{ $self->conf->{whatToTrace} };
    $self->userLogger->notice("User $user has been disconnected") if $user;

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

sub stamp {
    my $self = shift;
    my $res =
      $self->conf->{cipher} ? $self->conf->{cipher}->encrypt( time() ) : 1;
    $res =~ s/\+/%2B/g;
    return $res;
}

# Transfer POST data with auto submit
# @return void
sub autoPost {
    my ( $self, $req ) = @_;

    # Get URL and Form fields
    $req->{urldc} = $req->postUrl;
    my $formFields = $req->postFields;

    $self->clearHiddenFormValue($req);
    foreach ( keys %$formFields ) {
        $self->setHiddenFormValue( $req, $_, $formFields->{$_}, "", 0 );
    }

    # Display info before redirecting
    if ( $req->info() ) {
        $req->{infoFormMethod} = $req->param('method') || "post";
        return PE_INFO;
    }

    $req->datas->{redirectFormMethod} = "post";
    return PE_REDIRECT;
}

# Add element into $self->{portalHiddenFormValues}, those values could be
# used to hide values into HTML form.
# @param fieldname The field name which will contain the correponding value
# @param value The associated value
# @param prefix Prefix of the field key
# @param base64 Encode value in base64
# @return nothing
sub setHiddenFormValue {
    my ( $self, $req, $key, $val, $prefix, $base64 ) = @_;

    # Default values
    $prefix = "lmhidden_" unless defined $prefix;
    $base64 = 1           unless defined $base64;

    # Store value
    if ($val) {
        $key = $prefix . $key;
        $val =~ s/\+/%2B/g;
        $req->{portalHiddenFormValues}->{$key} = $val;
        $self->logger->debug("Store $val in hidden key $key");
    }
}

## @method public void getHiddenFormValue(string fieldname, string prefix, boolean base64)
# Get value into $self->{portalHiddenFormValues}.
# @param fieldname The existing field name which contains a value
# @param prefix Prefix of the field key
# @param base64 Decode value from base64
# @return string The associated value
sub getHiddenFormValue {
    my ( $self, $req, $key, $prefix, $base64 ) = @_;

    # Default values
    $prefix = "lmhidden_" unless defined $prefix;
    $base64 = 1           unless defined $base64;

    $key = $prefix . $key;

    # Get value
    if ( my $val = $req->param($key) ) {
        $val = decode_base64($val) if $base64;
        return $val;
        $self->logger->debug("Hidden value $val found for key $key");
    }

    # No value found
    return undef;
}

## @method protected void clearHiddenFormValue(arrayref keys)
# Clear values form stored hidden fields
# Delete all keys if no keys provided
# @param keys Array reference of keys
# @return nothing
sub clearHiddenFormValue {
    my ( $self, $req, $keys ) = @_;

    unless ( defined $keys ) {
        delete $req->{portalHiddenFormValues};
        $self->logger->debug("Delete all hidden values");
    }
    else {
        foreach (@$keys) {
            delete $req->{portalHiddenFormValues}->{$_};
            $self->logger->debug("Delete hidden value for key $_");
        }
    }

    return;
}

# Get the first value of a multivaluated session value
sub getFirstValue {
    my ( $self, $value ) = @_;

    my @values = split /$self->{conf}->{multiValuesSeparator}/, $value;

    return $values[0];
}

sub info {
    my ( $self, $req, $info ) = @_;
    return $req->info($info);
}

sub fullUrl {
    my ( $self, $req ) = @_;
    my $pHost = $self->conf->{portal};
    $pHost =~ s#^(https?://[^/]+)(?:/.*)?$#$1#;
    return $pHost . $req->uri;
}

sub cookie {
    my ( $self, %h ) = @_;
    my @res;
    $res[0] = "$h{name}" or die("name required");
    $res[0] .= "=$h{value}";
    $h{path} ||= '/';
    $h{HttpOnly} //= $self->conf->{httpOnly};
    $h{expires}  //= $self->conf->{cookieExpiration};
    foreach (qw(domain path expires max_age HttpOnly)) {
        my $f = $_;
        $f =~ s/_/-/g;
        push @res, "$f=$h{$_}" if ( $h{$_} );
    }
    push @res, 'secure' if ( $h{secure} );
    return join( '; ', @res );
}

sub _dump {
    my ( $self, $variable ) = @_;
    require Data::Dumper;
    $Data::Dumper::Indent = 0;
    $self->logger->debug( "Dump: " . Data::Dumper::Dumper($variable) );
    return;
}

sub sendHtml {
    my ( $self, $req, $template, %args ) = @_;
    push @{ $req->respHeaders },
      'X-XSS-Protection'       => '1; mode=block',
      'X-Content-Type-Options' => 'nosniff';

    # Set authorizated URL for POST
    my $csp = $self->csp . "form-action 'self'";
    if ( my $url = $req->urldc ) {
        $url =~ s#https?://([^/]+).*#$1#;
        $csp .= " $url";
    }
    my $url = $args{params}->{URL};
    if ( $url and $url =~ s#https?://([^/]+).*#$1# ) {
        $csp .= " $url";
    }
    $csp .= ';';

    # Deny using portal in frame except if it is required
    unless ( $req->frame or $self->conf->{portalAntiFrame} == 0 ) {
        push @{ $req->respHeaders }, 'X-Frame-Options' => 'DENY';
        $csp .= "frame-ancestors 'none';";
    }

    # Check if frames need to be embedded
    my @url;
    if ( $req->info ) {
        @url = map { s#https?://([^/]+).*#$1#; $_ }
          ( $req->info =~ /<iframe.*?src="(.*?)"/sg );
    }
    if (@url) {
        $csp .= join( ' ', 'child-src', @url ) . ';';
    }

    # Set CSP header
    push @{ $req->respHeaders }, 'Content-Security-Policy' => $csp;

    return $self->SUPER::sendHtml( $req, $template, %args );
}

sub rebuildCookies {
    my ( $self, $req ) = @_;
    my @tmp;
    for ( my $i = 0 ; $i < @{ $req->{respHeaders} } ; $i += 2 ) {
        push @tmp, $req->respHeaders->[0], $req->respHeaders->[1]
          unless ( $req->respHeaders->[0] eq 'Set-Cookie' );
    }
    $req->{respHeaders} = \@tmp;
    $self->buildCookie($req);
}

sub tplParams {
    return (
        SKIN       => $_[0]->conf->{portalSkin},
        PORTAL_URL => $_[0]->conf->{portal},
    );
}

1;
