# This module loads known enabled plugins. To add custom modules, just add them
# into "plugins" list in lemonldap-ng.ini, section "portal"
package Lemonldap::NG::Portal::Main::Plugins;

use strict;
use Mouse;

our $VERSION = '2.0.0';

##@method list enabledPlugins
#
#@return list of enabled plugins
sub enabledPlugins {
    my ($self) = @_;
    my @res;

    # Search for IssuerDB* modules enabled
    foreach my $key (qw(SAML OpenID CAS OpenIDConnect)) {
        if ( $self->conf->{"issuerDB${key}Activation"} ) {
            $self->lmlog( "IssuerDB${key} enabled", 'debug' );
            push @res, "IssuerDB$key";
        }
    }

    # Check if captcha is required
    # TODO: verify if this list is OK
    foreach my $key (
        qw(captcha_login_enabled captcha_mail_enabled captcha_register_enabled))
    {
        if ( $self->conf->{$key} ) {
            $self->lmLog( 'Captcha enabled', 'debug' );
            push @res, 'Captcha';
            last;
        }
    }

    # Check if SOAP is enabled
    # TODO: REST
    push @res, 'SOAP' if ( $self->conf->{Soap} );

    # Check if notification is enabled
    push @res, 'Notifications' if ( $self->conf->{notification} );
    foreach my $type (qw(password register)) {
        my $tmp = $self->conf->{$type};
        if ( $tmp and $tmp ne 'Null' ) {
            $tmp = ucfirst($type) . "DB$tmp";
            $self->lmLog("$tmp enabled");
            push @res, $tmp;
        }
    }

    # TODO: Password

    # Check if custom plugins are required
    if ( $self->conf->{plugins} ) {
        $self->lmLog( 'Custom plugins: ' . $self->conf->{plugins}, 'debug' );
        push @res, grep ( /\w/, split( /,\s*/, $self->conf->{plugins} ) );
    }
}

1;
