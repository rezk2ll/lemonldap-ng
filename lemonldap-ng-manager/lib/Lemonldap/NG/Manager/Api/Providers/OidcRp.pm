package Lemonldap::NG::Manager::Api::Providers::OidcRp;
our $VERSION = '2.0.7';

package Lemonldap::NG::Manager::Api;

use 5.10.0;
use utf8;
use Mouse;

extends 'Lemonldap::NG::Manager::Api::Common';

sub getOidcRpByConfKey {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    $self->logger->debug("[API] OIDC RP $confKey configuration requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $oidcRp = $self->_getOidcRpByConfKey( $conf, $confKey );

    # $self->logger->debug("$oidcRp :: ");
    # use Data::Dumper; print STDERR Dumper($oidcRp);

    # Return 404 if not found
    unless ( defined $oidcRp ) {
        return $self->sendError( $req,
            "OIDC relying party '$confKey' not found", 404 );
    }

    return $self->sendJSONresponse( $req, $oidcRp );
}

sub findOidcRpByConfKey {
    my ( $self, $req ) = @_;

    my $pattern = (
        defined $req->params('uPattern')
        ? $req->params('uPattern')
        : ( defined $req->params('pattern') ? $req->params('pattern') : undef )
    );

    unless ( defined $pattern ) {
        return $self->sendError( $req, 'Invalid input: pattern is missing',
            405 );
    }

    $self->logger->debug(
        "[API] Find OIDC RPs by confKey regexp $pattern requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my @oidcRps;

    foreach ( keys %{ $conf->{oidcRPMetaDataOptions} } ) {
        if ( $_ =~ $pattern ) {
            push @oidcRps, $self->_getOidcRpByConfKey( $conf, $_ );
        }
    }

    return $self->sendJSONresponse( $req, [@oidcRps] );
}

sub findOidcRpByClientId {
    my ( $self, $req ) = @_;

    my $clientId = (
        defined $req->params('uClientId') ? $req->params('uClientId')
        : (
            defined $req->params('clientId') ? $req->params('clientId')
            : undef )
    );

    unless ( defined $clientId ) {
        return $self->sendError( $req, 'Invalid input: clientId is missing',
            405 );
    }

    $self->logger->debug("[API] Find OIDC RPs by clientId $clientId requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $oidcRp = $self->_getOidcRpByClientId( $conf, $clientId );

    unless ( defined $oidcRp ) {
        return $self->sendError( $req, "OIDC relying party with clientId '$clientId' not found", 404 );
    }

    return $self->sendJSONresponse( $req, $oidcRp );
}

sub addOidcRp {
    my ( $self, $req ) = @_;

    my $add = $req->jsonBodyToObj;

    unless ($add) {
        return $self->sendError( $req, "Invalid input: " . $req->error, 405 );
    }

    unless ( defined $add->{confKey} ) {
        return $self->sendError( $req, 'Invalid input: confKey is missing',
            405 );
    }

    unless ( defined $add->{clientId} ) {
        return $self->sendError( $req, 'Invalid input: clientId is missing',
            405 );
    }

    $self->logger->debug(
"[API] Add OIDC RP with confKey $add->{confKey} and clientId $add->{clientId} requested"
    );

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    if ( defined $self->_getOidcRpByConfKey( $conf, $add->{confKey} ) ) {
        return $self->sendError(
            $req,
"Invalid input: An OIDC RP with confKey $add->{confKey} already exists",
            405
        );
    }

    if ( defined $self->_getOidcRpByClientId( $conf, $add->{clientId} ) ) {
        return $self->sendError(
            $req,
"Invalid input: An OIDC RP with clientId $add->{clientId} already exists",
            405
        );
    }

    unless ( defined $add->{options} ) {
        $add->{options} = {};
    }
    $add->{options}->{oidcRPMetaDataOptionsClientID} = $add->{clientId};

    my $res = $self->_pushOidcRp( $conf, $add->{confKey}, $add, 1 );
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    return $self->sendJSONresponse( $req,
        { message => "Successful operation" } );
}

sub updateOidcRp {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $update = $req->jsonBodyToObj;

    unless ($update) {
        return $self->sendError( $req, "Invalid input: " . $req->error, 405 );
    }

    $self->logger->debug(
        "[API] OIDC RP $confKey configuration update requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $current = $self->_getOidcRpByConfKey( $conf, $confKey );

    # Return 404 if not found
    unless ( defined $current ) {
        return $self->sendError( $req,
            "OIDC relying party '$confKey' not found", 404 );
    }

    # check if new clientID exists already
    my $res = $self->_isNewOidcRpClientIdUnique( $conf, $confKey, $update );
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    $res = $self->_pushOidcRp( $conf, $confKey, $update, 0 );
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    return $self->sendJSONresponse( $req,
        { message => "Successful operation" } );
}

sub replaceOidcRp {

    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $replace = $req->jsonBodyToObj;

    unless ($replace) {
        return $self->sendError( $req, "Invalid input: " . $req->error, 405 );
    }

    unless ( defined $replace->{clientId} ) {
        return $self->sendError( $req, 'Invalid input: clientId is missing',
            405 );
    }

    $self->logger->debug(
        "[API] OIDC RP $confKey configuration replace requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    # Return 404 if not found
    unless ( defined $self->_getOidcRpByConfKey( $conf, $confKey ) ) {
        return $self->sendError( $req,
            "OIDC relying party '$confKey' not found", 404 );
    }

    # check if new clientID exists already
    my $res = $self->_isNewOidcRpClientIdUnique( $conf, $confKey, $replace );
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    $res = $self->_pushOidcRp( $conf, $confKey, $replace, 1 );
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    return $self->sendJSONresponse( $req,
        { message => "Successful operation" } );
}

sub deleteOidcRp {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $delete = $self->_getOidcRpByConfKey( $conf, $confKey );

    # Return 404 if not found
    unless ( defined $delete ) {
        return $self->sendError( $req,
            "OIDC relying party '$confKey' not found", 404 );
    }

    delete $conf->{oidcRPMetaDataOptions}->{$confKey};
    delete $conf->{oidcRPMetaDataExportedVars}->{$confKey};
    delete $conf->{oidcRPMetaDataOptionsExtraClaims}->{$confKey};

    # Save configuration
    $self->_confAcc->saveConf($conf);

    return $self->sendJSONresponse( $req,
        { message => "Successful operation" } );
}

sub _getOidcRpByConfKey {
    my ( $self, $conf, $confKey ) = @_;

    # Check if confKey is defined
    unless ( defined $conf->{oidcRPMetaDataOptions}->{$confKey} ) {
        return undef;
    }

    # Get Client ID
    my $clientId = $conf->{oidcRPMetaDataOptions}->{$confKey}
      ->{oidcRPMetaDataOptionsClientID};

    # Get exported vars
    my $exportedVars = $conf->{oidcRPMetaDataExportedVars}->{$confKey};

    # Get extra claim
    my $extraClaim = $conf->{oidcRPMetaDataOptionsExtraClaims}->{$confKey};

    # Get options
    my $options = $conf->{oidcRPMetaDataOptions}->{$confKey};

    return {
        confKey      => $confKey,
        clientId     => $clientId,
        exportedVars => $exportedVars,
        extraClaim   => $extraClaim,
        options      => $options
    };
}

sub _getOidcRpByClientId {
    my ( $self, $conf, $clientId ) = @_;

    foreach ( keys %{ $conf->{oidcRPMetaDataOptions} } ) {
        if ( $conf->{oidcRPMetaDataOptions}->{$_}
            ->{oidcRPMetaDataOptionsClientID} eq $clientId )
        {
            return $self->_getOidcRpByConfKey( $conf, $_ );
        }
    }
    return undef;
}

sub _isNewOidcRpClientIdUnique {
    my ( $self, $conf, $confKey, $oidcRp ) = @_;
    my $curClientId = $self->_getOidcRpByConfKey( $conf, $confKey )->{clientId};
    my $newClientId =
         $oidcRp->{clientId}
      || $oidcRp->{options}->{oidcRPMetaDataOptionsClientID}
      || "";
    if ( $newClientId ne '' && $newClientId ne $curClientId ) {
        if ( defined $self->_getOidcRpByClientId( $conf, $newClientId ) ) {
            return {
                res => 'ko',
                msg =>
"An OIDC relying party with clientId '$newClientId' already exists"
            };
        }
    }
    return { res => 'ok' };
}

sub _pushOidcRp {
    my ( $self, $conf, $confKey, $push, $replace ) = @_;

    if ($replace) {
        $conf->{oidcRPMetaDataOptions}->{$confKey}            = {};
        $conf->{oidcRPMetaDataExportedVars}->{$confKey}       = {};
        $conf->{oidcRPMetaDataOptionsExtraClaims}->{$confKey} = {};
        $push->{options} =
          $self->_setDefaultValues( $push->{options}, 'oidcRPMetaDataNode' );
    }

    if ( defined $push->{options} ) {
        my $res = $self->_hasAllowedAttributes( $push->{options},
            'oidcRPMetaDataNode' );
        unless ( $res->{res} eq 'ok' ) {
            return $res;
        }
        foreach ( keys %{ $push->{options} } ) {
            $conf->{oidcRPMetaDataOptions}->{$confKey}->{$_} =
              $push->{options}->{$_};
        }
    }

    if ( defined $push->{clientId} ) {
        $conf->{oidcRPMetaDataOptions}->{$confKey}
          ->{oidcRPMetaDataOptionsClientID} = $push->{clientId};
    }

    if ( defined $push->{exportedVars} ) {
        if ( $self->_isSimpleKeyValueHash( $push->{exportedVars} ) ) {
            foreach ( keys %{ $push->{exportedVars} } ) {
                $conf->{oidcRPMetaDataExportedVars}->{$confKey}->{$_} =
                  $push->{exportedVars}->{$_};
            }
        }
        else {
            return {
                res => 'ko',
                msg =>
"Invalid input: exportedVars is not a hash object with \"key\":\"value\" attributes"
            };
        }
    }

    if ( defined $push->{extraClaim} ) {
        if ( $self->_isSimpleKeyValueHash( $push->{extraClaim} ) ) {
            foreach ( keys %{ $push->{extraClaim} } ) {
                $conf->{oidcRPMetaDataOptionsExtraClaims}->{$confKey}->{$_} =
                  $push->{extraClaim}->{$_};
            }
        }
        else {
            return {
                res => 'ko',
                msg =>
"Invalid input: extraClaim is not a hash object with \"key\":\"value\" attributes"
            };
        }
    }

    # Save configuration
    $self->_confAcc->saveConf($conf);

    return { res => 'ok' };
}

1;
