package Lemonldap::NG::Manager::Help;

use AutoLoader qw(AUTOLOAD);
use UNIVERSAL qw(can);
our $VERSION = '0.33';

sub import {
    my ($caller_package) = caller;
    my $lang = shift;
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
    foreach $h (qw(authParams cookieName domain groups ldap macros storage vars
                   whatToTrace virtualHosts)) {
        *{"${caller_package}::help_$h"} = \&{"help_${h}_$l"};
    }
}

1;
__END__

=pod
=cut
sub help_authParams_en {
    print <<EOT;
<h3>Authentication Parameters</h3>
<dl>
<dt> Authentication type </dt>
<dd> By default,Lemonldap::NG uses ldap authentication scheme. You can change
this by 'SSL' for example.</dd>

<dt> Portal </dt>
<dd> Set here the URL used to authenticate users (portal). The portal has to
inherits from Lemonldap::NG::Portal::SharedConf.</dd>

<dt> Secured cookie (SSL) </dt>
<dd> An authenticated user is known by his cookie. If all (virtual) hosts use
HTTPS, set this value to 1 so the cookie will be protected and will not be
transmitted unless https is used.</dd>
</dl>
EOT
}

sub help_authParams_fr {
    print <<EOT;
<h3>Param&egrave;tres d'authentification</h3>
<dl>
<dt> Type d'authentification </dt>
<dd> Le sch&eacute;ma classique d'authentification Lemonldap::NG consiste &agrave; utiliser une
authentification par LDAP. Vous pouvez changer ceci en "SSL" par exemple.</dd>

<dt> Portail </dt>
<dd> Indiquez ici l'URL ou seront renvoy&eacute;s les utilisateurs non authentifi&eacute;s.
Cette URL doit bien sur correspondre &agrave; un portail utilisant
Lemonldap::NG::Portal::SharedConf.</dd>

<dt> Cookie s&eacute;curis&eacute; (SSL) </dt>
<dd> Une fois authentifi&eacute;, l'utilisateur est reconnu par son cookie. Si tous
les h&ocirc;tes virtuels de votre domaine son prot&eacute;g&eacute;s par SSL, mettez cette option
&agrave; 1, ainsi le cookie ne sera pr&eacute;sent&eacute; par le navigateur qu'aux sites prot&eacute;g&eacute;s,
ce qui &eacute;vite un vol de session.</dd>
</dl>
EOT
}

sub help_cookieName_en {
    print <<EOT;
<h3>Cookie Name</h3>
<p> Set here the name of the cookie ('lemonldap' by default).<br>

WARNING, any change here needs to restart all the Apache servers that use
a Lemonldap::NG::Handler.</p>
EOT
}

sub help_cookieName_fr {
    print <<EOT;
<h3>Nom de cookie</h3>
<p> Indiquez ici le nom du cookie ('lemonldap' par d&eacute;faut).<br>

ATTENTION, tout changement n&eacute;cessite le red&eacute;marrage de tous les serveurs Apache
h&eacute;bergeant des agents de protection Lemonldap::NG::Handler.</p>
EOT
}

sub help_domain_en {
    print <<EOT;
<h3>Protected domain</h3>
<p> Set here the main domain (or sub-domain) protected by Lemonldap::NG. If you
use "Cross domain authentication", set here the domain of the portal.<br>
WARNING : all the virtual hosts that are not under the same domain than the
portal must be protected by handlers that inherits from
Lemonldap::NG::Handler::CDA and if such handlers exist, you have to use
Lemonldap::NG::Portal::CDA.
EOT
}

sub help_domain_fr {
    print <<EOT;
<h3>Domaine prot&eacute;g&eacute;</h3>
<p> Indiquez ici le nom du domaine (ou du sous-domaine) contenant vos
applications &agrave; prot&eacute;ger. Si vous utilisez le "Cross domain
authentication", indiquez ici le domaine du portail<br>
ATTENTION : tous les h&ocirc;tes virtuels prot&eacute;g&eacute;s ne se trouvant
pas dans le m&ecirc;me domaine que le portail doivent &ecirc;tre prot&eacute;g&eacute;s par un agent
h&eacute;ritant de Lemonldap::NG::Handler::CDA et si un seul de ces agents est
utilis&eacute;, le portail doit &ecirc;tre de type Lemonldap::NG::Portal::CDA.
EOT
}

sub help_groups_en {
    print <<EOT;
<h3>User Groups</h3>
<p> Groups are not required but accelerate the treatment of the requests. For
example, if a virtual host is granted only for 3 users, the rule is&nbsp;:</p>
<pre>
    # test.example.com - Rules
    default =&gt; \$uid eq "user1" or \$uid eq "user2" or \$uid eq "user3"
</pre>
<p> The problem is that this rule is calculated for each HTTP request. Other
example, if 2 sites have the same rules, any modification on one has to be
write in the second. The 'groups' system solve this&nbsp;: groups are
evaluated one time in the authentication phase, and the result is stored in the
\$groups variable. The rule abode becomes&nbsp;:</p> 
<pre>
    # Group declaration
    group1 =&gt; \$uid eq "user1" or \$uid eq "user2" or \$uid eq "user3"

    # Use of the group :
    # test.example.com - Rules
    default =&gt; \$groups =~ /\\bgroup1\\b/
</pre>
<p> The last rule is a Perl regular expression (PCRE) that means 'search the
word "group1" in the string "groups"'.</p>
<p> The \$groups string joins all the groups where the user matchs the
expression. The groups are separated by a space in the \$groups string.</p>
EOT
}

sub help_groups_fr {
    print <<EOT;
<h3>Groupes d'utilisateurs</h3>
<p>Les groupes ne sont pas indispensables mais acc&eacute;l&egrave;rent le traitement des
requ&ecirc;tes. Par exemple, si un h&ocirc;te virtuel est autoris&eacute; nominativement &agrave;
user, user2 et user3, la r&egrave;gle d'acc&egrave;s s'&eacute;crira&nbsp;:</p>
<pre>
    # test.example.com - R&egrave;gles
    default =&gt; \$uid eq "user1" or \$uid eq "user2" or \$uid eq "user3"
</pre>
<p> Le probl&egrave;me est que cette expression sera calcul&eacute;e &agrave; chaque requ&ecirc;te HTTP.
D'autre part, si 2 h&ocirc;tes virtuels ont la m&ecirc;me r&egrave;gle d'acc&egrave;s, toute modification
doit &ecirc;tre r&eacute;percut&eacute;e sur les deux h&ocirc;tes virtuels. Le syst&egrave;me des groupes permet
de r&eacute;soudre ces deux probl&egrave;mes&nbsp;: lors de la connexion au portail, les
expressions complexes sont calcul&eacute;es une fois pour toute la session et le
r&eacute;sultat est stock&eacute; dans la cha&icirc;ne \$groups. L'exemple pr&eacute;c&eacute;dent devient
alors&nbsp;:</p>
<pre>
    # D&eacute;claration d'un groupe
    group1 =&gt; \$uid eq "user1" or \$uid eq "user2" or \$uid eq "user3"

    # Utilisation :
    # test.example.com - R&egrave;gles
    default =&gt; \$groups =~ /\\bgroup1\\b/
</pre>
<p> Cette derni&egrave;re expression est une expression r&eacute;guli&egrave;re Perl (PCRE) qui
correspond &agrave; la recherche du mot group1 dans la cha&icirc;ne \$groups (\\b signifie
d&eacute;but ou fin de mot).</p>

<p>La variable export&eacute;e \$groups est une cha&icirc;ne de caract&egrave;res compos&eacute;s de tous les
noms de groupes auquel l'utilisateur connect&eacute; appartient (c'est &agrave; dire les
noms de groupe pour lesquels l'expression est vraie).</p>
EOT
}

sub help_ldap_en {
    print <<EOT;
<h3>LDAP Parameters</h3>
<p>LDAP parameters are used to identify users. They must be set even if
authentication is done by another system (SSL for example).</p>
<ul>
  <li>LDAP base : required (except if your server accepts the requests without
   base). Example&nbsp;:
  <pre>   dc=example, dc=com </pre></li>
  <li>LDAP server port : 389 by default&nbsp;;</li>
  <li>LDAP server : Name (or IP address) of the LDAP server. To use LDAPS, set
   here&nbsp;:
    <pre>   ldaps://server/</pre>
   and don't forget to change port (636 for example)</li>
  <li>LDAP account : optional, must be set if anonymous connection cannot
   access to the wanted LDAP attributes. This account is used before LDAP
   authentication to find user's dn&nbsp;;
   </li>
  <li>LDAP password : password corresponding to the account above.
</ul>
EOT
}

sub help_ldap_fr {
    print <<EOT;
<h3>Param&egrave;tres LDAP</h3>
<p> Les param&egrave;tres LDAP servent &agrave; identifier les utilisateurs.
Ils doivent &ecirc;tre renseign&eacute;s m&ecirc;me si l'authentification est
r&eacute;alis&eacute;e par un autre moyen (SSL par exemple).</p>
<ul>
  <li>Base de recherche LDAP : obligatoire (&agrave; moins que votre serveur LDAP
  accepte les requ&ecirc;tes sans base). Exemple&nbsp;:
  <pre>   dc=example, dc=com </pre></li>
  <li>Port du serveur LDAP : 389 par d&eacute;faut&nbsp;;</li>
  <li>Serveur LDAP : Nom (ou adresse IP) du serveur LDAP. Pour une connexion
      LDAPS, indiquez ici&nbsp;:
      <pre>   ldaps://server/</pre>
      et n'oubliez pas de changer le port (636 en g&eacute;n&eacute;ral)</li>
  <li>Compte de connexion LDAP : optionnel, &agrave; renseigner si les attributs LDAP
    utilis&eacute;s ne sont pas accessibles par une session anonyme. Ce compte est
    utilis&eacute; avant l'authentification pour trouver le dn de l'utilisateur&nbsp;;
   </li>
  <li>Mot de passe LDAP : mot de passe correspondant au compte ci-dessus.
</ul>
EOT
}

sub help_macros_en {
    print <<EOT;
<h3>Macros</h3>
<p> Macros are used to add new variables to user variables attributes). Those
new variables are calculated from other variables issued from LDAP attributes.
This mechanism avoid to do more than one time the same operation in the
authentication phase. Example&nbsp;:</p>
<pre>
    # macros
    long_name => \$givenname . " " . \$surname
    admin     => \$uid eq "foo" or \$uid eq "bar"
    
    # test.example.com - Headers
    Name      => \$long_name
    
    # test.example.com - Rules
    ^/admin/ => \$admin
EOT
}

sub help_macros_fr {
    print <<EOT;
<h3>Macros</h3>
<p> Les macros permettent d'ajouter des variables calcul&eacute;es &agrave;
partir des attributs LDAP (variables export&eacute;es). Elles &eacute;vitent
de r&eacute;p&eacute;ter le m&ecirc;me calcul plusieurs fois dans la phase
d'authentification. Exemple&nbsp;:</p>
<pre>
    # macros
    nom_complet => \$givenname . " " . \$surname
    admin => \$uid eq "foo" or \$uid eq "bar"
    
    # test.example.com - En-t&ecirc;tes
    Nom => \$nom_complet
    
    # test.example.com - R&egrave;gles
    ^/admin/ => \$admin
EOT
}

sub help_storage_en {
    print <<EOT;
<h3>Sessions Storage</h3>
<p> Lemonldap::NG sessions storage works with modules that inherits from
Apache::Session. You have to set here the choosen module and add the
corresponding parameters&nbsp;:</p>
<p>Examples :</p>
<ul>
  <li>Module =&gt; Apache::Session::File, <br>options :
    <ul>
      <li> Directory =&gt; /var/lib/lemonldap-ng/sessions</li>
    </ul>
  </li>
  <li>Module =&gt; Apache::Session::MySQL, <br>options :
    <ul>
      <li> DataSource =&gt; DBI:mysql:database=lemon;host=1.2.3.4</li>
      <li> UserName =&gt; Lemonldap
      <li> Password =&gt; mypass
      <li> timeout =&gt; 7200
    </ul>
  </li>
</ul>
<p>
<b>Note</b>&nbsp;: if you use <tt><b>purgeCentralCache</b></tt> script provided
 in the portal sources (to use in crontab), you can set the <b>timeout</b>
 parameter to manage sessions end (7200 secondes by default).
</p>
EOT
}

sub help_storage_fr {
    print <<EOT;
<h3>Stockage des sessions</h3>
<p> Le stockage des sessions Lemonldap::NG est r&eacute;alis&eacute; au travers des modules
h&eacute;rit&eacute;s de Apache::Session. Vous devez indiquer ici le module choisi et
indiquer les param&egrave;tres correspondants &agrave; ce module&nbsp;:</p>
<p>Exemples :</p>
<ul>
  <li>Module =&gt; Apache::Session::File, <br>options :
    <ul>
      <li> Directory =&gt; /var/lib/lemonldap-ng/sessions</li>
    </ul>
  </li>
  <li>Module =&gt; Apache::Session::MySQL, <br>options :
    <ul>
      <li> DataSource =&gt; DBI:mysql:database=lemon;host=1.2.3.4</li>
      <li> UserName =&gt; Lemonldap
      <li> Password =&gt; mypass
      <li> timeout =&gt; 7200
    </ul>
  </li>
</ul>
<p>
<b>Note</b>&nbsp;: si vous utilisez le script <tt><b>purgeCentralCache</b></tt>
 fourni dans les sources du portail (&agrave; mettre en crontab), vous pouvez ajouter
 le param&egrave;tre <b>timeout</b> pour g&eacute;rer la destruction des sessions (7200
 secondes par d&eacute;faut).
</p>
EOT
}

sub help_vars_en {
    print <<EOT;
<h3>Variables (LDAP attributes)</h3>
<p> Set here the LDAP attributes you need in your configuration or in exported
headers.</p>
<p> Declare as the following&nbsp;:</p>
<pre>  &lt;MyName&gt; =&gt; &lt;real LDAP attribute name&gt;</pre>
<p>Examples :</p>
<pre>
  uid   =&gt; uid
  unit  =&gt; ou
</pre>
Declared names can be used in rules, groups, macros and HTTP headers by using
them with '\$'. Example&nbsp;:
<pre>
  group1 =&gt; \$uid eq 'user1' or \$uid eq 'user2'
</pre>
EOT
}

sub help_vars_fr {
    print <<EOT;
<h3>Variables (attributs LDAP)</h3>
<p> Indiquez ici tous les attributs LDAP dont vous avez besoin dans votre
configuration (pour d&eacute;finir les groupes, les macros, les r&egrave;gles
d'acc&egrave;s aux h&ocirc;tes virtuels ou encore les en-t&ecirc;tes HTTP).</p>
<p>La d&eacute;claration d'une variable se fait sous la forme&nbsp;:</p>
<pre>  &lt;nom declare&gt; =&gt; &lt;nom de l'attribut LDAP&gt;</pre>
<p>Exemples :</p>
<pre>
  uid  =&gt; uid
  unite  =&gt; ou
</pre>
Les noms d&eacute;clar&eacute;s s'utilisent ensuite dans les r&egrave;gles, les
groupes, les macros ou les en-t&ecirc;tes HTTP en les faisant
pr&eacute;c&eacute;der du signe '\$'. Exemple&nbsp;:
<pre>
  group1 =&gt; \$uid eq 'user1' or \$uid eq 'user2'
</pre>
EOT
}

sub help_virtualHosts_en {
    print <<EOT;
<h3>Virtual Hosts</h3>

<p> A virtual host configuration is cutted in 2 pieces&nbsp;: the rules and the HTTP
headers.</p>

<p> <u>Note</u> : If portal and handlers are not in the same domain than declared
in "General Parameters" menu, <u>you have to use</u> CDA modules. Else, session
cookie is not seen by handlers.

<h4> Rules </h4>

<p> A rule associates a regular expression with a perl boolean expression.
When a user tries to access to an URL that match with the regular expression,
access is granted or not depending on the boolean expression result&nbsp;:</p>

<pre>
  # Virtual host test.example.com - rules
  ^/protected =&gt; \$groups =~ /\\bgroup1\\b/
</pre>

<p> This rule means that all URL starting with '/protected', are reserved to
users member of 'group1'. You can also use 'accept' and 'deny' keywords.
'accept' keyword means that all authenticated users are granted.</p>

<p> If URL doesn't match any regular expression, 'default' rule is called to
grant or not.</p>

<h4> Headers </h4>

<p> Headers are used to inform the remote application on the connected user.
They are declared as&nbsp;:
<tt>&lt;Header Name&gt;&nbsp;=&gt;&nbsp;&lt;Perl expression&gt;.
</p>

<p> Examples :</p>

<pre>
  Auth-User =&gt; \$uid
  Unite     =&gt; \$departmentUID
</pre>
EOT
}

sub help_virtualHosts_fr {
    print <<EOT;
<h3>H&ocirc;tes virtuels</h3>

<p> La configuration d'un h&ocirc;te virtuel est divis&eacute;e en 2 parties&nbsp;: les
r&egrave;gles et les en-t&ecirc;tes HTTP export&eacute;s.</p>

<p> <u>Note</u> : pour que le m&eacute;canisme d'authentification fonctionne, tous
les h&ocirc;tes virtuels et le portail doivent se trouver dans le domaine d&eacute;clar&eacute;
dans les param&egrave;tres g&eacute;n&eacute;raux ou <u>utiliser les modules CDA</u>
<i>(Cross-Domain-Authentication)</i> qui g&egrave;re la transmission de l'identifiant.</p>

<h4> R&egrave;gles</h4>

<p>Une r&egrave;gle associe une expression r&eacute;guli&egrave;re perl &agrave; une expression bool&eacute;enne.
Lors de l'acc&egrave;s d'un utilisateur, si l'URL demand&eacute;e correspond &agrave; la r&egrave;gle, le
droit d'acc&egrave;s est calcul&eacute; par l'expression bool&eacute;enne. Exemple&nbsp;:</p>

<pre>
  # H&ocirc;te virtuel test.example.com - r&egrave;gles
  ^/protected =&gt; \$groups =~ /\\bgroup1\\b/
</pre>

<p> La r&egrave;gle ci-dessus signifie que pour les URL commen&ccedil;ant par '/protected',
les utilisateurs doivent appartenir au groupe 'group1'. Vous pouvez &eacute;galement
utiliser les mots-clefs 'accept' et 'deny'. Attention, 'accept' signifie que
tous les utilisateurs authentifi&eacute;s peuvent acc&eacute;der.</p>

<p>Si l'URL demand&eacute;e ne correspond &agrave; aucune des expressions r&eacute;guli&egrave;res, le
droit d'acc&egrave;s est calcul&eacute; &agrave; partir de l'expression bool&eacute;enne d&eacute;finie dans
la r&egrave;gle par d&eacute;faut (default).</p>

<h4> En-t&ecirc;tes</h4>

<p> Les en-t&ecirc;tes servant &agrave; l'application &agrave; savoir qui est connect&eacute; se d&eacute;clarent
comme suit&nbsp;: <tt>&lt;nom de l'en-t&ecirc;te&gt; =&gt; &lt;expression Perl&gt;.
</p>

<p> Exemples :</p>

<pre>
  Auth-User =&gt; \$uid
  Unite     =&gt; \$departmentUID
</pre>
EOT
}

sub help_whatToTrace_en {
    print <<EOT;
<h3>What to log in Apache</h3>
<p> Set here le name of the variable (attribute) or macro that has to be used
in proected application Apache logs (don't forget "\$"). By default&nbsp;:
\$uid</p>
EOT
}

sub help_whatToTrace_fr {
    print <<EOT;
<h3>Donnée à journaliser dans Apache</h3>
<p> Indiquez ici le nom de la variable (attribut) ou de la macro qui doit être
utilisée pour alimenter les journaux Apache des applications protégées
(n'oubliez pas le "\$"). Par défaut&nbsp;: \$uid</p>
EOT
}
