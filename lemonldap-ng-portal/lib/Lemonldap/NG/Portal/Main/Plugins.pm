# This module loads known enabled plugins. To add custom modules, just add them
# into "plugins" list in lemonldap-ng.ini, section "portal"
package Lemonldap::NG::Portal::Main::Plugins;

our $VERSION = '2.0.0';

package Lemonldap::NG::Portal::Main;

use strict;
use Mouse;

# Plugins enabled by a simple boolean value (ordered list)
#
# Developers: U2F must be loaded before Notifications
our @pList = (
    portalDisplayResetPassword => '::Plugins::MailReset',
    portalStatus               => '::Plugins::Status',
    grantSessionRule           => '::Plugins::GrantSession',
    cda                        => '::Plugins::CDA',
    portalForceAuthn           => '::Plugins::ForceAuth',
    u2fActivation              => '::Plugins::U2F',
    u2fSelfRegistration        => '::Register::U2F',
    notification               => '::Plugins::Notifications',
);

##@method list enabledPlugins
#
#@return list of enabled plugins
sub enabledPlugins {
    my ($self) = @_;
    my @res;

    # Search for Issuer* modules enabled
    foreach my $key (qw(SAML OpenID CAS OpenIDConnect Get)) {
        if ( $self->conf->{"issuerDB${key}Activation"} ) {
            $self->lmLog( "Issuer${key} enabled", 'debug' );
            push @res, "::Issuer::$key";
        }
    }

    # Load static plugin list
    for ( my $i = 0 ; $i < @pList ; $i += 2 ) {
        push @res, $pList[ $i + 1 ] if ( $self->conf->{ $pList[$i] } );
    }

    # Check if SOAP is enabled
    push @res, '::Plugins::SOAPServer'
      if ( $self->conf->{soapSessionServer}
        or $self->conf->{soapConfigServer} );

    # Add REST (check is done by it)
    push @res, '::Plugins::RESTServer';

    if ( my $p = $self->conf->{passwordDB} ) {
        push @res, "::Password::$p" if ( $p ne 'Null' );
    }

    # Check if register is enabled
    push @res, '::Plugins::Register'
      if ( $self->conf->{registerDB} and $self->conf->{registerDB} ne 'Null' );

    # Check if custom plugins are required
    # TODO: change this name
    if ( $self->conf->{customPlugins} ) {
        $self->lmLog( 'Custom plugins: ' . $self->conf->{customPlugins},
            'debug' );
        push @res, grep ( /\w/, split( /,\s*/, $self->conf->{customPlugins} ) );
    }
    return @res;
}

1;
