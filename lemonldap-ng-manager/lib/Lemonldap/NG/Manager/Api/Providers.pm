package Lemonldap::NG::Manager::Api::Providers;
our $VERSION = '2.0.7';

package Lemonldap::NG::Manager::Api;

sub getOidcRpByConfKey {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    $self->logger->debug("[API] OIDC RP $confKey configuration requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    # To save configuration
    #$self->_confAcc->saveConf( $conf ) ;

    # Dump object
    #use Data::Dumper; print STDERR Dumper($self);

    # Check if confKey is defined
    if ( !defined $conf->{oidcRPMetaDataOptions}->{$confKey} ) {
        return $self->sendError( $req, 'Service Provider not found', 404 );
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

    return $self->sendJSONresponse(
        $req,
        {
            confKey      => $confKey,
            clientId     => $clientId,
            exportedVars => $exportedVars,
            extraClaim  => $extraClaim,
            options => $options
        }
    );
}

1;
