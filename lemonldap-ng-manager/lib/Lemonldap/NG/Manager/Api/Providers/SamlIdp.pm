package Lemonldap::NG::Manager::Api::Providers::SamlIdp;

our $VERSION = '2.23.0';

package Lemonldap::NG::Manager::Api;

use strict;
use utf8;
use Mouse;
use XML::LibXML;
use Lemonldap::NG::Manager::Conf::Parser;

extends 'Lemonldap::NG::Manager::Api::Common';

use constant SAML_MD_NS => 'urn:oasis:names:tc:SAML:2.0:metadata';

sub getSamlIdpByConfKey {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    $self->logger->debug("[API] SAML IdP $confKey configuration requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    my $samlIdp = $self->_getSamlIdpByConfKey( $conf, $confKey );

    # Return 404 if not found
    return $self->sendError( $req,
        "SAML identity provider '$confKey' not found", 404 )
      unless ( defined $samlIdp );

    return $self->sendJSONresponse( $req, $samlIdp );
}

sub findSamlIdpByConfKey {
    my ( $self, $req ) = @_;

    my $pattern = (
        defined $req->params('uPattern')
        ? $req->params('uPattern')
        : ( defined $req->params('pattern') ? $req->params('pattern') : undef )
    );

    return $self->sendError( $req, 'Invalid input: pattern is missing', 400 )
      unless ( defined $pattern );

    unless ( $pattern = $self->_getRegexpFromPattern($pattern) ) {
        return $self->sendError( $req, 'Invalid input: pattern is invalid',
            400 );
    }

    $self->logger->debug(
        "[API] Find SAML IdPs by confKey regexp $pattern requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    my @samlIdps =
      map { $_ =~ $pattern ? $self->_getSamlIdpByConfKey( $conf, $_ ) : () }
      keys %{ $conf->{samlIDPMetaDataXML} };

    return $self->sendJSONresponse( $req, [@samlIdps] );
}

sub addSamlIdp {
    my ( $self, $req ) = @_;
    my $add = $req->jsonBodyToObj;

    return $self->sendError( $req, "Invalid input: " . $req->error, 400 )
      unless ($add);

    return $self->sendError( $req, 'Invalid input: confKey is missing', 400 )
      unless ( defined $add->{confKey} );

    return $self->sendError( $req, 'Invalid input: confKey is not a string',
        400 )
      if ( ref $add->{confKey} );

    return $self->sendError( $req, 'Invalid input: confKey is empty', 400 )
      unless ( $add->{confKey} );

    return $self->sendError( $req, 'Invalid input: metadata is missing', 400 )
      unless ( defined $add->{metadata} );

    $self->logger->debug(
        "[API] Add SAML IdP with confKey $add->{confKey} requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    return $self->sendError(
        $req,
        "Invalid input: A SAML IdP with confKey $add->{confKey} already exists",
        409
    ) if ( defined $self->_getSamlIdpByConfKey( $conf, $add->{confKey} ) );

    my $res = $self->_pushSamlIdp( $req, $conf, $add->{confKey}, $add, 1 );

    return $self->sendError( $req, $res->{msg}, $res->{code} || 400 )
      unless ( $res->{res} eq 'ok' );

    return $self->sendJSONresponse(
        $req,
        { message => "Successful operation" },
        code => 201
    );
}

sub updateSamlIdp {
    my ( $self, $req ) = @_;
    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $update = $req->jsonBodyToObj;

    return $self->sendError( $req, "Invalid input: " . $req->error, 400 )
      unless ($update);

    $self->logger->debug(
        "[API] SAML IdP $confKey configuration update requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    # Return 404 if not found
    return $self->sendError( $req,
        "SAML identity provider '$confKey' not found", 404 )
      unless ( defined $self->_getSamlIdpByConfKey( $conf, $confKey ) );

    my $res = $self->_pushSamlIdp( $req, $conf, $confKey, $update, 0 );

    return $self->sendError( $req, $res->{msg}, $res->{code} || 400 )
      unless ( $res->{res} eq 'ok' );

    return $self->sendJSONresponse( $req, undef, code => 204 );
}

sub replaceSamlIdp {
    my ( $self, $req ) = @_;
    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $replace = $req->jsonBodyToObj;

    return $self->sendError( $req, "Invalid input: " . $req->error, 400 )
      unless ($replace);

    return $self->sendError( $req, 'Invalid input: metadata is missing', 400 )
      unless ( defined $replace->{metadata} );

    $self->logger->debug(
        "[API] SAML IdP $confKey configuration replace requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    # Return 404 if not found
    return $self->sendError( $req,
        "SAML identity provider '$confKey' not found", 404 )
      unless ( defined $self->_getSamlIdpByConfKey( $conf, $confKey ) );

    my $res = $self->_pushSamlIdp( $req, $conf, $confKey, $replace, 1 );
    return $self->sendError( $req, $res->{msg}, $res->{code} || 400 )
      unless ( $res->{res} eq 'ok' );

    return $self->sendJSONresponse( $req, undef, code => 204 );
}

sub deleteSamlIdp {
    my ( $self, $req ) = @_;
    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    # Return 404 if not found
    return $self->sendError( $req,
        "SAML identity provider '$confKey' not found", 404 )
      unless ( defined $self->_getSamlIdpByConfKey( $conf, $confKey ) );

    delete $conf->{samlIDPMetaDataXML}->{$confKey};
    delete $conf->{samlIDPMetaDataOptions}->{$confKey};
    delete $conf->{samlIDPMetaDataExportedAttributes}->{$confKey};

    # Save configuration
    my $s = $self->_saveApplyConf( $req, $conf );
    return $self->sendError( $req, "Unable to save configuration ($s)", 500 )
      unless ( $s > 0 );

    return $self->sendJSONresponse( $req, undef, code => 204 );
}

sub _getSamlIdpByConfKey {
    my ( $self, $conf, $confKey ) = @_;

    # Check if confKey is defined
    return undef unless ( defined $conf->{samlIDPMetaDataXML}->{$confKey} );

    # Get options
    my $options = {};
    for
      my $configOption ( keys %{ $conf->{samlIDPMetaDataOptions}->{$confKey} } )
    {
        my $apiName  = $self->_translateOptionConfToApi($configOption);
        my $apiValue = $self->_translateValueConfToApi( $configOption,
            $conf->{samlIDPMetaDataOptions}->{$confKey}->{$configOption} );
        $options->{$apiName} = $apiValue;
    }

    my $exportedAttributes = {};
    my $attrs = $conf->{samlIDPMetaDataExportedAttributes}->{$confKey} || {};
    foreach ( keys %$attrs ) {
        my ( $mandatory, $name, $format, $friendlyName ) =
          split( /;/, $attrs->{$_} );
        $exportedAttributes->{$_} = {
            name      => $name,
            mandatory => ( $mandatory ? 'true' : 'false' ),
        };
        $exportedAttributes->{$_}->{format} = $format
          if ( defined $format and $format ne '' );
        $exportedAttributes->{$_}->{friendlyName} = $friendlyName
          if ( defined $friendlyName and $friendlyName ne '' );
    }

    return {
        confKey  => $confKey,
        metadata =>
          $conf->{samlIDPMetaDataXML}->{$confKey}->{samlIDPMetaDataXML},
        exportedAttributes => $exportedAttributes,
        options            => $options
    };
}

# Returns the entityID of an IdP EntityDescriptor, or dies. Metadata comes
# from outside, so no DTD, external entity or network access is allowed.
sub _readSamlIdpEntityId {
    my ( $self, $metadata ) = @_;

    die "metadata is not a string\n" if ( ref $metadata );

    my $doc = eval {
        XML::LibXML->new(
            load_ext_dtd    => 0,
            expand_entities => 0,
            no_network      => 1,
            expand_xinclude => 0,
        )->parse_string($metadata);
    };
    die "metadata is not valid XML\n" unless ($doc);
    die "metadata must not contain a DTD\n"
      if ( $doc->internalSubset or $doc->externalSubset );

    my $root = $doc->documentElement;
    die "metadata is not a SAML EntityDescriptor\n"
      unless ( $root->localname eq 'EntityDescriptor'
        and ( $root->namespaceURI // '' ) eq SAML_MD_NS );

    my $entityId = $root->getAttribute('entityID');
    die "metadata has no entityID\n" unless ($entityId);

    die "metadata has no IDPSSODescriptor\n"
      unless (
        $root->getChildrenByTagNameNS( SAML_MD_NS, 'IDPSSODescriptor' )->size );

    return $entityId;
}

sub _pushSamlIdp {
    my ( $self, $req, $conf, $confKey, $push, $replace ) = @_;

    if ( defined $push->{metadata} ) {
        my $entityId =
          eval { $self->_readSamlIdpEntityId( $push->{metadata} ) };
        unless ($entityId) {
            chomp( my $err = $@ );
            return { res => 'ko', msg => "Invalid input: $err" };
        }

        # Same entityID test as the configuration parser, which only sees
        # the stored XML
        foreach ( keys %{ $conf->{samlIDPMetaDataXML} } ) {
            next if ( $_ eq $confKey );
            my $xml = $conf->{samlIDPMetaDataXML}->{$_}->{samlIDPMetaDataXML}
              // '';
            my $other = $xml =~ /entityID=(['"])(.+?)\1/si ? $2 : undef;
            return {
                res  => 'ko',
                code => 409,
                msg  =>
"Invalid input: A SAML IdP with entityID $entityId already exists",
              }
              if ( defined $other and $other eq $entityId );
        }
    }

    my $translatedOptions = {};
    if ($replace) {
        $conf->{samlIDPMetaDataXML}->{$confKey}                = {};
        $conf->{samlIDPMetaDataOptions}->{$confKey}            = {};
        $conf->{samlIDPMetaDataExportedAttributes}->{$confKey} = {};
        $translatedOptions = $self->_getDefaultValues('samlIDPMetaDataNode');
    }

    if ( defined $push->{options} ) {
        return {
            res => 'ko',
            msg => "Invalid input: options is not a hash object"
          }
          unless ( ref( $push->{options} ) eq 'HASH' );

        foreach ( keys %{ $push->{options} } ) {
            my $optionName = $self->_translateOptionApiToConf( $_, 'samlIDP' );
            eval {
                my $optionValue =
                  $self->_translateValueApiToConf( $optionName,
                    $push->{options}->{$_} );
                $translatedOptions->{$optionName} = $optionValue;
            };
            if ($@) {
                return {
                    res => 'ko',
                    msg => "Invalid input: $@",
                };
            }
        }

        my $res = $self->_hasAllowedAttributes( $translatedOptions,
            'samlIDPMetaDataNode' );
        return $res unless ( $res->{res} eq 'ok' );
    }

    $self->_merge_hash( $conf, 'samlIDPMetaDataOptions', $confKey,
        $translatedOptions );

    $conf->{samlIDPMetaDataXML}->{$confKey}->{samlIDPMetaDataXML} =
      $push->{metadata}
      if ( defined $push->{metadata} );

    if ( defined $push->{exportedAttributes} ) {
        return {
            res => 'ko',
            msg => "Invalid input: exportedAttributes is not a hash object"
          }
          unless ( ref( $push->{exportedAttributes} ) eq 'HASH' );

        my $res =
          $self->_readSamlSpExportedAttributes( $push->{exportedAttributes},
            $conf->{samlIDPMetaDataExportedAttributes}->{$confKey} );
        return $res unless ( $res->{res} eq 'ok' );

        $conf->{samlIDPMetaDataExportedAttributes}->{$confKey} =
          $res->{exportedAttributes};
    }

    # Test new configuration
    my $parser = Lemonldap::NG::Manager::Conf::Parser->new( {
            refConf => $self->_confAcc->getConf( { noCache => 1 } ),
            newConf => $conf,
            req     => {},
        }
    );
    unless ( $parser->testNewConf( $self->p ) ) {
        return {
            res  => 'ko',
            code => 400,
            msg  => "Configuration error: "
              . join( ". ", map { $_->{message} } @{ $parser->errors } ),
        };
    }

    # Save configuration
    my $s = $self->_saveApplyConf( $req, $conf, $confKey );
    return {
        res  => 'ko',
        code => 500,
        msg  => "Unable to save configuration ($s)",
      }
      unless ( $s > 0 );

    return { res => 'ok' };
}

1;
