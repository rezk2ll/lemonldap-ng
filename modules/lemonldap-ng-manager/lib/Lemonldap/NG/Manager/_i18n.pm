package Lemonldap::NG::Manager::_i18n;

use AutoLoader qw(AUTOLOAD);
use UNIVERSAL qw(can);
our $VERSION = '0.2';

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

sub fr {
    return {
        configuration           => 'Configuration',
        exportedVars            => 'Attributs LDAP &agrave; exporter',
        generalParameters       => 'Param&egrave;tres g&eacute;n&eacute;raux',
        ldapParameters          => 'Param&egrave;tres LDAP',
        sessionStorage          => 'Stockage des sessions',
        globalStorageOptions    => 'Param&egrave;tres du module Apache::Session',
        authParams              => "Param&egrave;tres d'authentification",
        userGroups              => "Groupes d'utilisateurs",
        macros                  => "Macros",
        virtualHosts            => "H&ocirc;tes virtuels",
        authenticationType      => "Type d'authentification",
        securedCookie           => 'Cookie s&eacute;curis&eacute; (SSL)',
        domain                  => 'Domaine',
        cookieName              => 'Nom du cookie',
        apacheSessionModule     => 'Module Apache::Session',
        ldapServer              => 'Serveur LDAP',
        ldapPort                => 'Port du serveur LDAP',
        ldapBase                => 'Base de recherche LDAP',
        managerDn               => 'Compte de connexion LDAP',
        managerPassword         => 'Mot de passe LDAP',
        httpHeaders             => 'En-t&ecirc;tes HTTP',
        locationRules           => 'R&egrave;gles',

        # Attention: ici, &eacute; ne sera pas interprété par Firefox (msgBox)
        newVirtualHost          => 'Nouvel hote virtuel',
        newMacro                => 'Nouvelle macro',
        newGroup                => 'Nouveau groupe',
        newVar                  => 'Nouvelle variable',
        newRule                 => 'Nouvelle r&egrave;gle',
        newHeader               => 'Nouvel en-t&ecirc;te',
        newGSOpt                => 'Nouvelle option',
        saveConf                => 'Sauvegarder',
        deleteNode              => 'Supprimer',
        unableToSave            => 'Votre navigateur ne supporte pas les objets XMLHTTPRequest: sauvegarde impossible.',
        confSaved               => 'Configuration sauvegard&eacute;e sous le num&eacute;ro',
        saveFailure             => '&Eacute;chec de la sauvegarde',
        unknownError            => 'Erreur inconnue',
        waitingResult           => 'En attente...',
        configurationWasChanged => "configuration modifi&eacute;e depuis que vous l'avez t&eacute;l&eacute;charg&eacute;e",
        configLoaded            => 'Configuration charg&eacute;e',
        warningConfNotApplied   => "Vous devez recharger les agents pour que la configuration sauvegard&eacute;e soit appliqu&eacute;e",
        applyConf               => 'Appliquer',
        canNotReadApplyConfFile => 'Configuration non appliqu&eacute;e: impossible de lire le fichier de configuration',
        invalidLine             => 'Ligne invalide',
        error                   => 'Erreur',
        result                  => 'R&eacute;sultat',
        changesAppliedLater     => "Les changements seront effectifs d'ici 10 minutes. Utilisez \"apachectl reload\" sur les serveurs concern&eacute;s pour forcer la prise en compte imm&eacute;diate",
        prevConf                => 'Pr&eacute;c&eacute;dente',
        nextConf                => 'Suivante',
        lastConf                => 'Derni&egrave;re',
        deleteVirtualHost       => "Supprimer l'h&ocirc;te virtuel",

        # Attention: ici, &Ecirc; ne sera pas interprété par Firefox (msgBox)
        areYouSure              => 'Etes vous sur ?',
        syntaxError             => 'Erreur de syntaxe, configuration refus&eacute;e. Consultez les journaux du serveur web.',
        whatToTrace             => "Donn&eacute;e &agrave; inscrire dans les journaux d'Apache",
        deleteConf              => 'Effacer',
        confirmDeleteConf       => "Vous allez effacer cette configuration. Confirmez-vous ?",
        configurationDeleted    => 'Configuration &eacute;ffac&eacute;e',
        configurationNotDeleted => 'Configuration non &eacute;ffac&eacute;e',
    };
}

sub en {
    return {
        configuration           => 'Configuration',
        exportedVars            => 'Exported Variables',
        generalParameters       => 'General Parameters',
        ldapParameters          => 'LDAP Parameters',
        sessionStorage          => 'Session Storage',
        globalStorageOptions    => 'Session Storage Parameters',
        authParams              => "Authentication Parameters",
        userGroups              => "User Groups",
        macros                  => "Macros",
        virtualHosts            => "Virtual Hosts",
        authenticationType      => "Authentifition Type",
        securedCookie           => 'Secured Cookie (SSL)',
        domain                  => 'Domain',
        cookieName              => 'Cookie Name',
        apacheSessionModule     => 'Apache::Session module',
        ldapServer              => 'LDAP Server',
        ldapPort                => 'LDAP Server Port',
        ldapBase                => 'LDAP Search Base',
        managerDn               => 'LDAP Account',
        managerPassword         => 'LDAP Password',
        httpHeaders             => 'HTTP Headers',
        locationRules           => 'Rules',

        newVirtualHost          => 'New Virtual Host',
        newMacro                => 'New Macro',
        newGroup                => 'New Group',
        newVar                  => 'New Variable',
        newRule                 => 'New Rule',
        newHeader               => 'New Header',
        newGSOpt                => 'New Option',
        saveConf                => 'Save',
        deleteNode              => 'Delete',
        rules                   => 'Rules',
        unableToSave            => 'Your browser does not support XMLHTTPRequest objects: fail to save.',
        confSaved               => 'Configuration saved with number',
        saveFailure             => 'Save failure',
        unknownError            => 'Unknown error',
        waitingResult           => 'Waiting result...',
        configurationWasChanged => 'Configuration has been changed since you got it',
        configLoaded            => 'Configuration loaded',
        warningConfNotApplied   => 'You have to reload handlers to take the saved configuration in account',
        applyConf               => 'Apply',
        canNotReadApplyConfFile => 'Configuration not applied: cannot read configuration file',
        invalidLine             => 'Invalid Line',
        error                   => 'Error',
        result                  => 'Result',
        changesAppliedLater     => 'Changes will be effective within 10 minutes. Use "apachectl reload" on concerned servers for immediate reloading',
        prevConf                => 'Previous',
        nextConf                => 'Next',
        lastConf                => 'Last',
        deleteVirtualHost       => 'Delete virtual host',
        areYouSure              => 'Are you sure ?',
        syntaxError             => 'Syntax error, configuration refused. See web server logs for more.',
        whatToTrace             => "Attribute to use in Apache's logs",
        deleteConf              => 'Delete',
        confirmDeleteConf       => "You're going to delete configuration. Do you confirm ?",
        configurationDeleted    => 'Configuration deleted',
        configurationNotDeleted => 'Configuration not deleted',
    };
}
