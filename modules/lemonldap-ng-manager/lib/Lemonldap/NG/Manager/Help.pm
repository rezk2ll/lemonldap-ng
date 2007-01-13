package Lemonldap::NG::Manager::Help;

use AutoLoader qw(AUTOLOAD);
use UNIVERSAL qw(can);
our $VERSION = '0.21';

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
    foreach $h (qw(virtualHosts groups ldap vars storage macros)) {
        *{"${caller_package}::help_$h"} = \&{"help_${h}_$l"};
    }
}

1;
__END__

=pod
=cut
sub help_virtualHosts_en {
    print <<EOT;
<h3>Virtual Hosts</h3>
EOT
}

sub help_macros_en {
    print <<EOT;
<h3>User Groups</h3>
EOT
}

sub help_groups_en {
    print <<EOT;
<h3>User Groups</h3>
EOT
}

sub help_ldap_en {
    print <<EOT;
<h3>LDAP Parameters</h3>
EOT
}

sub help_vars_en {
    print <<EOT;
<h3>Variables (LDAP attributes)</h3>
EOT
}

sub help_storage_en {
    print <<EOT;
<h3>Sessions Storage</h3>
EOT
}

sub help_virtualHosts_fr {
    print <<EOT;
<h3>H&ocirc;tes virtuels</h3>
<p> La configuration d'un h&ocirc;te virtuel est divis&eacute;e en 2 parties&nbsp;: les
r&egrave;gles et les en-t&ecirc;tes HTTP export&eacute;s.
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

sub help_macros_fr {
    print <<EOT;
<h3>Macros</h3>
<p> Les macros permettent d'ajouter des variables calculées à partir des
attributs LDAP (variables exportées). Elles évitent de répéter le même calcul
plusieurs fois dans la configuration. Exemple&nbsp;:</p>
<pre>
    # macros
    nom_complet => \$givenname . " " . \$surname
    admin => \$uid eq "foo" or \$uid eq "bar"
    
    # test.example.com - En-têtes
    Nom => \$nom_complet
    
    # test.example.com - Règles
    ^/admin/ => \$admin
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
    # D&eacute;claration d'un groupe (on suppose ici que ou est un champ mono-valu&eacute;)
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
noms de groupe pour lesquels l'expression est vraie.</p>
EOT
}

sub help_ldap_fr {
    print <<EOT;
<h3>Param&egrave;tres LDAP</h3>
<p> Le param&egrave;tres LDAP servent &agrave; identifier les utilisateurs. Ils doivent &ecirc;tre
renseign&eacute;s m&ecirc;me si l'authentification est r&eacute;alis&eacute;e par un autre moyen (SSL par
exemple).</p>
<ul>
  <li>Base de recherche LDAP : obligatoire (&agrave; moins que votre serveur LDAP
  accepte les requ&ecirc;tes sans base)&nbsp;; exemple&nbsp;:
  <pre>   dc=example, dc=com </pre></li>
  <li>Port du serveur LDAP : 389 par d&eacute;faut&nbsp;;</li>
  <li>Serveur LDAP : Nom (ou adresse IP) du serveur LDAP&nbsp;;</li>
  <li>Compte de connexion LDAP : optionnel, &agrave; renseigner si les attributs LDAP
    utilis&eacute;s ne sont pas accessibles par une session anonyme. Ce compte est
    utilis&eacute; avant l'authentification pour trouver le dn de l'utilisateur&nbsp;;
   </li>
  <li>Mot de passe LDAP : mot de passe correspondant au compte ci-dessus.
</ul>
EOT
}

sub help_vars_fr {
    print <<EOT;
<h3>Variables (attributs LDAP)</h3>
<p> Indiquez ici tous les attributs LDAP dont vous avez besoin dans votre
configuration (pour d&eacute;finir les groupes, les r&egrave;gles d'acc&egrave;s au h&ocirc;tes virtuels
ou encore les en-t&ecirc;tes HTTP).</p>
<p>La d&eacute;claration d'une variable se fait sous la forme&nbsp;:</p>
<pre>  &lt;nom declare&gt; =&gt; &lt;nom de l'attribut LDAP&gt;</pre>
<p>Exemples :</p>
<pre>
  uid  =&gt; uid
  unite  =&gt; ou
</pre>
Les noms d&eacute;clar&eacute;s s'utilisent ensuite dans les r&egrave;gles, les groupes ou les
en-t&ecirc;tes HTTP en les faisant pr&eacute;c&eacute;der du signe '\$'. Exemple&nbsp;:
<pre>
  group1 =&gt; \$uid eq 'user1' or \$uid eq 'user2'
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
      <li> Directory =&gt; /var/cache/lemonldap</li>
    </ul>
  </li>
  <li>Module =&gt; Apache::Session::MySQL, <br>options :
    <ul>
      <li> DataSource =&gt; DBI:mysql:database=lemon;host=1.2.3.4</li>
      <li> UserName =&gt; Lemonldap
      <li> Password =&gt; mypass
    </ul>
  </li>
</ul>
EOT
}

