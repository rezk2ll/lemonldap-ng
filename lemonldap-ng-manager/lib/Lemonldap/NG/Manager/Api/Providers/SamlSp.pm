package Lemonldap::NG::Manager::Api::Providers::SamlSp;
our $VERSION = '2.0.7';

package Lemonldap::NG::Manager::Api;

use 5.10.0;
use utf8;
use Mouse;

extends 'Lemonldap::NG::Manager::Api::Common';

sub getSamlSpByConfKey {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    $self->logger->debug("[API] SAML SP $confKey configuration requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $samlSp = $self->_getSamlSpByConfKey( $conf, $confKey );

    # $self->logger->debug("$oidcRp :: ");
    # use Data::Dumper; print STDERR Dumper($oidcRp);

    # Check if confKey is defined
    unless ( defined $samlSp ) {
        return $self->sendError( $req,
            "SAML service Provider '$confKey' not found", 404 );
    }

    return $self->sendJSONresponse( $req, $samlSp );
}

sub findSamlSpByConfKey {
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
        "[API] Find SAML SPs by confKey regexp $pattern requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my @samlSps;

    foreach ( keys %{ $conf->{samlSPMetaDataXML} } ) {
        if ( $_ =~ $pattern ) {
            push @samlSps, $self->_getSamlSpByConfKey( $conf, $_ );
        }
    }

    return $self->sendJSONresponse( $req, [@samlSps] );
}

sub findSamlSpByEntityId {
    my ( $self, $req ) = @_;

    my $entityId = (
        defined $req->params('uEntityId') ? $req->params('uEntityId')
        : (
            defined $req->params('entityId') ? $req->params('entityId')
            : undef )
    );

    unless ( defined $entityId ) {
        return $self->sendError( $req, 'entityId is missing', 405 );
    }

    $self->logger->debug("[API] Find SAML SPs by entityId $entityId requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $samlSp = $self->_getSamlSpByEntityId( $conf, $entityId );

    unless ( defined $samlSp ) {
        return $self->sendError( $req, "SAML service Provider with entityID '$entityId' not found", 404 );
    }

    return $self->sendJSONresponse( $req, $samlSp );
}

sub addSamlSp {
    my ( $self, $req ) = @_;

    my $add = $req->jsonBodyToObj;

    unless ($add) {
        return $self->sendError( $req, "Invalid input: " . $req->error, 405 );
    }

    unless ( defined $add->{confKey} ) {
        return $self->sendError( $req, 'Invalid input: confKey is missing',
            405 );
    }

    unless ( defined $add->{metadata} ) {
        return $self->sendError( $req, 'Invalid input: metadata is missing',
            405 );
    }

    my $entityId = $self->_readSamlSpEntityId( $add->{metadata} );

    unless ( defined $entityId ) {
        return $self->sendError( $req,
            'Invalid input: entityID is missing in metadata', 405 );
    }

    $self->logger->debug(
"[API] Add SAML SP with confKey $add->{confKey} and entityID $entityId requested"
    );

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    if ( defined $self->_getSamlSpByConfKey( $conf, $add->{confKey} ) ) {
        return $self->sendError(
            $req,
"Invalid input: A SAML SP with confKey $add->{confKey} already exists",
            405
        );
    }

    if ( defined $self->_getSamlSpByEntityId( $conf, $entityId ) ) {
        return $self->sendError( $req,
            "Invalid input: A SAML SP with entityID $entityId already exists",
            405 );
    }

    my $res = $self->_pushSamlSp( $conf, $add->{confKey}, $add, 1 );
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    return $self->sendJSONresponse( $req,
        { message => "Successful operation" } );
}

sub replaceSamlSp {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $replace = $req->jsonBodyToObj;

    unless ($replace) {
        return $self->sendError( $req, "Invalid input: " . $req->error, 405 );
    }

    unless ( defined $replace->{metadata} ) {
        return $self->sendError( $req, 'Invalid input: metadata is missing',
            405 );
    }

    $self->logger->debug(
        "[API] SAML SP $confKey configuration replace requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    # Return 404 if not found
    unless ( defined $self->_getSamlSpByConfKey( $conf, $confKey ) ) {
        return $self->sendError( $req,
            "SAML service provider '$confKey' not found", 404 );
    }

    # check if new entityId exists already
    my $res = $self->_isNewSamlSpEntityIdUnique( $conf, $confKey, $replace );
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    $res = $self->_pushSamlSp( $conf, $confKey, $replace, 1 );
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    return $self->sendJSONresponse( $req,
        { message => "Successful operation" } );
}

sub updateSamlSp {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $update = $req->jsonBodyToObj;

    unless ($update) {
        return $self->sendError( $req, "Invalid input: " . $req->error, 405 );
    }

    $self->logger->debug(
        "[API] SAML SP $confKey configuration update requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $current = $self->_getSamlSpByConfKey( $conf, $confKey );

    # Return 404 if not found
    unless ( defined $current ) {
        return $self->sendError( $req,
            "SAML service provider '$confKey' not found", 404 );
    }

    my $res;
    if ( defined $update->{metadata} ) {

        # check if new entityId exists already
        $res = $self->_isNewSamlSpEntityIdUnique( $conf, $confKey, $update );
        unless ( $res->{res} eq 'ok' ) {
            return $self->sendError( $req, $res->{msg}, 405 );
        }
    }

    $res = $self->_pushSamlSp( $conf, $confKey, $update, 0 );
    unless ( $res->{res} eq 'ok' ) {
        return $self->sendError( $req, $res->{msg}, 405 );
    }

    return $self->sendJSONresponse( $req,
        { message => "Successful operation" } );

}

sub deleteSamlSp {
    my ( $self, $req ) = @_;

    my $confKey = $req->params('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    # Get latest configuration
    my $conf = $self->_confAcc->getConf;

    my $delete = $self->_getSamlSpByConfKey( $conf, $confKey );

    # Return 404 if not found
    unless ( defined $delete ) {
        return $self->sendError( $req,
            "SAML service provider '$confKey' not found", 404 );
    }

    delete $conf->{samlSPMetaDataXML}->{$confKey};
    delete $conf->{samlSPMetaDataOptions}->{$confKey};
    delete $conf->{samlSPMetaDataExportedAttributes}->{$confKey};

    # Save configuration
    $self->_confAcc->saveConf($conf);

    return $self->sendJSONresponse( $req,
        { message => "Successful operation" } );
}

sub _getSamlSpByConfKey {
    my ( $self, $conf, $confKey ) = @_;

    # Check if confKey is defined
    if ( !defined $conf->{samlSPMetaDataXML}->{$confKey} ) {
        return undef;
    }

    # Get metadata
    my $metadata = $conf->{samlSPMetaDataXML}->{$confKey}->{samlSPMetaDataXML};

    # Get options
    my $options = $conf->{samlSPMetaDataOptions}->{$confKey};

    my $samlSp = {
        confKey            => $confKey,
        metadata           => $metadata,
        exportedAttributes => {},
        options            => $options
    };

    # Get exported attributes
    foreach ( keys %{ $conf->{samlSPMetaDataExportedAttributes}->{$confKey} } )
    {
        # Extract fields from exportedAttr value
        my ( $mandatory, $name, $format, $friendly_name ) =
          split( /;/,
            $conf->{samlSPMetaDataExportedAttributes}->{$confKey}->{$_} );

        $mandatory = !!$mandatory ? 'true' : 'false';

        $samlSp->{exportedAttributes}->{$_} = {
            name      => $name,
            mandatory => $mandatory
        };

        if ( defined $friendly_name && $friendly_name ne '' ) {
            $samlSp->{exportedAttributes}->{$_}->{friendlyName} =
              $friendly_name;
        }

        if ( defined $format && $format ne '' ) {
            $samlSp->{exportedAttributes}->{$_}->{format} = $format;
        }
    }

    return $samlSp;
}

sub _getSamlSpByEntityId {
    my ( $self, $conf, $entityId ) = @_;

    foreach ( keys %{ $conf->{samlSPMetaDataXML} } ) {
        if (
            $self->_readSamlSpEntityId(
                $conf->{samlSPMetaDataXML}->{$_}->{samlSPMetaDataXML}
            ) eq $entityId
          )
        {
            return $self->_getSamlSpByConfKey( $conf, $_ );
        }
    }
    return undef;
}

sub _readSamlSpEntityId {
    my ( $self, $metadata ) = @_;
    if ( $metadata =~ /entityID=['"](.+?)['"]/ ) {
        return $1;
    }
    return undef;
}

sub _readSamlSpExportedAttributes {
    my ( $self, $attrs, $mergeWith ) = @_;
    my $allowedFormats = [
        "urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified",
        "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
        "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    ];
    foreach ( keys %{$attrs} ) {
        unless ( defined $attrs->{$_}->{name} ) {
            return { res => "ko", msg => "Exported attribute $_ has no name" };
        }
        my $mandatory    = 0;
        my $name         = $attrs->{$_}->{name};
        my $format       = '';
        my $friendlyName = '';
        if ( defined $mergeWith->{$_} ) {
            ( $mandatory, $name, $format, $friendlyName ) =
              split( /;/, $mergeWith->{$_} );
        }
        if ( defined $attrs->{$_}->{mandatory} ) {
            if (   $attrs->{$_}->{mandatory} eq '1'
                or $attrs->{$_}->{mandatory} eq 'true' )
            {
                $mandatory = 1;
            }
            else {
                $mandatory = 0;
            }
        }
        if ( defined $attrs->{$_}->{format} ) {
            $format = $attrs->{$_}->{format};
            unless ( length( grep { /^$format$/ } @{$allowedFormats} ) ) {
                return {
                    res => "ko",
                    msg => "Exported attribute $_ format does not exist."
                };
            }
        }
        if ( defined $attrs->{$_}->{friendlyName} ) {
            $friendlyName = $attrs->{$_}->{friendlyName};
        }
        $mergeWith->{$_} = "$mandatory;$name;$format;$friendlyName";
    }
    return { res => "ok", exportedAttributes => $mergeWith };
}

sub _pushSamlSp {
    my ( $self, $conf, $confKey, $push, $replace ) = @_;

    if ($replace) {
        $conf->{samlSPMetaDataXML}->{$confKey}                = {};
        $conf->{samlSPMetaDataOptions}->{$confKey}            = {};
        $conf->{samlSPMetaDataExportedAttributes}->{$confKey} = {};
        $push->{options} =
          $self->_setDefaultValues( $push->{options}, 'samlSPMetaDataNode' );
    }

    $conf->{samlSPMetaDataXML}->{$confKey}->{samlSPMetaDataXML} =
      $push->{metadata};

    if ( defined $push->{options} ) {
        my $res = $self->_hasAllowedAttributes( $push->{options},
            'samlSPMetaDataNode' );
        unless ( $res->{res} eq 'ok' ) {
            return $res;
        }
        foreach ( keys %{ $push->{options} } ) {
            $conf->{samlSPMetaDataOptions}->{$confKey}->{$_} =
              $push->{options}->{$_};
        }
    }

    if ( defined $push->{exportedAttributes} ) {
        my $res =
          $self->_readSamlSpExportedAttributes( $push->{exportedAttributes},
            $conf->{samlSPMetaDataExportedAttributes}->{$confKey} );
        unless ( $res->{res} eq 'ok' ) {
            return $res;
        }
        $conf->{samlSPMetaDataExportedAttributes}->{$confKey} =
          $res->{exportedAttributes};
    }

    # Save configuration
    $self->_confAcc->saveConf($conf);

    return { res => 'ok' };
}

sub _isNewSamlSpEntityIdUnique {
    my ( $self, $conf, $confKey, $newSp ) = @_;
    my $newEntityId = $self->_readSamlSpEntityId( $newSp->{metadata} );
    my $curEntityId =
      $self->_readSamlSpEntityId(
        $self->_getSamlSpByConfKey( $conf, $confKey )->{metadata} );
    if ( $newEntityId ne $curEntityId ) {
        if ( defined $self->_getSamlSpByEntityId( $conf, $newEntityId ) ) {
            return {
                res => 'ko',
                msg =>
"An SAML service provide with entityId '$newEntityId' already exists"
            };
        }
    }
    return { res => 'ok' };
}

1;
