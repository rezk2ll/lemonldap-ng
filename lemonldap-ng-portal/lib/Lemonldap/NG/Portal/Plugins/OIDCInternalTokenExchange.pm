package Lemonldap::NG::Portal::Plugins::OIDCInternalTokenExchange;

use strict;
use Mouse;

extends 'Lemonldap::NG::Portal::Lib::OIDCTokenExchange';

sub validate {
    my ( $self, $req, $rp, $subjectToken, $subjectTokenType,
        $requestedTokenType )
      = @_;

    if ( $subjectTokenType and $subjectTokenType ne 'access_token' ) {
        $self->logger->error("Given token isn't declared as access_token");
        return 0;
    }
    if ( $requestedTokenType and $requestedTokenType ne 'access_token' ) {
        $self->logger->error("Requested token isn't declared as access_token");
        return 0;
    }

    my $accessTokenSession = $self->oidc->getAccessToken($subjectToken);
    unless ($accessTokenSession) {
        $self->userLogger->error(
            "Unable to validate subject_token $subjectToken");
        return 0;
    }

    unless ( $rp eq $accessTokenSession->data->{rp} ) {
        $self->userLogger->error( "subject_token rp isn't $rp ("
              . $accessTokenSession->data->{rp}
              . ')s' );
        return 0;
    }

    my $id      = $accessTokenSession->data->{user_session_id};
    my $session = $self->p->getApacheSession($id);
    return $session->data->{ $self->conf->{whatToTrace} };
}

1;
