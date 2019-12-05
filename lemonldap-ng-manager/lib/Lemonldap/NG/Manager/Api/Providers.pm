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

    my $oidcRp = $self->_getOidcRp($conf, $confKey);
    # To save configuration
    #$self->_confAcc->saveConf( $conf ) ;

    # Dump object
    #use Data::Dumper; print STDERR Dumper($self);

    # Return 404 if not found
    unless (defined $oidcRp) {
        return $self->sendError( $req, "OIDC relying party '$confKey' not found", 404 );
    }

    return $self->sendJSONresponse(
        $req, $oidcRp
    );
}

sub findOidcRpByConfKey {
    my ( $self, $req ) = @_;

    my $pattern = (
      defined $req->params('uPattern') ?
        $req->params('uPattern') :
          ( defined $req->params('pattern') ? $req->params('pattern') : undef )
    );

    unless (defined $pattern) {
      return $self->sendError( $req, 'pattern is missing', 400 );
    }

    $self->logger->debug("[API] Find OIDC RPs by confKey regexp $pattern requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my @oidcRps;

    foreach (
        keys %{
            $conf->{oidcRPMetaDataOptions}
        }
      )
    {
        if ($_ =~ $pattern) {
            push @oidcRps, $self->_getOidcRp($conf, $_);
        }
    }

    return $self->sendJSONresponse(
        $req, [ @oidcRps ]
    );
}

sub _getOidcRp {
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
        extraClaim  => $extraClaim,
        options => $options
    };
}

sub getSamlSpByConfKey {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    $self->logger->debug("[API] SAML SP $confKey configuration requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    $samlSp = $self->_getSamlSp($conf, $confKey);

    # Check if confKey is defined
    unless (defined $samlSp) {
        return $self->sendError( $req, "SAML service Provider '$confKey' not found", 404 );
    }

    return $self->sendJSONresponse(
        $req, $samlSp
    );
}

sub findSamlSpByConfKey {
    my ( $self, $req ) = @_;

    my $pattern = (
      defined $req->params('uPattern') ?
        $req->params('uPattern') :
          ( defined $req->params('pattern') ? $req->params('pattern') : undef )
    );

    unless (defined $pattern) {
      return $self->sendError( $req, 'pattern is missing', 400 );
    }

    $self->logger->debug("[API] Find SAML SPs by confKey regexp $pattern requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my @samlSps;

    foreach (
        keys %{
            $conf->{samlSPMetaDataXML}
        }
      )
    {
        if ($_ =~ $pattern) {
            push @samlSps, $self->_getSamlSp($conf, $_);
        }
    }

    return $self->sendJSONresponse(
        $req, [ @samlSps ]
    );
}

sub _getSamlSp {
    my ( $self, $conf, $confKey ) = @_;

    # Check if confKey is defined
    if ( !defined $conf->{samlSPMetaDataXML}->{$confKey} ) {
        return undef;
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

    # Get options
    my $options = $conf->{samlSPMetaDataOptions}->{$confKey};

    return {
        confKey      => $confKey,
        metadata     => $metadata,
        exportedAttributes => $exportedAttributes,
        options => $options
    };
}

1;
