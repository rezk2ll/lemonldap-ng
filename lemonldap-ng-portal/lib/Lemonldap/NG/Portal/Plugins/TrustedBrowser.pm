# Trusted Browser service
# This package provides the ability to remember a browser across SSO logins
# It is meant to be used by multiple features
# - Auto-login (StayConnected)
# - 2FA bypass
#
# Browser registration is entirely handled by this plugin, and trigger by setting
# $req->param('stayconnected'), usually by the user clicking a checkbox.
# Request state is handled automatically during browser registration.
#
# Recognition of an already registered browser is not triggered by the plugin
# itself but by other plugins (StayConnected, 2FA engine).
# Plugins should call 'mustChallenge' to know if they need to start a TOTP
# challenge with the web browser. If it is the case, they run 'challenge' to
# prepare the validation form containing the JS challenge.
#
# Plugins must indicate a route for the challenge form to POST to. Plugins must
# implement that route, and in that route, call 'getKnownBrowserState' to check
# that the browser really is trusted, and then, continue the current flow.
#
# Plugins are responsible for saving the request state and restoring it during
# the recognition phase.
#

package Lemonldap::NG::Portal::Plugins::TrustedBrowser;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_ERROR
  PE_SENDRESPONSE
);

our $VERSION = '2.18.0';

extends qw(
  Lemonldap::NG::Portal::Main::Plugin
  Lemonldap::NG::Portal::Lib::OtherSessions
  Lemonldap::NG::Common::TOTP
);

# INTERFACE

use constant beforeLogout => 'logout';

# INITIALIZATION
has ott => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->conf->{formTimeout} );
        return $ott;
    }
);
has cookieName => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{stayConnectedCookieName} || 'llngconnection';
    }
);
has singleSession => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{stayConnectedSingleSession};
    }
);

# Default timeout: 1 month
has timeout => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]->conf->{stayConnectedTimeout} || 2592000;
    }
);

sub init {
    my ($self) = @_;
    $self->addUnauthRoute( registerbrowser => 'storeBrowser', ['POST'] );

    return 1;
}

# RUNNING METHODS

# This method is called by the portal in standard auth flows

sub newDevice {
    my ( $self, $req ) = @_;

    if ( $req->param('stayconnected') ) {
        my $totpSecret = $self->newSecret;

        my $state = $self->_getRegisterStateTplParams( $req, $totpSecret );
        $req->response(
            $self->p->sendHtml(
                $req,
                '../common/registerBrowser',
                params => {
                    TOTPSEC => $totpSecret,
                    ACTION  => '/registerbrowser',
                    %$state,
                }
            )
        );
        return PE_SENDRESPONSE;
    }
    return PE_OK;
}

# Store TOTP secret + request state into a temporary session
# and return relevant template parameters
sub _getRegisterStateTplParams {
    my ( $self, $req, $totpSecret ) = @_;

    my $checkLogins = $req->param('checkLogins') || 0;
    my $url         = $req->urldc;
    my $token       = $self->ott->createToken( {
            id          => $req->id,
            sessionInfo => $req->sessionInfo,
            totpSecret  => $totpSecret,
        }
    );
    my %state = (
        CHECKLOGINS => $checkLogins,
        URL         => $url,
        TOKEN       => $token,
    );
    return \%state;
}

# This method handles the browser response to the registerBrowser JS code
# and persists the registration
sub storeBrowser {
    my ( $self, $req ) = @_;

    if ( my $totpSecret = $self->_restoreRegisterState($req) ) {
        my $name = $req->sessionInfo->{ $self->conf->{whatToTrace} };
        if ( my $fg = $req->param('fg') ) {
            my $isTotp = ( $fg =~ s/^TOTP_// ) ? 1 : 0;
            if ( $isTotp
                and !$self->verifyCode( 30, 1, 6, $totpSecret, $fg ) )
            {
                $self->logger->warn( "Failed to register device, bad TOTP, "
                      . "device will not be remembered" );
            }
            else {
                my $ps = $self->newConnectionSession( { (
                            _session_uid => $name,
                            $isTotp
                            ? ( totpSecret => $totpSecret )
                            : ( fingerprint => $fg )
                        ),
                    },
                );

                # Cookie available 30 days by default
                $req->addCookie(
                    $self->p->cookie(
                        name    => $self->cookieName,
                        value   => $ps->id,
                        max_age => $self->timeout,
                        secure  => $self->conf->{securedCookie},
                    )
                );

                # Store connection ID in current session
                $self->p->updateSession( $req,
                    { _stayConnectedSession => $ps->id } );
            }
        }
        else {
            $self->logger->warn( "Browser did not return fingerprint, "
                  . "browser will not be remembered" );
        }
    }
    else {
        $self->userLogger->error(
            "Cannot restore trusted browser registration state");
        return $self->p->do( $req, [ sub { PE_ERROR } ] );
    }

    # Resume normal login flow
    $req->mustRedirect(1);
    return $self->p->do( $req,
        [ 'buildCookie', @{ $self->p->endAuth }, sub { PE_OK } ] );
}

sub _restoreRegisterState {
    my ( $self, $req ) = @_;

    if ( my $token = $req->param('token') ) {
        if ( my $saved_state = $self->ott->getToken($token) ) {

            # checkLogins is restored automatically as a request parameter
            $req->urldc( $req->param('url') );
            $req->sessionInfo( $saved_state->{sessionInfo} );
            $req->id( $saved_state->{id} );
            return $saved_state->{totpSecret};
        }
        else {
            $self->userLogger->error("Invalid trusted browser state token");
        }
    }
    else {
        $self->userLogger->error('Missing trusted browser state token');
    }
    return;

}

sub getTrustedBrowserSessionFromReq {
    my ( $self, $req ) = @_;

    if ( my $cid = $req->cookies->{ $self->cookieName } ) {
        return $self->getTrustedBrowserSession($cid);
    }
    else {
        $self->logger->debug("No trusted browser cookie was sent");
    }
    return;
}

sub getTrustedBrowserSession {
    my ( $self, $cid ) = @_;
    my $ps = Lemonldap::NG::Common::Session->new(
        storageModule        => $self->conf->{globalStorage},
        storageModuleOptions => $self->conf->{globalStorageOptions},
        kind                 => "SSO",
        id                   => $cid,
    );
    if ( $ps->data->{_session_uid} and ( time() < $ps->data->{_utime} ) ) {
        $self->logger->debug('Persistent connection found');
        return $ps;
    }
    else {
        $self->userLogger->notice('Persistent connection expired');
        unless ( $ps->{error} ) {
            $self->logger->debug(
                'Persistent connection session id = ' . $ps->{id} );
            $self->logger->debug( 'Persistent connection session _utime = '
                  . $ps->data->{_utime} );
            $ps->remove;
        }
    }
    return;
}

sub _hasFingerprintParams {
    my ( $self, $req ) = @_;
    return ( $req->param('fg') and $req->param('token') );
}

sub mustChallenge {
    my ( $self, $req, $expected_user ) = @_;

    my $ps = $self->getTrustedBrowserSessionFromReq($req);
    if ( $ps and not( $self->_hasFingerprintParams($req) ) ) {
        if ($expected_user) {
            return (  $ps->data->{_session_uid}
                  and $ps->data->{_session_uid} eq $expected_user );
        }
        else {
            return 1;
        }
    }
    return 0;
}

sub getKnownBrowserState {
    my ( $self, $req ) = @_;

    my $ps = $self->getTrustedBrowserSessionFromReq($req);
    if ( $ps and $self->_hasFingerprintParams($req) ) {
        my $fg    = $req->param('fg');
        my $token = $req->param('token');
        my $uid   = $ps->data->{_session_uid};

        my $token_data = $self->ott->getToken($token);
        return unless $token_data;

        if ( $self->checkFingerprint( $req, $ps, $uid, $fg ) ) {
            return {
                _trustedUser          => $uid,
                _stayConnectedSession => $ps->id,
                data                  => $token_data,
            };
        }
        else {
            $self->userLogger->warn("Fingerprint changed for $uid");
            $ps->remove;
            $self->logout($req);
        }
    }
    else {
        $self->logger->debug("No fingerprint or token parameter was sent");
    }
    return;
}

sub checkFingerprint {
    my ( $self, $req, $ps, $uid, $fg ) = @_;
    $self->logger->debug('Persistent connection found');
    if ( $self->conf->{stayConnectedBypassFG} ) {
        return 1;
    }
    else {
        if ( $fg =~ s/^TOTP_// ) {
            return 1
              if (
                $self->verifyCode( 30, 1, 6, $ps->data->{totpSecret}, $fg ) >
                0 );
        }
        elsif ( $fg eq $ps->data->{fingerprint} ) {
            return 1;
        }
    }
    return 0;
}

sub challenge {
    my ( $self, $req, $action, $info ) = @_;
    my $token = $self->ott->createToken($info);
    $req->response(
        $self->p->sendHtml(
            $req,
            '../common/registerBrowser',
            params => {
                TOKEN  => $token,
                ACTION => $action,
            }
        )
    );
    return PE_SENDRESPONSE;
}

sub logout {
    my ( $self, $req ) = @_;
    $req->addCookie(
        $self->p->cookie(
            name    => $self->cookieName,
            value   => 0,
            expires => 'Wed, 21 Oct 2015 00:00:00 GMT',
            secure  => $self->conf->{securedCookie},
        )
    );

    # Try to clean stayconnected cookie
    my $cid = $req->sessionInfo->{_stayConnectedSession};
    if ($cid) {
        my $ps = $self->getTrustedBrowserSession($cid);
        if ($ps) {
            $self->logger->debug("Cleaning up StayConnected session $cid");
            $ps->remove;
        }
    }

    return PE_OK;
}

sub removeExistingSessions {
    my ( $self, $uid ) = @_;
    $self->logger->debug("StayConnected: removing all sessions for $uid");

    my $sessions =
      $self->module->searchOn( $self->moduleOpts, '_session_uid', $uid );

    foreach ( keys %{ $sessions || {} } ) {
        if ( my $ps = $self->getTrustedBrowserSession($_) ) {

            # If this is a StayConnected session, remove it
            $ps->remove if $ps->{data}->{_connectedSince};
            $self->logger->debug("StayConnected removed session $_");
        }
        else {
            $self->logger->debug("StayConnected session $_ expired");
        }
    }
}

sub newConnectionSession {
    my ( $self, $info ) = @_;

    $info ||= {};

    # Remove existing sessions
    if ( $self->singleSession ) {
        $self->removeExistingSessions( $info->{_session_uid} );
    }

    return Lemonldap::NG::Common::Session->new(
        storageModule        => $self->conf->{globalStorage},
        storageModuleOptions => $self->conf->{globalStorageOptions},
        kind                 => "SSO",
        info                 => {
            _utime          => time + $self->timeout,
            _connectedSince => time,
            %$info,
        }
    );
}

1;
