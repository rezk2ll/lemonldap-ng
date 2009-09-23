## @file
# Relay authentication and userDB base.

## @class
# Relay authentication and userDB base class.
package Lemonldap::NG::Portal::_Relay;

use strict;
use Lemonldap::NG::Portal::Simple;
use MIME::Base64;
use SOAP::Lite;

our $VERSION = '0.1';

## @apmethod int relayInit()
# Checks if remote portal parameters are set.
# @return Lemonldap::NG::Portal constant
sub relayInit {
    my $self = shift;
    return PE_OK if ( $self->{_relayInitDone} );
    my @missing = ();
    foreach (qw(soapAuthService)) {
        push @missing, $_ unless ( defined( $self->{$_} ) );
    }
    $self->{soapSessionService} ||=
      $self->{soapAuthService} . 'index.pl/sessions';
    $self->{soapSessionService} =~ s/\.plindex.pl/\.pl/;
    $self->{remoteCookieName} ||= $self->{cookieName};
    $self->abort( "Missing parameters",
        "Required parameters: " . join( ', ', @missing ) )
      if (@missing);
    $self->{_relayInitDone}++;
    PE_OK;
}

## @apmethod int relayQuery()
# Queries the remote portal to authenticate users using given credentials
sub relayQuery {
    my $self = shift;
    return PE_OK if ( $self->{_relayQueryDone} );
    my $soap =
      SOAP::Lite->proxy( $self->{soapAuthService} )
      ->uri('urn:Lemonldap::NG::Common::CGI::SOAPService');
    my $r = $soap->getCookies( $self->{user}, $self->{password} );
    if ( $r->fault ) {
        $self->abort( "Unable to query authentication service",
            $r->fault->{faultstring} );
    }
    my $res = $r->result();

    # If authentication failed, display error
    if ( $res->{error} ) {
        $self->_sub( 'userError',
            "Authentication failed for $self->{user} "
              . $soap->error( 'fr', $res->{error} )->result() );
        return PE_BADCREDENTIALS;
    }
    $self->{remoteId} = $res->{cookies}->{ $self->{remoteCookieName} }
      or $self->abort("No cookie named $self->{remoteCookieName}");
    $self->{_relayQueryDone}++;
    PE_OK;
}

## @apmethod int setSessionInfo()
# Queries the remote portal to get users attributes and
# store them in local session
sub setSessionInfo {
    my $self = shift;
    return PE_OK if ( $self->{_setSessionInfoDone} );
    my $soap =
      SOAP::Lite->proxy( $self->{soapSessionService} )
      ->uri('urn:Lemonldap::NG::Common::CGI::SOAPService');
    my $r = $soap->getAttributes( $self->{remoteId} );
    if ( $r->fault ) {
        $self->abort( "Unable to query authentication service",
            $r->fault->{faultstring} );
    }
    my $res = $r->result();
    if ( $res->{error} ) {
        $self->_sub( 'userError',
            "Unable to get attributes for $self->{user} " );
        return PE_ERROR;
    }
    $self->{sessionInfo}->{$_} ||= $res->{attributes}->{$_}
      foreach ( keys %{ $res->{attributes} } );
    $self->{_setSessionInfoDone}++;
    PE_OK;
}

1;

