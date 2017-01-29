# This module loads known enabled plugins. To add custom modules, just add them
# into "plugins" list in lemonldap-ng.ini, section "portal"
package Lemonldap::NG::Portal::Main::Plugins;

our $VERSION = '2.0.0';

package Lemonldap::NG::Portal::Main;

use strict;

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

   # Check if captcha is required
   # TODO: verify if this list is OK
   #foreach my $key (
   #    qw(captcha_login_enabled captcha_mail_enabled captcha_register_enabled))
   #{
   #    if ( $self->conf->{$key} ) {
   #        $self->lmLog( 'Captcha enabled', 'debug' );
   #        push @res, '::Plugins::Captcha';
   #        last;
   #    }
   #}

    # Check if register is enabled
    push @res, '::Plugins::Register'
      if ( $self->conf->{registerDB} and $self->conf->{registerDB} ne 'Null' );

    push @res, '::Plugins::MailReset'
      if ( $self->conf->{portalDisplayResetPassword} );

    # Check if SOAP is enabled
    push @res, '::Plugins::SOAPServer'
      if ( $self->conf->{soapSessionServer}
        or $self->conf->{soapConfigServer} );

    # Check if portal status is enabled
    push @res, '::Plugins::Status' if ( $self->conf->{portalStatus} );

    # Add REST (check is done by it)
    push @res, '::Plugins::RESTServer';

    # Check if notification is enabled
    push @res, '::Plugins::Notifications' if ( $self->conf->{notifications} );
    foreach my $type (qw(password register)) {
        my $tmp = $self->conf->{$type};
        if ( $tmp and $tmp ne 'Null' ) {
            $tmp = '::' . ucfirst($type) . "DB::$tmp";
            $self->lmLog("$tmp enabled");
            push @res, $tmp;
        }
    }

    # Simple plugins
    # TODO: write these plugins
    push @res, '::Plugins::GrantSession' if ( $self->conf->{grantSessionRule} );
    push @res, '::Plugins::CDA'          if ( $self->conf->{cda} );
    push @res, '::Plugins::ForceAuth'    if ( $self->conf->{portalForceAuthn} );

    if ( my $p = $self->conf->{passwordDB} ) {
        push @res, "::Password::$p" if ( $p ne 'Null' );
    }

    # Check if custom plugins are required
    # TODO: change this name
    if ( $self->conf->{plugins} ) {
        $self->lmLog( 'Custom plugins: ' . $self->conf->{plugins}, 'debug' );
        push @res, grep ( /\w/, split( /,\s*/, $self->conf->{plugins} ) );
    }
    return @res;
}

1;
