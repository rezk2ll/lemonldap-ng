package Lemonldap::NG::Portal::Auth::Facebook;

use strict;
use Mouse;
use URI::Escape;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR PE_BADCREDENTIALS);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base';

# INITIALIZATION

sub init {
    my ($self) = @_;
    eval { require Net::Facebook::Oauth2; };
    if ($@) {
        $self->error("Unable to load Net::Facebook::Oauth2: $@");
        return 0;
    }
    my $ret = 1;
    foreach my $arg (qw(facebookAppId facebookAppSecret)) {
        unless ( $self->conf->{$arg} ) {
            $ret = 0;
            $self->error("Parameter $arg is required");
        }
    }
    return $ret;
}

# RUNNING METHODS

sub extractFormInfo {
    my ( $self, $req ) = @_;
    my $fb = $self->fb($req);

    # 1. Check Facebook responses

    # 1.1 Good responses
    if ( my $code = $req->param('code') ) {
        if ( my $access_token = $fb->get_access_token( code => $code ) ) {
            $req->{sessionInfo}->{_facebookToken} = $access_token;

     # Get mandatory fields (see https://developers.facebook.com/tools/explorer)
            my @fields = ('id');

            # Look at wanted fields
            if ( $self->getModule( $req, 'user' ) =~ /^Facebook/ ) {
                push @fields,
                  map { /^(\w+)$/ ? ($1) : () }
                  values %{ $self->conf->{facebookExportedVars} };
            }
            my $datas;

            # When a field is not granted, Facebook returns only an error
            # without real explanation. So here we try to reduce query until
            # having a valid response
            while (@fields) {
                $datas = $fb->get(
                    'https://graph.facebook.com/me',
                    { fields => join( ',', @fields ) }
                )->as_hash;
                unless ( ref $datas ) {
                    $self->logger->error("Unable to get any Facebook field");
                    return PE_ERROR;
                }
                if ( $datas->{error} ) {
                    my $tmp = pop @fields;
                    $self->logger->warn(
"Unable to get some Facebook fields ($datas->{error}->{message}). Retrying without $tmp"
                    );
                }
                else {
                    last;
                }
            }
            unless (@fields) {
                $self->logger->error("Unable to get any Facebook field");
                return PE_ERROR;
            }

            # Use id fieldto trace user
            unless ( $req->{user} = $datas->{id} ) {
                $self->logger->error('Unable to get Facebook id');
                return PE_ERROR;
            }
            $req->datas->{_facebookDatas} = $datas;

            # Force redirection to avoid displaying Oauth datas
            $req->mustRedirect(1);
            return PE_OK;
        }
        return PE_BADCREDENTIALS;
    }

    # 1.2 Bad responses
    if ( my $error_code = $req->param('error_code') ) {
        my $error_message = $req->param('error_message');
        $self->logger->error("Facebook error code $error_code: $error_message");
        return PE_ERROR;
    }

    # 2. Else redirect user to Facebook login page:

    # Build Facebook redirection
    # TODO: use a param to use "publish_stream" or not
    my $check_url = $fb->get_authorization_url(
        scope   => [ 'public_profile', 'email' ],
        display => 'page',
    );
    $req->urldc($check_url);
    $req->steps( [] );
    PE_OK;
}

sub authenticate {
    PE_OK;
}

sub setAuthSessionInfo {
    my ( $self, $req ) = @_;
    $req->{sessionInfo}->{authenticationLevel} =
      $self->conf->{facebookAuthnLevel};
    PE_OK;
}

sub authFinish {
    PE_OK;
}

sub authLogout {
    PE_OK;
}

sub getDisplayType {
    return "logo";
}

sub fb {
    my ( $self, $req ) = @_;
    my $conf = $self->{conf};
    my $fb;
    my $sep = '?';
    my $ret = $conf->{portal};
    foreach my $v ( [ $req->datas->{_url}, "url" ],
        [ $req->param( $conf->{authChoiceParam} ), $conf->{authChoiceParam} ] )
    {
        if ( $v->[0] ) {
            $ret .= "$sep$v->[1]=$v->[0]";
            $sep = '&';
        }
    }

    eval {
        $fb = Net::Facebook::Oauth2->new(
            application_id     => $conf->{facebookAppId},
            application_secret => $conf->{facebookAppSecret},
            callback           => $ret,
        );
    };
    $self->logger->error($@) if ($@);
    return $fb;
}

1;
