# Handler for Auth Basic

package My::AuthBasic;

# Load Auth Basic Handler
use Lemonldap::NG::Handler::SpecificHandlers::AuthBasic;
@ISA = qw(Lemonldap::NG::Handler::SpecificHandlers::AuthBasic);

__PACKAGE__->init(
    {

        # See Lemonldap::NG::Handler
    }
);

1;
