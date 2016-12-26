package Lemonldap::NG::Portal::Issuer::Get;

use strict;
use Mouse;
use URI::Escape;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK PE_BADURL);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Issuer';

# RUNNING METHODS

sub run {
    my ( $self, $req ) = @_;

    # Session ID
    my $session_id = $self->{sessionInfo}->{_session_id} || $self->{id};

    # Session creation timestamp
    my $time = $self->{sessionInfo}->{_utime} || time();
    $req->path =~ m#^$self->{conf}->{issuerDBGetPath}/(log(?:in|out))#;
    my $logInOut = $1 || 'login';
    if ( $logInOut eq 'login' ) {
        $self->lmLog( "IssuerGet: request for login", 'debug' );
        $self->computeGetParams($req);
        return PE_OK;
    }
    elsif ( $logInOut eq 'logout' ) {
        $self->lmLog( "IssuerGet: request for logout", 'debug' );

        # TODO
        # Display a link to the provided URL
        return PE_OK;
    }
    else {
        $self->lmLog( "IssuerGet: bad url", 'error' );
        return PE_BADURL;
    }
}

# Nothing to do here for now
sub logout {
    PE_OK;
}

# INTERNAL METHODS

sub computeGetParams {
    my ( $self, $req ) = @_;

    # Additional GET variables
    my @getPrms;
    if ( exists $self->conf->{issuerDBGetParameters} ) {
        unless ( $req->urldc =~ m#^https?://([^/]+)# ) {
            $self->lmLog( "Malformed url $req->urldc", 'error' );
            return;
        }
        my $vhost = $1;
        my $prms  = $self->conf->{issuerDBGetParameters}->{$vhost};
        unless ($prms) {
            $self->lmLog( "IssuerGet: $vhost has no configuration", 'warn' );
            return '';
        }
        foreach my $param ( keys %$prms ) {
            my $value =
              eval { uri_escape( $req->{sessionInfo}->{ $prms->{$param} } ) };
            if ($@) {
                $self->lmLog( "IssuerGet: unable to compute $param ($@)",
                    'error' );
                return;
            }
            $value =~ s/[\r\n\t]//;
            push @getPrms, "$param=$value";
        }
    }
    else {
        $self->lmLog( "IssuerGet: no configuration", 'warn' );
        return;
    }
    my $getVars = join '&', @getPrms;

    # If there are some GET variables to send
    # Add them to URL string
    if ( $getVars ne "" ) {
        my $urldc = $req->urldc;

        $urldc .= ( $urldc =~ /\?\w/ )
          ?

          # there are already get variables
          "&" . $getVars
          :

          # there are no get variables
          "?" . $getVars;
        $req->urldc($urldc);
    }
}

1;
