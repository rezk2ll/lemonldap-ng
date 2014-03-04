# Handler for Zimbra preauthentication

package My::Zimbra;

# Load Zimbra Handler
use Lemonldap::NG::Handler::SpecificHandlers::ZimbraPreAuth;
@ISA = qw(Lemonldap::NG::Handler::SpecificHandlers::ZimbraPreAuth);

__PACKAGE__->init(
    {

        # See Lemonldap::NG::Handler
    }
);

1;
