package Lemonldap::NG::Manager::Api::Providers::CasSrv;

our $VERSION = '2.23.0';

package Lemonldap::NG::Manager::Api;

use strict;
use utf8;
use Mouse;
use Lemonldap::NG::Manager::Conf::Parser;

extends 'Lemonldap::NG::Manager::Api::Common';

sub getCasSrvByConfKey {
    my ( $self, $req ) = @_;

    my $confKey = $req->param('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    $self->logger->debug("[API] CAS server $confKey configuration requested");

    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    my $casSrv = $self->_getCasSrvByConfKey( $conf, $confKey );

    return $self->sendError( $req, "CAS server '$confKey' not found", 404 )
      unless ( defined $casSrv );

    return $self->sendJSONresponse( $req, $casSrv );
}

sub findCasSrvByConfKey {
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
        "[API] Find CAS servers by confKey regexp $pattern requested");

    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    my @casSrvs =
      map { $_ =~ $pattern ? $self->_getCasSrvByConfKey( $conf, $_ ) : () }
      keys %{ $conf->{casSrvMetaDataOptions} };

    return $self->sendJSONresponse( $req, [@casSrvs] );
}

sub addCasSrv {
    my ( $self, $req ) = @_;
    my $add = $req->jsonBodyToObj;

    return $self->sendError( $req, "Invalid input: " . $req->error, 400 )
      unless ($add);

    return $self->sendError( $req, 'Invalid input: body is not an object', 400 )
      unless ( ref $add eq 'HASH' );

    return $self->sendError( $req, 'Invalid input: confKey is missing', 400 )
      unless ( defined $add->{confKey} );

    return $self->sendError( $req, 'Invalid input: confKey is not a string',
        400 )
      if ( ref $add->{confKey} );

    return $self->sendError( $req, 'Invalid input: confKey is empty', 400 )
      unless ( $add->{confKey} );

    return $self->sendError( $req, 'Invalid input: url is missing', 400 )
      unless ( ref $add->{options} eq 'HASH'
        and defined $add->{options}->{url} );

    $self->logger->debug(
        "[API] Add CAS server with confKey $add->{confKey} requested");

    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    return $self->sendError(
        $req,
"Invalid input: A CAS server with confKey $add->{confKey} already exists",
        409
    ) if ( defined $self->_getCasSrvByConfKey( $conf, $add->{confKey} ) );

    my $res = $self->_pushCasSrv( $req, $conf, $add->{confKey}, $add, 1 );

    return $self->sendError( $req, $res->{msg}, $res->{code} || 400 )
      unless ( $res->{res} eq 'ok' );

    return $self->sendJSONresponse(
        $req,
        { message => "Successful operation" },
        code => 201
    );
}

sub updateCasSrv {
    my ( $self, $req ) = @_;
    my $confKey = $req->param('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $update = $req->jsonBodyToObj;

    return $self->sendError( $req, "Invalid input: " . $req->error, 400 )
      unless ($update);

    return $self->sendError( $req, 'Invalid input: body is not an object', 400 )
      unless ( ref $update eq 'HASH' );

    return $self->sendError( $req, 'Invalid input: url cannot be removed', 400 )
      if ( ref $update->{options} eq 'HASH'
        and exists $update->{options}->{url}
        and !defined $update->{options}->{url} );

    $self->logger->debug(
        "[API] CAS server $confKey configuration update requested");

    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    return $self->sendError( $req, "CAS server '$confKey' not found", 404 )
      unless ( defined $self->_getCasSrvByConfKey( $conf, $confKey ) );

    my $res = $self->_pushCasSrv( $req, $conf, $confKey, $update, 0 );

    return $self->sendError( $req, $res->{msg}, $res->{code} || 400 )
      unless ( $res->{res} eq 'ok' );

    return $self->sendJSONresponse( $req, undef, code => 204 );
}

sub replaceCasSrv {
    my ( $self, $req ) = @_;
    my $confKey = $req->param('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $replace = $req->jsonBodyToObj;

    return $self->sendError( $req, "Invalid input: " . $req->error, 400 )
      unless ($replace);

    return $self->sendError( $req, 'Invalid input: body is not an object', 400 )
      unless ( ref $replace eq 'HASH' );

    return $self->sendError( $req, 'Invalid input: url is missing', 400 )
      unless ( ref $replace->{options} eq 'HASH'
        and defined $replace->{options}->{url} );

    $self->logger->debug(
        "[API] CAS server $confKey configuration replace requested");

    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    return $self->sendError( $req, "CAS server '$confKey' not found", 404 )
      unless ( defined $self->_getCasSrvByConfKey( $conf, $confKey ) );

    my $res = $self->_pushCasSrv( $req, $conf, $confKey, $replace, 1 );
    return $self->sendError( $req, $res->{msg}, $res->{code} || 400 )
      unless ( $res->{res} eq 'ok' );

    return $self->sendJSONresponse( $req, undef, code => 204 );
}

sub deleteCasSrv {
    my ( $self, $req ) = @_;
    my $confKey = $req->param('confKey')
      or return $self->sendError( $req, 'confKey is missing', 400 );

    my $conf = $self->_confAcc->getConf( { noCache => 1 } );

    return $self->sendError( $req, "CAS server '$confKey' not found", 404 )
      unless ( defined $self->_getCasSrvByConfKey( $conf, $confKey ) );

    delete $conf->{casSrvMetaDataOptions}->{$confKey};
    delete $conf->{casSrvMetaDataExportedVars}->{$confKey};
    delete $conf->{casSrvMetaDataOptionsProxiedServices}->{$confKey};

    my $s = $self->_saveApplyConf( $req, $conf );
    return $self->sendError( $req, "Unable to save configuration ($s)", 500 )
      unless ( $s > 0 );

    return $self->sendJSONresponse( $req, undef, code => 204 );
}

sub _getCasSrvByConfKey {
    my ( $self, $conf, $confKey ) = @_;

    return undef unless ( defined $conf->{casSrvMetaDataOptions}->{$confKey} );

    my $options = {};
    for
      my $configOption ( keys %{ $conf->{casSrvMetaDataOptions}->{$confKey} } )
    {
        $options->{ $self->_translateOptionConfToApi($configOption) } =
          $self->_translateValueConfToApi( $configOption,
            $conf->{casSrvMetaDataOptions}->{$confKey}->{$configOption} );
    }

    return {
        confKey      => $confKey,
        exportedVars => $conf->{casSrvMetaDataExportedVars}->{$confKey} || {},
        options      => $options
    };
}

sub _pushCasSrv {
    my ( $self, $req, $conf, $confKey, $push, $replace ) = @_;

    my $translatedOptions = {};
    if ($replace) {
        $conf->{casSrvMetaDataOptions}->{$confKey}      = {};
        $conf->{casSrvMetaDataExportedVars}->{$confKey} = {};
        $translatedOptions = $self->_getDefaultValues('casSrvMetaDataNode');
    }

    if ( defined $push->{options} ) {
        return {
            res => 'ko',
            msg => "Invalid input: options is not a hash object"
          }
          unless ( ref( $push->{options} ) eq 'HASH' );

        foreach ( keys %{ $push->{options} } ) {
            my $optionName = $self->_translateOptionApiToConf( $_, 'casSrv' );
            eval {
                $translatedOptions->{$optionName} =
                  $self->_translateValueApiToConf( $optionName,
                    $push->{options}->{$_} );
            };
            return { res => 'ko', msg => "Invalid input: $@" } if ($@);
        }

        my $res = $self->_hasAllowedAttributes( $translatedOptions,
            'casSrvMetaDataNode' );
        return $res unless ( $res->{res} eq 'ok' );
    }

    $self->_merge_hash( $conf, 'casSrvMetaDataOptions', $confKey,
        $translatedOptions );

    if ( defined $push->{exportedVars} ) {
        return {
            res => 'ko',
            msg =>
"Invalid input: exportedVars is not a hash object with \"key\":\"value\" attributes"
          }
          unless ( $self->_isSimpleKeyValueHash( $push->{exportedVars} ) );

        $self->_merge_hash(
            $conf,    'casSrvMetaDataExportedVars',
            $confKey, $push->{exportedVars}
        );
    }

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
