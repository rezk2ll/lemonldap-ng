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
with 'Lemonldap::NG::Portal::Lib::CrowdSec';

# Entrypoint
use constant aroundSub =>
  { getUser => 'sendIpAlerts', authenticate => 'sendIpAlerts' };

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
    return 1;
}

sub sendIpAlerts {
    my ( $self, $sub, $req ) = @_;
    my $ret = $sub->($req);

    # Nothing to do if config doesn't allow alerts or if auth is OK
    return $ret unless grep { $_ == $ret } @ALERTS;
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

1;
