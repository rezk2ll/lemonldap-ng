# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Manager.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 11;
BEGIN { use_ok('Lemonldap::NG::Manager') }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

$ENV{SCRIPT_NAME}          = "__SCRIPTNAME__";
$ENV{SCRIPT_FILENAME}      = $0;
my $h;
@ARGV = ("help=groups");
ok(
    $h = new Lemonldap::NG::Manager(
    {
	configStorage => {
	    type    => 'File',
	    dirName => ".",
	},
	dhtmlXTreeImageLocation => "/imgs/",
	jsFile => 'example/lemonldap-ng-manager.js',
    }
    )
);
ok( $h->header_public() );
ok( $h->start_html() );
ok( $h->main() );
ok( $h->end_html() );
ok( $h->print_css() );
ok( $h->print_lmjs() );
ok( $h->print_help() );
ok( $h->buildTree() );
my $tmp = &xml;
ok( ref( $h->tree2conf( \$tmp ) ) );

sub xml {
    return << 'EOF';
<root><text>Configuration 9</text>
<generalParameters><text>Paramtres gnraux</text>
<authParams><text>Paramtres d'authentification</text>
<authentication><text>Type d'authentification</text>
<value>ldap</value>
</authentication>
<portal><text>Portail</text>
<value>http://auth.example.com/</value>
</portal>
<securedCookie><text>Cookie scuris (SSL)</text>
<value>0</value>
</securedCookie>
</authParams>
<cookieName><text>Nom du cookie</text>
<value>lemonldap</value>
</cookieName>
<domain><text>Domaine</text>
<value>example.com</value>
</domain>
<exportedVars><text>Attributs LDAP exporter</text>
<cn><text>cn</text>
<value>cn</value>
</cn>
<mail><text>mail</text>
<value>mail</value>
</mail>
<uid><text>uid</text>
<value>uid</value>
</uid>
</exportedVars>
<ldapParameters><text>Paramtres LDAP</text>
<ldapBase><text>Base de recherche LDAP</text>
<value>dc=gendarmerie,dc=defense,dc=gouv,dc=fr</value>
</ldapBase>
<ldapPort><text>Port du serveur LDAP</text>
<value>389</value>
</ldapPort>
<ldapServer><text>Serveur LDAP</text>
<value>localhost</value>
</ldapServer>
<managerDn><text>Compte de connexion LDAP</text>
<value> </value>
</managerDn>
<managerPassword><text>Mot de passe LDAP</text>
<value> </value>
</managerPassword>
</ldapParameters>
<macros><text>Macros</text>
<value>undefined</value>
</macros>
<sessionStorage><text>Stockage des sessions</text>
<globalStorage><text>Module Apache::Session</text>
<value>Apache::Session::File</value>
</globalStorage>
<globalStorageOptions><text>Paramtres du module Apache::Session</text>
<Directory><text>Directory</text>
<value>/tmp</value>
</Directory>
</globalStorageOptions>
</sessionStorage>
</generalParameters>
<groups><text>Groupes d'utilisateurs</text>
<t0><text></text>
<value>undefined</value>
</t0>
</groups>
<virtualHosts><text>Htes virtuels</text>
<auth.example.com><text>auth.example.com</text>
<exportedHeaders_4><text>En-ttes HTTP</text>
<h_5><text>Auth-User</text>
<value>$uid</value>
</h_5>
</exportedHeaders_4>
<locationRules_4><text>Rgles</text>
<r_4><text>default</text>
<value>accept</value>
</r_4>
</locationRules_4>
</auth.example.com>
<test.example.com><text>test.example.com</text>
<exportedHeaders_1><text>En-ttes HTTP</text>
<h_3><text>Auth-User</text>
<value>$uid</value>
</h_3>
</exportedHeaders_1>
<locationRules_1><text>Rgles</text>
<r_1><text>test=no</text>
<value>deny</value>
</r_1>
<r_2><text>default</text>
<value>accept</value>
</r_2>
</locationRules_1>
</test.example.com>
</virtualHosts>
</root>
EOF
}
