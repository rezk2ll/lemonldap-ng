package Lemonldap::NG::Portal::Issuer::CAS;

use strict;
use Mouse;
use URI;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_CAS_SERVICE_NOT_ALLOWED
  PE_CONFIRM
  PE_ERROR
  PE_LOGOUT_OK
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Issuer',
  'Lemonldap::NG::Portal::Lib::CAS';

# INITIALIZATION

sub init {
    my ($self) = @_;

    # Launch parents initialization subroutines, then launch IdP en SP lists
    my $res = $self->Lemonldap::NG::Portal::Main::Issuer::init();
    $self->addUnauthRoute(
        ( $self->path ) => {
            serviceValidate => 'serviceValidate',
            validate        => 'validate',
            proxyValidate   => 'proxyValidate',
            proxy           => 'proxy'
        },
        ['GET']
    );
    return $res;
}

# RUNNING METHODS

# Main method (launched only for authenticated users, see Main/Issuer)
sub run {
    my ( $self, $req, $target ) = @_;

    # CAS URL
    my $cas_login           = 'login';
    my $cas_logout          = 'logout';
    my $cas_validate        = 'validate';
    my $cas_serviceValidate = 'serviceValidate';
    my $cas_proxyValidate   = 'proxyValidate';
    my $cas_proxy           = 'proxy';

    # Called URL
    my $url = $req->uri();

    # Session ID
    my $session_id = $req->{sessionInfo}->{_session_id} || $req->{id};

    # Session creation timestamp
    my $time = $req->{sessionInfo}->{_utime} || time();

    # 1. LOGIN
    if ( $target eq $cas_login ) {

        $self->lmLog( "URL $url detected as an CAS LOGIN URL", 'debug' );

        # GET parameters
        my $service = $self->p->getHiddenFormValue( $req, 'service' )
          || $req->param('service');
        my $renew =
          $self->p->getHiddenFormValue( $req, 'renew' ) || $req->param('renew');
        my $gateway = $self->p->getHiddenFormValue( $req, 'gateway' )
          || $req->param('gateway');
        my $casServiceTicket;

        # Renew
        if ( $renew and $renew eq 'true' ) {

            # Authentication must be replayed
            $self->lmLog( "Authentication renew requested", 'debug' );
            $self->{updateSession} = 1;
            $req->steps(
                [
                    @{ $self->p->beforeAuth },
                    $self->p->authProcess,
                    @{ $self->p->betweenAuthAndDatas },
                    $self->p->sessionDatas,
                    @{ $self->p->afterDatas },
                ]
            );
            return PE_OK;
        }

        # If no service defined, exit
        unless ( defined $service ) {
            $self->lmLog( "No service defined in CAS URL", 'debug' );
            return PE_OK;
        }

        # Check access on the service
        my $casAccessControlPolicy = $self->conf->{casAccessControlPolicy};

        if ( $casAccessControlPolicy =~ /^(error|faketicket)$/i ) {
            $self->lmLog( "CAS access control requested on service $service",
                'debug' );

            ## HERE
            unless ( $service =~ m#^https?://([^/]+)(/.*)?$# ) {
                $self->lmLog( "Bad service $service", 'error' );
                return PE_ERROR;
            }
            my ( $host, $uri ) = ( $1, $2 );
            if ( $self->p->HANDLER->grant( $req->sessionInfo, $1, undef, $2 ) )
            {
                $self->lmLog( "CAS service $service access allowed", 'debug' );
            }

            else {
                $self->lmLog( "CAS service $service access not allowed",
                    'error' );

                if ( $casAccessControlPolicy =~ /^(error)$/i ) {
                    $self->lmLog(
"Return error instead of redirecting user on CAS service",
                        'debug'
                    );
                    return PE_CAS_SERVICE_NOT_ALLOWED;
                }

                else {
                    $self->lmLog(
                        "Redirect user on CAS service with a fake ticket",
                        'debug' );
                    $casServiceTicket = "ST-F4K3T1CK3T";
                }
            }
        }

        unless ($casServiceTicket) {

            # Check last authentication time to decide if
            # the authentication is recent or not
            my $casRenewFlag = 0;
            my $last_authn_utime = $self->{sessionInfo}->{_lastAuthnUTime} || 0;
            if (
                time() - $last_authn_utime <
                $self->conf->{portalForceAuthnInterval} )
            {
                $self->lmLog(
                    "Authentication is recent, will set CAS renew flag to true",
                    'debug'
                );
                $casRenewFlag = 1;
            }

            # Create a service ticket
            $self->lmLog( "Create a CAS service ticket for service $service",
                'debug' );

            my $casServiceSession = $self->getCasSession();

            unless ($casServiceSession) {
                $self->lmLog( "Unable to create CAS session", 'error' );
                return PE_ERROR;
            }

            my $Sinfos;
            $Sinfos->{type}    = 'casService';
            $Sinfos->{service} = $service;
            $Sinfos->{renew}   = $casRenewFlag;
            $Sinfos->{_cas_id} = $session_id;
            $Sinfos->{_utime}  = $time;

            $casServiceSession->update($Sinfos);

            my $casServiceSessionID = $casServiceSession->id;
            $casServiceTicket = "ST-" . $casServiceSessionID;

            $self->lmLog( "CAS service session $casServiceSessionID created",
                'debug' );
        }

        # Redirect to service
        my $service_url = $service;
        $service_url .= (
            $service =~ /\?/
            ? '&ticket=' . $casServiceTicket
            : '?ticket=' . $casServiceTicket
        );

        $self->lmLog( "Redirect user to $service_url", 'debug' );

        $req->{urldc} = $service_url;

        $req->steps( [] );
        return PE_OK;
    }

    # 2. LOGOUT
    if ( $target eq $cas_logout ) {

        $self->lmLog( "URL $url detected as an CAS LOGOUT URL", 'debug' );

        # GET parameters
        my $logout_url = $req->param('url');

        # Delete linked CAS sessions
        $self->deleteCasSecondarySessions($session_id);

        # Delete local session
        if ( my $session = $self->p->getApacheSession( $session_id, 1 ) ) {
            unless ( $self->p->_deleteSession( $req, $session ) ) {
                $self->lmLog( "Fail to delete session $session_id ", 'error' );
            }

            if ($logout_url) {

                # Display a link to the provided URL
                $self->lmLog( "Logout URL $logout_url will be displayed",
                    'debug' );

                $self->info( $req,
'<h3 trmsg="back2CasUrl">The application you just logged out of has provided a link it would like you to follow</h3>'
                );
                $self->info( $req,
                    "<p><a href=\"$logout_url\">$logout_url</a></p>" );
                $req->datas->{activeTimer} = 0;

                return PE_CONFIRM;
            }
        }
        else {
            $self->lmLog( "Unknown session $session_id", 'info' );
        }

        return PE_LOGOUT_OK;

    }

    # 3. VALIDATE [CAS 1.0]
    if ( $target eq $cas_validate ) {

        $self->lmLog( "URL $url detected as an CAS VALIDATE URL", 'debug' );

        # This URL must not be called by authenticated users
        $self->lmLog(
            "CAS VALIDATE URL called by authenticated user, ignore it",
            'info' );

        return PE_OK;
    }

    # 4. SERVICE VALIDATE [CAS 2.0]
    if ( $target eq $cas_serviceValidate ) {

        $self->lmLog( "URL $url detected as an CAS SERVICE VALIDATE URL",
            'debug' );

        # This URL must not be called by authenticated users
        $self->lmLog(
            "CAS SERVICE VALIDATE URL called by authenticated user, ignore it",
            'info'
        );

        return PE_OK;
    }

    # 5. PROXY VALIDATE [CAS 2.0]
    if ( $target eq $cas_proxyValidate ) {

        $self->lmLog( "URL $url detected as an CAS PROXY VALIDATE URL",
            'debug' );

        # This URL must not be called by authenticated users
        $self->lmLog(
            "CAS PROXY VALIDATE URL called by authenticated user, ignore it",
            'info' );

        return PE_OK;
    }

    # 6. PROXY [CAS 2.0]
    if ( $target eq $cas_proxy ) {

        $self->lmLog( "URL $url detected as an CAS PROXY URL", 'debug' );

        # This URL must not be called by authenticated users
        $self->lmLog( "CAS PROXY URL called by authenticated user, ignore it",
            'info' );

        return PE_OK;
    }

    return PE_OK;
}

sub logout {
    my ( $self, $req ) = @_;

    # Session ID
    my $session_id = $req->{sessionInfo}->{_session_id} || $req->{id};

    # Delete linked CAS sessions
    $self->deleteCasSecondarySessions($session_id);

    return PE_OK;
}

# Direct request from SP to IdP

sub validate {
    my ( $self, $req ) = @_;
    $self->lmLog( 'URL ' . $req->uri . ' detected as an CAS VALIDATE URL',
        'debug' );

    # GET parameters
    my $service = $req->param('service');
    my $ticket  = $req->param('ticket');
    my $renew   = $req->param('renew');

    # Required parameters: service and ticket
    unless ( $service and $ticket ) {
        $self->lmLog( "Service and Ticket parameters required", 'error' );
        return $self->returnCasValidateError();
    }

    $self->lmLog(
        "Get validate request with ticket $ticket for service $service",
        'debug' );

    unless ( $ticket =~ s/^ST-// ) {
        $self->lmLog( "Provided ticket is not a service ticket (ST)", 'error' );
        return $self->returnCasValidateError();
    }

    my $casServiceSession = $self->getCasSession($ticket);

    unless ($casServiceSession) {
        $self->lmLog( "Service ticket session $ticket not found", 'error' );
        return $self->returnCasValidateError();
    }

    $self->lmLog( "Service ticket session $ticket found", 'debug' );

    my $service1_uri = URI->new($service);
    my $service2_uri = URI->new( $casServiceSession->data->{service} );

    # Check service
    unless ( $service1_uri->eq($service2_uri) ) {

        # Tolerate that relative URI are the same
        if (   $service1_uri->rel($service2_uri) eq "./"
            or $service2_uri->rel($service1_uri) eq "./" )
        {
            $self->lmLog(
"Submitted service $service1_uri does not exactly match initial service "
                  . $service2_uri
                  . ' but difference is tolerated.',
                'warn'
            );
        }
        else {
            $self->lmLog(
                "Submitted service $service does not match initial service "
                  . $casServiceSession->data->{service},
                'error'
            );
            $self->deleteCasSession($casServiceSession);
            return $self->returnCasValidateError();
        }
    }
    else {
        $self->lmLog( "Submitted service $service math initial servce",
            'debug' );
    }

    # Check renew
    if ( $renew and $renew eq 'true' ) {

        # We should check the ST was delivered with primary credentials
        $self->lmLog( "Renew flag detected ", 'debug' );

        unless ( $casServiceSession->data->{renew} ) {
            $self->lmLog(
"Authentication renew requested, but not done in former authentication process",
                'error'
            );
            $self->deleteCasSession($casServiceSession);
            return $self->returnCasValidateError();
        }
    }

    # Open local session
    my $localSession =
      $self->p->getApacheSession( $casServiceSession->data->{_cas_id}, 1 );

    unless ($localSession) {
        $self->lmLog(
            "Local session "
              . $casServiceSession->data->{_cas_id}
              . " notfound",
            'error'
        );
        $self->deleteCasSession($casServiceSession);
        return $self->returnCasValidateError();
    }

    # Get username
    my $username =
      $localSession->data->{ $self->conf->{casAttr}
          || $self->conf->{whatToTrace} };

    $self->lmLog( "Get username $username", 'debug' );

    # Return success message
    $self->deleteCasSession($casServiceSession);
    return $self->returnCasValidateSuccess($username);
}

sub proxy {
    my ( $self, $req ) = @_;
}

sub serviceValidate {
    my ( $self, $req ) = @_;
    return $self->_validate2( 'SERVICE', $req );
}

sub proxyValidate {
    my ( $self, $req ) = @_;
    return $self->_validate2( 'PROXY', $req );
}

# INTERNAL METHODS

sub _validate2 {
    my ( $self, $urlType, $req ) = @_;
    $self->lmLog(
        'URL ' . $req->uri . " detected as an CAS $urlType VALIDATE URL",
        'debug' );

    # GET parameters
    my $service = $req->param('service');
    my $ticket  = $req->param('ticket');
    my $pgtUrl  = $req->param('pgtUrl');
    my $renew   = $req->param('renew') // 'false';

    # PGTIOU
    my $casProxyGrantingTicketIOU;

    # Required parameters: service and ticket
    unless ( $service and $ticket ) {
        $self->lmLog( "Service and Ticket parameters required", 'error' );
        return $self->returnCasServiceValidateError( 'INVALID_REQUEST',
            'Missing mandatory parameters (service, ticket)' );
    }

    $self->lmLog(
        "Get "
          . lc($urlType)
          . " validate request with ticket $ticket for service $service",
        'debug'
    );

    # Get CAS session corresponding to ticket
    if ( $urlType eq 'SERVICE' and !( $ticket =~ s/^ST-// ) ) {
        $self->lmLog( "Provided ticket is not a service ticket (ST)", 'error' );
        return $self->returnCasServiceValidateError( 'INVALID_TICKET',
            'Provided ticket is not a service ticket' );
    }
    elsif ( $urlType eq 'PROXY' and !( $ticket =~ s/^(P|S)T-// ) ) {
        $self->lmLog( "Provided ticket is not a service or proxy ticket ($1T)",
            'error' );
        return $self->returnCasServiceValidateError( 'INVALID_TICKET',
            'Provided ticket is not a service or proxy ticket' );
    }

    my $casServiceSession = $self->getCasSession($ticket);

    unless ($casServiceSession) {
        $self->lmLog( "$urlType ticket session $ticket not found", 'error' );
        return $self->returnCasServiceValidateError( 'INVALID_TICKET',
            'Ticket not found' );
    }

    $self->lmLog( "$urlType ticket session $ticket found", 'debug' );

    my $service1_uri = URI->new($service);
    my $service2_uri = URI->new( $casServiceSession->data->{service} );

    # Check service
    unless ( $service1_uri->eq($service2_uri) ) {

        # Tolerate that relative URI are the same
        if (   $service1_uri->rel($service2_uri) eq "./"
            or $service2_uri->rel($service1_uri) eq "./" )
        {
            $self->lmLog(
"Submitted service $service1_uri does not exactly match initial service "
                  . $service2_uri
                  . ' but difference is tolerated.',
                'warn'
            );
        }
        else {
            $self->lmLog(
                "Submitted service $service does not match initial service "
                  . $casServiceSession->data->{service},
                'error'
            );
            $self->deleteCasSession($casServiceSession);
            return $self->returnCasServiceValidateError( 'INVALID_SERVICE',
                'Submitted service does not match initial service' );
        }
    }
    else {
        $self->lmLog( "Submitted service $service match initial service",
            'debug' );
    }

    # Check renew
    if ( $renew and $renew eq 'true' ) {

        # We should check the ST was delivered with primary credentials
        $self->lmLog( "Renew flag detected ", 'debug' );

        unless ( $casServiceSession->data->{renew} ) {
            $self->lmLog(
"Authentication renew requested, but not done in former authentication process",
                'error'
            );
            $self->deleteCasSession($casServiceSession);
            return $self->returnCasValidateError();
        }

    }

    # Proxies (for PROXY VALIDATE only)
    my $proxies = $casServiceSession->data->{proxies};

    # Proxy granting ticket
    if ($pgtUrl) {

        # Create a proxy granting ticket
        $self->lmLog( "Create a CAS proxy granting ticket for service $service",
            'debug' );

        my $casProxyGrantingSession = $self->getCasSession();

        if ($casProxyGrantingSession) {

            my $PGinfos;

            # PGT session
            $PGinfos->{type}    = 'casProxyGranting';
            $PGinfos->{service} = $service;
            $PGinfos->{_cas_id} = $casServiceSession->data->{_cas_id};
            $PGinfos->{_utime}  = $casServiceSession->data->{_utime};

            # Trace proxies
            $PGinfos->{proxies} = (
                  $proxies
                ? $proxies . $self->{multiValuesSeparator} . $pgtUrl
                : $pgtUrl
            );

            my $casProxyGrantingSessionID = $casProxyGrantingSession->id;
            my $casProxyGrantingTicket    = "PGT-" . $casProxyGrantingSessionID;

            $casProxyGrantingSession->update($PGinfos);

            $self->lmLog(
                "CAS proxy granting session $casProxyGrantingSessionID created",
                'debug'
            );

            # Generate the proxy granting ticket IOU
            my $tmpCasSession = $self->getCasSession();

            if ($tmpCasSession) {

                $casProxyGrantingTicketIOU = "PGTIOU-" . $tmpCasSession->id;
                $self->deleteCasSession($tmpCasSession);
                $self->lmLog(
"Generate proxy granting ticket IOU $casProxyGrantingTicketIOU",
                    'debug'
                );

                # Request pgtUrl
                if (
                    $self->callPgtUrl(
                        $pgtUrl, $casProxyGrantingTicketIOU,
                        $casProxyGrantingTicket
                    )
                  )
                {
                    $self->lmLog(
                        "Proxy granting URL $pgtUrl called with success",
                        'debug' );
                }
                else {
                    $self->lmLog( "Error calling proxy granting URL $pgtUrl",
                        'warn' );
                    $casProxyGrantingTicketIOU = undef;
                }
            }

        }
        else {
            $self->lmLog(
                "Error in proxy granting ticket management, bypass it",
                'warn' );
        }
    }

    # Open local session
    my $localSession =
      $self->p->getApacheSession( $casServiceSession->data->{_cas_id}, 1 );

    unless ($localSession) {
        $self->lmLog(
            "Local session "
              . $casServiceSession->data->{_cas_id}
              . " notfound",
            'error'
        );
        $self->deleteCasSession($casServiceSession);
        return $self->returnCasServiceValidateError( 'INTERNAL_ERROR',
            'No session associated to ticket' );
    }

    # Get username
    my $username =
      $localSession->data->{ $self->conf->{casAttr}
          || $self->conf->{whatToTrace} };

    $self->lmLog( "Get username $username", 'debug' );

    # Get attributes [CAS 3.0]
    my $attributes = {};
    if ( defined $self->conf->{casAttributes}
        and %{ $self->conf->{casAttributes} } )
    {
        foreach my $casAttribute ( keys %{ $self->conf->{casAttributes} } ) {
            my $localSessionValue =
              $localSession->data->{ $self->conf->{casAttributes}
                  ->{$casAttribute} };
            $attributes->{$casAttribute} = $localSessionValue
              if defined $localSessionValue;
        }
    }

    # Return success message
    $self->deleteCasSession($casServiceSession);
    return $self->returnCasServiceValidateSuccess( $req, $username,
        $casProxyGrantingTicketIOU, $proxies, $attributes );
}

1;
