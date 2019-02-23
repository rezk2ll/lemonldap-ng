package Lemonldap::NG::Portal::Plugins::CheckUser;

use Data::Dumper;
use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
    PE_CONFIRM
    PE_OK
    PE_TOKENEXPIRED
    PE_USERNOTFOUND
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

sub init {
    my ($self) = @_;
    $self->addAuthRoute( checkuser => 'check', [ 'GET', 'POST' ] );
    return 1;
}

# RUNNING METHOD

sub check {
    my ( $self, $req ) = @_;
    my $hdrs = my $attrs = {};
    my $auth = 0;
    my $msg  = 'checkUser';

    ## Check user attributes
    # Use submitted attribute if exists
    $req->{user} = $req->param('user') if ( $req->param('user') );
    $attrs = $self->_attributes($req);
    $self->logger->debug( "######## " . Dumper($attrs) );

    if ( $req->error ) {
        $msg   = 'PE' . $req->{error};
        $attrs = {};
    }

    # Check if user is allowed to access submitted URL and compute headers
    if ( $req->param('url') and %$attrs ) {

        # User is allowed ?
        $auth = $self->_authorized( $req, $req->param('url') );
        $self->logger->debug( "******** " . $auth );
        # Return VirtualHost headers
        $hdrs = $self->_headers( $req, $req->param('url') );
    }

    # Display form
    return $self->p->sendHtml(
        $req,
        'checkuser',
        params => {
            MAIN_LOGO  => $self->conf->{portalMainLogo},
            LANGS      => $self->conf->{showLanguages},
            MSG        => $msg,
            HEADERS    => %$hdrs,
            ATTRIBUTES => %$attrs,
            ALLOWED    => $auth,
            PORTAL     => $self->conf->{portal},
        }
    );
}

sub _attributes {
    my ( $self, $req ) = @_;

    # Search user in database
    $req->steps(
        [   'getUser',                  'setSessionInfo',
            'setMacros',                'setGroups',
            'setPersistentSessionInfo', 'setLocalGroups'
        ]
    );
    if ( my $error = $self->p->process($req) ) {
        if ( $error == PE_USERNOTFOUND ) {
            $self->userLogger->warn( "Check asked for an unvalid user ("
                    . $req->param('user')
                    . ")" );
        }
        return $req->error($error);
    }
    return $req->{sessionInfo};
}

sub _headers {
    my ( $self, $req ) = @_;
    return {};
}

sub _authorized {
    my ( $self, $req, $uri ) = @_;

    # Check rights
    my ( $vhost, $appuri ) = $uri =~ m#^https?://([^/]*)(.*)#;
    $vhost =~ s/:\d+$//;
    $vhost = $self->p->HANDLER->resolveAlias($vhost);
    $appuri ||= '/';
    return $self->p->HANDLER->grant( $req, $req->{sessionInfo}, $appuri, undef,
        $vhost );
}

1;
