## @file
# CAS Issuer file

## @class
# CAS Issuer class
package Lemonldap::NG::Portal::IssuerDBCAS;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_CAS;
our @ISA = qw(Lemonldap::NG::Portal::_CAS);

our $VERSION = '0.01';

## @method void issuerDBInit()
# Nothing to do
# @return Lemonldap::NG::Portal error code
sub issuerDBInit {
    my $self = shift;

    return PE_OK;
}

## @apmethod int issuerForUnAuthUser()
# Manage CAS request for unauthenticated user
# @return Lemonldap::NG::Portal error code
sub issuerForUnAuthUser {
    my $self = shift;

    my $portal = $self->{portal};
    $portal =~ s/\/$//;

    # CAS URLs
    my $cas_login_url           = $portal . '/cas/login';
    my $cas_logout_url          = $portal . '/cas/logout';
    my $cas_validate_url        = $portal . '/cas/validate';
    my $cas_serviceValidate_url = $portal . '/cas/serviceValidate';
    my $cas_proxyValidate_url   = $portal . '/cas/proxyValidate';
    my $cas_proxy_url           = $portal . '/cas/proxy';

    # Called URL
    my $url = $self->url();

    # 1. LOGIN
    if ( $url =~ /\Q$cas_login_url\E/io ) {

        $self->lmLog( "URL $url detected as an CAS LOGIN URL", 'debug' );

        # GET parameters
        my $service = $self->getHiddenFormValue('service')
          || $self->param('service');
        my $renew = $self->getHiddenFormValue('renew') || $self->param('renew');
        my $gateway = $self->getHiddenFormValue('gateway')
          || $self->param('gateway');

        # Keep values in hidden fields
        $self->setHiddenFormValue( 'service', $service );
        $self->setHiddenFormValue( 'renew',   $renew );
        $self->setHiddenFormValue( 'gateway', $gateway );

        # Gateway
        # Authentication must use non-interactive mean
        if ( $gateway eq 'true' ) {

            # TODO
            $self->lmLog( "Gateway authentication not managed", 'warn' );

        }

    }

    # 2. LOGOUT
    if ( $url =~ /\Q$cas_logout_url\E/io ) {

        $self->lmLog( "URL $url detected as an CAS LOGOUT URL", 'debug' );

        # GET parameters
        my $logout_url = $self->param('url');

        if ($logout_url) {

            # We should display a link to the provided URL
            # TODO
            $self->lmLog( "Return URL not managed", 'warn' );
        }

        return PE_LOGOUT_OK;

    }

    # 3. VALIDATE [CAS 1.0]
    if ( $url =~ /\Q$cas_validate_url\E/io ) {

        $self->lmLog( "URL $url detected as an CAS VALIDATE URL", 'debug' );

        # GET parameters
        my $service = $self->param('service');
        my $ticket  = $self->param('ticket');
        my $renew   = $self->param('renew');

        # Required parameters: service and ticket
        unless ( $service and $ticket ) {
            $self->lmLog( "Service and Ticket parameters required", 'error' );
            $self->returnCasValidateError();
        }

        $self->lmLog(
            "Get validate request with ticket $ticket for service $service",
            'debug' );

        # Get CAS session corresponding to ticket
        unless ( $ticket =~ s/^ST-// ) {
            $self->lmLog( "Provided ticket is not a service ticket (ST)",
                'error' );
            $self->returnCasValidateError();
        }

        my $casServiceSession = $self->getCasSession($ticket);

        unless ($casServiceSession) {
            $self->lmLog( "Service ticket session $ticket not found", 'error' );
            $self->returnCasValidateError();
        }

        $self->lmLog( "Service ticket session $ticket found", 'debug' );

        # Check service
        unless ( $service eq $casServiceSession->{service} ) {
            $self->lmLog(
                "Submitted service $service does not match initial service "
                  . $casServiceSession->{service},
                'error'
            );
            untie %$casServiceSession;
            $self->returnCasValidateError();
        }

        $self->lmLog( "Submitted service $service math initial servce",
            'debug' );

        # Check renew
        if ( $renew eq 'true' ) {

            # We should check the ST was delivered with primary credentials
            # TODO
            $self->lmLog( "Renew parameter not managed", 'warn' );
        }

        # Open local session
        my $localSession =
          $self->getApacheSession( $casServiceSession->{_cas_id}, 1 );

        unless ($localSession) {
            $self->lmLog(
                "Local session " . $casServiceSession->{_cas_id} . " notfound",
                'error'
            );
            untie %$casServiceSession;
            $self->returnCasValidateError();
        }

        # Get username
        my $username = $localSession->{ $self->{whatToTrace} };

        $self->lmLog( "Get username $username", 'debug' );

        # Close sessions
        untie %$casServiceSession;
        untie %$localSession;

        # Return success message
        $self->returnCasValidateSuccess($username);

        # We should not be there
        return PE_ERROR;
    }

    return PE_OK;
}

## @apmethod int issuerForAuthUser()
# Manage CAS request for unauthenticated user
# @return Lemonldap::NG::Portal error code
sub issuerForAuthUser {
    my $self   = shift;

    my $portal = $self->{portal};
    $portal =~ s/\/$//;

    # CAS URLs
    my $cas_login_url           = $portal . '/cas/login';
    my $cas_logout_url          = $portal . '/cas/logout';
    my $cas_validate_url        = $portal . '/cas/validate';
    my $cas_serviceValidate_url = $portal . '/cas/serviceValidate';
    my $cas_proxyValidate_url   = $portal . '/cas/proxyValidate';
    my $cas_proxy_url           = $portal . '/cas/proxy';

    # Called URL
    my $url = $self->url();

    # Session ID
    my $session_id = $self->{sessionInfo}->{_session_id} || $self->{id};

    # Session creation timestamp
    my $time = $self->{sessionInfo}->{_utime} || time();

    # 1. LOGIN
    if ( $url =~ /\Q$cas_login_url\E/io ) {

        $self->lmLog( "URL $url detected as an CAS LOGIN URL", 'debug' );

        # GET parameters
        my $service = $self->getHiddenFormValue('service')
          || $self->param('service');
        my $renew = $self->getHiddenFormValue('renew') || $self->param('renew');
        my $gateway = $self->getHiddenFormValue('gateway')
          || $self->param('gateway');

        # Renew
        if ( $renew eq 'true' ) {

        # Authentication must be replayed
        # TODO
            $self->lmLog( "Authentication renewal not managed", 'warn' );
        }

        # If no service defined, exit
        unless ( defined $service ) {
            $self->lmLog( "No service defined in CAS URL", 'debug' );
            return PE_OK;
        }

        # Create a service ticket
        $self->lmLog( "Create a CAS service ticket for service $service",
            'debug' );

        my $casServiceSession = $self->getCasSession();

        return PE_ERROR unless $casServiceSession;

        $casServiceSession->{type}    = 'casService';
        $casServiceSession->{service} = $service;
        $casServiceSession->{_cas_id} = $session_id;
        $casServiceSession->{_utime}  = $time;

        my $casServiceSessionID = $casServiceSession->{_session_id};
        my $casServiceTicket    = "ST-" . $casServiceSessionID;

        untie %$casServiceSession;

        $self->lmLog( "CAS service session $casServiceSessionID created",
            'debug' );

        # Redirect to service
        my $service_url = (
              $service =~ /\?/
            ? $service .= '&ticket=' . $casServiceTicket
            : $service .= '?ticket=' . $casServiceTicket
        );

        $self->lmLog( "Redirect user to $service_url", 'debug' );

        $self->{urldc} = $service_url;

        return $self->_subProcess(qw(autoRedirect));
    }

    # 2. LOGOUT
    if ( $url =~ /\Q$cas_logout_url\E/io ) {

        $self->lmLog( "URL $url detected as an CAS LOGOUT URL", 'debug' );

        # GET parameters
        my $logout_url = $self->param('url');

        if ($logout_url) {

            # We should display a link to the provided URL
            # TODO
        }

        # Delete linked CAS sessions
        $self->deleteCasSecondarySessions($session_id);

        # Delete local session
        unless (
            $self->_deleteSession( $self->getApacheSession( $session_id, 1 ) ) )
        {
            $self->lmLog( "Fail to delete session $session_id ", 'error' );
        }

        return PE_LOGOUT_OK;

    }

    # 3. VALIDATE [CAS 1.0]
    if ( $url =~ /\Q$cas_validate_url\E/io ) {

        $self->lmLog( "URL $url detected as an CAS VALIDATE URL", 'debug' );

        # This URL must not be called by authenticated users
        $self->lmLog(
            "CAS VALIDATE URL called by authenticated user, ignore it",
            'info' );

        return PE_OK;
    }

    return PE_OK;
}

## @apmethod int issuerLogout()
# Destroy linked CAS sessions
# @return Lemonldap::NG::Portal error code
sub issuerLogout {
    my $self = shift;

    # Session ID
    my $session_id = $self->{sessionInfo}->{_session_id} || $self->{id};

    # Delete linked CAS sessions
    $self->deleteCasSecondarySessions($session_id);

    return PE_OK;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::IssuerDBCAS - CAS IssuerDB for LemonLDAP::NG

=head1 DESCRIPTION

CAS Issuer implementation in LemonLDAP::NG

=head1 SEE ALSO

L<Lemonldap::NG::Portal>
http://www.jasig.org/cas/protocol

=head1 AUTHOR

Clement OUDOT, E<lt>clement@oodo.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Clement OUDOT

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
