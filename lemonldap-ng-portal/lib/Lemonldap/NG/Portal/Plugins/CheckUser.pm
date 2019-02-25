package Lemonldap::NG::Portal::Plugins::CheckUser;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
    PE_CONFIRM
    PE_OK
    PE_TOKENEXPIRED
    PE_USERNOTFOUND
    PE_NOTOKEN
);

our $VERSION = '2.0.3';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INITIALIZATION

has ott => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott = $_[0]->{p}
            ->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->{conf}->{formTimeout} );
        return $ott;
    }
);

sub hAttr {
    $_[0]->{conf}->{checkUserHiddenAttributes} . ' '
        . $_[0]->{conf}->{hiddenAttributes};
}

sub init {
    my ($self) = @_;
    $self->addAuthRoute( checkuser => 'check',   ['POST'] );
    $self->addAuthRoute( checkuser => 'display', ['GET'] );
    return 1;
}

# RUNNING METHOD

sub check {
    my ( $self, $req ) = @_;
    my ( $hdrs, $attrs, $array_attrs, $array_hdrs ) = ( {}, {}, [], [] );
    my $msg    = 'checkUser';
    my $result = '';
    my $auth   = 0;

    # Check token
    if ( $self->conf->{requireToken} ) {
        my $token = $req->param('token');
        my $msg   = '';
        unless ($token) {
            $self->userLogger->warn('CheckUser try without token');
            $msg   = PE_NOTOKEN;
            $token = $self->ott->createToken( $req->sessionInfo );
        }
        unless ( $self->ott->getToken($token) ) {
            $self->userLogger->warn('Ask try with expired/bad token');
            $msg   = PE_TOKENEXPIRED;
            $token = $self->ott->createToken( $req->sessionInfo );
        }
        return $self->p->sendHtml(
            $req,
            'checkuser',
            params => {
                PORTAL    => $self->conf->{portal},
                MAIN_LOGO => $self->conf->{portalMainLogo},
                LANGS     => $self->conf->{showLanguages},
                MSG       => "PE$msg",
                ALERTE    => 'message-warning',
                TOKEN     => $token,
            }
        ) if $msg;
    }

    ## Check user session datas
    # Use submitted attribute if exists
    my $url = $req->param('url') || '';
    $req->{user} = $req->param('user') if ( $req->param('user') );
    $self->logger->debug("Check requested for $req->{user}");
    $attrs = $self->_userDatas($req);
    if ( $req->error ) {
        $msg   = 'PE' . $req->{error};
        $attrs = {};
    }

    # Create an array of hashes for template loop
    $self->logger->debug("Delete hidden attributes");
    foreach my $k ( sort keys %$attrs ) {

        # Ignore hidden attributes or empty values
        if ( $self->conf->{checkUserDisplayEmptyValues} ) {
            push @$array_attrs, { key => $k, value => $attrs->{$k} }
                unless ( $self->hAttr =~ /\b$k\b/ );
        }
        else {
            push @$array_attrs, { key => $k, value => $attrs->{$k} }
                unless ( $self->hAttr =~ /\b$k\b/ or !$attrs->{$k} );
        }
    }

    # Check if user is allowed to access submitted URL and compute headers
    if ( $url and %$attrs ) {

        # User is allowed ?
        $auth = $self->_authorization( $req, $url );
        $self->logger->debug(
            "checkUser requested for user: $req->{user} and URL: $url");
        $result = $auth ? "allowed" : "forbidden";
        $self->userLogger->notice(
            "checkUser -> $req->{user} is $result to access: $url");

        # Return VirtualHost headers
        $array_hdrs = $self->_headers( $req, $url );
    }
    my $token = $self->ott->createToken( $req->sessionInfo );

    # Display form
    return $self->p->sendHtml(
        $req,
        'checkuser',
        params => {
            PORTAL    => $self->conf->{portal},
            MAIN_LOGO => $self->conf->{portalMainLogo},
            LANGS     => $self->conf->{showLanguages},
            MSG       => $msg,
            ALERTE    => 'message-positive',
            LOGIN     => (
                  $self->p->checkXSSAttack( 'LOGIN', $req->{user} ) ? ""
                : $req->{user}
            ),
            URL => (
                  $self->p->checkXSSAttack( 'URL', $url ) ? ""
                : $url
            ),
            ALLOWED     => $result,
            ALERTE_AUTH => ($result eq 'allowed' ? "alert-success" : "alert-danger"),
            HEADERS     => $array_hdrs,
            ATTRIBUTES  => $array_attrs,
            TOKEN       => $token,
        }
    );
}

sub display {
    my ( $self, $req ) = @_;
    my $token = $self->ott->createToken( $req->sessionInfo );

    # Display form
    return $self->p->sendHtml(
        $req,
        'checkuser',
        params => {
            PORTAL    => $self->conf->{portal},
            MAIN_LOGO => $self->conf->{portalMainLogo},
            LANGS     => $self->conf->{showLanguages},
            MSG       => 'checkUser',
            ALERTE    => 'message-positive',
            LOGIN     => (
                $self->p->checkXSSAttack( 'LOGIN', $req->{user} )
                ? ""
                : $req->{user}
            ),
            TOKEN => $token,
        }
    );
}

sub _userDatas {
    my ( $self, $req ) = @_;

    # Search user in database
    my $steps = [ 'getUser', 'setSessionInfo', 'setMacros', 'setGroups' ];
    $self->conf->{checkUserDisplayPersistentInfo}
        ? push @$steps, 'setPersistentSessionInfo', 'setLocalGroups'
        : push @$steps, 'setLocalGroups';
    $req->steps($steps);
    if ( my $error = $self->p->process($req) ) {
        if ( $error == PE_USERNOTFOUND ) {
            $self->userLogger->warn( 'Check requested for an unvalid user ('
                    . $req->{user}
                    . ")" );
        }
        $self->logger->debug("Process returned error: $error");
        return $req->error($error);
    }
    return $req->{sessionInfo};
}

sub _authorization {
    my ( $self, $req, $uri ) = @_;

    # Check rights
    my ( $vhost, $appuri ) = $uri =~ m#^https?://([^/]*)(.*)#;
    $vhost =~ s/:\d+$//;
    $vhost = $self->p->HANDLER->resolveAlias($vhost);
    $appuri ||= '/';
    return $self->p->HANDLER->grant( $req, $req->{sessionInfo}, $appuri,
        undef, $vhost );
}

sub _headers {
    my ( $self, $req, $uri ) = @_;
    my ( $vhost, $appuri ) = $uri =~ m#^https?://([^/]*)(.*)#;
    $vhost =~ s/:\d+$//;
    $req->{env}->{HTTP_HOST} = $vhost;
    $self->p->HANDLER->headersInit( $self->{conf} );
    return $self->p->HANDLER->checkHeaders( $req, $req->{sessionInfo} );
}

1;
