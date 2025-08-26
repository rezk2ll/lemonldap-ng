package Lemonldap::NG::Portal::Plugins::CrowdSecAgent;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_BADCERTIFICATE
  PE_BADCREDENTIALS
  PE_BADOTP
  PE_CAPTCHAERROR
  PE_MALFORMEDUSER
  PE_OK
  PE_OPENID_BADID
  PE_SAML_SIGNATURE_ERROR
  PE_SENDRESPONSE
  PE_USERNOTFOUND
);

our $VERSION = '2.19.0';

our @ALERTS = (
    PE_USERNOTFOUND,         PE_BADCREDENTIALS,
    PE_BADCERTIFICATE,       PE_MALFORMEDUSER,
    PE_SAML_SIGNATURE_ERROR, PE_OPENID_BADID,
    PE_CAPTCHAERROR,         PE_BADOTP,
);

extends 'Lemonldap::NG::Portal::Main::Plugin';
with 'Lemonldap::NG::Common::CrowdSec';

has rule => ( is => 'rw', default => sub { 0 } );

has filters => ( is => 'rw', default => sub { {} } );

has banResponse => ( is => 'rw' );

# Entrypoint
use constant aroundSub => {

    # Filter function (if crowdsecFilters is set)
    controlUrl => 'controlUrl',

    # Generate alerts for bad credentials
    getUser      => 'sendIpAlerts',
    authenticate => 'sendIpAlerts'
};

sub init {
    my ($self) = @_;
    $self->_init or return 0;
    unless ($self->conf->{crowdsecMachineId}
        and $self->conf->{crowdsecPassword} )
    {
        $self->logger->error(
            'Crowdsec report enabled without machine_id and password');
        return 0;
    }
    $self->rule(
        $self->p->buildRule( $self->conf->{crowdsecAgent}, 'crowdsecAgent' ) );

    if ( $self->conf->{crowdsecFilters} ) {
        if ( -d $self->conf->{crowdsecFilters} ) {
            with 'Lemonldap::NG::Portal::Lib::CrowdsecFilter';
            $self->initializeFilters;
        }
        else {
            $self->logger->error(
                'Crowdsec filter directory not found, ignoring');
        }
    }

    $self->banResponse(
        $self->_banResponse(
            $self->conf->{crowdSecAgentResponseCode},
            $self->conf->{crowdSecAgentResponseValue}
        )
    );

    return 1;
}

sub sendIpAlerts {
    my ( $self, $sub, $req ) = @_;
    my $ret = $sub->($req);

    if ( !$self->rule->( $req, $req->sessionInfo ) ) {
        $self->logger->debug('Crowdsec-agent disabled for this env');
        return $ret;
    }

    # Nothing to do if config doesn't allow alerts or if auth is OK
    unless ( grep { $_ == $ret } @ALERTS ) {
        $self->logger->debug(
            "Crowdsec-Agent: not an authentication error: code $ret");
        return $ret;
    }
    my $msg = 'Authentication failed: '
      . &Lemonldap::NG::Portal::Main::Constants::portalConsts->{$ret};
    $self->alert( $req->address, $msg )
      ? $self->auditLog(
        $req,
        code    => 200,
        message => "Alert sent to Crowdsec: $msg",
        ip      => $req->address
      )
      : $self->logger->error(
        "Unable to send alert to Crowdsec (was '$msg' for " . $req->address );
    return $ret;
}

sub controlUrl {
    my ( $self, $sub, $req ) = @_;
    my $ret = $sub->($req);
    return $ret if $ret;

    if ( !$self->rule->( $req, $req->sessionInfo ) ) {
        $self->logger->debug('Crowdsec-agent disabled for this env');
        return $ret;
    }

    return $ret unless $self->filters;
    if (    $self->filters->{url}
        and $req->env->{REQUEST_URI} =~ $self->filters->{url} )
    {
        my $msg = 'Bad URI detected: ' . $req->env->{REQUEST_URI};
        $self->alert( $req->address, $msg, { reason => "LLNG bad URL" } )
          ? $self->auditLog(
            $req,
            code         => 200,
            message      => "Alert sent to Crowdsec: $msg",
            ip           => $req->address,
            uri          => $req->env->{REQUEST_URI},
            matchingPart => $&,
          )
          : $self->logger->error(
            "Unable to send alert to Crowdsec (was '$msg' for "
              . $req->address );
        $req->response( $self->banResponse );
        return PE_SENDRESPONSE;
    }
    return $ret;
}

sub _banResponse {
    my ( $self, $code, $value ) = @_;
    if ( $code == 200 ) {
        return [
            200,
            [ 'Content-Type' => 'text/html' ],
            [ $value || '<html><body>dummy</body></html>' ]
        ];
    }
    if ( $code == 302 ) {
        return [ 302, [ Location => $value || 'https://somewhere.else' ], [] ];
    }
    return [ 404, [], [ $value || 'Not found' ] ];
}

1;
