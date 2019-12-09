# This module implements all the methods that responds to '/api/*' requests
package Lemonldap::NG::Manager::Api;

use 5.10.0;
use utf8;
use Mouse;

extends 'Lemonldap::NG::Common::Conf::RESTServer';

use Lemonldap::NG::Manager::Api::2F;
use Lemonldap::NG::Manager::Api::Providers;

our $VERSION = '2.0.7';

#############################
# I. INITIALIZATION METHODS #
#############################

use constant defaultRoute => 'api.html';

sub addRoutes {
    my ( $self, $conf ) = @_;

    # HTML template
    $self->addRoute( 'api.html', undef, ['GET'] )

      ->addRoute(
        api => {
            v1 => {
                hello => "helloworld",
            },
        },
        ['GET']
      )

      ->addRoute(
        v1 => {
            providers => {
                oidc => {
                    rp => {
                        findByConfKey => {
                            ':uPattern' => 'findOidcRpByConfKey'
                        },
                        findByClientId => {
                            ':uClientId' => 'findOidcRpByClientId'
                        },
                        ':confKey' => 'getOidcRpByConfKey'
                    },
                },
                saml => {
                    sp => {
                        findByConfKey => {
                            ':uPattern' => 'findSamlSpByConfKey'
                        },
                        findByEntityId => {
                            ':uEntityId' => 'findSamlSpByEntityId'
                        },
                        ':confKey' => 'getSamlSpByConfKey'
                    },
                },
            },
        },
        ['GET']
      )

      ->addRoute(
        v1 => {
            providers => {
                oidc => {
                    rp => 'addOidcRp'
                },
                saml => {
                    sp => 'addSamlSp'
                },
            },
        },
        ['POST']
      )

      ->addRoute(
        v1 => {
            providers => {
                oidc => {
                    rp => {':confKey' => 'replaceOidcRp'}
                },
                saml => {
                    sp => {':confKey' => 'replaceSamlSp'}
                },
            },
        },
        ['PUT']
      )

      ->addRoute(
        v1 => {
            providers => {
                oidc => {
                    rp => {':confKey' => 'updateOidcRp'}
                },
                saml => {
                    sp => {':confKey' => 'updateSamlSp'}
                },
            },
        },
        ['PATCH']
      )

      ->addRoute(
        v1 => {
            providers => {
                oidc => {
                    rp => {':confKey' => 'deleteOidcRp'}
                },
                saml => {
                    sp => {':confKey' => 'deleteSamlSp'}
                },
            },
        },
        ['DELETE']
      );
}

1;
