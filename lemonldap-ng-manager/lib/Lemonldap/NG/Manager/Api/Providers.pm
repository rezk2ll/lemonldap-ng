package Lemonldap::NG::Manager::Api::Providers;
our $VERSION = '2.0.7';

package Lemonldap::NG::Manager::Api;

use Lemonldap::NG::Manager::Build::CTrees;
use Scalar::Util 'weaken';

# TODO check attributes type + first node

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
      return $self->sendError( $req, 'pattern is missing', 405 );
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
      return $self->sendError( $req, 'clientId is missing', 405 );
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

    my $add = $req->jsonBodyToObj;

    unless ($add) {
        return $self->sendError( $req, "Invalid input: Request content could not be parse to json", 404 );
    }

    unless (defined $add->{confKey}) {
      return $self->sendError( $req, 'Invalid input: confKey is missing', 405 );
    }

    unless (defined $add->{clientId}) {
      return $self->sendError( $req, 'Invalid input: clientId is missing', 405 );
    }

    $self->logger->debug("[API] Add OIDC RP with confKey $add->{confKey} and clientId $add->{clientId} requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    if (defined $self->_getOidcRpByConfKey($conf, $add->{confKey})) {
      return $self->sendError( $req, "Invalid input: An OIDC RP with confKey $add->{confKey} already exists", 405 );
    }

    if (defined $self->_getOidcRpByClientId($conf, $add->{clientId})) {
      return $self->sendError( $req, "Invalid input: An OIDC RP with clientId $add->{clientId} already exists", 405 );
    }

    unless (defined $add->{options}) {
        $add->{options} = {};
    }
    $add->{options}->{oidcRPMetaDataOptionsClientID} = $add->{clientId};

    $res = $self->_pushOidcRp($conf, $add->{confKey}, $add, 0);
    unless ($res->{res} eq 'ok') {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    return $self->sendJSONresponse($req, "Successful operation");
}

sub updateOidcRp {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $update = $req->jsonBodyToObj;

    unless ($update) {
      return $self->sendError( $req, "Invalid input: Request content could not be parse to json", 405 );
    }

    $self->logger->debug("[API] OIDC RP $confKey configuration update requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $current = $self->_getOidcRpByConfKey($conf, $confKey);

    # Return 404 if not found
    unless (defined  $current) {
        return $self->sendError( $req, "OIDC relying party '$confKey' not found", 404 );
    }

    # check if new clientID exists already
    my $res = $self->_isNewOidcRpClientIdUnique($conf, $confKey, $update);
    unless ($res->{res} eq 'ok') {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    $res = $self->_pushOidcRp($conf, $confKey, $update, 0);
    unless ($res->{res} eq 'ok') {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    return $self->sendJSONresponse($req, "Successful operation");
}

sub replaceOidcRp {

    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $replace = $req->jsonBodyToObj;

    unless ($replace) {
        return $self->sendError( $req, "Invalid input: Request content could not be parse to json", 405 );
    }

    unless (defined $replace->{clientId}) {
      return $self->sendError( $req, 'Invalid input: clientId is missing', 405 );
    }

    $self->logger->debug("[API] OIDC RP $confKey configuration replace requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    # Return 404 if not found
    unless (defined  $self->_getOidcRpByConfKey($conf, $confKey)) {
        return $self->sendError( $req, "OIDC relying party '$confKey' not found", 404 );
    }

    # check if new clientID exists already
    my $res = $self->_isNewOidcRpClientIdUnique($conf, $confKey, $replace);
    unless ($res->{res} eq 'ok') {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    $res = $self->_pushOidcRp($conf, $confKey, $replace, 1);
    unless ($res->{res} eq 'ok') {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    return $self->sendJSONresponse($req, "Successful operation");
}

sub _isNewOidcRpClientIdUnique {
    my ( $self, $conf, $confKey, $oidcRp) = @_;

    my $curClientId = $self->_getOidcRpByConfKey($conf, $confKey)->{clientId};
    my $newClientId = $oidcRp->{clientId} || $oidcRp->{options}->{oidcRPMetaDataOptionsClientID} || "";
    if ($newClientId ne '' && $newClientId ne $curClientId) {
        if ( defined $self->_getOidcRpByClientId($conf, $newClientId) ) {
            return { res => 'ko' , msg => "An OIDC relying party with clientId '$newClientId' already exists" };
        }
    }
    return { res => 'ok' };
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

sub _pushOidcRp {
    my ( $self, $conf, $confKey, $push, $replace) = @_;

    if ($replace) {
        $conf->{oidcRPMetaDataOptions}->{$confKey} = {};
        $conf->{oidcRPMetaDataExportedVars}->{$confKey} = {};
        $conf->{samlSPMetaDataExportedAttributes}->{$confKey} = {};
        $conf->{oidcRPMetaDataOptionsExtraClaims}->{$confKey} = {};
    }

    if (defined $push->{options}) {
        $res = $self->_hasAllowedAttributes($push->{options}, 'oidcRPMetaDataNode');
        unless ($res->{res} eq 'ok') {
            return $res;
        }
        $conf->{oidcRPMetaDataOptions}->{$confKey} = $push->{options};
    }

    if (defined $push->{clientId}) {
        $conf->{oidcRPMetaDataOptions}->{$confKey}->{oidcRPMetaDataOptionsClientID} = $push->{clientId};
    }

    if (defined $push->{exportedVars}) {
        if ($self->_isSimpleKeyValueHash($push->{exportedVars})) {
            $conf->{oidcRPMetaDataExportedVars}->{$confKey} = $push->{exportedVars};
        } else {
            return { res => 'ko', msg => "Invalid input: exportedVars is not a hash object with \"key\":\"value\" attributes" };
        }
    }

    if (defined $push->{extraClaim}) {
        if ($self->_isSimpleKeyValueHash($push->{extraClaim})) {
            $conf->{oidcRPMetaDataOptionsExtraClaims}->{$confKey} = $push->{extraClaim};
        } else {
            return { res => 'ko', msg => "Invalid input: extraClaim is not a hash object with \"key\":\"value\" attributes" };
        }
    }

    # Save configuration
    $self->_confAcc->saveConf($conf);

    return { res => 'ok' };
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
      return $self->sendError( $req, 'pattern is missing', 405 );
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
      return $self->sendError( $req, 'entityId is missing', 405 );
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

    my $add = $req->jsonBodyToObj;

    unless ($add) {
        return $self->sendError( $req, "Invalid input: Request content could not be parse to json", 404 );
    }

    unless (defined $add->{confKey}) {
      return $self->sendError( $req, 'Invalid input: confKey is missing', 405 );
    }

    unless (defined $add->{metadata}) {
      return $self->sendError( $req, 'Invalid input: metadata is missing', 405 );
    }

    my $entityId = $self->_readSamlSpEntityId($add->{metadata});

    unless (defined $entityId) {
      return $self->sendError( $req, 'Invalid input: entityID is missing in metadata', 405 );
    }

    $self->logger->debug("[API] Add SAML SP with confKey $add->{confKey} and entityID $entityId requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    if (defined $self->_getSamlSpByConfKey($conf, $add->{confKey})) {
      return $self->sendError( $req, "Invalid input: A SAML SP with confKey $add->{confKey} already exists", 405 );
    }

    if (defined $self->_getSamlSpByEntityId($conf, $entityId)) {
      return $self->sendError( $req, "Invalid input: A SAML SP with entityID $entityId already exists", 405 );
    }

    $res = $self->_pushSamlSp($conf, $add->{confKey}, $add, 0);
    unless ($res->{res} eq 'ok') {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    return $self->sendJSONresponse($req, "Successful operation");
}

sub replaceSamlSp {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $replace = $req->jsonBodyToObj;

    unless ($replace) {
        return $self->sendError( $req, "Invalid input: Request content could not be parse to json", 405 );
    }

    unless (defined $replace->{metadata}) {
      return $self->sendError( $req, 'Invalid input: metadata is missing', 405 );
    }

    $self->logger->debug("[API] SAML SP $confKey configuration replace requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    # Return 404 if not found
    unless (defined  $self->_getSamlSpByConfKey($conf, $confKey)) {
        return $self->sendError( $req, "SAML service provider '$confKey' not found", 404 );
    }

    # check if new entityId exists already
    $res = $self->_isNewSamlSpEntityIdUnique($conf, $confKey, $replace);
    unless ($res->{res} eq 'ok') {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    $res = $self->_pushSamlSp($conf, $confKey, $replace, 1);
    unless ($res->{res} eq 'ok') {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    return $self->sendJSONresponse($req, "Successful operation");
}

sub updateSamlSp {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $update = $req->jsonBodyToObj;

    unless ($update) {
      return $self->sendError( $req, "Invalid input: Request content could not be parse to json", 405 );
    }

    $self->logger->debug("[API] SAML SP $confKey configuration update requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $current = $self->_getSamlSpByConfKey($conf, $confKey);

    # Return 404 if not found
    unless (defined  $current) {
        return $self->sendError( $req, "SAML service provider '$confKey' not found", 404 );
    }

    if (defined $update->{metadata}) {
        # check if new entityId exists already
        $res = $self->_isNewSamlSpEntityIdUnique($conf, $confKey, $update);
        unless ($res->{res} eq 'ok') {
            return $self->sendError( $req, $res->{msg}, 405 );
        }
    }

    $res = $self->_pushSamlSp($conf, $confKey, $update, 0);
    unless ($res->{res} eq 'ok') {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

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
            return { res => "ko", msg => "Exported attribute $_ has no name"};
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
                return { res => "ko", msg => "Exported attribute $_ format does not exist."};
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

sub _pushSamlSp {
    my ( $self, $conf, $confKey, $push, $replace) = @_;

    if ($replace) {
        $conf->{samlSPMetaDataXML}->{$confKey} = {};
        $conf->{samlSPMetaDataOptions}->{$confKey} = {};
        $conf->{samlSPMetaDataExportedAttributes}->{$confKey} = {};
    }

    $conf->{samlSPMetaDataXML}->{$confKey}->{samlSPMetaDataXML} = $push->{metadata};

    if (defined $push->{options}) {
        my $res = $self->_hasAllowedAttributes($push->{options}, 'samlSPMetaDataNode');
        unless ($res->{res} eq 'ok') {
            return $res;
        }
        $conf->{samlSPMetaDataOptions}->{$confKey} = $push->{options};
    }

    if (defined $push->{exportedAttributes}) {
        my $res = $self->_readSamlSpExportedAttributes($push->{exportedAttributes});
        unless ($res->{res} eq 'ok') {
            return $res;
        }
        $conf->{samlSPMetaDataExportedAttributes}->{$confKey} = $res->{exportedAttributes};
    }

    # Save configuration
    $self->_confAcc->saveConf($conf);

    return { res => 'ok' };
}

sub _isNewSamlSpEntityIdUnique {
    my ( $self, $conf, $confKey, $newSp) = @_;
    my $newEntityId = $self->_readSamlSpEntityId($newSp->{metadata});
    my $curEntityId = $self->_readSamlSpEntityId($self->_getSamlSpByConfKey($conf, $confKey)->{metadata});
    if ($newEntityId ne $curEntityId) {
        if (defined $self->_getSamlSpByEntityId($conf, $newEntityId) ) {
            return { res => 'ko', msg => "An SAML service provide with entityId '$newEntityId' already exists" };
        }
    }
    return { res => 'ok' };
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
    my ( $self, $attributes, $rootNode) = @_;

    my @allowedAttributes = $self->_listAttributes($rootNode);

    foreach $attribute (keys %{$attributes}) {
        if (length(ref($attribute))) {
            return {
                res => "ko",
                msg => "Invalid input: Attribute $attribute is not a string."
            };
        }
        unless (grep {/^$attribute$/} @allowedAttributes) {
            return {
                res => "ko",
                msg => "Invalid input: Attribute $attribute does not exist."
            };
        }
    }

    return { res => "ok" };
}

sub _listAttributes {
    my ( $self, $rootNode, $titles) = @_;

    my $mainTree = Lemonldap::NG::Manager::Build::CTrees::cTrees();

    my $rootNodes = [ grep { ref($_) eq "HASH" } @{$mainTree->{$rootNode}} ];

    my @attributes;
    foreach $node (@{$rootNodes}) {
        push @attributes, $self->_listNodeAttributes($node);
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
