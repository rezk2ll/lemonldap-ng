package Lemonldap::NG::Manager::_i18n;

use AutoLoader qw(AUTOLOAD);
our $VERSION = '0.32';

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
        areYouSure                => "Etes vous sur ?",
        authParams                => "Param&egrave;tres d'authentification",
        authenticationType        => "Type d'authentification",
        canNotReadApplyConfFile   => "Configuration non appliqu&eacute;e: impossible de lire le fichier de configuration",
        changesAppliedLater       => "Les changements seront effectifs d'ici 10 minutes. Utilisez \"apachectl reload\" sur les serveurs concern&eacute;s pour forcer la prise en compte imm&eacute;diate",
        checkLogs                 => "Consultez les journaux d'Apache",
        confSaved                 => "Configuration sauvegard&eacute;e sous le num&eacute;ro",
        configLoaded              => "Configuration charg&eacute;e",
        configuration             => "Configuration",
        configurationDeleted      => "Configuration &eacute;ffac&eacute;e",
        configurationNotDeleted   => "Configuration non &eacute;ffac&eacute;e",
        configurationWasChanged   => "configuration modifi&eacute;e depuis que vous l'avez t&eacute;l&eacute;charg&eacute;e",
        confirmDeleteConf         => "Vous allez effacer cette configuration. Confirmez-vous ?",
        cookieName                => "Nom du cookie",
        containsAnAssignment      => 'contient une affectation ("="). Confusion possible avec "==".',
        deleteConf                => "Effacer",
        deleteNode                => "Supprimer",
        deleteVirtualHost         => "Supprimer l'h&ocirc;te virtuel",
        domain                    => "Domaine",
        error                     => "Erreur",
        exportedVars              => "Attributs LDAP &agrave; exporter",
        field                     => "Champ",
        generalParameters         => "Param&egrave;tres g&eacute;n&eacute;raux",
        globalStorageOptions      => "Param&egrave;tres du module Apache::Session",
        group                     => "Groupe",
        header                    => "En-t&ecirc;te",
        httpHeaders               => "En-t&ecirc;tes HTTP",
        invalidLine               => "Ligne invalide",
        invalidVirtualHostName    => "Nom de d'h&ocirc;te virtuel incorrect",
        invalidWhatToTrace        => "La donn&eacute;e &agrave; inscrire dans les journaux ne peut contenir qu'un attribut export&eacute; ou une macro",
        isNotANumber              => "n'est pas un nombre",
        isNotAValidAttributeName  => "n'est pas un nom d'attribut valide",
        isNotAValidCookieName     => "n'est pas un nom de cookie valide",
        isNotAValidDomainName     => "n'est pas un nom de domaine valide",
        isNotAValidGroupName      => "n'est pas un nom de groupe valide",
        isNotAValidHTTPHeaderName => "n'est pas un nom d'en-t&ecirc;te HTTP valide",
        isNotAValidLDAPAttributeName => "n'est pas un nom d'attribut LDAP valide",
        isNotAValidMacroName      => "n'est pas un nom de macro valide",
        isNotAValidVirtualHostName => "n'est pas un nom d'h&ocirc;te virtuel valide",
        lastConf                  => "Derni&egrave;re",
        ldapBase                  => "Base de recherche LDAP",
        ldapParameters            => "Param&egrave;tres LDAP",
        ldapPort                  => "Port du serveur LDAP",
        ldapServer                => "Serveur LDAP",
        locationRules             => "R&egrave;gles",
        macro                     => "Macro",
        macros                    => "Macros",
        managerDn                 => "Compte de connexion LDAP",
        managerPassword           => "Mot de passe LDAP",
        newGSOpt                  => "Nouvelle option",
        newGroup                  => "Nouveau groupe",
        newHeader                 => "Nouvel en-t&ecirc;te",
        newMacro                  => "Nouvelle macro",
        newRule                   => "Nouvelle r&egrave;gle",
        newVar                    => "Nouvelle variable",
        newVirtualHost            => "Nouvel h&ocirc;te virtuel",
        nextConf                  => "Suivante",
        portal                    => "Portail",
        prevConf                  => "Pr&eacute;c&eacute;dente",
        result                    => "R&eacute;sultat",
        rule                      => "R&egrave;gle",
        rules                     => "R&egrave;gles",
        saveConf                  => "Sauvegarder",
        saveFailure               => "&Eacute;chec de la sauvegarde",
        securedCookie             => "Cookie s&eacute;curis&eacute; (SSL)",
        sessionStorage            => "Stockage des sessions",
        sessionTimeout            => "Dur&eacute;e de vie des sessions",
        syntaxError               => "Erreur de syntaxe",
        unableToSave              => "Votre navigateur ne supporte pas les objets XMLHTTPRequest: sauvegarde impossible.",
        unknownError              => "Erreur inconnue",
        unknownErrorInVars        => "Erreur inconnue dans les attributs export&eacute;s",
        userGroups                => "Groupes d'utilisateurs",
        value                     => "Valeur",
        virtualHosts              => "H&ocirc;tes virtuels",
        waitingResult             => "En attente...",
        warningConfNotApplied     => "Vous devez recharger les agents pour que la configuration sauvegard&eacute;e soit appliqu&eacute;e",
        whatToTrace               => "Donn&eacute;e &agrave; inscrire dans les journaux d'Apache",
    };
}
