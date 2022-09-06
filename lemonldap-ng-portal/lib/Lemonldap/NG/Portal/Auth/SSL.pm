package Lemonldap::NG::Portal::Auth::SSL;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_CERTIFICATEREQUIRED
  PE_ERROR
  PE_BADCERTIFICATE
  PE_FIRSTACCESS
  PE_OK
);

our $VERSION = '2.0.12';

extends 'Lemonldap::NG::Portal::Main::Auth';

# INITIALIZATION

has AjaxInitScript => ( is => 'rw', default => '' );
has Name           => ( is => 'ro', default => 'SSL' );
has InitCmd        => (
    is      => 'ro',
    default => q@$self->p->setHiddenFormValue( $req, usertoken => 0, '', 0 )@
);

# Auth Token
has authott => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->cache(0);
        return $ott;
    }
);

sub init {
    my ($self) = @_;
    $self->AjaxInitScript( '<script type="application/init">{"sslHost":"'
          . $self->conf->{sslHost}
          . '"}</script>' )
      if $self->conf->{sslByAjax};

    $self->addUnauthRoute( 'authssl' => 'auth_ssl', ['GET'] );

    # Used for session upgrade/reauthn
    $self->addAuthRoute( 'authssl' => 'auth_ssl', ['GET'] );

    return 1;
}

# Create authentication token so you can use 2FA, notifications, etc, with Ajax
sub auth_ssl {
    my ( $self, $req ) = @_;

    my $ssl_user = $self->get_user_from_req($req);
    if ($ssl_user) {
        my $token = $self->authott->createToken( {
                ssl_user => $ssl_user,
                type     => 'auth_ssl_token',
            }
        );
        if ($token) {
            return $self->sendJSONresponse(
                $req,
                {
                    usertoken => $token,
                    error     => PE_OK,
                }
            );
        }
        else {
            $self->logger->error("Could not create user token for $ssl_user");
            $req->wantErrorRender(1);
            return $self->p->do( $req, [ sub { PE_ERROR } ] );
        }
    }
    else {
        $req->wantErrorRender(1);
        return $self->p->do( $req, [ sub { PE_CERTIFICATEREQUIRED } ] );
    }
}

sub get_user_from_req {
    my ( $self, $req ) = @_;

    my $field = $self->conf->{SSLVar};
    if ( $req->env->{SSL_CLIENT_I_DN} ) {
        $self->logger->debug(
            'Received SSL issuer ' . $req->env->{SSL_CLIENT_I_DN} );

        if ( my $tmp =
            $self->conf->{SSLVarIf}->{ $req->env->{SSL_CLIENT_I_DN} } )
        {
            $field = $tmp;
        }
    }
    my $value = $req->env->{$field};
    if ($value) {
        $self->logger->debug("Using SSL environment variable $field");
    }
    else {
        $self->logger->notice(
            "No name found in certificate, check your configuration");
    }

    return $value;
}

# Read username in SSL environment variables, or return an error
# @return Lemonldap::NG::Portal constant
sub extractFormInfo {
    my ( $self, $req ) = @_;

    # If this is the ajax query, allow response to contain HTML code
    # to update the portal error message
    if ( $req->wantJSON ) {
        $req->wantErrorRender(1);
    }

    my $token_id = $req->param('usertoken');
    if ($token_id) {
        return $self->_set_user_from_token( $req, $token_id );
    }

    my $ssl_user = $self->get_user_from_req($req);

    if ( $ssl_user and $req->user($ssl_user) ) {
        $self->userLogger->notice( "GoodSSL authentication for " . $req->user );
        return PE_OK;
    }
    elsif ( $req->env->{SSL_CLIENT_S_DN} ) {
        return PE_BADCERTIFICATE;
    }
    elsif ( $self->conf->{sslByAjax} and not $req->param('nossl') ) {

        # If this is the AJAX query
        if ( $req->wantJSON ) {
            return PE_CERTIFICATEREQUIRED;
        }

        $self->logger->debug( 'Append ' . $self->{Name} . ' init/script' );
        $req->data->{customScript} .= $self->{AjaxInitScript};
        $self->logger->debug(
            "Send init/script -> " . $req->data->{customScript} );
        $req->data->{waitingMessage} = 1;

        eval( $self->InitCmd );
        die 'Unable to launch init commmand ' . $self->{InitCmd} if ($@);
        return PE_FIRSTACCESS;
    }
    else {
        if ( $self->conf->{sslByAjax} ) {
            $self->logger->debug( 'Append ' . $self->{Name} . ' init/script' );
            $req->data->{customScript} .= $self->{AjaxInitScript};
            $self->logger->debug(
                "Send init/script -> " . $req->data->{customScript} );
            return PE_BADCERTIFICATE;
        }
        $self->userLogger->warn('No certificate found');
        return PE_CERTIFICATEREQUIRED;
    }
}

sub _set_user_from_token {
    my ( $self, $req, $token_id ) = @_;
    my $token = $self->authott->getToken($token_id);
    if ($token) {
        if ( $token->{type} eq 'auth_ssl_token' ) {
            $req->user( $token->{ssl_user} );
            $self->userLogger->notice(
                "GoodSSL authentication for " . $req->user );
            return PE_OK;
        }
        else {
            $self->logger->error( "Unexpected token type: " . $token->{type} );
            return PE_ERROR;
        }
    }

    $self->logger->error("Could not fetch user token $token_id");
    return PE_ERROR;
}

sub authenticate {
    return PE_OK;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    $req->sessionInfo->{authenticationLevel} = $self->conf->{SSLAuthnLevel};
    return PE_OK;
}

sub getDisplayType {
    my ($self) = @_;
    return ( $self->{conf}->{sslByAjax} ? "sslform" : "logo" );
}

sub authLogout {
    return PE_OK;
}

1;
