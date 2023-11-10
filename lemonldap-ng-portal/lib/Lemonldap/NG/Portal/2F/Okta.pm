package Lemonldap::NG::Portal::2F::Okta;

use HTTP::Request;
use JSON;
use Mouse;
use WWW::Form::UrlEncoded qw/build_urlencoded/;
use Lemonldap::NG::Common::UserAgent;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_BADCREDENTIALS
  PE_BADOTP
  PE_ERROR
  PE_SENDRESPONSE
);

extends 'Lemonldap::NG::Portal::Lib::Code2F';

has prefix    => ( is => 'ro', default => 'okta' );
has conf_type => ( is => 'ro', default => 'okta' );

has ua => (
    is      => 'rw',
    lazy    => 1,
    builder => sub {
        my $ua = Lemonldap::NG::Common::UserAgent->new( $_[0]->{conf} );
        $ua->env_proxy();
        return $ua;
    }
);

sub init {
    my ($self) = @_;

    # Check mandatory parameters
    unless ( $self->conf->{okta2fAdminURL} ) {
        $self->error("Okta 2F: Admin URL is required");
        return 0;
    }
    unless ( $self->conf->{okta2fApiKey} ) {
        $self->error("Okta 2F: API key is required");
        return 0;
    }

    # Prepare UA headers
    $self->ua->default_headers->header( 'Accept'       => 'application/json' );
    $self->ua->default_headers->header( 'Content-Type' => 'application/json' );
    $self->ua->default_headers->header(
        'Authorization' => 'SSWS ' . $self->conf->{okta2fApiKey} );

    return $self->SUPER::init();
}

sub run {
    my ( $self, $req, $token ) = @_;

    my $okta_userid        = $self->getOktaUserID( $req->user );
    my $okta_sms_factor_id = $self->getOktaSMSFactorID( $req, $okta_userid );

    my $issue_response =
      $self->ua->post( $self->conf->{okta2fAdminURL}
          . '/api/v1/users/'
          . $okta_userid
          . '/factors/'
          . $okta_sms_factor_id
          . '/verify' );

    if ( $issue_response->is_error ) {
        $self->logger->error(
            "Unable to issue factor challenge for $okta_userid in Okta:"
              . $issue_response->content );
        return PE_ERROR;
    }

    $self->logger->debug("SMS code sent to $okta_userid");

    my $tmp = $self->sendCodeForm( $req, TOKEN => $token );

    $req->response($tmp);
    return PE_SENDRESPONSE;

}

sub verify_external {
    my ( $self, $req, $session, $code ) = @_;

    my $okta_userid =
      $self->getOktaUserID( $session->{ $self->conf->{whatToTrace} } );
    my $okta_sms_factor_id = $self->getOktaSMSFactorID( $req, $okta_userid );

    my $issue_content = to_json( { 'passCode' => $code } );
    my $issue_request = HTTP::Request->new(
        'POST',
        $self->conf->{okta2fAdminURL}
          . '/api/v1/users/'
          . $okta_userid
          . '/factors/'
          . $okta_sms_factor_id
          . '/verify',
        [],
        $issue_content
    );
    my $issue_response = $self->ua->request($issue_request);

    if ( $issue_response->is_error ) {
        $self->logger->error(
            "Unable to verify code $code for $okta_userid in Okta:"
              . $issue_response->content );
        return PE_ERROR;
    }
    my $okta_verification =
      $self->decodeJSON( $issue_response->decoded_content );

    unless ( $okta_verification->{factorResult} eq "SUCCESS" ) {
        $self->logger->error(
            "Verifiation failed for code $code for $okta_userid in Okta");
        return PE_BADOTP;
    }

    $self->logger->debug("SMS code verified in Okta for $okta_userid");

    return PE_OK;
}

# Convert JSON to HashRef
# @return HashRef JSON decoded content
sub decodeJSON {
    my ( $self, $json ) = @_;
    my $json_hash;

    eval { $json_hash = from_json( $json, { allow_nonref => 1 } ); };
    return undef if ($@);
    unless ( ref $json_hash ) {
        $self->logger->error("Wanted a JSON object, got: $json_hash");
        return undef;
    }

    return $json_hash;
}

# Get Okta user ID
# @return String Okta user ID
sub getOktaUserID {
    my ( $self, $okta_login ) = @_;
    my $okta_userid;

    # Search user
    $self->logger->debug("Search $okta_login in Okta");
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
        return PE_ERROR;
    }

    my $okta_user = $self->decodeJSON( $user_response->decoded_content );
    unless ( $okta_user and $okta_user->[0]->{id} ) {
        $self->logger->error("User $okta_login not found in Okta");
        return PE_ERROR;
    }

    $okta_userid = $okta_user->[0]->{id};

    $self->logger->debug("Found Okta ID $okta_userid for user $okta_login");

    return $okta_userid;
}

# Get Okta SMS factor ID
# @return String Okta SMS factor ID
sub getOktaSMSFactorID {
    my ( $self, $req, $okta_userid ) = @_;
    my $okta_sms_factor_id;

    # Search factors
    my $factor_response =
      $self->ua->get( $self->conf->{okta2fAdminURL}
          . '/api/v1/users/'
          . $okta_userid
          . '/factors' );
    if ( $factor_response->is_error ) {
        $self->logger->error( "Unable to get factors for $okta_userid in Okta:"
              . $factor_response->content );
        return PE_ERROR;
    }

    my $okta_factor = $self->decodeJSON( $factor_response->decoded_content );
    unless ($okta_factor) {
        $self->logger->error("No factors for $okta_userid in Okta");
        return PE_ERROR;
    }

    # Loop on factors to find SMS
    foreach (@$okta_factor) {
        unless ( $_->{factorType} eq "sms" ) {
            next;
        }

        $okta_sms_factor_id = $_->{id};
        last;
    }

    unless ($okta_sms_factor_id) {
        $self->logger->error("No SMS factor found for $okta_userid");
        return PE_ERROR;
    }

    return $okta_sms_factor_id;
}

1;
