package Lemonldap::NG::Portal::Main::Process;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants;
use Lemonldap::NG::Portal::Main::Request;

our $VERSION = '2.0.0';

# Auth process
sub extractFormInfo {
    my $self = shift;
    return $self->_authentication->extractFormInfo(@_);
}

sub getUser {
    my $self = shift;
    return $self->_userDB->getUser(@_);
}

sub authenticate {
    my $self = shift;
    return $self->_authentication->authenticate(@_);
}

# Session data providing

sub setSessionInfo {
    my ( $self, $req ) = @_;

    # Get the current user module
    $req->{sessionInfo}->{_userDB} = $self->get_module("user");

    # Store IP address from remote address or X-FORWARDED-FOR header
    $req->{sessionInfo}->{ipAddr} = $req->remote_ip;

    # Date and time
    if ( $self->conf->{updateSession} ) {
        $req->{sessionInfo}->{updateTime} =
          strftime( "%Y%m%d%H%M%S", localtime() );
    }
    else {
        $req->{sessionInfo}->{_utime} ||= time();
        $req->{sessionInfo}->{startTime} =
          strftime( "%Y%m%d%H%M%S", localtime() );
        $req->{sessionInfo}->{_lastSeen} = time() if $self->conf->{timeoutActivity};
    }

    # Get environment variables matching exportedVars
    foreach ( keys %{ $self->conf->{exportedVars} } ) {
        if ( my $tmp = $ENV{ $self->conf->{exportedVars}->{$_} } ) {
            $tmp =~ s/[\r\n]/ /gs;
            $req->{sessionInfo}->{$_} = $tmp;
        }
    }

    # Store URL origin in session
    $req->{sessionInfo}->{_url} = $req->datas->{urldc};

    # Call UserDB setSessionInfo
    return $self->_userDB->setSessionInfo($req) );

    PE_OK;
}

sub setMacros {
    my ( $self, $req ) = @_;
    foreach ( sort keys %{ $self->_macros } ) {
        $req->{sessionInfo}->{$_} = $self->_macros->{$_}->($req);
    }
    PE_OK;
}

sub setGroups {
    my ( $self, $req ) = @_;
}

sub setPersistentSessionInfo {
    my ( $self, $req ) = @_;
}

sub setLocalGroups {
    my ( $self, $req ) = @_;
}

sub grantSession {
    my ( $self, $req ) = @_;
}

sub store {
    my ( $self, $req ) = @_;
}

sub buildCookie {
    my ( $self, $req ) = @_;
}

1;
