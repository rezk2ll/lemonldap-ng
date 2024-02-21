package Lemonldap::NG::Portal::Lib::Okta;

use strict;
use Mouse::Role;
use WWW::Form::UrlEncoded qw/build_urlencoded/;

has ua => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {
        my $ua = Lemonldap::NG::Common::UserAgent->new( $_[0]->{conf} );
        $ua->env_proxy();
        return $ua;
    }
);

sub searchProfile {
    my ( $self, $okta_login ) = @_;

    my $okta_search =
      build_urlencoded( 'search', 'profile.login eq "' . $okta_login . '"' );
    my $user_response =
      $self->ua->get(
        $self->conf->{okta2fAdminURL} . '/api/v1/users/?' . $okta_search );
    if ( $user_response->is_error ) {
        $self->logger->error( "Unable to get user "
              . $okta_login
              . " in Okta:"
              . $user_response->content );
        return;
    }

    return $user_response->decoded_content;
}

1;
