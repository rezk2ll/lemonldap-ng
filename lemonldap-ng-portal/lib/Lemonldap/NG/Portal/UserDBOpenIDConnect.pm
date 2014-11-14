## @file
# OpenIDConnect userDB mechanism

## @class
# OpenIDConnect userDB mechanism class
package Lemonldap::NG::Portal::UserDBOpenIDConnect;

use strict;
use JSON;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::_Browser;

our @ISA     = (qw(Lemonldap::NG::Portal::_Browser));
our $VERSION = '2.00';

## @apmethod int userDBInit()
# Do nothing
# @return Lemonldap::NG::Portal constant
sub userDBInit {
    PE_OK;
}

## @apmethod int getUser()
# Do nothing
# @return Lemonldap::NG::Portal constant
sub getUser {
    my $self = shift;

    my $access_token = $self->{tmp}->{access_token};
    my $userinfo_uri = $self->{OIDCRPUserInfoURI};

    return PE_OK unless $userinfo_uri;

    $self->lmLog(
        "Request User Info on $userinfo_uri with access token $access_token",
        'debug' );

    my $userinfo_response = $self->ua->get( $userinfo_uri,
        "Authorization" => "Bearer $access_token" );

    if ( $userinfo_response->is_error ) {
        $self->lmLog( "Bad User Info response: " . $userinfo_response->message,
            'error' );
        $self->lmLog( $userinfo_response->decoded_content, 'debug' );
        return PE_ERROR;
    }

    my $userinfo_content = $userinfo_response->decoded_content;

    $self->lmLog( "UserInfo received: $userinfo_content", 'debug' );

    $self->{tmp}->{OpenIDConnect_user_info} = decode_json $userinfo_content;

    PE_OK;
}

## @apmethod int setSessionInfo()
# Do nothing
# @return Lemonldap::NG::Portal constant
sub setSessionInfo {
    my $self = shift;

    my %vars = ( %{ $self->{exportedVars} }, %{ $self->{OIDCRPExportedVars} } );
    while ( my ( $k, $v ) = each %vars ) {
        $self->{sessionInfo}->{$k} =
          $self->{tmp}->{OpenIDConnect_user_info}->{$v}
          || "";
    }

    PE_OK;
}

## @apmethod int setGroups()
# Do nothing
# @return Lemonldap::NG::Portal constant
sub setGroups {
    PE_OK;
}

1;

