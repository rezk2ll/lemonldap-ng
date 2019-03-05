package Lemonldap::NG::Portal::Plugins::CheckUser;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
    PE_BADCREDENTIALS
    PE_TOKENEXPIRED
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
    my ( $attrs, $array_attrs, $array_hdrs ) = ( {}, [], [] );
    my $msg = my $auth = '';

    # Check access rule
    unless ( $self->accessCtrl( $req, 'checkuser' ) ) {
        $self->userLogger->error(
            "user $req->{user} not allowed to access /checkuser");
        return $self->p->lmError( $req, 403 );
    }
    $self->userLogger->notice(
        "user $req->{user} is allowed to access /checkuser");

    # Check token
    if ( $self->conf->{requireToken} ) {
        my $token = $req->param('token');
        unless ($token) {
            $self->userLogger->warn('CheckUser try without token');
            $msg   = PE_NOTOKEN;
            $token = $self->ott->createToken( $req->sessionInfo );
        }
        unless ( $self->ott->getToken($token) ) {
            $self->userLogger->warn('Checkuser try with expired/bad token');
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
                ALERTE    => 'alert-warning',
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
        $msg = 'PE' . $req->{error};
        $array_attrs = [ [], [], [] ];
        $attrs = {};
    }
    else {
        $msg = 'checkUser';

        # Create an array of hashes for template loop
        $self->logger->debug("Delete hidden or empty attributes");
        if ( $self->conf->{checkUserDisplayEmptyValues} ) {
            foreach my $k ( sort keys %$attrs ) {

                # Ignore hidden attributes
                push @$array_attrs, { key => $k, value => $attrs->{$k} }
                    unless ( $self->hAttr =~ /\b$k\b/ );
            }
        }
        else {
            foreach my $k ( sort keys %$attrs ) {

                # Ignore hidden attributes and empty values
                push @$array_attrs, { key => $k, value => $attrs->{$k} }
                    unless ( $self->hAttr =~ /\b$k\b/ or !$attrs->{$k} );
            }
        }

        # ARRAY_REF = [ A_REF GROUPS, A_REF MACROS, A_REF OTHERS ]
        $array_attrs = $self->_splitAttributes($array_attrs);
    }

    # Check if user is allowed to access submitted URL and compute headers
    if ( $url and %$attrs ) {

        # User is allowed ?
        $url = 'http://' . $url unless ( $url =~ m#^https?://[^/]*.*# );
        $auth = $self->_authorization( $req, $url );
        $self->logger->debug(
            "checkUser requested for user: $req->{user} and URL: $url");
        if ( $auth >= 0 ) {

            $auth = $auth ? "allowed" : "forbidden";
            $self->userLogger->notice( "checkUser -> $req->{user} is "
                    . uc($auth)
                    . " to access: $url" );

            # Return VirtualHost headers
            $array_hdrs = $self->_headers( $req, $url );
        }
        else {
            $auth = 'VHnotFound';
            $self->userLogger->notice(
                "checkUser -> URL: $url has no configuration");
        }
    }

    my $alert_auth = 'alert-warning';
    if    ( $auth eq 'allowed' )   { $alert_auth = 'alert-success' }
    elsif ( $auth eq 'forbidden' ) { $alert_auth = 'alert-danger' }

    # Display form
    return $self->p->sendHtml(
        $req,
        'checkuser',
        params => {
            PORTAL    => $self->conf->{portal},
            MAIN_LOGO => $self->conf->{portalMainLogo},
            LANGS     => $self->conf->{showLanguages},
            MSG       => $msg,
            ALERTE =>
                ( $msg eq 'checkUser' ? 'alert-info' : 'alert-warning' ),
            LOGIN => (
                  $self->p->checkXSSAttack( 'LOGIN', $req->{user} ) ? ""
                : $req->{user}
            ),
            URL => (
                  $self->p->checkXSSAttack( 'URL', $url ) ? ""
                : $url
            ),
            ALLOWED     => $auth,
            ALERTE_AUTH => $alert_auth,
            HEADERS     => $array_hdrs,
            ATTRIBUTES  => $array_attrs->[2],
            MACROS      => $array_attrs->[1],
            GROUPS      => $array_attrs->[0],
            TOKEN       => (
                  $self->conf->{requireToken}
                ? $self->ott->createToken( $req->sessionInfo )
                : ''
            )
        }
    );
}

sub display {
    my ( $self, $req ) = @_;

    # Check access rule
    unless ( $self->accessCtrl( $req, 'checkuser' ) ) {
        $self->userLogger->error(
            "user $req->{user} not allowed to access /checkuser");
        return $self->p->lmError( $req, 403 );
    }
    $self->userLogger->notice(
        "user $req->{user} is allowed to access /checkuser");

    # Display form
    return $self->p->sendHtml(
        $req,
        'checkuser',
        params => {
            PORTAL    => $self->conf->{portal},
            MAIN_LOGO => $self->conf->{portalMainLogo},
            LANGS     => $self->conf->{showLanguages},
            MSG       => 'checkUser',
            ALERTE    => 'alert-info',
            LOGIN     => (
                  $self->p->checkXSSAttack( 'LOGIN', $req->{user} ) ? ""
                : $req->{user}
            ),
            TOKEN => (
                  $self->conf->{requireToken}
                ? $self->ott->createToken( $req->sessionInfo )
                : ''
            )
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
        if ( $error == PE_BADCREDENTIALS ) {
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
    my ( $vhost, $appuri ) = $uri =~ m#^https?://([^/]*)(.*)#;
    my $exist = 0;
    $vhost =~ s/:\d+$//;
    $appuri ||= '/';

    foreach my $vh ( keys %{$self->conf->{locationRules}} ) {
        if ( $vh eq $vhost ) {
            $exist = 1;
            $self->logger->debug("VirtualHost: $vh found in Conf");
            last;
        }
    }

    return $exist
        ? $self->p->HANDLER->grant( $req, $req->{sessionInfo}, $appuri,
        undef, $vhost )
        : -1;
}

sub _headers {
    my ( $self, $req, $uri ) = @_;
    my ( $vhost, $appuri ) = $uri =~ m#^https?://([^/]*)(.*)#;
    $vhost =~ s/:\d+$//;
    $req->{env}->{HTTP_HOST} = $vhost;
    $self->p->HANDLER->headersInit( $self->{conf} );
    return $self->p->HANDLER->checkHeaders( $req, $req->{sessionInfo} );
}

sub _splitAttributes {
    my ( $self, $attrs ) = @_;
    my ( $grps, $mcrs, $others ) = ( [], [], [] );
    my $macros = $self->{conf}->{macros};
    $self->logger->debug("Dispatching attributes...");
    while (@$attrs) {
        my $element = shift @$attrs;
        my $ok      = 0;
        if ( $element->{key} eq 'groups' ) {
            $self->logger->debug('Key "groups" found');
            my $separator = $self->{conf}->{multiValuesSeparator};
            my @tmp = split /\Q$separator/, $element->{value};
            $grps = [ map { { value => $_ } } sort @tmp ];
            next;
        }
        foreach my $key ( sort keys %$macros ) {
            if ( $element->{key} eq $key ) {
                push @$mcrs, $element;
                $ok = 1;
                last;
            }
        }
        push @$others, $element unless $ok;
    }
    return [ $grps, $mcrs, $others ];
}

1;
