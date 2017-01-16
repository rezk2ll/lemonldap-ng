package Lemonldap::NG::Portal::Auth::Demo;

use strict;
use Mouse;
use URI::Escape;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR);

our $VERSION = '2.0.0';

# INITIALIZATION

has twitterRequestTokenURL => (
    is      => 'ro',
    default => sub {
        $_[0]->conf->{twitterRequestTokenURL}
          || 'https://api.twitter.com/oauth/request_token';
    }
);

has twitterAuthorizeURL => (
    is      => 'ro',
    default => sub {
        $_[0]->conf->{twitterAuthorizeURL}
          || 'https://api.twitter.com/oauth/authorize';
    }
);

has twitterAccessTokenURL => (
    is      => 'ro',
    default => sub {
        $_[0]->conf->{twitterAccessTokenURL}
          || 'https://api.twitter.com/oauth/access_token';
    }
);

sub init {
    my ($self) = @_;
    unless ( $self->conf->{twitterKey} and $self->conf->{twitterSecret} ) {
        $self->error('twitterKey and twitterSecret parameters are required');
        return 0;
    }
    eval {
        require Net::OAuth;
        $Net::OAuth::PROTOCOL_VERSION = &Net::OAuth::PROTOCOL_VERSION_1_0A();
    };
    if ($@) {
        $self->error("Unable to load Net::OAuth: $@");
        return 0;
    }
    return 1;
}

sub extractFormInfo {
    my ( $self, $req ) = @_;
    my $nonce = time;

    # 1. Request to authenticate
    unless ( $req->param('twitterback') ) {
        $self->lmLog( 'Redirection to Twitter', 'debug' );

        # 1.1 Try to get token to dialog with Twitter
        my $callback_url = $self->url();

        # Twitter callback parameter
        $callback_url .=
          ( $callback_url =~ /\?/ ? '&' : '?' ) . "twitterback=1";

        # Add request state parameters
        if ( $req->datas->{_url} ) {
            my $url_param = 'url=' . uri_escape( $req->datas->{_url} );
            $callback_url .= ( $callback_url =~ /\?/ ? '&' : '?' ) . $url_param;
        }
        if ( $req->param( $self->conf->{authChoiceParam} ) ) {
            my $url_param =
              $self->conf->{authChoiceParam} . '='
              . uri_escape( $req->param( $self->conf->{authChoiceParam} ) );
            $callback_url .= ( $callback_url =~ /\?/ ? '&' : '?' ) . $url_param;
        }

        # Forward hidden fields
        if ( exists $req->{portalHiddenFormValues} ) {

            $self->lmLog( "Add hidden values to Twitter redirect URL",
                'debug' );

            foreach ( keys %{ $req->{portalHiddenFormValues} } ) {
                $callback_url .=
                    ( $callback_url =~ /\?/ ? '&' : '?' )
                  . $_ . '='
                  . uri_escape( $req->{portalHiddenFormValues}->{$_} );
            }
        }

        my $request = Net::OAuth->request("request token")->new(
            consumer_key     => $self->conf->{twitterKey},
            consumer_secret  => $self->conf->{twitterSecret},
            request_url      => $self->twitterRequestTokenURL,
            request_method   => 'POST',
            signature_method => 'HMAC-SHA1',
            timestamp        => time,
            nonce            => $nonce,
            callback         => $callback_url,
        );

        $request->sign;

        my $request_url = $request->to_url;

        $self->lmLog( "POST $request_url to Twitter", 'debug' );

        my $res = $self->ua()->post($request_url);
        $self->lmLog( "Twitter response: " . $res->as_string, 'debug' );

        if ( $res->is_success ) {
            my $response = Net::OAuth->response('request token')
              ->from_post_body( $res->content );

            # 1.2 Store token key and secret in cookies
            $req->addCookie(
                $self->cookie(
                    name    => '_twitSec',
                    value   => $response->token_secret,
                    expires => '+3m'
                )
            );

            # 1.3 Redirect user to Twitter
            my $authorize_url =
              $self->twitterAuthorizeURL . "?oauth_token=" . $response->token;
            $self->redirect( -uri => $authorize_url );
            $self->quit();
        }
        else {
            $self->lmLog( 'Twitter OAuth protocol error: ' . $res->content,
                'error' );
            return PE_ERROR;
        }
    }

    # 2. User is back from Twitter
    my $request_token = $req->param('oauth_token');
    my $verifier      = $req->param('oauth_verifier');
    unless ( $request_token and $verifier ) {
        $self->lmLog( 'Twitter OAuth protocol error', 'error' );
        return PE_ERROR;
    }

    $self->lmLog(
        "Get token $request_token and verifier $verifier from Twitter",
        'debug' );

    # 2.1 Reconnect to Twitter
    my $access = Net::OAuth->request("access token")->new(
        consumer_key     => $self->conf->{twitterKey},
        consumer_secret  => $self->conf->{twitterSecret},
        request_url      => $self->twitterAccessTokenURL,
        request_method   => 'POST',
        signature_method => 'HMAC-SHA1',
        verifier         => $verifier,
        token            => $request_token,
        token_secret     => $self->cookie('_twitSec'),
        timestamp        => time,
        nonce            => $nonce,
    );
    $access->sign;

    my $access_url = $access->to_url;

    $self->lmLog( "POST $access_url to Twitter", 'debug' );

    my $res_access = $self->ua()->post($access_url);
    $self->lmLog( "Twitter response: " . $res_access->as_string, 'debug' );

    if ( $res_access->is_success ) {
        my $response = Net::OAuth->response('access token')
          ->from_post_body( $res_access->content );

        # Get user_id and screename
        $req->datas->{_twitterUserId} = $response->{extra_params}->{user_id};
        $req->datas->{_twitterScreenName} =
          $response->{extra_params}->{screen_name};

        $self->lmLog(
            "Get user id "
              . $req->datas->{_twitterUserId}
              . " and screen name "
              . $req->datas->{_twitterScreenName},
            'debug'
        );
    }
    else {
        $self->lmLog( 'Twitter OAuth protocol error: ' . $res_access->content,
            'error' );
        return PE_ERROR;
    }

    # 2.4 Set $req->{user} to screen name
    $req->user( $req->datas->{_twitterScreenName} );
    $self->lmLog( "Good Twitter authentication for $req->{user}", 'debug' );

    # Force redirection to avoid displaying OAuth datas
    $req->{mustRedirect} = 1;

    # Clean temporaries cookies
    $req->addCookie(
        $self->cookie( -name => '_twitSec', -value => 0, -expires => '-3m' ) );
    PE_OK;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;

    $req->{sessionInfo}->{authenticationLevel} =
      $req->datas->{twitterAuthnLevel};
    $req->{sessionInfo}->{_twitterUserId} = $req->datas->{_twitterUserId};
    $req->{sessionInfo}->{_twitterScreenName} =
      $req->datas->{_twitterScreenName};

    PE_OK;
}

sub authenticate {
    PE_OK;
}

sub authLogout {
    PE_OK;
}

sub getDisplayType {
    return "logo";
}

1;
