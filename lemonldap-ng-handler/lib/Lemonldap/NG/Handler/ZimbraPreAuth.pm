##@file
# Zimbra preauthentication

##@class
# Zimbra preauthentication
#
# It will build Zimbra preauth URL

# This specific handler is intended to be called directly by Apache

package Lemonldap::NG::Handler::Specific::ZimbraPreAuth;

use strict;
use Lemonldap::NG::Handler::ApacheMP2 qw(:all);
use base qw(Lemonldap::NG::Handler::ApacheMP2::Main);
use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);

our $VERSION = '2.0.0';

sub handler {
    my ( $class, $request ) = ( __PACKAGE__, shift );
    $class->run($request);
}

## @rmethod Apache2::Const run(Apache2::RequestRec r)
# Overload main run method
# @param r Current request
# @return Apache2::Const value ($class->OK, $class->FORBIDDEN, $class->REDIRECT or $class->SERVER_ERROR)
sub run {
    my $class = shift;
    my $r     = $_[0];
    my $ret   = $class->SUPER::run();

    # Continue only if user is authorized
    return $ret unless ( $ret == $class->OK );

    # Get current URI
    my $uri = $class->uri_with_args($r);

    # Get Zimbra parameters
    my $localConfig      = $class->localConfig;
    my $zimbraPreAuthKey = $localConfig->{zimbraPreAuthKey};
    my $zimbraAccountKey = $localConfig->{zimbraAccountKey} || 'uid';
    my $zimbraBy         = $localConfig->{zimbraBy} || 'id';
    my $zimbraUrl        = $localConfig->{zimbraUrl} || '/service/preauth';
    my $zimbraSsoUrl     = $localConfig->{zimbraSsoUrl} || '^/zimbrasso$';
    my $timeout          = $localConfig->{'timeout'} || '0';

    # Display found values in debug mode
    $class->lmLog( "zimbraPreAuthKey: $zimbraPreAuthKey", 'debug' );
    $class->lmLog( "zimbraAccountKey: $zimbraAccountKey", 'debug' );
    $class->lmLog( "zimbraBy: $zimbraBy",                 'debug' );
    $class->lmLog( "zimbraUrl: $zimbraUrl",               'debug' );
    $class->lmLog( "zimbraSsoUrl: $zimbraSsoUrl",         'debug' );
    $class->lmLog( "timeout: $timeout",                   'debug' );

    # Return if we are not on a Zimbra SSO URI
    return $class->OK unless ( $uri =~ $zimbraSsoUrl );

    # Check mandatory parameters
    unless ($zimbraPreAuthKey) {
        $class->lmLog( "No Zimbra preauth key configured", 'error' );
        return $class->SERVER_ERROR;
    }

    # Build URL
    my $zimbra_url =
      $class->_buildZimbraPreAuthUrl( $zimbraPreAuthKey, $zimbraUrl,
        $class->datas->{$zimbraAccountKey},
        $zimbraBy, $timeout );

    # Header location
    Lemonldap::NG::Handler::API->set_header_out( 'Location' => $zimbra_url );

    # Return $class->REDIRECT
    return $class->REDIRECT;
}

## @method private string _buildZimbraPreAuthUrl(string key, string url, string account, string by, int timeout)
# Build Zimbra PreAuth URL
# @param key PreAuthKey
# @param url URL
# @param account User account
# @param by Account type
# @param timeout Timout
# @return Zimbra PreAuth URL
sub _buildZimbraPreAuthUrl {
    my ( $class, $key, $url, $account, $by, $timeout ) = @_;

    # Expiration time is calculated with _utime and timeout
    my $expires =
      $timeout ? ( $class->datas->{_utime} + $timeout ) * 1000 : $timeout;

    # Timestamp
    my $timestamp = time() * 1000;

    # Compute preauth value
    my $computed_value =
      hmac_sha1_hex( "$account|$by|$expires|$timestamp", $key );

    $class->lmLog(
        "Compute value $account|$by|$expires|$timestamp into $computed_value",
        'debug' );

    # Build PreAuth URL
    my $zimbra_url =
"$url?account=$account&by=$by&timestamp=$timestamp&expires=$expires&preauth=$computed_value";

    $class->lmLog( "Build Zimbra URL: $zimbra_url", 'debug' );

    return $zimbra_url;
}

__PACKAGE__->init( {} );

1;
