# Handler for Secure Token

package My::SecureToken;

# Load Secure Token Handler
use Lemonldap::NG::Handler::SpecificHandlers::SecureToken;
@ISA = qw(Lemonldap::NG::Handler::SpecificHandlers::SecureToken);

__PACKAGE__->init(
    {

        # See Lemonldap::NG::Handler
    }
);

1;
