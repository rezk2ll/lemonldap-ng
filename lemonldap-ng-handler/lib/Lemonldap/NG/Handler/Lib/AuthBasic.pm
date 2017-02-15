package Lemonldap::NG::Handler::Lib::AuthBasic;

use strict;
use Exporter;
use Digest::MD5;
use MIME::Base64;
use HTTP::Headers;
use SOAP::Lite;    # link protected portalRequest
use Lemonldap::NG::Common::Session;

our $VERSION = '2.0.0';
our @ISA     = ('Exporter');
our @EXPORT  = qw(fetchId retrieveSession createSession hideCookie goToPortal);
our @EXPORT_OK = @EXPORT;

## @rmethod protected fetchId
# Get user session id from Authorization header
# Unlike usual processing, session id is computed from user creds,
# so that it remains secret but handler can easily get it.
# It is still changed from time to time - once a day - to prevent from
# using indefinitely a session id disclosed accidentally or maliciously.
# @return session id
sub fetchId {
    my $class = shift;
    if ( my $creds = $class->header_in('Authorization') ) {
        $creds =~ s/^Basic\s+//;
        my @date = localtime;
        my $day  = $date[5] * 366 + $date[7];
        return Digest::MD5::md5_hex( $creds . $day );
    }
    else {
        return 0;
    }
}

## @rmethod protected boolean retrieveSession(id)
# Tries to retrieve the session whose index is id,
# and if needed, ask portal to create it through a SOAP request
# @return true if the session was found, false else
sub retrieveSession {
    my ( $class, $id ) = @_;

    # First check if session already exists
    return 1
      if ( $class->Lemonldap::NG::Handler::Main::retrieveSession($id) );

    # Then ask portal to create it
    if ( $class->createSession($id) ) {
        return $class->Lemonldap::NG::Handler::Main::retrieveSession($id);
    }
    else {
        return 0;
    }
}

## @rmethod protected boolean createSession(id)
# Ask portal to create it through a SOAP request
# @return true if the session is created, else false
sub createSession {
    my ( $class, $id ) = @_;

    # Add client IP as X-Forwarded-For IP in SOAP request
    my $xheader = $class->header_in('X-Forwarded-For');
    $xheader .= ", " if ($xheader);
    $xheader .= $class->remote_ip;
    my $soapHeaders = HTTP::Headers->new( "X-Forwarded-For" => $xheader );

    # TODO: use adminSession or sessions
    my $soapClient = SOAP::Lite->proxy(
        $class->tsv->{portal}->() . '/sessions',
        default_headers => $soapHeaders
    )->uri('urn:Lemonldap/NG/Common/PSGI/SOAPService');

    my $creds = $class->header_in('Authorization');
    $creds =~ s/^Basic\s+//;
    my ( $user, $pwd ) = ( decode_base64($creds) =~ /^(.*?):(.*)$/ );
    $class->logger->debug("AuthBasic authentication for user: $user");
    my $soapRequest = $soapClient->getCookies( $user, $pwd, $id );

    # Catch SOAP errors
    if ( $soapRequest->fault ) {
        $class->abort( "SOAP request to the portal failed: "
              . $soapRequest->fault->{faultstring} );
    }
    else {
        my $res = $soapRequest->result();

        # If authentication failed, display error
        if ( $res->{errorCode} ) {
            $class->userLogger->notice( "Authentication failed for $user: "
                  . $soapClient->error( $res->{errorCode}, 'en' )->result() );
            return 0;
        }
        else {
            return 1;
        }
    }
}

## @rmethod protected void hideCookie()
# Hide user credentials to the protected application
sub hideCookie {
    my $class = shift;
    $class->logger->debug("removing Authorization header");
    $class->unset_header_in('Authorization');
}

## @rmethod protected int goToPortal(string url, string arg)
# If user is asked to authenticate, return $class->AUTH_REQUIRED,
# else redirect him to the portal to display some message defined by $arg
# @param $url Url requested
# @param $arg optionnal GET parameters
# @return Apache2::Const::REDIRECT or Apache2::Const::AUTH_REQUIRED
sub goToPortal {
    my ( $class, $url, $arg ) = @_;
    if ($arg) {
        return $class->Lemonldap::NG::Handler::Main::goToPortal( $url, $arg );
    }
    else {
        $class->set_header_out(
            'WWW-Authenticate' => 'Basic realm="LemonLDAP::NG"' );
        return $class->AUTH_REQUIRED;
    }
}

1;
