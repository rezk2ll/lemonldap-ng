package Lemonldap::NG::Portal::Auth::CAS;

use strict;
use Mouse;
use URI::Escape;
use Lemonldap::NG::Common::FormEncode;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_CONFIRM
  PE_ERROR
  PE_OK
  PE_REDIRECT
  PE_SENDRESPONSE
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base', 'Lemonldap::NG::Portal::Lib::CAS';

# PROPERTIES

has srvNumber => ( is => 'rw', default => 0 );
has srvList   => ( is => 'rw', default => sub { [] } );

# INITIALIZATION

sub init {
    my ($self) = @_;
    return 0 unless ( $self->loadSrv );
    my @tab = ( keys %{ $self->casSrvList } );
    unless (@tab) {
        $self->logger->error("No CAS server configured");
        return 0;
    }
    $self->srvNumber( scalar @tab );
    my @list;

    my $portalPath = $self->conf->{portal};
    $portalPath =~ s#^https?://[^/]+/?#/#;

    foreach (@tab) {
        my $name = $self->conf->{casSrvMetaDataOptions}->{$_}
          ->{casSrvMetaDataOptionsDisplayName};
        my $icon = $self->conf->{casSrvMetaDataOptions}->{$_}
          ->{casSrvMetaDataOptionsIcon};
        my $img_src;

        if ($icon) {
            $img_src =
              ( $icon =~ m#^https?://# )
              ? $icon
              : $portalPath . $self->p->staticPrefix . "/common/" . $icon;
        }

        push @list,
          {
            val   => $_,
            name  => $name,
            icon  => $img_src,
            class => "openidconnect",
          };
    }
    $self->srvList( \@list );
    return 1;
}

# RUNNING METHODS

sub extractFormInfo {
    my ( $self, $req ) = @_;

    # Local URL
    my $local_url = $self->p->fullUrl($req);

    # Add request state parameters
    if ( $req->datas->{_url} ) {
        $local_url .= ( $local_url =~ /\?/ ? '&' : '?' )
          . build_urlencoded( url => $req->datas->{_url} );
    }
    if ( $self->conf->{authChoiceParam}
        and my $tmp = $req->param( $self->conf->{authChoiceParam} ) )
    {
        $local_url .= ( $local_url =~ /\?/ ? '&' : '?' )
          . build_urlencoded( $self->conf->{authChoiceParam} => $tmp );
    }

    # Forward hidden fields
    if ( $req->{portalHiddenFormValues}
        and %{ $req->{portalHiddenFormValues} } )
    {

        $self->logger->debug("Add hidden values to CAS redirect URL\n");
        $local_url .= ( $local_url =~ /\?/ ? '&' : '?' )
          . build_urlencoded( %{ $req->{portalHiddenFormValues} } );
    }

    # Catch proxy callback
    if ( $req->param('casProxy') ) {
        $self->logger->debug("CAS: Proxy callback detected");

        my $pgtIou = $req->param('pgtIou');
        my $pgtId  = $req->param('pgtId');

        if ( $pgtIou and $pgtId ) {

            # Store pgtId and pgtIou
            my $pgtSessionId = $self->storePGT( $pgtIou, $pgtId );
            unless ($pgtSessionId) {
                $self->userLogger->error(
                    "CAS: Unable to store pgtIou $pgtIou and pgtId $pgtId");
            }
            else {
                $self->logger->debug(
"CAS: Store pgtIou $pgtIou and pgtId $pgtId in session $pgtSessionId"
                );
            }
        }

        # Exit
        $req->response( [ 200, [ 'Content-Length' => 0 ], [] ] );
        return PE_SENDRESPONSE;
    }

    my $srv;

    # Check Service Ticket
    my $ticket = $req->param('ticket');

    # Check if CAS server is chosen
    unless ( ( $ticket and $srv = $req->cookies->{llngcasserver} )
        or $srv = $req->param('idp') )
    {
        $self->logger->debug("Redirecting user to CAS server list");

        # Auto select provider if there is only one
        if ( $self->srvNumber == 1 ) {
            ($srv) = keys %{ $self->casSrvList };
            $self->logger->debug("Selecting the only defined CAS server: $srv");
        }

        else {

            # Server list
            my $portalPath = $self->{portal};
            $portalPath =~ s#^https?://[^/]+/?#/#;

            $req->datas->{list}            = $self->opList;
            $req->datas->{confirmRemember} = 0;

            $req->datas->{login} = 1;
            return PE_CONFIRM;
        }
    }

    my $srvConf = $self->conf->{casSrvMetaDataOptions}->{$srv};
    unless ($srvConf) {
        $self->userLogger->error("CAS server $srv not configured");
        return PE_ERROR;
    }

    # Provider is choosen
    $self->logger->debug("CAS server $srv choosen");

    $req->datas->{_casSrvCurrent} = $srv;

    # Build login URL
    my $login_url = $self->getServerLoginURL( $local_url, $srvConf );
    $login_url .= '&renew=true'   if $srvConf->{casSrvMetaDataOptionsRenew};
    $login_url .= '&gateway=true' if $srvConf->{casSrvMetaDataOptionsGateway};

    # Unless a ticket has been found, we redirect the user
    unless ($ticket) {
        $self->logger->debug("CAS: Redirect user to $login_url");
        $req->{urldc} = $login_url;
        $req->steps( [] );
        $req->addCookie(
            $self->p->cookie(
                name   => 'llngcasserver',
                value  => $srv,
                secure => $self->conf->{securedCookie},
            )
        );
        return PE_REDIRECT;
    }

    $self->logger->debug("CAS: Service Ticket received: $ticket");

    # Ticket found, try to validate it
    $local_url =~ s/ticket=[^&]+//;
    $local_url =~ s/\?$//;
    ( $req->{user}, $req->datas->{casAttr} ) =
      $self->validateST( $req, $local_url, $ticket, $srvConf );
    unless ( $req->{user} ) {
        $self->userLogger->error("CAS: Unable to validate ST $ticket");
        return PE_ERROR;
    }
    else {
        $self->logger->debug("CAS: User $req->{user} found");
    }

    # Request proxy tickets for proxied services
    my $proxied = $srvConf->{casSrvMetaDataOptionsProxiedServices}->{$_} || {};
    if ( %$proxied ) {

        # Check we received a PGT
        my $pgtId = $req->datas->{pgtId};

        unless ($pgtId) {
            $self->logger->error(
                "CAS: Proxy mode activated, but no PGT received");
            return PE_ERROR;
        }

        # Get a proxy ticket for each proxied service
        foreach ( keys %$proxied ) {
            my $service = $proxied->{$_};
            my $pt = $self->retrievePT( $service, $srvConf );

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
    $req->{sessionInfo}->{authenticationLevel} = $self->conf->{casAuthnLevel};
    $req->{sessionInfo}->{_casSrv}             = $req->datas->{_casSrvCurrent};
    PE_OK;
}

sub authLogout {
    my ( $self, $req ) = @_;

    # Build CAS logout URL
    my $logout_url = $self->getServerLogoutURL(
        uri_escape( $self->p->fullUrl($req) ),
        $self->conf->{casSrvMetaDataOptions}->{ $req->userData->{_casSrv} }
          ->{casSrvMetaDataOptionsUrl}
    );

    $self->logger->debug("Build CAS logout URL: $logout_url");

    # Register CAS logout URL in logoutServices
    $req->datas->{logoutServices}->{CASserver} = $logout_url;

    PE_OK;
}

sub getDisplayType {
    return "logo";
}

1;
