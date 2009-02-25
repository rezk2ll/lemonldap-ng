## @file
# SOAP methods for Lemonldap::NG portal

## @class
# Add SOAP methods to the Lemonldap::NG portal.
package Lemonldap::NG::Portal::_SOAP;

use strict;
use Lemonldap::NG::Portal::Simple;
require SOAP::Lite;

## @method void startSoapServices()
# Check the URI requested (PATH_INFO environment variable) and launch the
# corresponding SOAP methods using soapTest().
# If "soapOnly" is set, reject otehr request. Else, simply return.
sub startSoapServices {
    my $self = shift;
    if (
        $ENV{PATH_INFO}
        and my $tmp = {
            '/sessions'      => 'getAttributes',
            '/adminSessions' => 'setAttributes newSession',
            '/config'        => 'getConfig'
        }->{ $ENV{PATH_INFO} }
      )
    {
        $self->soapTest($tmp);
        $self->{soapOnly} = 1;
    }
    else {
        $self->soapTest("getCookies error");
    }
    $self->abort( 'Bad request', 'Only SOAP requests are accepted here' )
      if ( $self->{soapOnly} );
}

####################
# SOAP subroutines #
####################

=begin WSDL

_IN user $string User name
_IN password $string Password
_RETURN $getCookiesResponse Response

=end WSDL

=cut

##@method SOAP::Data getCookies(string user,string password)
# Called in SOAP context, returns cookies in an array.
# This subroutine works only for portals working with user and password
#@param user uid
#@param password password
#@return session => { error => code , cookies => { cookieName1 => value ,... } }
sub getCookies {
    my $self = shift;
    $self->{error} = PE_OK;
    ( $self->{user}, $self->{password} ) = ( shift, shift );
    $self->lmLog( "SOAP authentication request for $self->{user}", 'debug' );
    unless ( $self->{user} && $self->{password} ) {
        $self->{error} = PE_FORMEMPTY;
    }
    else {
        $self->{error} = $self->_subProcess(
            qw(authInit userDBInit getUser setAuthSessionInfo setSessionInfo
              setMacros setGroups authenticate store buildCookie)
        );
    }
    my @tmp = ();
    push @tmp, SOAP::Data->name( error => $self->{error} );
    my @cookies = ();
    unless ( $self->{error} ) {
        foreach ( @{ $self->{cookie} } ) {
            push @cookies, SOAP::Data->name( $_->name, $_->value );
        }
    }
    else {
        my @cookieNames = split /\s+/, $self->{cookieName};
        foreach (@cookieNames) {
            push @cookies, SOAP::Data->name( $_, 0 );
        }
    }
    push @tmp, SOAP::Data->name( cookies => \SOAP::Data->value(@cookies) );
    my $res = SOAP::Data->name( session => \SOAP::Data->value(@tmp) );
    $self->updateStatus;
    return $res;
}

=begin WSDL

_IN id $string Cookie value
_RETURN $getAttributesResponse Response

=end WSDL

=cut

##@method SOAP::Data getAttributes(string id)
# Return attributes of the session identified by $id.
# @param $id Cookie value
# @return SOAP::Data sequence
sub getAttributes {
    my ( $self, $id ) = @_;
    die 'id is required' unless ($id);
    my $h = $self->getApacheSession( $id, 1 );
    my @tmp = ();
    unless ($h) {
        $self->_sub( 'userNotice',
            "SOAP attributes request: session $id not found" );
        push @tmp, SOAP::Data->name( error => 1 )->type('int');
    }
    else {
        $self->_sub( 'userInfo',
            "SOAP attributes request for " . $h->{ $self->{whatToTrace} } );
        push @tmp, SOAP::Data->name( error => 0 )->type('int');
        push @tmp,
          SOAP::Data->name( attributes =>
              _buildSoapHash( $h, split /\s+/, $self->{exportedAttr} ) );
        untie(%$h);
    }
    my $res = SOAP::Data->name( session => \SOAP::Data->value(@tmp) );
    return $res;
}

##@method SOAP::Data getConfig()
# Return Lemonldap::NG configuration. Warning, this is not a well formed
# SOAP::Data object so it can be difficult to read by other languages than
# Perl. It's not really a problem since this function is written to be read by
# Lemonldap::NG components and is not designed to be shared.
# @return hashref serialized in SOAP by SOAP::Lite
sub getConfig {
    my $self = shift;
    my $conf = $self->_getLmConf() or die("No configuration available");
    return $conf;
}

##@fn private SOAP::Data _buildSoapHash()
# Serialize a hashref into SOAP::Data. Types are fixed to "string".
# @return SOAP::Data serialized datas
sub _buildSoapHash {
    my ( $h, @keys ) = @_;
    my @tmp = ();
    @keys = keys %$h unless (@keys);
    foreach (@keys) {
        if ( ref( $h->{$_} ) eq 'ARRAY' ) {
            push @tmp,
              SOAP::Data->name( $_, \SOAP::Data->value( @{ $h->{$_} } ) );
        }
        elsif ( ref( $h->{$_} ) ) {
            push @tmp, SOAP::Data->name( $_ => _buildSoapHash( $h->{$_} ) );
        }
        else {
            push @tmp, SOAP::Data->name( $_, $h->{$_} )->type('string')
              if ( defined( $h->{$_} ) );
        }
    }
    return \SOAP::Data->value(@tmp);
}

1;

