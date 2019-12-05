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
        return $self->sendError( $req, "OIDC relying party '$confKey' not found", 404 );
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

sub getSamlSpByConfKey {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    $self->logger->debug("[API] SAML SP $confKey configuration requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    # Check if confKey is defined
    if ( !defined $conf->{samlSPMetaDataXML}->{$confKey} ) {
        return $self->sendError( $req, "SAML service Provider '$confKey' not found", 404 );
    }

    # Get metadata
    my $metadata = $conf->{samlSPMetaDataXML}->{$confKey}
      ->{samlSPMetaDataXML};

    # Get exported attributes
    my %exportedAttributes;
    foreach (
        keys %{
            $conf->{samlSPMetaDataExportedAttributes}
              ->{$confKey}
        }
      )
    {
        # Extract fields from exportedAttr value
        my ( $mandatory, $name, $format, $friendly_name ) =
          split( /;/,
            $conf->{samlSPMetaDataExportedAttributes}
              ->{$confKey}->{$_} );

        $mandatory = !!$mandatory ? 'true' : 'false';

        $exportedAttributes->{$_} = {
            name => $name,
            mandatory => $mandatory
        };

        if (defined $friendly_name && $friendly_name ne '') {
            $exportedAttributes->{$_}->{friendlyName} = $friendly_name;
        }

        if (defined $format && $format ne '') {
            $exportedAttributes->{$_}->{format} = $format;
        }
    }

    # Dump object
    use Data::Dumper; print STDERR Dumper($exportedAttributes);

    # Get options
    my $options = $conf->{samlSPMetaDataOptions}->{$confKey};

    return $self->sendJSONresponse(
        $req,
        {
            confKey      => $confKey,
            metadata     => $metadata,
            exportedAttributes => $exportedAttributes,
            options => $options
        }
    );
}

1;
