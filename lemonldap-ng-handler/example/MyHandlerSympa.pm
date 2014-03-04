# Handler for Sympa autologin

package My::Sympa;

# Load Sympa Handler
use Lemonldap::NG::Handler::SpecificHandlers::SympaAutoLogin;
@ISA = qw(Lemonldap::NG::Handler::SpecificHandlers::SympaAutoLogin);

__PACKAGE__->init(
    {

        # See Lemonldap::NG::Handler
    }
);

1;
