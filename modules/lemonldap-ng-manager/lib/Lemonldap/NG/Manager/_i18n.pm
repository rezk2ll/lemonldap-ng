## @file
# Messages translation for Lemonldap::NG::Manager

## @class
# Messages translation for Lemonldap::NG::Manager.
package Lemonldap::NG::Manager::_i18n;

# Developer warning : this file must be utf8 encoded

use strict;
use AutoLoader qw(AUTOLOAD);
our $VERSION = '0.5';

## @fn void import(string lang)
# Import messages
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

__END__

=pod
=cut

sub en {
    return {
        apacheSessionModule          => 'Apache::Session module',
        applyConf                    => 'Apply',
        areYouSure                   => 'Are you sure ?',
        authenticationType           => 'Authentication Type',
        canNotReadApplyConfFile      => 'Configuration not applied: cannot read configuration file',
        changesAppliedLater          => 'Changes will be effective within 10 minutes. Use "apachectl reload" on concerned servers for immediate reloading',
        checkLogs                    => 'Check Apache logs',
        confSaved                    => 'Configuration saved with number',
        configLoaded                 => 'Configuration loaded',
        configurationDeleted         => 'Configuration deleted',
        configurationNotDeleted      => 'Configuration not deleted',
        configurationWasChanged      => 'Configuration has been changed since you got it',
        confirmDeleteConf            => "You're going to delete configuration. Do you confirm ?",
        containsAnAssignment         => 'contains an assignment ("="). Possible confusion with "==".',
        deleteConf                   => 'Delete',
        deleteNode                   => 'Delete',
        deleteVirtualHost            => 'Delete virtual host',
        error                        => 'Error',
        field                        => 'Field',
        group                        => 'Group',
        httpHeaders                  => 'HTTP Headers',
        invalidLine                  => 'Invalid Line',
        invalidVirtualHostName       => 'Invalid virtual host name',
        invalidWhatToTrace           => "Data to use in Apache's logs can contain only an exported attribute or a macro",
        isNotANumber                 => 'is not a number',
        isNotAValidAttributeName     => 'is not a valid attribute name',
        isNotAValidCookieName        => 'is not a valid cookie name',
        isNotAValidDomainName        => 'is not a valid domain name',
        isNotAValidGroupName         => 'is not a valid group name',
        isNotAValidHTTPHeaderName    => 'is not a valid HTTP header name',
        isNotAValidLDAPAttributeName => 'is not a valid LDAP attribute name',
        isNotAValidMacroName         => 'is not a valid macro name',
        isNotAValidVirtualHostName   => 'is not a valid virtual host name',
        lastConf                     => 'Last',
        locationRules                => 'Rules',
        macro                        => 'Macro',
        newGSOpt                     => 'New Option',
        newGroup                     => 'New Group',
        newHeader                    => 'New Header',
        newMacro                     => 'New Macro',
        newVar                       => 'New Variable',
        newVirtualHost               => 'New Virtual Host',
        nextConf                     => 'Next',
        prevConf                     => 'Previous',
        result                       => 'Result',
        rule                         => 'Rule',
        saveConf                     => 'Save',
        saveFailure                  => 'Save failure',
        syntaxError                  => 'Syntax error',
        unableToSave                 => 'Your browser does not support XMLHTTPRequest objects: fail to save.',
        unknownError                 => 'Unknown error',
        unknownErrorInVars           => 'Unknown error in exported attributes',
        userGroups                   => 'User Groups',
        value                        => 'Value',
        waitingResult                => 'Waiting result...',
        warningConfNotApplied        => 'You have to reload handlers to take the saved configuration in account',
    };
}

sub fr {
    return {
        apacheSessionModule          => 'Module Apache::Session',
        applyConf                    => 'Appliquer',
        areYouSure                   => 'Êtes vous sur ?',
        authenticationType           => "Type d'authentification",
        canNotReadApplyConfFile      => 'Configuration non appliquée: impossible de lire le fichier de configuration',
        changesAppliedLater          => "Les changements seront effectifs d'ici 10 minutes. Utilisez \"apachectl reload\" sur les serveurs concernés pour forcer la prise en compte immédiate",
        checkLogs                    => "Consultez les journaux d'Apache",
        confSaved                    => 'Configuration sauvegardée sous le numéro',
        configLoaded                 => 'Configuration chargée',
        configurationDeleted         => 'Configuration éffacée',
        configurationNotDeleted      => 'Configuration non éffacée',
        configurationWasChanged      => "configuration modifiée depuis que vous l'avez téléchargée",
        confirmDeleteConf            => 'Vous allez effacer cette configuration. Confirmez-vous ?',
        containsAnAssignment         => 'contient une affectation ("="). Confusion possible avec "==".',
        deleteConf                   => 'Effacer',
        deleteNode                   => 'Supprimer',
        deleteVirtualHost            => "Supprimer l'hôte virtuel",
        error                        => 'Erreur',
        field                        => 'Champ',
        group                        => 'Groupe',
        httpHeaders                  => 'En-têtes HTTP',
        invalidLine                  => 'Ligne invalide',
        invalidVirtualHostName       => "Nom de d'hôte virtuel incorrect",
        invalidWhatToTrace           => "La donnée à inscrire dans les journaux ne peut contenir qu'un attribut exporté ou une macro",
        isNotANumber                 => "n'est pas un nombre",
        isNotAValidAttributeName     => "n'est pas un nom d'attribut valide",
        isNotAValidCookieName        => "n'est pas un nom de cookie valide",
        isNotAValidDomainName        => "n'est pas un nom de domaine valide",
        isNotAValidGroupName         => "n'est pas un nom de groupe valide",
        isNotAValidHTTPHeaderName    => "n'est pas un nom d'en-tête HTTP valide",
        isNotAValidLDAPAttributeName => "n'est pas un nom d'attribut LDAP valide",
        isNotAValidMacroName         => "n'est pas un nom de macro valide",
        isNotAValidVirtualHostName   => "n'est pas un nom d'hôte virtuel valide",
        lastConf                     => 'Dernière',
        locationRules                => 'Règles',
        macro                        => 'Macro',
        macros                       => 'Macros',
        newGSOpt                     => 'Nouvelle option',
        newGroup                     => 'Nouveau groupe',
        newHeader                    => 'Nouvel en-tête',
        newMacro                     => 'Nouvelle macro',
        newVar                       => 'Nouvelle variable',
        newVirtualHost               => 'Nouvel hôte virtuel',
        nextConf                     => 'Suivante',
        prevConf                     => 'Précédente',
        result                       => 'Résultat',
        rule                         => 'Règle',
        saveConf                     => 'Sauvegarder',
        saveFailure                  => 'Échec de la sauvegarde',
        syntaxError                  => 'Erreur de syntaxe',
        unableToSave                 => 'Votre navigateur ne supporte pas les objets XMLHTTPRequest: sauvegarde impossible.',
        unknownError                 => 'Erreur inconnue',
        unknownErrorInVars           => 'Erreur inconnue dans les attributs exportés',
        userGroups                   => "Groupes d'utilisateurs",
        value                        => 'Valeur',
        waitingResult                => 'En attente...',
        warningConfNotApplied        => 'Vous devez recharger les agents pour que la configuration sauvegardée soit appliquée',
    };
}
