package Lemonldap::NG::Manager::_i18n;

# Developer warning : this file must be utf8 encoded

use AutoLoader qw(AUTOLOAD);
our $VERSION = '0.33';

sub import {
    my ($caller_package) = caller;
    my $lang = pop;
    $lang = lc($lang);
    $lang =~ s/-/_/g;
    foreach ( split( /[,;]/, $lang ) ) {
        next if /=/;
        if ( __PACKAGE__->can($_) ) {
            $functions = &$_;
            last;
        }
    }
    $functions ||= &en;
    while ( my ( $f, $v ) = each(%$functions) ) {
        *{"${caller_package}::txt_$f"} = sub { $v };
    }
}

*fr_fr = *fr;
*en_us = *en;

1;

__END__

=pod
=cut

sub en {
    return {
        apacheSessionModule       => "Apache::Session module",
        applyConf                 => "Apply",
        areYouSure                => "Are you sure ?",
        authParams                => "Authentication Parameters",
        authenticationType        => "Authentication Type",
        canNotReadApplyConfFile   => "Configuration not applied: cannot read configuration file",
        changesAppliedLater       => 'Changes will be effective within 10 minutes. Use "apachectl reload" on concerned servers for immediate reloading',
        checkLogs                 => "Check Apache logs",
        confSaved                 => "Configuration saved with number",
        configLoaded              => "Configuration loaded",
        configuration             => "Configuration",
        configurationDeleted      => "Configuration deleted",
        configurationNotDeleted   => "Configuration not deleted",
        configurationWasChanged   => "Configuration has been changed since you got it",
        confirmDeleteConf         => "You're going to delete configuration. Do you confirm ?",
        cookieName                => "Cookie Name",
        containsAnAssignment      => 'contains an assignment ("="). Possible confusion with "==".',
        deleteConf                => "Delete",
        deleteNode                => "Delete",
        deleteVirtualHost         => "Delete virtual host",
        domain                    => "Domain",
        error                     => "Error",
        exportedVars              => "Exported Variables",
        field                     => "Field",
        generalParameters         => "General Parameters",
        globalStorageOptions      => "Session Storage Parameters",
        group                     => "Group",
        header                    => "Header",
        httpHeaders               => "HTTP Headers",
        invalidLine               => "Invalid Line",
        invalidVirtualHostName    => "Invalid virtual host name",
        invalidWhatToTrace        => "Data to use in Apache's logs can contain only an exported attribute or a macro",
        isNotANumber              => "is not a number",
        isNotAValidAttributeName  => "is not a valid attribute name",
        isNotAValidCookieName     => "is not a valid cookie name",
        isNotAValidDomainName     => "is not a valid domain name",
        isNotAValidGroupName      => "is not a valid group name",
        isNotAValidHTTPHeaderName => "is not a valid HTTP header name",
        isNotAValidLDAPAttributeName => "is not a valid LDAP attribute name",
        isNotAValidMacroName      => "is not a valid macro name",
        isNotAValidVirtualHostName => "is not a valid virtual host name",
        lastConf                  => "Last",
        ldapBase                  => "LDAP Search Base",
        ldapParameters            => "LDAP Parameters",
        ldapPort                  => "LDAP Server Port",
        ldapServer                => "LDAP Server",
        locationRules             => "Rules",
        macro                     => "Macro",
        macros                    => "Macros",
        managerDn                 => "LDAP Account",
        managerPassword           => "LDAP Password",
        newGSOpt                  => "New Option",
        newGroup                  => "New Group",
        newHeader                 => "New Header",
        newMacro                  => "New Macro",
        newRule                   => "New Rule",
        newVar                    => "New Variable",
        newVirtualHost            => "New Virtual Host",
        nextConf                  => "Next",
        portal                    => "Portal",
        prevConf                  => "Previous",
        result                    => "Result",
        rule                      => "Rule",
        rules                     => "Rules",
        saveConf                  => "Save",
        saveFailure               => "Save failure",
        securedCookie             => "Secured Cookie (SSL)",
        sessionStorage            => "Session Storage",
        sessionTimeout            => "Session timeout",
        syntaxError               => "Syntax error",
        unableToSave              => "Your browser does not support XMLHTTPRequest objects: fail to save.",
        unknownError              => "Unknown error",
        unknownErrorInVars        => "Unknown error in exported attributes",
        userGroups                => "User Groups",
        value                     => "Value",
        virtualHosts              => "Virtual Hosts",
        waitingResult             => "Waiting result...",
        warningConfNotApplied     => "You have to reload handlers to take the saved configuration in account",
        whatToTrace               => "Attribute to use in Apache's logs",
    };
}

sub fr {
    return {
        apacheSessionModule       => "Module Apache::Session",
        applyConf                 => "Appliquer",
        areYouSure                => "Êtes vous sur ?",
        authParams                => "Paramètres d'authentification",
        authenticationType        => "Type d'authentification",
        canNotReadApplyConfFile   => "Configuration non appliquée: impossible de lire le fichier de configuration",
        changesAppliedLater       => "Les changements seront effectifs d'ici 10 minutes. Utilisez \"apachectl reload\" sur les serveurs concernés pour forcer la prise en compte immédiate",
        checkLogs                 => "Consultez les journaux d'Apache",
        confSaved                 => "Configuration sauvegardée sous le numéro",
        configLoaded              => "Configuration chargée",
        configuration             => "Configuration",
        configurationDeleted      => "Configuration éffacée",
        configurationNotDeleted   => "Configuration non éffacée",
        configurationWasChanged   => "configuration modifiée depuis que vous l'avez téléchargée",
        confirmDeleteConf         => "Vous allez effacer cette configuration. Confirmez-vous ?",
        cookieName                => "Nom du cookie",
        containsAnAssignment      => 'contient une affectation ("="). Confusion possible avec "==".',
        deleteConf                => "Effacer",
        deleteNode                => "Supprimer",
        deleteVirtualHost         => "Supprimer l'hôte virtuel",
        domain                    => "Domaine",
        error                     => "Erreur",
        exportedVars              => "Attributs LDAP à exporter",
        field                     => "Champ",
        generalParameters         => "Paramètres généraux",
        globalStorageOptions      => "Paramètres du module Apache::Session",
        group                     => "Groupe",
        header                    => "En-tête",
        httpHeaders               => "En-têtes HTTP",
        invalidLine               => "Ligne invalide",
        invalidVirtualHostName    => "Nom de d'hôte virtuel incorrect",
        invalidWhatToTrace        => "La donnée à inscrire dans les journaux ne peut contenir qu'un attribut exporté ou une macro",
        isNotANumber              => "n'est pas un nombre",
        isNotAValidAttributeName  => "n'est pas un nom d'attribut valide",
        isNotAValidCookieName     => "n'est pas un nom de cookie valide",
        isNotAValidDomainName     => "n'est pas un nom de domaine valide",
        isNotAValidGroupName      => "n'est pas un nom de groupe valide",
        isNotAValidHTTPHeaderName => "n'est pas un nom d'en-tête HTTP valide",
        isNotAValidLDAPAttributeName => "n'est pas un nom d'attribut LDAP valide",
        isNotAValidMacroName      => "n'est pas un nom de macro valide",
        isNotAValidVirtualHostName => "n'est pas un nom d'hôte virtuel valide",
        lastConf                  => "Dernière",
        ldapBase                  => "Base de recherche LDAP",
        ldapParameters            => "Paramètres LDAP",
        ldapPort                  => "Port du serveur LDAP",
        ldapServer                => "Serveur LDAP",
        locationRules             => "Règles",
        macro                     => "Macro",
        macros                    => "Macros",
        managerDn                 => "Compte de connexion LDAP",
        managerPassword           => "Mot de passe LDAP",
        newGSOpt                  => "Nouvelle option",
        newGroup                  => "Nouveau groupe",
        newHeader                 => "Nouvel en-tête",
        newMacro                  => "Nouvelle macro",
        newRule                   => "Nouvelle règle",
        newVar                    => "Nouvelle variable",
        newVirtualHost            => "Nouvel hôte virtuel",
        nextConf                  => "Suivante",
        portal                    => "Portail",
        prevConf                  => "Précédente",
        result                    => "Résultat",
        rule                      => "Règle",
        rules                     => "Règles",
        saveConf                  => "Sauvegarder",
        saveFailure               => "Échec de la sauvegarde",
        securedCookie             => "Cookie sécurisé (SSL)",
        sessionStorage            => "Stockage des sessions",
        sessionTimeout            => "Durée de vie des sessions",
        syntaxError               => "Erreur de syntaxe",
        unableToSave              => "Votre navigateur ne supporte pas les objets XMLHTTPRequest: sauvegarde impossible.",
        unknownError              => "Erreur inconnue",
        unknownErrorInVars        => "Erreur inconnue dans les attributs exportés",
        userGroups                => "Groupes d'utilisateurs",
        value                     => "Valeur",
        virtualHosts              => "Hôtes virtuels",
        waitingResult             => "En attente...",
        warningConfNotApplied     => "Vous devez recharger les agents pour que la configuration sauvegardée soit appliquée",
        whatToTrace               => "Donnée à inscrire dans les journaux d'Apache",
    };
}
