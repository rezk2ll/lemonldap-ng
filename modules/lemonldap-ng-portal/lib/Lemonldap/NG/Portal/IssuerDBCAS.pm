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
    PE_OK;
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
        # TODO
        if ( $gateway eq 'true' ) {
            $self->lmLog( "Gateway authentication not managed", 'error' );
            return PE_ERROR;
        }

    }

    PE_OK;
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
        # Authentication must be replayed
        # TODO
        if ( $renew eq 'true' ) {
            $self->lmLog( "Authentication renewal not managed", 'error' );
            return PE_ERROR;
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
        $casServiceSession->{id}      = $session_id;

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

        $self->{urldc} = $service_url;

        return $self->_subProcess(qw(autoRedirect));
    }

    PE_OK;
}

## @apmethod int issuerLogout()
# Destroy linked CAS sessions
# @return Lemonldap::NG::Portal error code
sub issuerLogout {
    my $self = shift;

    # TODO

    PE_OK;
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
