## @file
# Help messages used by the manager.

## @class
# Import help messages subroutines in Lemonldap::NG::Manager in the wanted language.
package Lemonldap::NG::Manager::Help;

use AutoLoader qw(AUTOLOAD);
our $VERSION = '0.5';

## @fn void import(string lang)
# Import help messages subroutines in Lemonldap::NG::Manager in the wanted language.
# @param $lang language, or $ENV{HTTP_ACCEPT_LANGUAGE} by default
# @return nothing
sub import {
    my ($caller_package) = caller;
    my $lang = shift || $ENV{HTTP_ACCEPT_LANGUAGE};
    $lang = lc($lang);
    foreach ( split( /[,;]/, $lang ) ) {
        next if /=/;
        s/fr-fr/fr/;
        s/en-us/en/;
        if ( __PACKAGE__->can("help_groups_$_") ) {
            $l = $_;
            last;
        }
    }
    $l ||= "en";
    foreach $h (
        qw(authParams cookieName domain groups ldap macros storage timeout
        timeoutActivity vars whatToTrace virtualHosts portalForceAuthn default
        samlIDPMetaDataNode samlServicePrivateKeySig samlServicePrivateKeyEnc
        portal securedCookie)
      )
    {
        *{"${caller_package}::help_$h"} = \&{"help_${h}_$l"};
    }
}

1;
__END__

=pod
=cut
## authParams
# en
sub help_authParams_en {
    print <<EOT;
<h3>Modules</h3>

<p>LemonLDAP::NG use three types of modules:</p>
<ul>
 <li><tt>auhtentication</tt>: how authentication is done,</li>
 <li><tt>userDB</tt>: how user information for session are collected,</li>
 <li><tt>passwordDB</tt>: how password is changed.</li>
</ul>

<h4>Authentication module</h4>
<ul>
 <li><tt>LDAP</tt>: authentication done with an LDAP directory,</li>
 <li><tt>SSL</tt>: authentication is done by Apache <tt>mod_ssl</tt> and the portal checks 
 if SSL variable is set,</li>
 <li><tt>DBI</tt>: authentication done with a database</li>
 <li><tt>Apache</tt>: authentication is done by Apache with any mechanism that set
  <tt>REMOTE_USER</tt> environment variable. This allows to use any Apache
  authentication module as <tt>mod_auth_basic</tt>, <tt>mod_auth_kerb</tt>, ...</li>
 <li><tt>CAS</tt>: authentication is delegated to a CAS server,</li>
 <li><tt>Remote</tt>: authentication is delegated to a remote LemonLDAP::NG portal,</li>
 <li><tt>Proxy</tt>: authentication is done via Web Services on another LemonLDAP::NG portal,</li>
 <li><tt>OpenID</tt>: authentication is delegated to an OpenID server,</li>
 <li><tt>Twitter</tt>: authentication is delegated to Twitter,</li>
 <li><tt>SAML</tt>: authentication is delegation to an SAML2 Identity Provider,</li>
 <li><tt>None</tt>: transparent authentication (all users are logged),</li>
 <li><tt>Multi</tt>: authentication modules are stacked, the first working opens the session.
 You can associate conditions to each modules with following syntax:
 <tt>Module Condtions;Module Conditions;Module Conditions</tt>
</ul>

<h4>Users module</h4>
<ul>
 <li><tt>LDAP</tt>: get attributes from an LDAP directory,</li>
 <li><tt>DBI</tt>: get attributes from a database,</li>
 <li><tt>Env</tt>: get attributes from Apache environment variables,</li>
 <li><tt>SAML</tt>: use SAML2 attributes requests,</li>
 <li><tt>Remote</tt>: delegated to a remote LemonLDAP::NG portal,</li>
 <li><tt>Proxy</tt>: done via Web Services on another LemonLDAP::NG portal,</li>
 <li><tt>None</tt>: nothing is collected,</li>
 <li><tt>Multi</tt>: users modules are stacked.
 You can associate conditions to each modules with following syntax:
 <tt>Module Condtions;Module Conditions;Module Conditions</tt>
</ul>

<h4>Password module</h4>
<ul>
 <li><tt>LDAP</tt>: change password in an LDAP directory,</li>
 <li><tt>DBI</tt>: change password in a database,</li>
 <li><tt>None</tt>: do nothing,</li>
</ul>

EOT
}

#fr
sub help_authParams_fr {
    print <<EOT;
<h3>Modules</h3>

<p>LemonLDAP::NG utilise trois types de modules :</p>
<ul>
 <li><tt>auhtentication</tt> : comment est effectuée l'authentification,</li>
 <li><tt>userDB</tt> : comment sont collectées les informations de l'utilisateur pour la session,</li>
 <li><tt>passwordDB</tt> : comment est changé le mot de passe.</li>
</ul>

<h4>Module d'authentification</h4>
<ul>
 <li><tt>LDAP</tt> : authentification faite sur un annuaire LDAP,</li>
 <li><tt>SSL</tt> : authentification faite par Apache <tt>mod_ssl</tt> et vérification par
 le portail que la variable d'environnement SSL est définie,</li>
 <li><tt>DBI</tt> : authentification faite sur une base de données</li>
 <li><tt>Apache</tt> : authentification faite par Apache avec n'importe quel mécanisme qui définit
  la variable d'environnement <tt>REMOTE_USER</tt>. Cela permet d'utiliser des modules
  d'authentification comme <tt>mod_auth_basic</tt>, <tt>mod_auth_kerb</tt>, ...</li>
 <li><tt>CAS</tt> : authentification faite sur un serveur CAS,</li>
 <li><tt>Remote</tt> : authentification faite sur un portail LemonLDAP::NG distant,</li>
 <li><tt>Proxy</tt> : authentification faite par Web Services sur un portail LemonLDAP::NG distant,</li>
 <li><tt>OpenID</tt> : authentification faite sur un serveur OpenID,</li>
 <li><tt>Twitter</tt> : authentification faite sur Twitter,</li>
 <li><tt>SAML</tt> : authentication faite sur un fournisseur d'identité SAML2,</li>
 <li><tt>None</tt> : authentification transparente (tous les utilisateurs sont authentifiés),</li>
 <li><tt>Multi</tt> : les modules d'authentification sont empilés, le premier qui fonctionne ouvre la session.
 Vous pouvez associer des conditions à chaque module avec la syntaxe suivante :
 <tt>Module Condtions;Module Conditions;Module Conditions</tt>
</ul>

<h4>Module utilisateurs</h4>
<ul>
 <li><tt>LDAP</tt> : lecture des attributs sur un annuaire LDAP,</li>
 <li><tt>DBI</tt> : lecture des attributs sur une base de données,</li>
 <li><tt>Env</tt> : lecture des variables d'environnement Apache,</li>
 <li><tt>SAML</tt> : utilisation de requêtes d'attributs SAML2,</li>
 <li><tt>Remote</tt> : lecture des attributs sur un portail LemonLDAP::NG distant,</li>
 <li><tt>Proxy</tt> : lecture des attributs par Web Services sur un portail LemonLDAP::NG distant,</li>
 <li><tt>None</tt> : pas de lecture,</li>
 <li><tt>Multi</tt> : les modules utilisateurs sont empilés.
 Vous pouvez associer des conditions à chaque module avec la syntaxe suivante :
 <tt>Module Condtions;Module Conditions;Module Conditions</tt>
</ul>

<h4>Module de mot de passe</h4>
<ul>
 <li><tt>LDAP</tt> : changement du mot de passe dans un annuaire LDAP,</li>
 <li><tt>DBI</tt> : changement du mot de passe dans une base de données,</li>
 <li><tt>None</tt> : pas de changement de mot de passe,</li>
</ul>

EOT
}

## portal
# en
sub help_portal_en {
    print <<EOT;
<h3>Portal</h3>
<p>Set here the URL where users go to authenticate.</p>
<p class="default">Default value: http://auth.example.com</p>
<p class="info">This URL must be inside the principal SSO DNS domain</p>
EOT
}

# fr
sub help_portal_fr {
    print <<EOT;
<h3>Portail</h3>
<p>Adresse où les utilisateurs viennent s'authentifier.</p>
<p class="default">Valeur par défaut : http://auth.example.com</p>
<p class="info">Cette adresse doit faire partie du domaine DNS principal.</p>
EOT
}

## securedCookie
# en
sub help_securedCookie_en {
    print <<EOT;
<h3>Secured cookie</h3>
<p>An authenticated user is known by his cookie. If all (virtual) hosts use
HTTPS, set this value to 1 so the cookie will be protected and will not be
transmitted unless https is used. You can also set it to generate 2 cookies,
1 secure and the other not. Handlers detects if they are in https mode or not
and will choose the good cookie.</p>
<p class="default">Default value: 0</p>
EOT
}

# fr
sub help_securedCookie_fr {
    print <<EOT;
<h3>Cookie sécurisé</h3>
<p>Un utilisateur authentifié est reconnu par son cookie. Si tous les hôtes
(virtuels) utilisent HTTPS, mettez cette valeur à 1 afin que les cookie soit protégé,
c'est-à-dire qu'il ne sera envoyé qu'aux applications HTTPS. Il est également possible
de générer 2 cookies (un sécurisé, l'autre non). Le Handler détecte alors lequel
des deux utiliser.</p>
<p class="default">Valeur par défaut : 0</p>
EOT
}

## cookieName
# en
sub help_cookieName_en {
    print <<EOT;
<h3>Cookie Name</h3>
<p>Set here the name of the cookie.<p>
<p class="default">Default value: lemonldap</p>
<p class="info">Any change here needs to restart all the Apache servers that use
a Handler.</p>
EOT
}

# fr
sub help_cookieName_fr {
    print <<EOT;
<h3>Nom de cookie</h3>
<p>Indiquez ici le nom du cookie.</p>
<p class="default">Valeur par défaut : lemonldap</p>
<p class="info">Tout changement nécessite le redémarrage de tous les
serveurs Apache hébergeant un Hanlder.</p>
EOT
}

## domain
# en
sub help_domain_en {
    print <<EOT;
<h3>Protected domain</h3>
<p>Set here the main DNS domain (or sub-domain) protected by LemonLDAP::NG.</p>
<p class="default">Default value: example.com</p>
<p class="info">If some protected applications belongs to another domain, you
need to activate the cross-domain authentication feature (also called multiple domains).</p>
EOT
}

# fr
sub help_domain_fr {
    print <<EOT;
<h3>Domaine protégé</h3>
<p>Indiquez ici le nom du domaine DNS (ou du sous-domaine) contenant vos
applications à protéger.</p>
<p class="default">Valeur par défaut : example.com</p>
<p class="info">Si certaines applications protégées appartiennent à un domaine DNS
différent, il faut alors activer l'option de domaines croisés (aussi appelée domaines multiples)</p>
EOT
}

## groups
# en
sub help_groups_en {
    print <<EOT;
<h3>User Groups</h3>
<p>Groups are not required but accelerate the treatment of the requests. For
example, if a virtual host is granted only for 3 users, the rule is:</p>
<pre>
    # test.example.com - Rules
    default =&gt; \$uid eq "user1" or \$uid eq "user2" or \$uid eq "user3"
</pre>
<p>The problem is that this rule is calculated for each HTTP request. Other
example, if 2 sites have the same rules, any modification on one has to be
written in the second. The <tt>groups</tt> system solve this: groups are
evaluated one time in the authentication phase, and the result is stored in the
<tt>\$groups</tt> variable. The rule above becomes:</p>
<pre>
    # Group declaration
    group1 =&gt; \$uid eq "user1" or \$uid eq "user2" or \$uid eq "user3"

    # Use of the group
    # test.example.com - Rules
    default =&gt; \$groups =~ /\\bgroup1\\b/
</pre>
<p>The last rule is a Perl regular expression (PCRE) that means: search the
word "group1" in the string <tt>\$groups</tt>.</p>
<p>The <tt>\$groups</tt> string joins all the groups where the user matches the
expression. The groups are separated by a space in the <tt>\$groups</tt> string.</p>
EOT
}

# fr
sub help_groups_fr {
    print <<EOT;
<h3>Groupes d'utilisateurs</h3>
<p>Les groupes ne sont pas indispensables mais accélèrent le
traitement des requêtes. Par exemple, si un hôte virtuel est
autorisé nominativement à user1, user2 et user3, la règle
d'accès s'écrira&nbsp;:</p>
<pre>
    # test.example.com - Règles
    default =&gt; \$uid eq "user1" or \$uid eq "user2" or \$uid eq "user3"
</pre>
<p>Le problème est que cette expression sera calculée à
chaque requête HTTP. D'autre part, si 2 hôtes virtuels ont la
même règle d'accès, toute modification doit être
répercutée sur les deux hôtes virtuels. Le système
des groupes permet de résoudre ces deux problèmes&nbsp;: lors de
la connexion au portail, les expressions complexes sont calculées une
fois pour toute la session et le résultat est stocké dans la
chaîne <tt>\$groups</tt>. L'exemple précédente devient
alors&nbsp;:</p>
<pre>
    # Déclaration d'un groupe
    group1 =&gt; \$uid eq "user1" or \$uid eq "user2" or \$uid eq "user3"

    # Utilisation
    # test.example.com - Règles
    default =&gt; \$groups =~ /\\bgroup1\\b/
</pre>
<p>Cette dernière expression est une expression régulière
Perl (PCRE) qui correspond à la recherche du mot group1 dans la
chaîne <tt>\$groups</tt> (\\b signifie début ou fin de mot).</p>
<p>La variable exportée <tt>\$groups</tt> est une chaîne de
caractères composée de tous les noms de groupes auxquels
l'utilisateur connecté appartient (c'est à dire les noms de
groupe pour lesquels l'expression est vraie).</p>
EOT
}

## ldap
# en
sub help_ldap_en {
    print <<EOT;
<h3>LDAP parameters</h3>

<ul>
  <li>Server host: Name(s) (or IP address(es)) of the LDAP server(s).
   You can specify more than one server separated by commas and/or spaces,
   they will be tried in the specified order.
   You can also use encrypted connections:
   <ul>
    <li><tt>LDAPS</tt>: instead of a server name, use:
     <pre>ldaps://server/</pre>
    </li>
    <li><tt>TLS</tt>: instead of a server name, use:
     <pre>ldap+tls://server/</pre>
     you can also set any of the parameters needed by Net::LDAP start_tls
     function:
     <pre>ldap+tls://server/?verify=none&amp;capath=/etc/ssl</pre>
     See Net::LDAP(3) manual page to know all available parameters.
     You can also set caPath or caFile parameters in the new() function when
     building the portal (because they should depend on local file system).
    </li>
   </ul>
  </li>
  <li>Server port: only used if no LDAP URI used in Server host</li>
  <li>Users search base: DN of users branch. Example:
  <pre>dc=example, dc=com</pre>
  </li>
  <li>Account: optional, must be set if anonymous connection cannot
   access to the wanted LDAP attributes. This account is used before LDAP
   authentication to find user DN. It is also used for password modification.
   </li>
  <li>Password: password corresponding to the account above.
</ul>
EOT
}

# fr
sub help_ldap_fr {
    print <<EOT;
<h3>Paramètres LDAP</h3>
<ul>
  <li>Hôte: Nom(s) (ou adresse(s) IP) du(des) serveur(s) LDAP.
   Vous pouvez indiquer plusieurs serveurs ici séparés par des
   virgules et/ou des espaces. Ils seront testés dans l'ordre
   indiqué. Vous pouvez également utiliser des connexions
   chiffrées&nbsp;:
   <ul>
    <li><tt>LDAPS</tt> : au lieu de noms de serveurs, indiquez ici&nbsp;:
     <pre>ldaps://serveur/</pre>
    </li>
    <li><tt>TLS</tt> : au lieu de noms de serveurs, indiquez ici&nbsp;:
     <pre>ldap+tls://serveur/</pre>
     vous pouvez également y ajouter tous les paramètres
     demandés par la fonction start_tls de Net::LDAP&nbsp;:
     <pre>ldap+tls://serveur/?verify=none&amp;capath=/etc/ssl</pre>
     Reportez-vous à la page de manuel de Net::LDAP(3) pour
     connaître les paramètres disponibles.
     Vous pouvez également utiliser les paramètres caPath ou
     caFile lors de la construction du portail dans la fonction new() (car
     ils peuvent dépendre du système de fichier local).
    </li>
   </ul>
  </li>
  <li>Port: utilisé seulement si l'hôte n'est pas une URI LDAP</li>
  <li>Base de recherche des utilisateurs: DN de la branche des utilisateurs.
  Exemple&nbsp;:
  <pre>dc=example, dc=com </pre></li>
  <li>Compte de connexion LDAP: optionnel, à renseigner si les
   attributs LDAP utilisés ne sont pas accessibles par une session
    anonyme. Ce compte est utilisé avant l'authentification pour trouver
    le dn de l'utilisateur. Il est également utilisé pour la modification du mot de passe.
   </li>
  <li>Mot de passe LDAP: mot de passe correspondant au compte ci-dessus.
</ul>
EOT
}

## macros
# en
sub help_macros_en {
    print <<EOT;
<h3>Macros</h3>
<p> Macros are used to add new variables to user variables attributes. Those
new variables are calculated from other variables issued from user attributes.
They can be used anywhere and are seen as normal attributes.
This mechanism avoid to do more than one time the same operation in the
authentication phase. Example:</p>
<pre>
    # macros
    long_name =&gt; \$givenname . " " . \$surname
    admin     =&gt; \$uid eq "foo" or \$uid eq "bar"
    
    # test.example.com - Headers
    Name      =&gt; \$long_name
    
    # test.example.com - Rules
    ^/admin/ =&gt; \$admin
</pre>

<h4>Tips</h4>

<h5>Redefining attributes</h5>
<p>You can create a macro with the same name than an exported value. If so,
the attribute is redefined. Example:</p>
<pre>
    uid =&gt; $uid . "\\\@domain.com"
</pre>

<h5>Using regural expressions</h5>

<p>Suppose you want to extract the string 'admin' or 'user' in an attribute,
in Perl, you can use <tt>\$mail&nbsp;=~&nbsp;s/^.*(user|admin)/\$1/</tt>. To
use it in Lemonldap::NG, you have to do the following&nbsp;:</p>
<pre>
    mail =&gt; (\$mail =~ /(user|admin)/)[0]
</pre>
<p>Explanation: <tt>\$mail =~ /(user|admin)/</tt> returns 0 or 1, but
<tt>(\$mail =~ /(user|admin)/)</tt> is a "list context" so it returns an array
containing all elements recognized. So <tt>(\$mail =~ /(user|admin)/)[0]</tt>
returns the first element.</p>
EOT
}

# fr
sub help_macros_fr {
    print <<EOT;
<h3>Macros</h3>
<p>Les macros permettent d'ajouter des variables calculées à
partir des attributs de l'utilisateur (variables exportées). Elles sont ensuite vues
comme des attributs classiques.
Elles évitent de répéter le même calcul plusieurs
fois dans la phase d'authentification. Exemple&nbsp;:</p>
<pre>
    # macros
    nom_complet =&gt; \$givenname . " " . \$surname
    admin =&gt; \$uid eq "foo" or \$uid eq "bar"
    
    # test.example.com - En-t&ecirc;tes
    Nom =&gt; \$nom_complet
    
    # test.example.com - R&egrave;gles
    ^/admin/ =&gt; \$admin
</pre>

<h4>Astuces</h4>

<h5>Redéfinir les attributs</h5>
<p>Une macro peut porter le même nom qu'un attribut exporté. 
Si c'est la cas, l'attribut est redéfini. Exemple&nbsp;:</p>
<pre>
    uid =&gt; $uid . "\\\@domain.com"
</pre>

<h5>Utilisation des expressions régulières</h5>

<p>En supposant que l'on souhaite extraire la chaîne 'admin' ou 'user' d'un attribut,
en Perl, on peut utiliser <tt>\$mail&nbsp;=~&nbsp;s/^.*(user|admin)/\$1/</tt>. Pour
l'utiliser dans Lemonldap::NG, il faut faire&nbsp;:</p>
<pre>
    mail =&gt; (\$mail =~ /(user|admin)/)[0]
</pre>
<p>Explication&nbsp;: <tt>\$mail =~ /(user|admin)/</tt> retourne 0 ou 1, mais
<tt>(\$mail =~ /(user|admin)/)</tt> est un contexte de liste donc il retourne un tableau
contenant tous les éléments reconnus. Donc <tt>(\$mail =~ /(user|admin)/)[0]</tt>
renvoie le premier élément.</p>
EOT
}

## storage
# en
sub help_storage_en {
    print <<EOT;
<h3>Sessions Storage</h3>
<p>Lemonldap::NG sessions storage works with modules that inherits from
Apache::Session. You have to set here the choosen module and add the
corresponding parameters.</p>
<p>Examples:</p>
<ul>
  <li>Module <tt>Apache::Session::File</tt>:
  <pre>Directory =&gt; /var/lib/lemonldap-ng/sessions</pre>
  </li>
  <li>Module <tt>Apache::Session::MySQL</tt>:
      <pre>
      DataSource =&gt; DBI:mysql:database=lemon;host=1.2.3.4
      UserName =&gt; Lemonldap
      Password =&gt; mypass
      </pre>
  </li>
</ul>
EOT
}

# fr
sub help_storage_fr {
    print <<EOT;
<h3>Stockage des sessions</h3>
<p>Le stockage des sessions Lemonldap::NG est réalisé au travers
des modules hérités de Apache::Session. Vous devez indiquer ici
le module choisi et les paramètres correspondants.</p>
<p>Exemples&nbsp;:</p>
<ul>
  <li>Module <tt>Apache::Session::File</tt>:
      <pre> Directory =&gt; /var/lib/lemonldap-ng/sessions</pre>
  </li>
  <li>Module <tt>Apache::Session::MySQL</tt>:
      <pre>
      DataSource =&gt; DBI:mysql:database=lemon;host=1.2.3.4
      UserName =&gt; Lemonldap
      Password =&gt; mypass
      </pre>
  </li>
</ul>
EOT
}

## timeout
# en
sub help_timeout_en {
    print <<EOT;
<h3>Sessions timeout</h3>
<p> Set here the sessions timeout in seconds. It will be used by the
<tt>purgeCentralStorage</tt> script installed in cron directory.</p>
<p class="info">The timeout does not take into account user activity. A timeout of 2 hours
will close a session 2 hours after its creation, even if user is still using it.</p>
EOT
}

# fr
sub help_timeout_fr {
    print <<EOT;
<h3>Durée de vie des sessions</h3>
<p>Indiquez ici la durée de vie des sessions en secondes. Elle est
utilisée par le script <tt>purgeCentralStorage</tt> installé dans le cron.</p>
<p class="info">La durée de vie ne tient pas compte de l'activité de l'utilisateur. Une durée
de vie de 2 heures fermera la session 2 heures après sa création, même si l'utilisateur est
toujours en train de l'utiliser.</p>
EOT
}

## timeoutActivity
# en
sub help_timeoutActivity_en {
    print <<EOT;
<h3>Sessions activity timeout</h3>
<p> Set here the sessions activity timeout in seconds. It will be used by the
<tt>purgeCentralStorage</tt> script installed in cron directory.</p>
<p class="info">The activity timeout takes into account user activity. A activity timeout of
15 minutes will close a session 15 minutes after last user activity.</p>
EOT
}

# fr
sub help_timeoutActivity_fr {
    print <<EOT;
<h3>Délai d'inactivité des sessions</h3>
<p>Indiquez ici le délai d'inactivité des sessions en secondes. Il est
utilisée par le script <tt>purgeCentralStorage</tt> installé dans le cron.</p>
<p class="info">Le délai d'inactivité des sessions tient compte de l'activité de l'utilisateur.
Un délai d'inactivité de 15 minutes fermera la session 15 minutes après la dernière activité de l'utilisateur.</p>
EOT
}

## vars
# en
sub help_vars_en {
    print <<EOT;
<h3>Exported variables</h3>
<p>Set here the attributes that will be collected from <tt>userDb</tt></p>
<p>Declare as the following:</p>
<pre>MyName =&gt; real_attribute_name</pre>
<p>Examples:</p>
<pre>
  uid   =&gt; uid
  unit  =&gt; ou
</pre>
<p>Declared names can be used in rules, groups, macros and HTTP headers by using
them with '\$'. Example:
<pre>
  group1 =&gt; \$uid eq 'user1' or \$uid eq 'user2'
</pre>
EOT
}

# fr
sub help_vars_fr {
    print <<EOT;
<h3>Variables exportées</h3>
<p>Indiquez ici tous les attributs qui seront collectés depuis <tt>userDB</tt></p>
<p>La déclaration d'une variable se fait sous la forme&nbsp;:</p>
<pre>  MonNom =&gt; nom_reel_attribute</pre>
<p>Exemples&nbsp;:</p>
<pre>
  uid  =&gt; uid
  unite  =&gt; ou
</pre>
<p>Les noms déclarés s'utilisent ensuite dans les règles, les
groupes, les macros ou les en-têtes HTTP en les faisant
précéder du signe '\$'. Exemple&nbsp;:
<pre>
  group1 =&gt; \$uid eq 'user1' or \$uid eq 'user2'
</pre>
EOT
}

## virtualHosts
# en
sub help_virtualHosts_en {
    print <<EOT;
<h3>Virtual Hosts</h3>
<p>A virtual host configuration is cutted in 2 pieces: the rules and the
HTTP headers.</p>
<p class="info">If portal and Handlers are not in the same domain than declared
in <tt>General Parameters</tt> menu, active Cross-Domain Authenticatin functionnality.
Else, session cookie is not seen by Handlers.

<h4>Rules</h4>
<p>A rule associates a regular expression with a perl boolean expression.
When a user tries to access to an URL that match with the regular expression,
access is granted or not depending on the boolean expression result:</p>
<pre>
  # Virtual host test.example.com - rules
  ^/protected =&gt; \$groups =~ /\\bgroup1\\b/
</pre>

<p>This rule means that all URL starting with <tt>/protected</tt> are reserved to
users member of <tt>group1</tt>. You can also use <tt>accept</tt>, <tt>deny</tt> and <tt>unprotect</tt>
keywords</p>
<ul>
 <li><tt>accept</tt>: all authenticated users are granted,</li>
 <li><tt>deny</tt>: no one is granted,</li>
 <li><tt>unprotect</tt>: authenticaion not required.</li>
</ul>

<p>If URL doesn't match any regular expression, <tt>default</tt> rule is called to
grant or not.</p>

<h5>Logout</h5>
<p>You can also write Logout rules to intercept application logout url using the
reserved words:</p>
<ul>
 <li><tt>logout_sso URL</tt>: the request generates a redirection to the portal to call
  logout mechanism. The request is not given to the application so its logout
  function is not called. After logout, the user is redirected to the URL,</li>
 <li><tt>logout_app URL</tt> (Apache-2.x only)  the request is transmitted to the
  application, but the result is not displayed: the user is redirected to the
  URL,</li>
 <li><tt>logout_app_sso URL</tt> (Apache-2.x only): the request is transmitted to the
  application and then, the user is redirected to the portal with the logout
  call and then, he is redirected to the given URL.</li>
</ul>

<h4>Headers</h4>
<p>Headers are used to inform the remote application on the connected user.
They are declared as:</p>
<pre>&lt;Header Name&gt;&nbsp;=&gt;&nbsp;&lt;Perl expression&gt;.</pre>

<p>Examples:</p>
<pre>
  Auth-User =&gt; \$uid
  Unite     =&gt; \$departmentUID
</pre>
EOT
}

# fr
sub help_virtualHosts_fr {
    print <<EOT;
<h3>Hôtes virtuels</h3>

<p> La configuration d'un hôte virtuel est divisée en 2
parties&nbsp;: les règles et les en-têtes HTTP.</p>

<p class="info"> Pour que le mécanisme d'authentification fonctionne,
tous les hôtes virtuels et le portail doivent se trouver dans le domaine
déclaré dans les paramètres généraux ou alors il faut activer la fonction
Cross-Domain-Authentication.</p>

<h4>Règles</h4>
<p>Une règle associe une expression régulière perl
à une expression booléenne. Lors de l'accès d'un
utilisateur, si l'URL demandée correspond à la règle, le
droit d'accès est calculé par l'expression booléenne.
Exemple&nbsp;:</p>
<pre>
  # Hôte virtuel test.example.com - règles
  ^/protected =&gt; \$groups =~ /\\bgroup1\\b/
</pre>

<p>La règle ci-dessus signifie que pour les URL commençant par
<tt>/protected</tt>, les utilisateurs doivent appartenir au groupe <tt>group1</tt>.
Vous pouvez également utiliser les mots-clefs <tt>accept</tt>, <tt>deny</tt> et
<tt>unprotect</tt>:</p>
<ul>
 <li><tt>accept</tt>: tous les utilisateurs authentifiés peuvent accéder,</li>
 <li><tt>deny</tt>: personne ne peut accéder,</li>
 <li><tt>unprotect</tt>: l'authentification n'est pas obligatoire.</li>
</ul>

<p>Si l'URL demandée ne correspond à aucune des expressions
régulières, le droit d'accès est calculé à
partir de l'expression booléenne définie dans la règle par
défaut (<tt>default</tt>).</p>

<h5>Déconnexion</h5>
Vous pouvez également écrire des règles pour intercepter
les URL de déconnexions des applications en utilisant les
mots-clefs&nbsp;:
<ul>
 <li><tt>logout_sso URL</tt> : la requête entraîne une redirection vers le portail
  avec l'appel au système de déconnexion. La requête n'est
  pas transmise à l'application. Après déconnexion,
  l'utilisateur est renvoyé vers l'URL,</li>
 <li><tt>logout_app URL</tt> (Apache-2.x seulement) : la requête est transmise
  à l'applications mais le résultat n'est pas
  affiché&nbsp;: l'utilisateur est redirigé vers l'URL,</li>
 <li><tt>logout_app_sso URL</tt> (Apache-2.x seulement) : la requête est transmise
  à l'application et ensuite, l'utilisateur est redirigé vers le
  portail avec appel au système de déconnexion. Il est ensuite
  redirigé vers l'URL.</li>
</ul>

<h4>En-têtes</h4>

<p>Les en-têtes permettant à l'application de savoir qui est
connecté se déclarent comme suit&nbsp;:</p>
<pre>&lt;nom de l'en-t&ecirc;te&gt; =&gt; &lt;expression Perl&gt;.</pre>

<p>Exemples :</p>
<pre>
  Auth-User =&gt; \$uid
  Unite     =&gt; \$departmentUID
</pre>
EOT
}

## whatToTrace
# en
sub help_whatToTrace_en {
    print <<EOT;
<h3>User name in Apache</h3>
<p>Set here the name of the variable (attribute) or macro that has to be used
in protected application Apache logs (don't forget "\$").</p>
<p class="info">This value will be pushed in <tt>REMOTE_USER</tt> environment variable.</p>
<p class="default">Default value: \$uid</p>
EOT
}

# fr
sub help_whatToTrace_fr {
    print <<EOT;
<h3>Nom de l'utilisateur dans Apache</h3>
<p>Indiquez ici le nom de la variable (attribut) ou de la macro qui doit
être utilisée pour alimenter les journaux Apache des applications
protégées (n'oubliez pas le "\$").</p>
<p class="info">Cette valeur sera inscrite dans la variable d'environnement <tt>REMOTE_USER</tt>.</p>
<p class="default">Valeur par défaut : \$uid</p>
EOT
}

## portalForceAuthn
# en
sub help_portalForceAuthn_en {
    print <<EOT;
<h3>Force authentication on portal</h3>
<p>By default, once user is authenticated on portal, when he comes back to it, the authentication is kept and the menu is displayed.</p>
<p>Enabling this option will force the user to reauthenticate, and its session will be updated.</p>
<p class="info">ID and start date of the session are not modified. The update date is added in field <tt>updateDate</tt>. Other informations are updated.</p>
<p class="default">Default value: 0</p>
EOT
}

#fr
sub help_portalForceAuthn_fr {
    print <<EOT;
<h3>Forcer l'authentification sur le portail</h3>
<p>Par défaut, lorsqu'un utilisateur est authentifié sur le portail, lorsqu'il y revient son authentification est conservée et le menu est affiché.</p>
<p>L'activation de cette option forcera l'utilisateur à s'authentifier de nouveau et sa session sera alors mise à jour.</p>
<p class="info">L'identifiant et la date de création de la session ne sont pas modifiés. La date de mise à jour est indiquée dans le champ <tt>updateDate</tt>. Les autres informations son mises à jour.</p>
<p class="default">Valeur par défaut : 0</p>
EOT
}

## default
# en
sub help_default_en {
    print <<EOT;
<h3>Welcome on configuration manager</h3>
<p>Parameters are listed in the configuration tree under different categories:
<ul>
<li>General parameters</li>
<li>Variables</li>
<li>Virtual hosts</li>
<li>SAML2 service</li>
<li>SAML2 identity providers</li>
</ul>
</p>
<p>Select a category to display parameters and sub categories.</p>
<p>Click on <tt>Save</tt> button to register modifications.</p>
<p class="info">This interface concerns the global configuration. All parameters can be overriden in the local configuration file named <tt>lemonldap-ng.ini</tt>.</p>
EOT
}

# fr
sub help_default_fr {
    print <<EOT;
<h3>Bienvenue sur le gestionnaire de configuration</h3>
<p>Les paramètres sont listés dans l'arbre de configuration sous différentes catégories :
<ul>
<li>Paramètres généraux</li>
<li>Variables</li>
<li>Hôtes virtuels</li>
<li>Service SAML2</li>
<li>Fournisseurs d'identité SAML2</li>
</ul>
<p>Chosir une catégorie pour afficher les paramètres et sous catégories.</p>
<p>Cliquer sur le bouton <tt>Sauvegarder</tt> pour enregistrer les modifications.</p>
<p class="info">Cette interface concerne la configuration globale. Tous les paramètres peuvent être surchargés dans le fichier local de configuration nommé <tt>lemonldap-ng.ini</tt>.</p>
EOT
}

## saml
# en
sub help_saml_en {
    print <<EOT;
<h3>SAML</h3>
<p>LemonLDAP::NG is SAML compliant, and can be used as:
<ul>
<li>SAML Service Provider:
<ul>
<li>authentication => SAML</li>
<li>userDB => SAML</li>
</ul>
</li>
<li>SAML Identity Provider:
<ul>
<li>issuerDB => SAML</li>
</ul>
</li>
</ul>
<p class="info">SAML features requires <a href="http://lasso.entrouvert.org" alt="Lasso">Lasso</a> module.</p>
EOT
}

# fr
sub help_saml_fr {
    print <<EOT;
<h3>SAML</h3>
<p>LemonLDAP::NG est compatible SAML, et peut être utilisé en tant que :
<ul>
<li>Fournisseur de service SAML :
<ul>
<li>authentication => SAML</li>
<li>userDB => SAML</li>
</ul>
</li>
<li>Fournisseur d'identité SAML :
<ul>
<li>issuerDB => SAML</li>
</ul>
</li>
</ul>
<p class="info">L'activation du SAML nécessite le module <a href="http://lasso.entrouvert.org" alt="Lasso">Lasso</a>.</p>
EOT
}

## samlServicePrivateKeySig
# en
sub help_samlServicePrivateKeySig_en {
    print <<EOT;
<h3>SAML service private key for signature</h3>
<p>Load here the service private key in PEM format.</p>
<p>Example:</p>
<pre>
-----BEGIN RSA PRIVATE KEY-----
MIIBOgIBAAJBANZ2b5wb43eJRYnln2bfo+neq6ZQYksmFtn3juDB/UklfwVN0XPi
8NBHXFQjfXPeVse6Ztjl+C443jRCkSawVZMCAwEAAQJBALO56WrADG5+waIApwdF
YE575wmnz9f+gaQEzN4adDM5CgKplp5a5HUxinkLSMuYHNW7E8sh27A6wsF8zeiZ
9mECIQD1kno1Y9st1NtGsrK9yXL55oTbXD7cdx1m4c2i+5E+WQIhAN+Rx065mJuh
2nsZ7FESLorDzpdrI0SvuNAUI5+7uG3LAiBRvR28Y65yxOTv1U81aLZCg/443a12
yJcaxZIi68VekQIgUTljUcS4HwLkn4jBhIq4gg21humTvKai3GYUszm+PZUCIDnR
X1EobS0/HFKASpX7GG4VTi9Rbd5jWbM5ZfSlCjLJ
-----END RSA PRIVATE KEY-----
</pre>
<p class="info">The corresponding public key or certificate must be loaded inside SAML service metadata.</p>
EOT
}

# fr
sub help_samlServicePrivateKeySig_fr {
    print <<EOT;
<h3>Clé privée de signature du service SAML</h3>
<p>Charger ici la clé privé du service au format PEM.</p>
<p>Exemple :</p>
<pre>
-----BEGIN RSA PRIVATE KEY-----
MIIBOgIBAAJBANZ2b5wb43eJRYnln2bfo+neq6ZQYksmFtn3juDB/UklfwVN0XPi
8NBHXFQjfXPeVse6Ztjl+C443jRCkSawVZMCAwEAAQJBALO56WrADG5+waIApwdF
YE575wmnz9f+gaQEzN4adDM5CgKplp5a5HUxinkLSMuYHNW7E8sh27A6wsF8zeiZ
9mECIQD1kno1Y9st1NtGsrK9yXL55oTbXD7cdx1m4c2i+5E+WQIhAN+Rx065mJuh
2nsZ7FESLorDzpdrI0SvuNAUI5+7uG3LAiBRvR28Y65yxOTv1U81aLZCg/443a12
yJcaxZIi68VekQIgUTljUcS4HwLkn4jBhIq4gg21humTvKai3GYUszm+PZUCIDnR
X1EobS0/HFKASpX7GG4VTi9Rbd5jWbM5ZfSlCjLJ
-----END RSA PRIVATE KEY-----
</pre>
<p class="info">La clé publique ou le certificat correspondant doit être chargé dans les metadonnées du service.</p>
EOT
}

## samlServicePrivateKeyEnc
# en
sub help_samlServicePrivateKeyEnc_en {
    print <<EOT;
<h3>SAML service private key for encryption</h3>
<p>Load here the service private key in PEM format. If empty, Lemonldap::NG will use the SAML service private key for signature.</p>
<p>Example:</p>
<pre>
-----BEGIN RSA PRIVATE KEY-----
MIIBOgIBAAJBANZ2b5wb43eJRYnln2bfo+neq6ZQYksmFtn3juDB/UklfwVN0XPi
8NBHXFQjfXPeVse6Ztjl+C443jRCkSawVZMCAwEAAQJBALO56WrADG5+waIApwdF
YE575wmnz9f+gaQEzN4adDM5CgKplp5a5HUxinkLSMuYHNW7E8sh27A6wsF8zeiZ
9mECIQD1kno1Y9st1NtGsrK9yXL55oTbXD7cdx1m4c2i+5E+WQIhAN+Rx065mJuh
2nsZ7FESLorDzpdrI0SvuNAUI5+7uG3LAiBRvR28Y65yxOTv1U81aLZCg/443a12
yJcaxZIi68VekQIgUTljUcS4HwLkn4jBhIq4gg21humTvKai3GYUszm+PZUCIDnR
X1EobS0/HFKASpX7GG4VTi9Rbd5jWbM5ZfSlCjLJ
-----END RSA PRIVATE KEY-----
</pre>
<p class="info">The corresponding public key or certificate must be loaded inside SAML service metadata.</p>
EOT
}

# fr
sub help_samlServicePrivateKeyEnc_fr {
    print <<EOT;
<h3>Clé privée de chiffrement du service SAML</h3>
<p>Charger ici la clé privé du service au format PEM. Si non définie, Lemonldap::NG utilisera la clé privé de signature du service SAML.</p>
<p>Exemple :</p>
<pre>
-----BEGIN RSA PRIVATE KEY-----
MIIBOgIBAAJBANZ2b5wb43eJRYnln2bfo+neq6ZQYksmFtn3juDB/UklfwVN0XPi
8NBHXFQjfXPeVse6Ztjl+C443jRCkSawVZMCAwEAAQJBALO56WrADG5+waIApwdF
YE575wmnz9f+gaQEzN4adDM5CgKplp5a5HUxinkLSMuYHNW7E8sh27A6wsF8zeiZ
9mECIQD1kno1Y9st1NtGsrK9yXL55oTbXD7cdx1m4c2i+5E+WQIhAN+Rx065mJuh
2nsZ7FESLorDzpdrI0SvuNAUI5+7uG3LAiBRvR28Y65yxOTv1U81aLZCg/443a12
yJcaxZIi68VekQIgUTljUcS4HwLkn4jBhIq4gg21humTvKai3GYUszm+PZUCIDnR
X1EobS0/HFKASpX7GG4VTi9Rbd5jWbM5ZfSlCjLJ
-----END RSA PRIVATE KEY-----
</pre>
<p class="info">La clé publique ou le certificat correspondant doit être chargé dans les metadonnées du service.</p>
EOT
}

