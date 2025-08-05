package Lemonldap::NG::Portal::Plugins::CrowdSec;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_ERROR
  PE_SESSIONNOTGRANTED
);

our $VERSION = '2.19.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';
with 'Lemonldap::NG::Portal::Lib::CrowdSec';

# Entrypoint
use constant beforeAuth => 'checkRejections';
use constant afterSub   => { setPersistentSessionInfo => 'checkIpStatus' };

sub checkIpStatus {
    my ( $self, $req ) = @_;
    my $ip = $req->address;
    my ( $ok, $err ) = $self->bouncer($ip);

    # bouncer() answer $ok=0 only when Crowdsec response rejects the given IP
    return PE_OK if ( $ok and $err and $self->conf->{crowdsecIgnoreFailures} );

    # When $ok==0, $err contains the Crowdsec decision
    unless ($ok) {
        if ( $self->conf->{crowdsecAction} eq 'reject' ) {
            $self->auditLog(
                $req,
                code    => 403,
                message => $err,
                ip      => $ip,
            );
            return PE_SESSIONNOTGRANTED;
        }
        else {
            $self->auditLog(
                $req,
                code    => 200,
                message => "$err (ignored)",
                ip      => $ip,
            );
            $req->env->{CROWDSEC_REJECT} = 1;
            return PE_OK;
        }
    }
    return $err ? $err : PE_OK;
}

sub checkRejections {
    return PE_OK;
}

1;
