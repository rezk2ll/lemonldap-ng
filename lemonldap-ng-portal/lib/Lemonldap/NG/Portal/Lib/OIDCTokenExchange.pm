package Lemonldap::NG::Portal::Lib::OIDCTokenExchange;

use strict;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_SENDRESPONSE
  PE_OK
);
use Mouse;

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INTERFACE
use constant hook => { oidcGotTokenExchange => 'tokenExchange' };

has oidc => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $_[0]
          ->p->loadedModules->{'Lemonldap::NG::Portal::Issuer::OpenIDConnect'};
    }
);

sub init { 1 }

# MAIN METHOD
#
# Important note: only PE_OK and PE_RESPONSE are used here because:
#  - oidcGotTokenExchange only accept PE_SENDRESPONSE has positive response
#  - PE_OK permits to continue to check other plugins
sub tokenExchange {
    my ( $self, $req, $rp ) = @_;

    unless ( $self->oidc ) {
        $self->logger->error('Authentication is not OIDC, aborting');
        return PE_OK;
    }

    $self->logger->debug("Matrix Refresh Token exchange for $rp");

    # 1. Validate request
    #
    # Note that client_id and grant_type value are verified by
    # ::/lib::OpenIDConnect

    my $clientId     = $req->param('client_id');       # already validated
    my $subjectToken = $req->param('subject_token');
    unless ($subjectToken) {
        $self->userLogger->error('Token exchange called without subject_token');
        return PE_OK;
    }

    # Even if these fields are required in Oauth2, it seems that it is not
    # required by Keycloak..

    my @types;
    foreach my $name (qw(subject_token_type requested_token_type)) {
        my $val = $req->param($name);
        if ($val) {
            unless ($val =~ s/^urn:ietf:params:oauth:token-type://
                and $val =~ /^(?:(?:refresh|access|id)_token|saml[12])$/ )
            {
                $self->logger->info(
                    "Malformed $name: " . $req->param('subject_token_type') );
                return PE_OK;
            }
        }
        push @types, $val;
    }

    # 1.1. Use subclass validate() to get user ID
    my $uid = $self->validate( $req, $rp, $subjectToken, @types );
    return PE_OK unless $uid;

    # 2. Check for audience and authorization
    my $targetClientId = $req->param('audience') // $clientId;
    my $requestedRp    = $rp;
    if ( $targetClientId and $targetClientId ne $clientId ) {
        ($requestedRp) = grep {
            $self->oidc->rpOptions->{$_}->{oidcRPMetaDataOptionsClientID} eq
              $targetClientId
        } keys %{ $self->oidc->rpOptions };
        unless ($requestedRp) {
            $self->logger->debug(
                "Token exchange request for an unexistent RP $targetClientId");
            return PE_OK;
        }
        my $list = $self->oidc->rpOptions->{$requestedRp}
          ->{oidcRPMetaDataOptionsTokenXAuthorizedRP};
        unless ( $list and grep { $_ eq $rp } split /[,;\s]+/, $list ) {
            $self->userLogger->error(
                "Token exchange for an unauthorized RP $targetClientId");
            return PE_OK;
        }
    }

    # 2. Create access_token

    # 3.2. Else find a corresponding refresh_token and use it

    # TODO: get user from refresh_tokens (or access_token) and build and return
    # an access_token
    my $opts = { $self->oidc->_storeOpts() };

    # 3.1. Create a new refresh_token if missing
    $req->user($uid);
    $req->steps( [
            'getUser',        'setAuthSessionInfo',
            'setSessionInfo', $self->p->groupsAndMacros,
            'setLocalGroups'
        ]
    );
    if ( my $error = $self->p->process($req) ) {
        if ( $error == PE_OK ) {
            $self->userLogger->warn(
                    'Token exchange requested for an invalid user ('
                  . $req->{user}
                  . ")" );
        }
        $self->logger->error("Unable to find user $uid");
        return PE_OK;
    }

    my $refreshToken = $self->oidc->newRefreshToken(
        $rp,
        {
            %{ $req->sessionInfo },
            scope        => $req->param('scope') || 'openid',
            client_id    => $targetClientId,
            _session_uid => $uid,
            grant_type   => $req->param('grant_type'),
        },
    );
    unless ($refreshToken) {
        return PE_OK;
    }

    # 4. Use normal method to create new access_token from refresh_token
    #
    # TODO: remote may want a refresh_token

    my $res =
      $self->oidc->_handleRefreshTokenGrant( $req, $requestedRp,
        $refreshToken->id, $targetClientId );

    # Insert refresh_token in response
    my $tmp = JSON::from_json( $res->[2]->[0] );
    $tmp->{refresh_token} = $refreshToken->id;
    $res->[2]->[0] = JSON::to_json($tmp);

    $req->response($res);

    return PE_SENDRESPONSE;
}

1;
