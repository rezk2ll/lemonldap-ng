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
    if ( my $tmp = $req->param( $self->conf->{authChoiceParam} ) ) {
        my $url_param = $self->conf->{authChoiceParam} . '=' . uri_escape($tmp);
        $local_url .= ( $local_url =~ /\?/ ? '&' : '?' ) . $url_param;
    }

    # Forward hidden fields
    if ( $req->{portalHiddenFormValues}
        and %{ $req->{portalHiddenFormValues} } )
    {

        $self->lmLog( "Add hidden values to CAS redirect URL\n", 'debug' );

        foreach ( keys %{ $req->{portalHiddenFormValues} } ) {
            $local_url .=
                ( $local_url =~ /\?/ ? '&' : '?' )
              . $_ . '='
              . uri_escape( $req->{portalHiddenFormValues}->{$_} );
        }
    }

    if ( $self->proxy ) {
        $self->lmLog( "CAS: Proxy mode activated", 'debug' );
        my $proxy_url = $self->p->fullUrl($req) . '?casProxy=1';

        if ( my $tmp = $req->param( $self->conf->{authChoiceParam} ) ) {
            $proxy_url .= '&' . $self->conf->{authChoiceParam} . "=$tmp";
        }

        $self->lmLog( "CAS Proxy URL: $proxy_url", 'debug' );

        $self->cas->proxyMode(
            pgtFile        => $self->conf->{CAS_pgtFile},
            pgtCallbackUrl => $proxy_url
        );
    }

    # Catch proxy callback
    if ( $req->param('casProxy') ) {
        $self->lmLog( "CAS: Proxy callback detected", 'debug' );

        my $pgtIou = $req->param('pgtIou');
        my $pgtId  = $req->param('pgtId');

        if ( $pgtIou and $pgtId ) {

            # Store pgtId and pgtIou
            unless ( $self->cas->storePGT( $pgtIou, $pgtId ) ) {
                $self->lmLog( "CAS: error " . &AuthCAS::get_errors(), 'error' );
            }
            else {
                $self->lmLog( "CAS: Store pgtIou $pgtIou and pgtId $pgtId",
                    'debug' );
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
        $self->lmLog( "CAS: Redirect user to $login_url", 'debug' );
        $req->{urldc} = $login_url;
        $req->steps( [] );
        return PE_REDIRECT;
    }

    $self->lmLog( "CAS: Service Ticket received: $ticket", 'debug' );

    # Ticket found, try to validate it
    unless ( $req->{user} = $self->cas->validateST( $local_url, $ticket ) ) {
        $self->lmLog( "CAS: error " . &AuthCAS::get_errors(), 'error' );
        return PE_ERROR;
    }
    else {
        $self->lmLog( "CAS: User $req->{user} found", 'debug' );
    }

    # Request proxy tickets for proxied services
    if ( $self->proxy ) {

        # Check we received a PGT
        my $pgtId = $self->cas->{pgtId};

        unless ($pgtId) {
            $self->lmLog( "CAS: Proxy mode activated, but no PGT received",
                'error' );
            return PE_ERROR;
        }

        # Get a proxy ticket for each proxied service
        foreach ( keys %{ $self->conf->{CAS_proxiedServices} } ) {
            my $service = $self->conf->{CAS_proxiedServices}->{$_};
            my $pt      = $self->cas->retrievePT($service);

            unless ($pt) {
                $self->lmLog(
                    "CAS: No proxy ticket recevied for service $service",
                    'error' );
                return PE_ERROR;
            }

            $self->lmLog( "CAS: Received proxy ticket $pt for service $service",
                'debug' );

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

    $self->lmLog( "Build CAS logout URL: $logout_url", 'debug' );

    # Register CAS logout URL in logoutServices
    $req->datas->{logoutServices}->{CASserver} = $logout_url;

    PE_OK;
}

sub getDisplayType {
    return "logo";
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::Auth::CAS - Perl extension for building Lemonldap::NG
compatible portals with CAS authentication.

=head1 SYNOPSIS

=head1 DESCRIPTION

This library just overload few methods of Lemonldap::NG::Portal::Simple to use
CAS mechanism: we've just try to get CAS ticket.

See L<Lemonldap::NG::Portal::Simple> for usage and other methods.

=head1 SEE ALSO

L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Portal::Simple>,
L<http://lemonldap-ng.org/>

=head1 AUTHOR

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Thomas Chemineau, E<lt>thomas.chemineau@gmail.comE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2007-2010 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2009-2016 by Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item Copyright (C) 2009 by Thomas Chemineau, E<lt>thomas.chemineau@gmail.comE<gt>

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
