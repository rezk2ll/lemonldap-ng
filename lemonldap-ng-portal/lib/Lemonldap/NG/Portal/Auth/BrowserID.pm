package Lemonldap::NG::Portal::Auth::BrowserID;

use strict;
use Mouse;
use JSON;
use LWP::UserAgent;
use HTTP::Request;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_ERROR PE_BADCREDENTIALS PE_FIRSTACCESS);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Auth::Base';

# PROPERTIES

# return LWP::UserAgent object
has ua => (
    is      => 'rw',
    lasy    => 1,
    builder => sub {

        # TODO : LWP options to use a proxy for example
        my $ua = LWP::UserAgent->new();
        push @{ $ua->requests_redirectable }, 'POST';
        $ua->env_proxy();
        return $ua;
    }
);

# INITIALIZATION

# Enables Browser ID (required for templates) and
# LWP::UserAgent object
sub init {
    my ($self) = @_;
    $self->p->{customParameters}->{browserIdEnabled} = 1;
    foreach (
        qw(browserIdSiteName browserIdSiteLogo browserIdBackgroundColor browserIdAutoLogin)
      )
    {
        $self->p->{customParameters}->{$_} = $self->conf->{$_}
          if ( $self->conf->{$_} );
    }
    return $self->ua;
}

# RUNNING METHODS

# Get BrowserID assertion
# @return Lemonldap::NG::Portal constant
sub extractFormInfo {
    my ( $self, $req ) = @_;

    # Assertion should be browserIdAssertion parameter
    if ( my $browserIdAssertion = $req->param('browserIdAssertion') ) {
        $self->lmLog( "BrowserID Assertion found: $browserIdAssertion",
            'debug' );

        # Resolve assertion
        my $postdata =
          "assertion=$browserIdAssertion&audience=" . $self->conf->{portal};

        $self->lmLog(
            "Send $postdata to " . $self->conf->{browserIdVerificationURL},
            'debug' );

        # Prepare and launch request to BrowserID IdP
        my $request = HTTP::Request->new(
            'POST' => $self->conf->{browserIdVerificationURL} );
        $request->content_type('application/x-www-form-urlencoded');
        $request->content($postdata);

        my $answer = $self->ua()->request($request);

        $self->lmLog( "Verification response: " . $answer->as_string, 'debug' );

        # Check if HTTP response is OK
        if ( $answer->code() == "200" ) {

            # Get JSON answser and decode it
            my $browserIdAnswer = $answer->content;
            $self->lmLog( "Received BrowserID answer: $browserIdAnswer",
                'debug' );
            eval { $browserIdAnswer = JSON::from_json($browserIdAnswer); };
            if ($@) {
                $self->lmLog( "JSON decode error: $@", 'error' );
                return PE_ERROR;
            }

            # Then check for IdP response
            if ( $browserIdAnswer->{status} eq "okay" ) {
                $req->user( $browserIdAnswer->{email} );
                $self->lmLog(
                    "Found user $req->user in BrowserID verification answer",
                    'debug' );
                return PE_OK;
            }

            # Look for IdP rejection reason
            else {
                if ( $browserIdAnswer->{reason} ) {
                    $self->lmLog(
"Assertion $browserIdAssertion verification error: $browserIdAnswer->{reason}",
                        'error'
                    );

                }
                else {
                    $self->lmLog(
"Assertion $browserIdAssertion not verified by BrowserID provider",
                        'error'
                    );
                }
                return PE_BADCREDENTIALS;
            }
        }
        else {
            $self->lmLog(
"Fail to validate BrowserId assertion $browserIdAssertion: BrowserID server has returned a $answer->code code",
                'error'
            );
            return PE_ERROR;
        }
    }

    # No assertion, return to login page with BrowserID login script
    $req->{customParameters}->{browserIdLoadLoginScript} = 1;
    return PE_FIRSTACCESS;
}

sub authenticate {
    PE_OK;
}

sub authLogout {
    $_[1]->{customParameters}->{browserIdLoadLoginScript} = 1;
    PE_OK;
}

sub authForce {
    0;
}

sub getDisplayType {
    return 'logo';
}

1;
