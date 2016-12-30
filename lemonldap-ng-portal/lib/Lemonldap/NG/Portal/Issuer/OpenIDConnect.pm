package Lemonldap::NG::Portal::Issuer::OpenIDConnect;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_ERROR
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Issuer',
  'Lemonldap::NG::Portal::Lib::OpenIDConnect';

# INITIALIZATION

sub init {
    my ($self) = @_;

    # Initialize RP list
    return 0
      unless ( $self->Lemonldap::NG::Portal::Main::Issuer::init()
        and $self->loadRPs );

    # Manage RP requests
    $self->addRouteFromConf(
        'Unauth',
        oidcServiceMetaDataTokenURI        => 'token',
        oidcServiceMetaDataUserInfoURI     => 'userInfo',
        oidcServiceMetaDataJWKSURI         => 'jwks',
        oidcServiceMetaDataRegistrationURI => 'registration',
        oidcServiceMetaDataEndSessionURI   => 'endSessionDone',
        oidcServiceMetaDataCheckSessionURI => 'checkSession',
    );

    # Manage user requests
    $self->addRouteFromConf(
        'Auth',
        oidcServiceMetaDataTokenURI        => 'badAuthRequest',
        oidcServiceMetaDataUserInfoURI     => 'badAuthRequest',
        oidcServiceMetaDataJWKSURI         => 'badAuthRequest',
        oidcServiceMetaDataRegistrationURI => 'badAuthRequest',
        oidcServiceMetaDataCheckSessionURI => 'checkSession',
    );
    return 1;
}

# RUNNING METHODS

# Main method (launched only for authenticated users, see Main/Issuer)
sub run {
    my ( $self, $req, $path ) = @_;
    if ($path) {

        # AUTHORIZE
        if ( $path eq $self->conf->{oidcServiceMetaDataAuthorizeURI} ) {
        }
        elsif ( $path eq $self->conf->{oidcServiceMetaDataEndSessionURI} ) {
        }
    }
    $self->lmLog( "Unknown OIDC url $path, skipping", 'error' );
    return PE_OK;
}

sub authorize {
    my ( $self, $req ) = @_;
}

sub token {
    my ( $self, $req ) = @_;
}

sub userInfo {
    my ( $self, $req ) = @_;
}

sub jwks {
    my ( $self, $req ) = @_;
}

sub registration {
    my ( $self, $req ) = @_;
}

sub endSessionDone {
    my ( $self, $req ) = @_;
}

sub checkSession {
    my ( $self, $req ) = @_;
}

sub badAuthRequest {
    my ( $self, $req ) = @_;
    return $self->p->sendError( $req,
        $req->uri . ' may not be called by an authenticated user', 400 );
}

sub logout {
    my ( $self, $req ) = @_;
}

# Internal methods

sub addRouteFromConf {
    my ( $self, $type, %subs ) = @_;
    my $adder = "add${type}Route";
    foreach ( keys %subs ) {
        my $sub = $subs{$_};
        my $path = $self->conf->{$_};
        unless ($path) {
            $self->lmLog( "$_ parameter not defined", 'error' );
            next;
        }
        $self->$adder( $self->path => { $path => $sub }, [ 'GET', 'POST' ] );
    }
}

1;
__END__
