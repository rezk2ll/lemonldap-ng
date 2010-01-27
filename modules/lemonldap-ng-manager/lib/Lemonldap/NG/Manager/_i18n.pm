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
        advancedParams             => 'Advanced parameters',
        authentication             => 'Authentication module',
        authParams       => 'Authentication',
        clickHereToForce           => 'Click here to force',
        Configuration              => 'Configuration',
        confModuledeprecated =>
'This module has been deprecated, set "forceUpload=1" in lemonldap-ng.ini to use it',
        confSaved                  => 'Configuration saved',
        confWasChanged             => 'Configuration has been changed',
        cookieExpiration           => 'Cookie expiration time',
        cookieName                 => 'Cookie Name',
        cookieParams                => 'Cookies',
        databaseLocked             => 'Database locked by another process',
        domain                     => 'Domain',
        exportedAttr               => 'SOAP exported attributes',
        exportedVars               => 'Exported Variables',
        generalParameters          => 'General Parameters',
        globalStorage              => 'Apache::Session module',
        globalStorageOptions       => 'Apache::Session module parameters',
        grantSessionRule            => 'Opening conditions',
        groups                     => 'Groups',
        headers                    => 'HTTP Headers',
        https                      => 'Default value for https parameter',
        ldapBase                   => 'LDAP Search Base',
        ldapParams                 => 'LDAP parameters',
        ldapPort                   => 'LDAP Server Port',
        ldapServer                 => 'LDAP Server',
        logParams                   => 'Logs',
        macros                     => 'Macros',
        mailBody                   => 'Mail content',
        mailFrom                   => 'Mail sender',
        mailSubject                => 'Mail subject',
        managerDn                  => 'LDAP Account',
        managerPassword            => 'LDAP Password',
        notification               => 'Active notifications',
        notifications              => 'Notifications',
        notificationStorage        => 'Notifications storage type',
        notificationStorageOptions => 'Storage module parameters',
        notifyDeleted              => 'Display deleted sessions',
        notifyOther                 => 'Display other sessions',
        passwordDB                  => 'Password database type',
        passwordManagement         => 'Password management',
        portal                     => 'Portal',
        portalAutocomplete          => 'Auto complete',
        portalDisplayAppslist       => 'Display applications list',
        portalDisplayChangePassword => 'Display password change',
        portalDisplayLogout         => 'Display logout',
        portalDisplayResetPassword  => 'Display reset password',
        portalForceAuthn            => 'Force authentication',
        portalOpenLinkInNewWindow   => 'New window',
        portalParams                => 'Portal',
        portalRequireOldPassword    => 'Require old password',
        portalSkin                  => 'Skin',
        portalUserAttr              => 'User attribute',
        randomPasswordRegexp       => 'Regexp for password generation',
        rules                      => 'Rules',
        securedCookie              => 'Secured Cookie (SSL)',
        sessionParams               => 'Sessions',
        sessionStorage             => 'Sessions Storage',
        singleIP                   => 'One IP only by user',
        singleSession              => 'One session only by user',
        singleUserByIP             => 'One user by IP address',
        SMTPServer                 => 'SMTP server',
        Soap                       => 'Activate portal SOAP functions',
        storePassword              => 'Store user password in session datas',
        syntaxError                => 'Syntax Error',
        syslog                     => 'Syslog facility',
        timeout                    => 'Sessions timeout',
        trustedDomains             => 'Trusted domains',
        unknownError               => 'Unknown error',
        uploadDenied               => 'Upload denied',
        userDB                     => 'Users database type',
        userControl                => 'Username control',
        useXForwardedForIP         => "Use X-Forwarded-For header address",
        variables                  => "Variables",
        virtualHosts               => 'Virtual Hosts',
        whatToTrace                 => "REMOTE_USER environment variable",
    };
}

sub fr {
    return {
        advancedParams             => 'Paramètres avancés',
        authentication             => "Module d'authentification",
        authParams       => "Authentification",
        clickHereToForce => 'Cliquer ici pour forcer',
        Configuration              => 'Configuration',
        confModuledeprecated =>
"Ce module est obsolète, indiquez \"forceUpload=1\" dans le fichier lemonldap-ng.ini pour l'utiliser",
        confSaved                  => 'Configuration sauvegardée',
        confWasChanged             => 'Configuration modifiée entre-temps',
        cookieExpiration           => 'Durée de vie du cookie',
        cookieName                 => 'Nom du cookie',
        cookieParams     => 'Cookies',
        databaseLocked             => 'Base de donnée verrouillée par un autre processus',
        domain                     => 'Domaine',
        exportedAttr   => 'Attributs exportés par le portail (SOAP)',
        exportedVars               => 'Attributs à exporter',
        generalParameters          => 'Paramètres généraux',
        globalStorage              => 'Module Apache::Session',
        globalStorageOptions       => 'Paramètres du module Apache::Session',
        grantSessionRule           => "Conditions d'ouverture",
        groups                     => 'Groupes',
        headers                    => 'En-têtes HTTP',
        https                      => 'Valeur par défaut du paramètre https',
        ldapBase                   => 'Base de recherche LDAP',
        ldapParams                 => 'Paramètres LDAP',
        ldapPort                   => 'Port du serveur LDAP',
        ldapServer                 => 'Serveur LDAP',
        logParams                  => 'Journalisation',
        macros                     => 'Macros',
        mailBody                   => 'Contenu du message',
        mailFrom                   => 'Expéditeur du message',
        mailSubject                => 'Sujet du message',
        managerDn                  => 'Compte de connexion LDAP',
        managerPassword            => 'Mot de passe LDAP',
        notification               => 'Active les notifications',
        notifications              => 'Notifications',
        notificationStorage        => 'Type de stockage des notifications',
        notificationStorageOptions => 'Paramètres du module de stockage',
        notifyDeleted              => 'Affiche les sessions effacées',
        notifyOther                => 'Affiche les autres sessions',
        passwordDB                 => 'Type de base de données des mots-de-passe',
        passwordManagement         => 'Gestion des mots-de-passe',
        portal                     => 'Portail',
        portalAutocomplete    => 'Auto complétion',
        portalDisplayAppslist => 'Affichage liste des applications',
        portalDisplayChangePassword => 'Affichage changement de mot de passe',
        portalDisplayLogout         => 'Affichage déconnexion',
        portalDisplayResetPassword =>
          'Affichage réinitialisation de mot de passe',
        portalForceAuthn          => 'Authentication forcée',
        portalOpenLinkInNewWindow => 'Nouvelle fenêtre',
        portalParams              => 'Portail',
        portalRequireOldPassword  => 'Ancien mot de passe requis',
        portalSkin                => 'Thème visuel',
        portalUserAttr            => "Attribut de l'utilisateur",
        randomPasswordRegexp =>
          'Expression regulière pour la génération des mots-de-passe',
        rules                      => 'Règles',
        securedCookie              => 'Cookie sécurisé (SSL)',
        sessionParams  => 'Sessions',
        sessionStorage             => 'Stockage des sessions',
        singleIP                   => 'Une seule IP par utilisateur',
        singleSession              => 'Une seule session par utilisateur',
        singleUserByIP             => 'Une seule adresse IP par utilisateur',
        SMTPServer                 => 'Serveur SMTP',
        Soap                       => 'Active les fonctions SOAP du portail',
        storePassword =>
"Stocke le mot-de-passe de l'utilisateur dans les données de session",
        syntaxError                => 'Erreur de syntaxe',
        syslog                     => 'Facilité syslog',
        timeout                    => 'Durée de vie des sessions',
        trustedDomains             => 'Domaines appouvés',
        unknownError   => 'Erreur inconnue',
        uploadDenied               => 'Téléchargement refusé',
        userDB                     => "Type de base de données d'utilisateurs",
        userControl                => "Contrôle du nom d'utilisateur",
        useXForwardedForIP =>
          "Utiliser l'adresse IP de l'en-tête X-Forwarded-For",
        variables                  => "Variables",
        virtualHosts               => 'Hôtes virtuels',
        whatToTrace  => "Variable d'environnement REMOTE_USER",
    };
}

