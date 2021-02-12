package Lemonldap::NG::Portal::Plugins::CheckDevOps;

use strict;
use Mouse;
use JSON qw(from_json to_json);
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_ERROR
  PE_NOTOKEN
  PE_TOKENEXPIRED
  PE_BAD_DEVOPS_FILE
);

our $VERSION = '2.0.12';

extends qw(
  Lemonldap::NG::Portal::Main::Plugin
  Lemonldap::NG::Portal::Lib::_tokenRule
);

# INITIALIZATION

has ott => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $ott =
          $_[0]->{p}->loadModule('Lemonldap::NG::Portal::Lib::OneTimeToken');
        $ott->timeout( $_[0]->{conf}->{formTimeout} );
        return $ott;
    }
);

sub init {
    my ($self) = @_;
    $self->addAuthRoute( checkdevops => 'run',  ['POST'] )
      ->addAuthRoute( checkdevops => 'display', ['GET'] );

    return 1;
}

# RUNNING METHOD

sub display {
    my ( $self, $req ) = @_;

    # Display form
    my $params = {
        PORTAL    => $self->conf->{portal},
        MAIN_LOGO => $self->conf->{portalMainLogo},
        SKIN      => $self->p->getSkin($req),
        LANGS     => $self->conf->{showLanguages},
        MSG       => 'checkDevOps',
        ALERTE    => 'alert-info',
        FILE      => '',
        TOKEN     => (
              $self->ottRule->( $req, {} )
            ? $self->ott->createToken()
            : ''
        )
    };
    return $self->sendJSONresponse( $req, $params ) if $req->wantJSON;

    # Display form
    return $self->p->sendHtml( $req, 'checkdevops', params => $params, );
}

sub run {
    my ( $self, $req ) = @_;
    my ( $msg, $alert );
    my $headers = [];

    # Check token
    if ( $self->ottRule->( $req, {} ) ) {
        my $token;
        $msg = PE_OK;
        if ( $token = $req->param('token') ) {
            unless ( $self->ott->getToken($token) ) {
                $self->userLogger->warn(
                    'CheckDevOps called with an expired/bad token');
                $msg   = PE_TOKENEXPIRED;
                $token = $self->ott->createToken();
            }
        }
        else {
            $self->userLogger->warn('CheckDevOps called without token');
            $msg   = PE_NOTOKEN;
            $token = $self->ott->createToken();
        }

        my $params = {
            PORTAL    => $self->conf->{portal},
            MAIN_LOGO => $self->conf->{portalMainLogo},
            SKIN      => $self->p->getSkin($req),
            LANGS     => $self->conf->{showLanguages},
            MSG       => "PE$msg",
            ALERTE    => 'alert-warning',
            FILE      => '',
            TOKEN     => $token,
        };
        return $self->p->sendJSONresponse( $req, $params )
          if $req->wantJSON && $msg;

        # Display form
        return $self->p->sendHtml( $req, 'checkdevops', params => $params )
          if $msg;
    }

    my $json = eval { from_json( $req->param('checkDevOpsFile') ) };
    if ($@) {
        $msg   = 'PE' . PE_BAD_DEVOPS_FILE;
        $alert = 'alert-danger';
        $json  = '';
        $self->userLogger->error("CheckDevOps: bad 'rules.json' file ($@)");
    }
    else {
        my $vhost   = $self->p->HANDLER->resolveAlias($req);
        my $handler = $self->p->HANDLER;

        # Compile headers & rules
        $handler->headersInit( undef,       { $vhost => $json->{headers} } );
        $handler->locationRulesInit( undef, { $vhost => $json->{rules} } );
        $headers = $handler->checkHeaders( $req, $req->userData );
        my $list = join ', ', map { "$_->{key}:$_->{value}" } @$headers;
        $self->logger->debug("CheckDevOps compiled headers: $list");

        # Prepare form
        $msg   = 'checkDevOps';
        $alert = 'alert-info';
        $json  = $req->param('checkDevOpsFile');
        $self->logger->debug("CheckDevOps provided file: $json");
    }

    my $params = {
        PORTAL    => $self->conf->{portal},
        MAIN_LOGO => $self->conf->{portalMainLogo},
        SKIN      => $self->p->getSkin($req),
        LANGS     => $self->conf->{showLanguages},
        MSG       => $msg,
        ALERTE    => $alert,
        FILE      => $json,
        HEADERS   => $headers,
        TOKEN     => (
              $self->ottRule->( $req, {} )
            ? $self->ott->createToken()
            : ''
        )
    };
    return $self->p->sendJSONresponse( $req, $params ) if $req->wantJSON;

    # Display form
    return $self->p->sendHtml( $req, 'checkdevops', params => $params, );
}

1;
