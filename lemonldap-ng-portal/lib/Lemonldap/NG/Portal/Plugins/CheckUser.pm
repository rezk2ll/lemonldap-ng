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
    my ( $self, $req )   = @_;
    my ( $hdrs, $attrs, $array_attrs, $array_hdrs ) = ( {}, {}, [],[] );
    my $msg         = 'checkUser';
    my $auth        = 0;

    ## Check user attributes
    # Use submitted attribute if exists
    my $url = $req->param('url') || '';
    $req->{user} = $req->param('user') if ( $req->param('user') );
    $self->logger->debug("Check requested for $req->{user}");
    $attrs = $self->_attributes($req);
    if ( $req->error ) {
        $msg   = 'PE' . $req->{error};
        $attrs = {};
    }

    $self->logger->debug( "######## " . Dumper($attrs) );

    # Create an array of hashes for template loop
    while ( my ( $k, $v ) = each %$attrs ) {
        push @$array_attrs, { key => $k, value => $v };

        ##### TODO -> DELETE hidden attributes

    }

    $self->logger->debug( "******** " . Dumper($array_attrs) );

    # Check if user is allowed to access submitted URL and compute headers
    if ( $url and %$attrs ) {

        # User is allowed ?
        $auth = $self->_authorized( $req, $url );
        $self->logger->debug(
            "checkUser requested for user: $req->{user} and URL: $url");
        my $result = $auth ? "ALLOWED" : "FORBIDDEN";
        $self->userLogger->notice(
            "checkUser -> $req->{user} is $result to access: $url");

        # Return VirtualHost headers
        $hdrs = $self->_headers( $req, $url );
        while ( my ( $k, $v ) = each %$hdrs ) {
            push @$array_hdrs, { key => $k, value => $v };
        }

        $self->logger->debug( "+++++++++++++ " . Dumper($array_hdrs) );
        
    }

    # Display form
    return $self->p->sendHtml(
        $req,
        'checkuser',
        params => {
            PORTAL     => $self->conf->{portal},
            MAIN_LOGO  => $self->conf->{portalMainLogo},
            LANGS      => $self->conf->{showLanguages},
            MSG        => $msg,
            LOGIN      => $req->{user},
            URL        => $url,
            ALLOWED    => $auth,
            HEADERS    => $array_hdrs,
            ATTRIBUTES => $array_attrs,
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
            $self->userLogger->warn( "Check requested for an unvalid user ("
                    . $req->{user}
                    . ")" );
        }
        $self->logger->debug("Process returned error: $error");
        return $req->error($error);
    }
    return $req->{sessionInfo};
}

sub _headers {
    my ( $self, $req ) = @_;
    return { 'HEADER1' => 'TEST' };
}

sub _authorized {
    my ( $self, $req, $uri ) = @_;

    # Check rights
    my ( $vhost, $appuri ) = $uri =~ m#^https?://([^/]*)(.*)#;
    $vhost =~ s/:\d+$//;
    $vhost = $self->p->HANDLER->resolveAlias($vhost);
    $appuri ||= '/';
    return $self->p->HANDLER->grant( $req, $req->{sessionInfo}, $appuri,
        undef, $vhost );
}

1;
