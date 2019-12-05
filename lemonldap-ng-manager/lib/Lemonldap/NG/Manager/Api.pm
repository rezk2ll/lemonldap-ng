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
                    rp => { ':confKey' => 'getOidcRpByConfKey' },
                },
                saml => {
                    sp => { ':confKey' => 'getSamlSpByConfKey' },
                },
            },
        },
        ['GET']
      );
}

1;
