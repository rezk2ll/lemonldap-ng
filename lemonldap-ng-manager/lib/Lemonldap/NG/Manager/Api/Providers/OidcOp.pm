package Lemonldap::NG::Manager::Api::Providers::OidcOp;

our $VERSION = '2.23.0';

package Lemonldap::NG::Manager::Api;

use strict;
use utf8;
use Mouse;
use JSON;
use Lemonldap::NG::Manager::Conf::Parser;

extends 'Lemonldap::NG::Manager::Api::Common';

sub getOidcOpByConfKey {
    my ( $self, $req ) = @_;

    my $confKey = $req->param('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    $self->logger->debug("[API] OIDC OP $confKey configuration requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    my $oidcOp = $self->_getOidcOpByConfKey( $conf, $confKey );

    # Return 404 if not found
    return $self->sendError( $req, "OIDC provider '$confKey' not found", 404 )
      unless ( defined $oidcOp );

    return $self->sendJSONresponse( $req, $oidcOp );
}

sub findOidcOpByConfKey {
    my ( $self, $req ) = @_;

    my $pattern = (
        defined $req->param('uPattern')
        ? $req->param('uPattern')
        : ( defined $req->param('pattern') ? $req->param('pattern') : undef )
    );

    return $self->sendError( $req, 'Invalid input: pattern is missing', 400 )
      unless ( defined $pattern );

    unless ( $pattern = $self->_getRegexpFromPattern($pattern) ) {
        return $self->sendError( $req, 'Invalid input: pattern is invalid',
            400 );
    }

    $self->logger->debug(
        "[API] Find OIDC OPs by confKey regexp $pattern requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    my @oidcOps =
      map { $_ =~ $pattern ? $self->_getOidcOpByConfKey( $conf, $_ ) : () }
      keys %{ $conf->{oidcOPMetaDataOptions} };

    return $self->sendJSONresponse( $req, [@oidcOps] );
}

sub addOidcOp {
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
        "[API] Add OIDC OP with confKey $add->{confKey} requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    return $self->sendError(
        $req,
        "Invalid input: An OIDC OP with confKey $add->{confKey} already exists",
        409
    ) if ( defined $self->_getOidcOpByConfKey( $conf, $add->{confKey} ) );

    my $res = $self->_pushOidcOp( $req, $conf, $add->{confKey}, $add, 1 );

    return $self->sendError( $req, $res->{msg}, 400 )
      unless ( $res->{res} eq 'ok' );

    return $self->sendJSONresponse(
        $req,
        { message => "Successful operation" },
        code => 201
    );
}

sub updateOidcOp {
    my ( $self, $req ) = @_;
    my $confKey = $req->param('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $update = $req->jsonBodyToObj;

    return $self->sendError( $req, "Invalid input: " . $req->error, 400 )
      unless ($update);

    $self->logger->debug(
        "[API] OIDC OP $confKey configuration update requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    # Return 404 if not found
    return $self->sendError( $req, "OIDC provider '$confKey' not found", 404 )
      unless ( defined $self->_getOidcOpByConfKey( $conf, $confKey ) );

    my $res = $self->_pushOidcOp( $req, $conf, $confKey, $update, 0 );

    return $self->sendError( $req, $res->{msg}, 400 )
      unless ( $res->{res} eq 'ok' );

    return $self->sendJSONresponse( $req, undef, code => 204 );
}

sub replaceOidcOp {
    my ( $self, $req ) = @_;
    my $confKey = $req->param('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $replace = $req->jsonBodyToObj;

    return $self->sendError( $req, "Invalid input: " . $req->error, 400 )
      unless ($replace);

    return $self->sendError( $req, 'Invalid input: metadata is missing', 400 )
      unless ( defined $replace->{metadata} );

    $self->logger->debug(
        "[API] OIDC OP $confKey configuration replace requested");

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    # Return 404 if not found
    return $self->sendError( $req, "OIDC provider '$confKey' not found", 404 )
      unless ( defined $self->_getOidcOpByConfKey( $conf, $confKey ) );

    my $res = $self->_pushOidcOp( $req, $conf, $confKey, $replace, 1 );
    return $self->sendError( $req, $res->{msg}, 400 )
      unless ( $res->{res} eq 'ok' );

    return $self->sendJSONresponse( $req, undef, code => 204 );
}

sub deleteOidcOp {
    my ( $self, $req ) = @_;
    my $confKey = $req->param('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    # Get latest configuration
    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    # Return 404 if not found
    return $self->sendError( $req, "OIDC provider '$confKey' not found", 404 )
      unless ( defined $self->_getOidcOpByConfKey( $conf, $confKey ) );

    delete $conf->{oidcOPMetaDataOptions}->{$confKey};
    delete $conf->{oidcOPMetaDataJSON}->{$confKey};
    delete $conf->{oidcOPMetaDataJWKS}->{$confKey};
    delete $conf->{oidcOPMetaDataExportedVars}->{$confKey};

    # Save configuration
    $self->_saveApplyConf( $req, $conf );

    return $self->sendJSONresponse( $req, undef, code => 204 );
}

sub _getOidcOpByConfKey {
    my ( $self, $conf, $confKey ) = @_;

    # Check if confKey is defined
    return undef unless ( defined $conf->{oidcOPMetaDataOptions}->{$confKey} );

    # Get options
    my $options = {};
    for
      my $configOption ( keys %{ $conf->{oidcOPMetaDataOptions}->{$confKey} } )
    {
        my $apiName  = $self->_translateOptionConfToApi($configOption);
        my $apiValue = $self->_translateValueConfToApi( $configOption,
            $conf->{oidcOPMetaDataOptions}->{$confKey}->{$configOption} );
        $options->{$apiName} = $apiValue;
    }

    return {
        confKey      => $confKey,
        metadata     => $conf->{oidcOPMetaDataJSON}->{$confKey},
        jwks         => $conf->{oidcOPMetaDataJWKS}->{$confKey},
        exportedVars => $conf->{oidcOPMetaDataExportedVars}->{$confKey},
        options      => $options
    };
}

sub _pushOidcOp {
    my ( $self, $req, $conf, $confKey, $push, $replace ) = @_;

    # The portal reads the provider's discovery document and JWKS from these
    # JSON strings
    foreach my $field (qw(metadata jwks)) {
        next unless ( defined $push->{$field} );
        return {
            res => 'ko',
            msg => "Invalid input: $field is not a JSON object string"
          }
          unless ( !ref( $push->{$field} )
            and ref( eval { from_json( $push->{$field} ) } ) eq 'HASH' );
    }

    my $translatedOptions = {};
    if ($replace) {
        $conf->{oidcOPMetaDataOptions}->{$confKey} = {};

        # Same default claims as a provider created in the manager
        $conf->{oidcOPMetaDataExportedVars}->{$confKey} = {
            %{
                Lemonldap::NG::Manager::Build::Attributes::attributes()
                  ->{oidcOPMetaDataExportedVars}->{default}
            }
        };
        delete $conf->{oidcOPMetaDataJWKS}->{$confKey};
        $translatedOptions = $self->_getDefaultValues('oidcOPMetaDataNode');
    }

    if ( defined $push->{options} ) {
        return {
            res => 'ko',
            msg => "Invalid input: options is not a hash object"
          }
          unless ( ref( $push->{options} ) eq 'HASH' );

        foreach ( keys %{ $push->{options} } ) {

            my $optionName = $self->_translateOptionApiToConf( $_, 'oidcOP' );
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
            'oidcOPMetaDataNode' );
        return $res unless ( $res->{res} eq 'ok' );

        my $extra =
          $translatedOptions->{oidcOPMetaDataOptionsAuthEndpointExtraParams};
        return {
            res => 'ko',
            msg => "Invalid input: authEndpointExtraParams is not a hash"
              . " object with \"key\":\"value\" attributes"
          }
          if ( defined $extra and !$self->_isSimpleKeyValueHash($extra) );
    }

    $self->_merge_hash( $conf, 'oidcOPMetaDataOptions', $confKey,
        $translatedOptions );

    $conf->{oidcOPMetaDataJSON}->{$confKey} = $push->{metadata}
      if ( defined $push->{metadata} );

    if ( defined $push->{jwks} ) {
        $conf->{oidcOPMetaDataJWKS}->{$confKey} = $push->{jwks};
    }
    elsif ( exists $push->{jwks} ) {
        delete $conf->{oidcOPMetaDataJWKS}->{$confKey};
    }

    if ( defined $push->{exportedVars} ) {
        if ( $self->_isSimpleKeyValueHash( $push->{exportedVars} ) ) {
            $self->_merge_hash(
                $conf,    'oidcOPMetaDataExportedVars',
                $confKey, $push->{exportedVars}
            );
        }
        else {
            return {
                res => 'ko',
                msg =>
"Invalid input: exportedVars is not a hash object with \"key\":\"value\" attributes"
            };
        }
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
    $self->_saveApplyConf( $req, $conf, $confKey );

    return { res => 'ok' };
}

1;
