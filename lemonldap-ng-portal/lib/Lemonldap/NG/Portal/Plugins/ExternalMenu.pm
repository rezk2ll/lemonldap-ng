package Lemonldap::NG::Portal::Plugins::ExternalMenu;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

our $VERSION = '2.22.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INTERFACE
use constant endAuth     => 'setExternalMenu';
use constant forAuthUser => 'setExternalMenu';

# Compiled URL sub
has externalMenuUrl => ( is => 'rw' );

# INITIALIZATION
sub init {
    my ($self) = @_;

    my $url = $self->conf->{externalMenu};

    # Minimum URL format validation
    if ( $url and $url !~ m#^(?:\w+)://# ) {
        $self->logger->error('externalMenu must be a valid URL');
        return 0;
    }

    # Compile URL with variable substitution
    my $sub =
      $self->p->HANDLER->buildSub( $self->p->HANDLER->substitute("qq{$url}") );
    unless ($sub) {
        $self->logger->error( 'externalMenu URL compilation error: '
              . $self->p->HANDLER->tsv->{jail}->error );
        return 0;
    }
    $self->externalMenuUrl($sub);
    return 1;
}

# RUNNING METHOD
sub setExternalMenu {
    my ( $self, $req ) = @_;

    # Only set urldc if:
    # - Authentication succeeded (PE_OK)
    # - urldc is not already set
    unless ( $req->{urldc} ) {
        if ( my $url = $self->externalMenuUrl->( $req, $req->sessionInfo ) ) {
            $self->logger->debug("ExternalMenu: redirecting to $url");
            $req->{urldc} = $url;
        }
    }
    return PE_OK;
}

1;
