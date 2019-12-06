package Lemonldap::NG::Manager::Api::Providers;
our $VERSION = '2.0.7';

package Lemonldap::NG::Manager::Api;

use Lemonldap::NG::Manager::Build::CTrees;
use Scalar::Util 'weaken';

sub getOidcRpByConfKey {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    $self->logger->debug("[API] OIDC RP $confKey configuration requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $oidcRp = $self->_getOidcRpByConfKey($conf, $confKey);
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
            push @oidcRps, $self->_getOidcRpByConfKey($conf, $_);
        }
    }

    return $self->sendJSONresponse(
        $req, [ @oidcRps ]
    );
}

sub findOidcRpByClientId {
    my ( $self, $req ) = @_;

    my $clientId = (
      defined $req->params('uClientId') ?
        $req->params('uClientId') :
          ( defined $req->params('clientId') ? $req->params('clientId') : undef )
    );

    unless (defined $clientId) {
      return $self->sendError( $req, 'clientId is missing', 400 );
    }

    $self->logger->debug("[API] Find OIDC RPs by clientId $clientId requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $oidcRp = $self->_getOidcRpByClientId($conf, $clientId);

    if (defined $oidcRp) {
        return $self->sendJSONresponse($req, $oidcRp);
    }
    return $self->sendJSONresponse($req, {});
}

sub addOidcRp {
    my ( $self, $req) = @_;

    my $oidcRp = $req->jsonBodyToObj;

    unless (defined $oidcRp->{confKey}) {
      return $self->sendError( $req, 'Invalid input: confKey is missing', 405 );
    }

    unless (defined $oidcRp->{clientId}) {
      return $self->sendError( $req, 'Invalid input: clientId is missing', 405 );
    }

    $self->logger->debug("[API] Add OIDC RP with confKey $oidcRp->{confKey} and clientId $oidcRp->{clientId} requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    if (defined $self->_getOidcRpByConfKey($conf, $oidcRp->{confKey})) {
      return $self->sendError( $req, "Invalid input: An OIDC RP with confKey $oidcRp->{confKey} already exists", 405 );
    }

    if (defined $self->_getOidcRpByClientId($conf, $oidcRp->{clientId})) {
      return $self->sendError( $req, "Invalid input: An OIDC RP with clientId $oidcRp->{clientId} already exists", 405 );
    }

    unless (defined $oidcRp->{options}) {
        $oidcRp->{options} = {};
    }
    $oidcRp->{options}->{oidcRPMetaDataOptionsClientID} = $oidcRp->{clientId};
    my $res = $self->_hasAllowedAttributes($oidcRp->{options}, 'oidcRPMetaDataNode', ['oidcRPMetaDataOptions', 'oidcRPMetaDataOptionsDisplay']);
    unless ($res->{res} eq 'ok') {
        return $self->sendError( $req, $res->{message}, 405);
    }
    my $displayOptions = $self->_filterAttributes($oidcRp->{options}, 'oidcRPMetaDataNode', ['oidcRPMetaDataOptionsDisplay']);

    $self->logger->debug("displayOptions");
    use Data::Dumper; print STDERR Dumper($displayOptions);

    if ($displayOptions) {
        $conf->{oidcRPMetaDataOptionsDisplay}->{$oidcRp->{confKey}} = $displayOptions;
    }

    my $options = $self->_filterAttributes($oidcRp->{options}, 'oidcRPMetaDataNode', ['oidcRPMetaDataOptions']);

    $self->logger->debug("options");
    use Data::Dumper; print STDERR Dumper($options);

    if ($options) {
        $conf->{oidcRPMetaDataOptions}->{$oidcRp->{confKey}} = $options;
    }

    if (defined $oidcRp->{exportedVars}) {
        if ($self->_isSimpleKeyValueHash($oidcRp->{exportedVars})) {
            $conf->{oidcRPMetaDataExportedVars}->{$oidcRp->{confKey}} = $oidcRp->{exportedVars};
        } else {
            return $self->sendError( $req, "Invalid input: exportedVars is not a hash object with \"key\":\"value\" attributes", 405 );
        }
    }

    if (defined $oidcRp->{extraClaim}) {
        if ($self->_isSimpleKeyValueHash($oidcRp->{extraClaim})) {
            $conf->{oidcRPMetaDataOptionsExtraClaims}->{$oidcRp->{confKey}} = $oidcRp->{extraClaim};
        } else {
            return $self->sendError( $req, "Invalid input: extraClaim is not a hash object with \"key\":\"value\" attributes", 405 );
        }
    }

    # Save configuration
    #$self->_confAcc->saveConf($conf);

    return $self->sendJSONresponse($req, "Successful operation");
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

    # Merge display with options
    my $dispOptions = $conf->{oidcRPMetaDataOptionsDisplay}->{$confKey};
    @options{keys %{$dispOptions}} = values %{$dispOptions};

    return {
        confKey      => $confKey,
        clientId     => $clientId,
        exportedVars => $exportedVars,
        extraClaim  => $extraClaim,
        options => $options
    };
}

sub _getOidcRpByClientId {
    my ( $self, $conf, $clientId ) = @_;

    foreach (
        keys %{
            $conf->{oidcRPMetaDataOptions}
        }
      )
    {
        if ($conf->{oidcRPMetaDataOptions}->{$_}->{oidcRPMetaDataOptionsClientID} eq $clientId) {
            return $self->_getOidcRpByConfKey($conf, $_)
        }
    }
    return undef;
}

sub getSamlSpByConfKey {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    $self->logger->debug("[API] SAML SP $confKey configuration requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    $samlSp = $self->_getSamlSpByConfKey($conf, $confKey);

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
            push @samlSps, $self->_getSamlSpByConfKey($conf, $_);
        }
    }

    return $self->sendJSONresponse(
        $req, [ @samlSps ]
    );
}

sub findSamlSpByEntityId {
    my ( $self, $req ) = @_;

    my $entityId = (
      defined $req->params('uEntityId') ?
        $req->params('uEntityId') :
          ( defined $req->params('entityId') ? $req->params('entityId') : undef )
    );

    unless (defined $entityId) {
      return $self->sendError( $req, 'entityId is missing', 400 );
    }

    $self->logger->debug("[API] Find SAML SPs by entityId $entityId requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $samlSp = $self->_getSamlSpByEntityId($conf, $entityId);

    if (defined $samlSp) {
        return $self->sendJSONresponse($req, $samlSp);
    }
    return $self->sendJSONresponse($req, {});
}

sub addSamlSp {
    my ( $self, $req) = @_;

    my $samlSp = $req->jsonBodyToObj;

    unless (defined $samlSp->{confKey}) {
      return $self->sendError( $req, 'Invalid input: confKey is missing', 405 );
    }

    unless (defined $samlSp->{metadata}) {
      return $self->sendError( $req, 'Invalid input: metadata is missing', 405 );
    }

    my $entityId = $self->_readSamlSpEntityId($samlSp->{metadata});

    unless (defined $entityId) {
      return $self->sendError( $req, 'Invalid input: entityID is missing in metadata', 405 );
    }

    $self->logger->debug("[API] Add SAML SP with confKey $samlSp->{confKey} and entityID $entityId requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    if (defined $self->_getSamlSpByConfKey($conf, $samlSp->{confKey})) {
      return $self->sendError( $req, "Invalid input: A SAML SP with confKey $samlSp->{confKey} already exists", 405 );
    }

    if (defined $self->_getSamlSpByEntityId($conf, $entityId)) {
      return $self->sendError( $req, "Invalid input: A SAML SP with entityID $entityId already exists", 405 );
    }

    $conf->{samlSPMetaDataXML}->{$samlSp->{confKey}}->{samlSPMetaDataXML} = $samlSp->{metadata};

    my $options;
    if (defined $samlSp->{options}) {
        $options = $samlSp->{options};
    }
    my $res = $self->_hasAllowedAttributes($options, 'samlSPMetaDataNode', ['samlSPMetaDataOptions']);
    unless ($res->{res} eq 'ok') {
        return $self->sendError( $req, $res->{message}, 405);
    }

    $conf->{samlSPMetaDataOptions}->{$samlSp->{confKey}} = $options;

    if (defined $samlSp->{exportedAttributes}) {
        my $res = $self->_readSamlSpExportedAttributes($samlSp->{exportedAttributes});
        unless ($res->{res} eq 'ok') {
            return $self->sendError( $req, $res->{message}, 405);
        }
        $conf->{samlSPMetaDataExportedAttributes}->{$samlSp->{confKey}} = $res->{exportedAttributes};
    }

    # Save configuration
    $self->_confAcc->saveConf($conf);

    return $self->sendJSONresponse($req, "Successful operation");
}

sub _getSamlSpByConfKey {
    my ( $self, $conf, $confKey ) = @_;

    # Check if confKey is defined
    if ( !defined $conf->{samlSPMetaDataXML}->{$confKey} ) {
        return undef;
    }

    # Get metadata
    my $metadata = $conf->{samlSPMetaDataXML}->{$confKey}
      ->{samlSPMetaDataXML};

    # Get options
    my $options = $conf->{samlSPMetaDataOptions}->{$confKey};

    my $samlSp = {
        confKey      => $confKey,
        metadata     => $metadata,
        exportedAttributes => {},
        options => $options
    };

    # Get exported attributes
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

        $samlSp->{exportedAttributes}->{$_} = {
            name => $name,
            mandatory => $mandatory
        };

        if (defined $friendly_name && $friendly_name ne '') {
            $samlSp->{exportedAttributes}->{$_}->{friendlyName} = $friendly_name;
        }

        if (defined $format && $format ne '') {
            $samlSp->{exportedAttributes}->{$_}->{format} = $format;
        }
    }


    return $samlSp;
}

sub _getSamlSpByEntityId {
    my ( $self, $conf, $entityId ) = @_;

    foreach (
        keys %{
            $conf->{samlSPMetaDataXML}
        }
      )
    {
        if ($self->_readSamlSpEntityId($conf->{samlSPMetaDataXML}->{$_}->{samlSPMetaDataXML}) eq $entityId) {
            return $self->_getSamlSpByConfKey($conf, $_);
        }
    }
    return undef;
}

sub _readSamlSpEntityId {
    my ( $self, $metadata ) = @_;
    if ($metadata =~ /entityID=['"](.+?)['"]/) {
        return $1;
    }
    return undef;
}
sub _readSamlSpExportedAttributes {
    my ( $self, $attrs ) = @_;
    my $exportedAttributes;

    my @allowedFormats = [
      "urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified",
      "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
      "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    ];
    foreach (keys %{$attrs}) {

        unless (defined $attrs->{$_}->{name}) {
            return { res => "ko", message => "Exported attribute $_ has no name"};
        }
        my $mandatory = 0;
        if (defined $attrs->{$_}->{mandatory}) {
            if ( $attrs->{$_}->{mandatory} eq '1' or $attrs->{$_}->{mandatory} eq 'true' ) {
                $mandatory = 1;
            }
        }
        my $format = '';
        if (defined $attrs->{$_}->{format}) {
            unless (length(grep {/^$attrs->{$_}->{format}$/} @allowedFormats)) {
                return { res => "ko", message => "Exported attribute $_ format does not exist."};
            }
            $format = $attrs->{$_}->{format};
        }
        my $friendlyName = '';
        if (defined $attrs->{$_}->{friendlyName}) {
            $friendlyName = $attrs->{$_}->{friendlyName};
        }
        $exportedAttributes->{$_} = "$mandatory;$attrs->{$_}->{name};$format;$friendlyName";
    }
    return { res => "ok", exportedAttributes => $exportedAttributes };
}

sub _isSimpleKeyValueHash {
    my ( $self, $hash) = @_;
    if (ref($hash) ne "HASH") {
        return 0;
    }
    foreach (keys %{$hash}) {
        if (ref($hash->{$_}) ne '' || ref($_) ne '') {
            return 0;
        }
    }
    return 1;
}
sub _hasAllowedAttributes {
    my ( $self, $attributes, $rootNode, @titles) = @_;

    my @allowedAttributes = $self->_listAttributes($rootNode, @titles);

    foreach $attribute (keys %{$attributes}) {
        unless (grep {/^$attribute$/} @allowedAttributes) {
            return {
                res => "ko",
                message => "Invalid input: Attribute $attribute does not exist."
            };
        }
    }

    return { res => "ok" };
}

sub _filterAttributes {
    my ( $self, $attributes, $rootNode, $titles) = @_;

    my @keepAttributes = $self->_listAttributes($rootNode, $titles);

    my $filteredAttributes = {};

    foreach $attribute (keys %{$attributes}) {
        if (grep {/^$attribute$/} @keepAttributes) {
            $filteredAttributes->{$attribute} = $attributes->{$attribute};
        }
    }

    return $filteredAttributes;
}

sub _listAttributes {
    my ( $self, $rootNode, $titles) = @_;

    my $mainTree = Lemonldap::NG::Manager::Build::CTrees::cTrees();

    my $rootNodes = [ grep { ref($_) eq "HASH" } @{$mainTree->{$rootNode}} ];

    my @attributes;
    foreach $node (@{$rootNodes}) {
        if (grep {/^$node->{title}$/} @{$titles}) {
            push @attributes, $self->_listNodeAttributes($node);
        }
    }
    return @attributes;
}

sub _listNodeAttributes {
    my ( $self, $node) = @_;

    my @attributes;
    foreach $child (@{$node->{nodes}}) {
        if (ref($child) eq "HASH"){
            push (@attributes, $self->_listNodeAttributes($child));
        } else {
           push (@attributes, $child);
        }
    }

    return @attributes;
}

1;
