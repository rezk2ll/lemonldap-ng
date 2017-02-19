package Lemonldap::NG::Portal::Auth::CAS;

use strict;
use Mouse;
use URI::Escape;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_ERROR
  PE_OK
  PE_REDIRECT
  PE_SENDRESPONSE
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base', 'Lemonldap::NG::Portal::Lib::CAS';

# PROPERTIES

# Act as a proxy if proxied services configured
has proxy => (
    is      => 'rw',
    builder => sub {
        return
          ref( $_[0]->conf->{CAS_proxiedServices} ) eq 'HASH'
          ? ( %{ $_[0]->conf->{CAS_proxiedServices} } ? 1 : 0 )
          : 0;
    }
);

has cas => ( is => 'rw' );

# INITIALIZATION

sub init {
    my ($self) = @_;
    eval { require AuthCAS };
    if ($@) {
        $self->error("Unable to load AuthCAS: $@");
        return 0;
    }
    $self->cas(
        AuthCAS->new(
            casUrl => $self->conf->{CAS_url},
            CAFile => $self->conf->{CAS_CAFile},
        )
    );
    return 1;
}

# RUNNING METHODS

sub extractFormInfo {
    my ( $self, $req ) = @_;

    # Local URL
    my $local_url = $self->p->fullUrl($req);

    # Add request state parameters
    if ( $req->datas->{_url} ) {
        my $url_param = 'url=' . uri_escape( $req->datas->{_url} );
        $local_url .= ( $local_url =~ /\?/ ? '&' : '?' ) . $url_param;
    }
    if ( $self->conf->{authChoiceParam}
        and my $tmp = $req->param( $self->conf->{authChoiceParam} ) )
    {
        my $url_param = $self->conf->{authChoiceParam} . '=' . uri_escape($tmp);
        $local_url .= ( $local_url =~ /\?/ ? '&' : '?' ) . $url_param;
    }

    # Forward hidden fields
    if ( $req->{portalHiddenFormValues}
        and %{ $req->{portalHiddenFormValues} } )
    {

        $self->logger->debug("Add hidden values to CAS redirect URL\n");

        foreach ( keys %{ $req->{portalHiddenFormValues} } ) {
            $local_url .=
                ( $local_url =~ /\?/ ? '&' : '?' )
              . $_ . '='
              . uri_escape( $req->{portalHiddenFormValues}->{$_} );
        }
    }

    if ( $self->proxy ) {
        $self->logger->debug("CAS: Proxy mode activated");
        my $proxy_url = $self->p->fullUrl($req) . '?casProxy=1';

        if ( $self->conf->{authChoiceParam}
            and my $tmp = $req->param( $self->conf->{authChoiceParam} ) )
        {
            $proxy_url .= '&' . $self->conf->{authChoiceParam} . "=$tmp";
        }

        $self->logger->debug("CAS Proxy URL: $proxy_url");

        $self->cas->proxyMode(
            pgtFile        => $self->conf->{CAS_pgtFile},
            pgtCallbackUrl => $proxy_url
        );
    }

    # Catch proxy callback
    if ( $req->param('casProxy') ) {
        $self->logger->debug("CAS: Proxy callback detected");

        my $pgtIou = $req->param('pgtIou');
        my $pgtId  = $req->param('pgtId');

        if ( $pgtIou and $pgtId ) {

            # Store pgtId and pgtIou
            unless ( $self->cas->storePGT( $pgtIou, $pgtId ) ) {
                $self->userLogger->error(
                    "CAS: error " . &AuthCAS::get_errors() );
            }
            else {
                $self->logger->debug(
                    "CAS: Store pgtIou $pgtIou and pgtId $pgtId");
            }
        }

        # Exit
        $req->response( [ 200, [ 'Content-Length' => 0 ], [] ] );
        return PE_SENDRESPONSE;
    }

    # Build login URL
    my $login_url = $self->cas->getServerLoginURL($local_url);
    $login_url .= '&renew=true'   if $self->conf->{CAS_renew};
    $login_url .= '&gateway=true' if $self->conf->{CAS_gateway};

    # Check Service Ticket
    my $ticket = $req->param('ticket');

    # Unless a ticket has been found, we redirect the user
    unless ($ticket) {
        $self->logger->debug("CAS: Redirect user to $login_url");
        $req->{urldc} = $login_url;
        $req->steps( [] );
        return PE_REDIRECT;
    }

    $self->logger->debug("CAS: Service Ticket received: $ticket");

    # Ticket found, try to validate it
    unless ( $req->{user} = $self->cas->validateST( $local_url, $ticket ) ) {
        $self->userLogger->error( "CAS: error " . &AuthCAS::get_errors() );
        return PE_ERROR;
    }
    else {
        $self->logger->debug("CAS: User $req->{user} found");
    }

    # Request proxy tickets for proxied services
    if ( $self->proxy ) {

        # Check we received a PGT
        my $pgtId = $self->cas->{pgtId};

        unless ($pgtId) {
            $self->logger->error(
                "CAS: Proxy mode activated, but no PGT received");
            return PE_ERROR;
        }

        # Get a proxy ticket for each proxied service
        foreach ( keys %{ $self->conf->{CAS_proxiedServices} } ) {
            my $service = $self->conf->{CAS_proxiedServices}->{$_};
            my $pt      = $self->cas->retrievePT($service);

            unless ($pt) {
                $self->logger->error(
                    "CAS: No proxy ticket recevied for service $service");
                return PE_ERROR;
            }

            $self->logger->debug(
                "CAS: Received proxy ticket $pt for service $service");

            # Store it in session
            $req->{sessionInfo}->{ '_casPT' . $_ } = $pt;
        }

    }

    return PE_OK;
}

sub authenticate {
    PE_OK;
}

# Set authenticationLevel.
sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    $req->{sessionInfo}->{authenticationLevel} = $self->conf->{CAS_authnLevel};
    PE_OK;
}

sub authLogout {
    my ( $self, $req ) = @_;

    # Build CAS logout URL
    my $logout_url =
      $self->cas->getServerLogoutURL( uri_escape( $self->p->fullUrl($req) ) );

    $self->logger->debug("Build CAS logout URL: $logout_url");

    # Register CAS logout URL in logoutServices
    $req->datas->{logoutServices}->{CASserver} = $logout_url;

    PE_OK;
}

sub getDisplayType {
    return "logo";
}

1;
