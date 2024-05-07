package Lemonldap::NG::Portal::Plugins::_OIDCTokenExchange;

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

    my $clientId         = $req->param('client_id');         # already validated
    my $subjectToken     = $req->param('subject_token');
    my $subjectTokenType = $req->param('subject_token_type');
    unless ($subjectToken) {
        $self->userLogger->error('Token exchange called without subject_token');
        return PE_OK;
    }

    # Even if this field is required in Oauth2, it seems that it is not required
    # by Keycloak.
    if ($subjectTokenType) {
        unless ($subjectTokenType =~ s/^urn:ietf:params:oauth:token-type://
            and $subjectTokenType =~
            /^(?:(?:refresh|access|id)_token|saml[12])$/ )
        {
            $self->userLogger->error( 'Malformed subject_token_type: '
                  . $req->param('subject_token_type') );
            return PE_OK;
        }
    }

    # 1.1. Use subclass validate() to get user ID
    my $uid = $self->validate( $req, $rp, $subjectToken, $subjectTokenType );
    return PE_OK unless $uid;

    # 2. Check for audience and authorization
    my $targetClientId = $req->param('audience') // $clientId;
    my $requestedRp = $rp;
    if ( $targetClientId and $targetClientId ne $clientId ) {
        ($requestedRp) = grep {
            $self->oidc->rpOptions->{$_}->{oidcRPMetaDataOptionsClientID} eq
              $targetClientId
        } keys %{ $self->oidc->rpOptions };
        unless ($requestedRp) {
            $self->userLogger->error(
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
    my $opts     = { $self->oidc->_storeOpts() };
    my $sessions = Lemonldap::NG::Common::Apache::Session->searchOn( {
            %{ $opts->{storageModuleOptions} },
            backend => $opts->{storageModule},
        },
        '_session_uid',
        $uid,
    );
    my @keys =
      sort { return $sessions->{$b}->{_utime} <=> $sessions->{$a}->{_utime}; }
      grep {
        # Only refresh_token sessions
        $sessions->{$_}->{_type} eq 'refresh_token'

          # Verify that $rp matches
          and $sessions->{$_}->{client_id} eq $targetClientId
      }
      keys %$sessions;

    unless (@keys) {

        # 3.1. If allowed, create a new refresh_token if missing
        unless ( $self->oidc->rpOptions->{$rp}
            ->{oidcRPMetaDataOptionsTokenXNoNewSession} )
        {
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

            my $res = $self->oidc->newRefreshToken(
                $rp,
                {
                    %{ $req->sessionInfo },
                    scope     => $req->param('scope') || 'openid profile email',
                    client_id => $targetClientId,
                    _session_uid => $uid,
                    grant_type   => $req->param('grant_type'),
                },
            );
            unless ($res) {
                return PE_OK;
            }
            push @keys, $res->id;
        }
        else {
            $self->userLogger->warn("No refresh_session found for $uid");
            return PE_OK;
        }
    }

    # 4. Use normal method to create new access_token from refresh_token
    #
    # TODO: remote may want a refresh_token

    $req->response(
        $self->oidc->_handleRefreshTokenGrant(
            $req, $requestedRp, $keys[0], $targetClientId
        )
    );

    return PE_SENDRESPONSE;
}

1;
