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
    return $self->_userDB->setGroups(@_);
}

sub setPersistentSessionInfo {
    my ( $self, $req ) = @_;

    # Do not restore infos if session already opened
    unless ( $req->{id} ) {
        my $key = $req->{sessionInfo}->{ $self->conf->{whatToTrace} };

        return PE_OK unless ( $key and length($key) );

        my $persistentSession = $self->getPersistentSession($key);

        if ($persistentSession) {
            $self->lmLog( "Persistent session found for $key", 'debug' );
            foreach my $k ( keys %{ $persistentSession->data } ) {

                # Do not restore some parameters
                next if $k =~ /^_(?:utime|session_(?:u?id|kind))$/;
                $self->lmLog( "Restore persistent parameter $k", 'debug' );
                $req->{sessionInfo}->{$k} = $persistentSession->data->{$k};
            }
        }
    }

    PE_OK;
}

sub setLocalGroups {
    my ( $self, $req ) = @_;
    foreach ( sort keys %{ $self->_groups } ) {
        if ( $self->_groups->{$_}->($req) ) ) {
            $req->{sessionInfo}->{groups} .=
              $self->conf->{multiValuesSeparator} . $_;
            $req->{sessionInfo}->{hGroups}->{$_}->{name} = $_;
        }
    }

    # Clear values separator at the beginning
    if ( $req->{sessionInfo}->{groups} ) {
        $req->{sessionInfo}->{groups} =~
          s/^\Q$self->conf->{multiValuesSeparator}\E//o;
    }
    PE_OK;
}

sub store {
    my ( $self, $req ) = @_;

    # Now, user is authenticated => inform handler
    $req->userData($req->sessionInfo);
    
    # Create second session for unsecure cookie
    if($self->conf->{securedCookie} == 2 ) {
        my $session2 = $self->getApacheSession( undef, 1 );

        my %infos = %{ $req->{sessionInfo} };
        $infos{_httpSessionType} = 1;

        $session2->update( \%infos );

        $req->{sessionInfo}->{_httpSession} = $session2->id;
    }

    # Main session
    my $session = $self->getApacheSession( $req->{id}, 0, $self->{force} );
    return PE_APACHESESSIONERROR unless ($session);

    # Compute unsecure cookie value if needed
    if ( $self->conf->{securedCookie} == 3 ) {
        $req->{sessionInfo}->{_httpSession} =
          $self->conf->{cipher}->encryptHex( $self->{id}, "http" );
    }

    # Fill session
    my $infos = {};
    foreach my $k ( keys %{ $req->{sessionInfo} } ) {
        next unless defined $req->{sessionInfo}->{$k};
        my $displayValue = $req->{sessionInfo}->{$k};
        if ( $self->conf->{hiddenAttributes} =~ /\b$k\b/ ) {
            $displayValue = '****';
        }
        $self->lmLog( "Store $displayValue in session key $k", 'debug' );
        $self->_dump($displayValue) if ref($displayValue);
        $infos->{$k} = $self->{sessionInfo}->{$k};
    }
    $session->update($infos);

    PE_OK;
}

sub buildCookie {
    my ( $self, $req ) = @_;
    push @{ $req->respCookies },
      $self->cookie(
        name     => $self->{cookieName},
        value    => $self->{id},
        domain   => $self->{domain},
        path     => "/",
        secure   => $self->{securedCookie},
        HttpOnly => $self->{httpOnly},
        expires  => $self->{cookieExpiration},
        @_,
      );
    if ( $self->conf->{securedCookie} >= 2 ) {
        push @{ $req->respCookies },
          $self->cookie(
            name     => $self->{cookieName} . "http",
            value    => $self->{sessionInfo}->{_httpSession},
            domain   => $self->{domain},
            path     => "/",
            secure   => 0,
            HttpOnly => $self->{httpOnly},
            expires  => $self->{cookieExpiration},
            @_,
          );
    }
    PE_OK;
}

sub cookie {
    my ($self,%h) = @_;
    my @res;
    $req[0] = "$h{name}" or die("name required");
    my $res[0] .= "=$h{value}";
    foreach (qw(domain path expires max_age)) {
        my $f = $_;
        s/_/-/g;
        push @res, "$_=$h{$f}" if($h{$f});
    }
    return join('; ',@res);
}

1;
