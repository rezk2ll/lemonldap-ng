package Lemonldap::NG::Manager::_i18n;

use AutoLoader qw(AUTOLOAD);
use UNIVERSAL qw(can);
our $VERSION = '0.11';

sub import {
    my ($caller_package) = caller;
    my $lang = shift;
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
        *{"${caller_package}::$f"} = sub { $v };
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
        configuration        => 'Configuration',
        exportedVars         => 'Attributs LDAP &agrave; exporter',
        generalParameters    => 'Param&egrave;tres g&eacute;n&eacute;raux',
        ldapParameters       => 'Param&egrave;tres LDAP',
        sessionStorage       => 'Stockage des sessions',
        globalStorageOptions => 'Param&egrave;tres du module Apache::Session',
        authParams           => "Param&egrave;tres d'authentification",
        userGroups           => "Groupes d'utilisateurs",
	macros               => "Macros",
        virtualHosts         => "H&ocirc;tes virtuels",
        authenticationType   => "Type d'authentification",
        securedCookie        => 'Cookie s&eacute;curis&eacute; (SSL)',
        domain               => 'Domaine',
        cookieName           => 'Nom du cookie',
        apacheSessionModule  => 'Module Apache::Session',
        ldapServer           => 'Serveur LDAP',
        ldapPort             => 'Port du serveur LDAP',
        ldapBase             => 'Base de recherche LDAP',
        managerDn            => 'Compte de connexion LDAP',
        managerPassword      => 'Mot de passe LDAP',
        httpHeaders          => 'En-t&ecirc;tes HTTP',
        locationRules        => 'R&egrave;gles',
    };
}

sub en {
    return {
        configuration        => 'Configuration',
        exportedVars         => 'Exported Variables',
        generalParameters    => 'General Parameters',
        ldapParameters       => 'LDAP Parameters',
        sessionStorage       => 'Session Storage',
        globalStorageOptions => 'Session Storage Parameters',
        authParams           => "Authentication Parameters",
        userGroups           => "User Groups",
        virtualHosts         => "Virtual Hosts",
        authenticationType   => "Authentifition Type",
        securedCookie        => 'Secured Cookie (SSL)',
        domain               => 'Domain',
        cookieName           => 'Cookie Name',
        apacheSessionModule  => 'Apache::Session module',
        ldapServer           => 'LDAP Server',
        ldapPort             => 'LDAP Server Port',
        ldapBase             => 'LDAP Search Base',
        managerDn            => 'LDAP Account',
        managerPassword      => 'LDAP Password',
        httpHeaders          => 'HTTP Headers',
        locationRules        => 'Rules',
    };
}
