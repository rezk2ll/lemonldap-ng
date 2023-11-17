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
  PE_NOTOKEN
  PE_SENDRESPONSE
  PE_TOKENEXPIRED
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

    # Add Okta factor choice endpoint
    unless ( $self->noRoute ) {
        $self->logger->debug( 'Adding ' . $self->prefix . '2fchoice route' );
        $self->addUnauthRoute(
            $self->prefix . '2fchoice' => '_issueFactor',
            ['POST']
        );
        $self->addUnauthRoute(
            $self->prefix . '2fchoice' => '_redirect',
            ['GET']
        );
    }
    return $self->SUPER::init();
}

sub run {
    my ( $self, $req, $token ) = @_;

    my $okta_userid = $self->getOktaUserID( $req->user );
    unless ($okta_userid) {
        $self->logger->error( "No Okta user found for " . $req->user );
        return PE_ERROR;
    }
    $self->ott->updateToken( $token, __oktaUserId => $okta_userid );

    # Get available factors ( factorid, factortype )
    my $okta_factors = $self->getOktaActiveFactors( $req, $okta_userid );

    unless ( keys %$okta_factors ) {
        $self->logger->error("No factor found for $okta_userid");
        return PE_ERROR;
    }

    $self->logger->debug("Found factors for $okta_userid");
    $self->p->_dump($okta_factors);

    # More than one factor  has been found, display okta choice
    $self->logger->debug("Prepare Okta Factor choice");
    my ( $checkLogins, $stayConnected ) = $self->getFormParams($req);
    my $res = $self->p->sendHtml(
        $req,
        'okta2fchoice',
        params => {
            TOKEN         => $token,
            CHECKLOGINS   => $checkLogins,
            STAYCONNECTED => $stayConnected,
            MODULES       => [
                map { { CODE => $_, LABEL => $okta_factors->{$_} } }
                sort keys %$okta_factors
            ],
        }
    );
    $req->response($res);
    return PE_SENDRESPONSE;
}

sub verify_external {
    my ( $self, $req, $session, $code ) = @_;

    my $okta_userid     = $session->{__oktaUserId};
    my $selected_factor = $session->{__oktaFactorId};
    unless ( $okta_userid && $selected_factor ) {
        $self->logger->error("Missing Okta data (userid, factorid) in OTT");
        return PE_ERROR;
    }

    my $issue_content = to_json( { 'passCode' => $code } );
    my $issue_request = HTTP::Request->new(
        'POST',
        $self->conf->{okta2fAdminURL}
          . '/api/v1/users/'
          . $okta_userid
          . '/factors/'
          . $selected_factor
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

    $self->logger->debug(
        "Verify 2FA code $code with factor $selected_factor for $okta_userid:"
          . $issue_response->decoded_content );
    my $okta_verification =
      $self->decodeJSON( $issue_response->decoded_content );

    unless ( $okta_verification->{factorResult} eq "SUCCESS" ) {
        $self->logger->error(
            "Verifiation failed for code $code for $okta_userid in Okta");
        return PE_BADOTP;
    }

    $self->logger->debug("2FA code verified in Okta for $okta_userid");

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
        return;
    }

    my $okta_user = $self->decodeJSON( $user_response->decoded_content );
    unless ( $okta_user and $okta_user->[0]->{id} ) {
        $self->logger->error("User $okta_login not found in Okta");
        return;
    }

    $okta_userid = $okta_user->[0]->{id};

    $self->logger->debug("Found Okta ID $okta_userid for user $okta_login");

    return $okta_userid;
}

# Get Okta active factors
# @return HashRef Okta factor list
sub getOktaActiveFactors {
    my ( $self, $req, $okta_userid ) = @_;
    my $okta_factors = {};

    # Search factors
    my $factor_response =
      $self->ua->get( $self->conf->{okta2fAdminURL}
          . '/api/v1/users/'
          . $okta_userid
          . '/factors' );
    if ( $factor_response->is_error ) {
        $self->logger->error( "Unable to get factors for $okta_userid in Okta:"
              . $factor_response->content );
        return $okta_factors;
    }

    $self->logger->debug(
        "Get factors for $okta_userid:" . $factor_response->decoded_content );

    my $okta_factor = $self->decodeJSON( $factor_response->decoded_content );
    unless ($okta_factor) {
        $self->logger->error("No factors for $okta_userid in Okta");
        return $okta_factors;
    }

    # Loop on factors to find SMS
    foreach (@$okta_factor) {

        my $factor_id     = $_->{id};
        my $factor_type   = $_->{factorType};
        my $factor_status = $_->{status};
        if ( $factor_status ne "ACTIVE" ) {
            $self->logger->debug(
"Factor $factor_id of type $factor_type for $okta_userid is not active, skipping it"
            );
            next;
        }

        $okta_factors->{$factor_id} = $factor_type;
    }

    return $okta_factors;
}

sub _issueFactor {
    my ( $self, $req ) = @_;

    # Check token
    my $token;
    unless ( $token = $req->param('token') ) {
        $self->userLogger->error( $self->prefix . ' 2F access without token' );
        eval { $self->setSecurity($req) };
        $req->mustRedirect(1);
        return $self->p->do( $req, [ sub { PE_NOTOKEN } ] );
    }

    my $session;
    unless ( $session = $self->ott->getToken( $token, 1 ) ) {
        $self->userLogger->info(
            'Invalid token during ' . $self->prefix . '2f choice' );
        $req->noLoginDisplay(1);
        return $self->p->do( $req, [ sub { PE_TOKENEXPIRED } ] );
    }

    my $okta_userid     = $session->{__oktaUserId};
    my $selected_factor = $req->param('sf');
    $self->ott->updateToken( $token, __oktaFactorId => $selected_factor );

    my $issue_response =
      $self->ua->post( $self->conf->{okta2fAdminURL}
          . '/api/v1/users/'
          . $okta_userid
          . '/factors/'
          . $selected_factor
          . '/verify' );

    if ( $issue_response->is_error ) {
        $self->logger->error(
            "Unable to issue factor challenge for $okta_userid in Okta:"
              . $issue_response->content );
        eval { $self->setSecurity($req) };
        $req->mustRedirect(1);
        return $self->p->do( $req, [ sub { PE_ERROR } ] );
    }

    my $okta_issue = $self->decodeJSON( $issue_response->decoded_content );

    if ( $okta_issue->{factorResult} eq "CHALLENGE" ) {

        $self->logger->debug( "2FA challenge sent to $okta_userid:"
              . $issue_response->content() );
        my $tmp = $self->sendCodeForm( $req, TOKEN => $token );

        $req->response($tmp);
        return $self->p->do( $req, [ sub { PE_SENDRESPONSE } ] );
    }

    elsif ( $okta_issue->{factorResult} eq "WAITING" ) {

        #TODO
    }

    eval { $self->setSecurity($req) };
    $req->mustRedirect(1);
    return $self->p->do( $req, [ sub { PE_ERROR } ] );
}

1;
