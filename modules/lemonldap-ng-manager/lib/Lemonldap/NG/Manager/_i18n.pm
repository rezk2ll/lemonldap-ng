## @file
# Messages translation for Lemonldap::NG::Manager

## @class
# Messages translation for Lemonldap::NG::Manager.
package Lemonldap::NG::Manager::_i18n;

# Developer warning : this file must be utf8 encoded

use strict;
use AutoLoader qw(AUTOLOAD);
our $VERSION = '0.5';

## @method string translate(string text,string lang)
# Returns $text translated in $lang.
#@param $text textId
#@param $lang Optional language string. If not set, uses Accept-Language
# HTTP header.
sub translate {
    my ( $self, $text, $lang ) = @_;
    return $text unless ( $text =~ /[a-z]/ );
    $lang ||= $ENV{HTTP_ACCEPT_LANGUAGE};
    $lang = lc($lang);
    $lang =~ s/-/_/g;
    foreach ( split( /[,;]/, $lang ), 'en' ) {
        next if /=/;
        if ( __PACKAGE__->can($_) ) {
            no strict 'refs';
            my $r = &$_()->{$text};
            if ($r) {
                return $r;
            }
            else {
                print STDERR __PACKAGE__ . ": $text not translated in $_\n";
                return $text;
            }
        }
    }
}

*fr_fr = *fr;
*en_us = *en;

1;
__END__

sub en {
    return {
        authentication               => 'Authentication module',
        authParams                   => 'Authentication parameters',
        Configuration                => 'Configuration',
        cookieName                   => 'Cookie Name',
        cookieParams                 => 'Cookies Parameters',
        domain                       => 'Domain',
        exportedVars                 => 'Exported Variables',
        generalParameters            => 'General Parameters',
        globalStorage                => 'Apache::Session module',
        globalStorageOptions         => 'Apache::Session module parameters',
        groups                       => 'Groups',
        headers                      => 'HTTP Headers',
        ldapBase                     => 'LDAP Search Base',
        ldapParams                   => 'LDAP parameters',
        ldapPort                     => 'LDAP Server Port',
        ldapServer                   => 'LDAP Server',
        macros                       => 'Macros',
        managerDn                    => 'LDAP Account',
        managerPassword              => 'LDAP Password',
        portal                       => 'Portal',
        rules                        => 'Rules',
        securedCookie                => 'Secured Cookie (SSL)',
        sessionParams                => 'Sessions Parameters',
        sessionStorage               => 'Sessions Storage',
        timeout                      => 'Sessions timeout',
        userDB                       => 'Users database type',
        virtualHosts                 => 'Virtual Hosts',
        whatToTrace                  => "Attribute to use in Apache's logs",
    };
}

sub fr {
    return {
        authentication               => "Module d'authentification",
        authParams                   => "Paramètres d'authentification",
        Configuration                => 'Configuration',
        cookieName                   => 'Nom du cookie',
        cookieParams                 => 'Paramètres des cookies',
        domain                       => 'Domaine',
        exportedVars                 => 'Attributs LDAP à exporter',
        generalParameters            => 'Paramètres généraux',
        globalStorage                => 'Module Apache::Session',
        globalStorageOptions         => 'Paramètres du module Apache::Session',
        groups                       => 'Groupes',
        headers                      => 'En-têtes HTTP',
        ldapBase                     => 'Base de recherche LDAP',
        ldapParams                   => 'Paramètres LDAP',
        ldapPort                     => 'Port du serveur LDAP',
        ldapServer                   => 'Serveur LDAP',
        macros                       => 'Macros',
        managerDn                    => 'Compte de connexion LDAP',
        managerPassword              => 'Mot de passe LDAP',
        portal                       => 'Portail',
        rules                        => 'Règles',
        securedCookie                => 'Cookie sécurisé (SSL)',
        sessionParams                => 'Paramètres des Sessions Parameters',
        sessionStorage               => 'Stockage des sessions',
        timeout                      => 'Durée de vie des sessions',
        userDB                       => "Type de base de données d'utilisateurs",
        virtualHosts                 => 'Hôtes virtuels',
        whatToTrace                  => "Donnée à inscrire dans les journaux d'Apache",
    };
}

