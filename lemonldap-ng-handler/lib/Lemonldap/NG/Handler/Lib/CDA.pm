package Lemonldap::NG::Handler::Lib::CDA;

use strict;

our $VERSION = '2.0.0';

sub run {
    my ( $class, $req, $rule, $protection ) = @_;
    my $uri = $class->unparsed_uri;
    my $cn  = $class->tsv->{cookieName};
    my ( $id, $session );
    if ( $uri =~ s/[\?&;]${cn}cda=(\w+)$//oi ) {
        if ( $id = $class->fetchId and $session = $class->retrieveSession($id) )
        {
            $class->logger->info(
                'CDA asked for an already available session, skipping');
        }
        else {
            my $cdaid = $1;
            $class->logger->debug("CDA request with id $cdaid");

            my $cdaInfos = $class->getCDAInfos($cdaid);
            unless ( $cdaInfos->{cookie_value} and $cdaInfos->{cookie_name} ) {
                $class->logger->error("CDA request for id $cdaid is not valid");
                return $class->FORBIDDEN;
            }

            my $redirectUrl   = $class->_buildUrl($uri);
            my $redirectHttps = ( $redirectUrl =~ m/^https/ );
            $class->set_header_out(
                'Location'   => $redirectUrl,
                'Set-Cookie' => $cdaInfos->{cookie_name} . "=" . 'c:'
                  . $class->tsv->{cipher}->encrypt(
                    $cdaInfos->{cookie_value} . ' ' . $class->resolveAlias
                  )
                  . "; path=/"
                  . ( $redirectHttps          ? "; secure"   : "" )
                  . ( $class->tsv->{httpOnly} ? "; HttpOnly" : "" )
                  . (
                    $class->tsv->{cookieExpiration}
                    ? "; expires="
                      . expires( $class->tsv->{cookieExpiration}, 'cookie' )
                    : ""
                  )
            );
            return $class->REDIRECT;
        }
    }
    return $class->SUPER::init( $req, $rule, $protection );
}

## @rmethod protected hash getCDAInfos(id)
# Tries to retrieve the CDA session, get infos and delete session
# @return CDA session infos
sub getCDAInfos {
    my ( $class, $id ) = @_;
    my $infos = {};

    # Get the session
    my $cdaSession = Lemonldap::NG::Common::Session->new(
        {
            storageModule        => $class->tsv->{sessionStorageModule},
            storageModuleOptions => $class->tsv->{sessionStorageOptions},
            cacheModule          => $class->tsv->{sessionCacheModule},
            cacheModuleOptions   => $class->tsv->{sessionCacheOptions},
            id                   => $id,
            kind                 => "CDA",
        }
    );

    unless ( $cdaSession->error ) {
        $class->logger->debug("Get CDA session $id");

        $infos->{cookie_value} = $cdaSession->data->{cookie_value};
        $infos->{cookie_name}  = $cdaSession->data->{cookie_name};

        $cdaSession->remove;
    }
    else {
        $class->logger->info("CDA Session $id can't be retrieved");
        $class->logger->info( $cdaSession->error );
    }

    return $infos;
}

1;
