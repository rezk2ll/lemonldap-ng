package Lemonldap::NG::Portal::Plugins::OIDCRevokeServer;

use strict;
use Lemonldap::NG::Portal::Issuer::OpenIDConnect;
use Mouse;

extends 'Lemonldap::NG::Portal::Main::Plugin';

our $VERSION = '2.22.0';

has oidc => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]
          ->p->loadedModules->{'Lemonldap::NG::Portal::Issuer::OpenIDConnect'};
    }
);

sub init {
    my ($self) = @_;
    unless ( $self->conf->{issuerDBOpenIDConnectActivation} ) {
        $self->logger->error(
            'This plugin can be used only if OIDC server is enabled');
        return 0;
    }

    $self->addUnauthRoute( oidcTokenRevoke => 'oidcTokenRevoke', ['POST'] );
    1;
}

sub oidcTokenRevoke {
    my ( $self, $req ) = @_;
    my $auth = $req->env->{HTTP_AUTHORIZATION};
    unless ($auth
        and $auth eq "Bearer " . $self->conf->{restOidcRevokeSecret} )
    {
        return $self->p->sendError( $req, 'Bad credentials', 401 );
    }

    return $self->oidc->_revokeToken(
        $req,
        sub {
            my ($session) = @_;
            return $self->getRP( $session->data->{client_id} );
        },
        'OIDCTokenRevokeServer'
    );
}

1;
