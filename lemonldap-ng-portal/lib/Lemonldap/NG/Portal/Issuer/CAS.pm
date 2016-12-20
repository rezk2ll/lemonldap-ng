package Lemonldap::NG::Portal::Issuer::CAS;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Issuer',
  'Lemonldap::NG::Portal::Lib::CAS';

# INITIALIZATION

sub init {
    my ($self) = @_;

    # Launch parents initialization subroutines, then launch IdP en SP lists
    return ( $self->Lemonldap::NG::Portal::Main::Issuer::init() );
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
        my $service = $self->getHiddenFormValue( $req, 'service' )
          || $req->param('service');
        my $renew =
          $self->getHiddenFormValue( $req, 'renew' ) || $req->param('renew');
        my $gateway = $self->getHiddenFormValue( $req, 'gateway' )
          || $req->param('gateway');
        my $casServiceTicket;

        # Renew
        if ( $renew eq 'true' ) {

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
            if ( $self->_grant($service) ) {
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
                time() - $last_authn_utime < $self->{portalForceAuthnInterval} )
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

        $self->{urldc} = $service_url;

        return $self->_subProcess(qw(autoRedirect));
    }

    # 2. LOGOUT
    if ( $target eq $cas_logout ) {

        $self->lmLog( "URL $url detected as an CAS LOGOUT URL", 'debug' );

        # GET parameters
        my $logout_url = $self->param('url');

        # Delete linked CAS sessions
        $self->deleteCasSecondarySessions($session_id);

        # Delete local session
        unless (
            $self->_deleteSession( $self->getApacheSession( $session_id, 1 ) ) )
        {
            $self->lmLog( "Fail to delete session $session_id ", 'error' );
        }

        if ($logout_url) {

            # Display a link to the provided URL
            $self->lmLog( "Logout URL $logout_url will be displayed", 'debug' );

            $self->info( "<h3>" . $self->msg(PM_BACKTOCASURL) . "</h3>" );
            $self->info("<p><a href=\"$logout_url\">$logout_url</a></p>");
            $self->{activeTimer} = 0;

            return PE_CONFIRM;
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

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::Issuer::CAS - CAS Issuer for LemonLDAP::NG

=head1 DESCRIPTION

CAS Issuer implementation in LemonLDAP::NG

=head1 SEE ALSO

L<Lemonldap::NG::Portal>,
L<http://www.jasig.org/cas/protocol>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2010-2016 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2012 by François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Copyright (C) 2010-2012 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=back

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.

=cut
