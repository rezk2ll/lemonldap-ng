package Lemonldap::NG::Manager;

use strict;

use XML::Simple;
#use AutoLoader qw(AUTOLOAD);
use Lemonldap::NG::Manager::Base;
use Lemonldap::NG::Manager::Conf;

our @ISA = qw(Lemonldap::NG::Manager::Base);

our $VERSION = '0.03';

sub new {
    my($class,$args) = @_;
    my $self = $class->SUPER::new();
    unless($args) {
	print STDERR "parameters are required, I can't start so\n";
	return 0;
    }
    %$self = (%$self,%$args);
    foreach(qw(configStorage dhtmlXTreeImageLocation)) {
        unless($self->{$_}) {
	    print STDERR qq/The "$_" parameter is required\n/;
	    return 0;
        }
    }
    $self->{jsFile} ||= $self->_dir."lemonldap-ng-manager.js";
    unless(-r $self->{jsFile}) {
	print STDERR qq#Unable to read $self->{jsFile}. You have to set "jsFile" parameter to /path/to/lemonldap-ng-manager.js\n#;
    }
    if($self->param('lmQuery')) {
        my $tmp = "print_" . $self->param('lmQuery');
	$self->$tmp;
    }
    else {
	my $datas;
	if($datas = $self->param('POSTDATA')) {
	    $self->print_upload(\$datas);
	}
	else {
	    return $self;
	}
    }
    exit;
}

# LOADED SUBROUTINES
#   HTML, CSS and Javascripts are loaded with Autoload and exported with
#   'Cache-Control: Public'. So it as not to be loaded each time

# Subroutines to make all the work
sub doall {
    my $self = shift;
    print $self->header_public($ENV{SCRIPT_FILENAME});
    print $self->start_html;
    print $self->main;
    print $self->end_html;
}

# CSS and Javascript export
sub print_css {
    my $self = shift;
    print $self->header_public($ENV{SCRIPT_FILENAME}, -type => 'text/css');
    $self->css;
}

sub print_libjs {
    my $self = shift;
    print $self->header_public($self->{jsFile}, -type => 'application/x-javascript');
    open F, $self->{jsFile};
    while(<F>) {
	print;
    }
    close F;
}

sub print_lmjs {
    my $self = shift;
    print $self->header_public($ENV{SCRIPT_FILENAME}, -type => 'text/javascript');
    $self->javascript;
}

# HELP subroutines

sub print_help {
    my $self = shift;
    print $self->header_public($ENV{SCRIPT_FILENAME});
    print "TODO: help";
}

# Configuration download subroutines
sub print_conf {
    my $self = shift;
    print $self->header( -type => "text/xml", '-Cache-Control' => 'private' );
    $self->printXmlConf;
    exit;
}

sub default {
    return {
	cfgNum => 0,
	ldapBase => "dc=example,dc=com",
    }
}

sub printXmlConf {
    my $self = shift;
    my $config = $self->config->getConf();
    $config = $self->default unless($config);
    my $tree   = {
        id   => '0',
        item => {
            id   => 'root',
            open => 1,
            text => "configuration $config->{cfgNum}",
            item => {
                generalParameters => {
                    text => 'Paramètres généraux',
                    item => {
                        exportedVars => {
                            text => "Attributs LDAP à mapper",
                            item => {},
                        },
                        ldapParameters => {
                            text => 'Paramètres LDAP',
                            item => {},
                        },
                        sessionStorage => {
                            text => 'Stockage des sessions',
                            item => {
                                globalStorageOptions => {
                                    text => 'Paramètres du module Apache::Session',
                                }
                            },
                        },
			authParams => {
			    text => "Paramètres d'authentification",
			    item => {},
			},
                    },
                },
                groups       => { text => "Groupes d'utilisateurs", },
                virtualHosts => {
                    text => "Hôtes virtuels",
                    open => 1,
                },
            },
        },
    };
    my $generalParameters = $tree->{item}->{item}->{generalParameters}->{item};
    my $exportedVars = $tree->{item}->{item}->{generalParameters}->{item}->{exportedVars}->{item};
    my $ldapParameters = $tree->{item}->{item}->{generalParameters}->{item}->{ldapParameters}->{item};
    my $sessionStorage = $tree->{item}->{item}->{generalParameters}->{item}->{sessionStorage}->{item};
    my $globalStorageOptions = $tree->{item}->{item}->{generalParameters}->{item}->{sessionStorage}->{item}->{globalStorageOptions}->{item};
    my $authParams = $tree->{item}->{item}->{generalParameters}->{item}->{authParams}->{item};
    $authParams->{authentication} = $self->xmlField( "value", $config->{authentication} || 'ldap', "Type d'authentification" );
    $authParams->{portal} = $self->xmlField( "value", $config->{portal} || 'http://portal/', "Portail" );
    $authParams->{securedCookie} = $self->xmlField( "value", $config->{securedCookie} || 0, "Cookie sécurisé (SSL)" );

    $generalParameters->{domain} = $self->xmlField( "value", $config->{domain} || 'example.com', 'Domaine' );
    $generalParameters->{cookieName} = $self->xmlField( "value", $config->{cookieName} || 'lemonldap', 'Nom du cookie' );

    $sessionStorage->{globalStorage} = $self->xmlField(
        "value",
        $config->{globalStorage} || 'Apache::Session::File',
        'Module Apache::Session'
    );

    $ldapParameters->{ldapServer} = $self->xmlField( "value", $config->{ldapServer} || 'localhost', 'Serveur LDAP' );
    $ldapParameters->{ldapPort} = $self->xmlField( "value", $config->{ldapPort} || 389, 'Port du serveur LDAP' );
    $ldapParameters->{ldapBase} = $self->xmlField( "value", $config->{ldapBase} || ' ', 'Base de recherche LDAP' );
    $ldapParameters->{managerDn} = $self->xmlField( "value", $config->{managerDn} || ' ', 'Compte de connexion LDAP');
    $ldapParameters->{managerPassword} = $self->xmlField( "value", $config->{managerPassword} || ' ', 'Mot de passe LDAP' );

    if ( $config->{exportedVars} ) {
        while ( my ( $n, $att ) = each( %{ $config->{exportedVars} } ) ) {
            $exportedVars->{$n} = $self->xmlField( "both", $att, $n );
        }
    }
    else {
        foreach (qw(mail uid cn)) {
            $exportedVars->{$_} = $self->xmlField( 'both', $_, $_ );
        }
    }

    if ( $config->{globalStorageOptions} ) {
	$tree->{item}->{item}->{generalParameters}->{item}->{sessionStorage}->{item}->{globalStorageOptions}->{item} = {};
        $globalStorageOptions = $tree->{item}->{item}->{generalParameters}->{item}->{sessionStorage}->{item}->{globalStorageOptions}->{item};
        while ( my ( $n, $opt ) = each( %{ $config->{globalStorageOptions} } ) ) {
            $globalStorageOptions->{$n} = $self->xmlField( "both", $opt, $n );
        }
    }
    else {
    }

    my $indice = 1;
    if ( $config->{locationRules} ) {
        $tree->{item}->{item}->{virtualHosts}->{item} = {};
        my $virtualHost = $tree->{item}->{item}->{virtualHosts}->{item};
        while ( my ( $host, $rules ) = each( %{ $config->{locationRules} } ) ) {
            $virtualHost->{$host} = $self->xmlField( "text", 'i', $host );
            my ( $ih, $ir ) =
              ( "exportedHeaders_$indice", "locationRules_$indice" );
            $virtualHost->{$host}->{item} = {
                "$ih" => { text => "Headers", },
                "$ir" => { text => "Règles", },
            };
            while ( my ( $reg, $expr ) = each(%$rules) ) {
                my $type = ( $reg eq 'default' ) ? 'value' : 'both';
                $virtualHost->{$host}->{item}->{$ir}->{item}->{"r_$indice"} =
                  $self->xmlField( $type, $expr, $reg );
                $indice++;
            }
            my $headers = $config->{exportedHeaders}->{$host};
            while ( my ( $h, $expr ) = each(%$headers) ) {
                $virtualHost->{$host}->{item}->{$ih}->{item}->{"h_$indice"} =
                  $self->xmlField( "both", $expr, $h );
                $indice++;
            }
        }
    }
    if ( $config->{groups} ) {
        $tree->{item}->{item}->{groups}->{item} = {};
        my $groups = $tree->{item}->{item}->{groups}->{item};
        while ( my ( $group, $expr ) = each( %{ $config->{groups} } ) ) {
            $groups->{$group} = $self->xmlField( 'both', $expr, $group );
        }
    }
    
    print XMLout( $tree,
        XMLDecl  => "<?xml version='1.0' encoding='iso-8859-1'?>",
        RootName => 'tree',
        KeyAttr  => { item => 'id', username => 'name' },
        NoIndent => 1
    );
}

sub xmlField {
    my ( $self, $type, $value, $text ) = @_;
    $value =~ s/"/\&#34;/g;
    $text  =~ s/"/\&#34;/g;
    return {
        text     => $text,
        aCol     => "#000000",
        sCol     => "#0000FF",
        userdata => [
            { name => 'value', content => $value },
            { name => 'modif', content => $type },
        ],
    };
}

# Upload subroutines
sub print_upload {
    my $self = shift;
    my $datas = shift;
    print $self->header( -type => "text/html" );
    my $tmp = $self->upload($datas);
    if($tmp) {
        print $tmp;
    }
    else {
	print 0;
    }
}

sub upload {
    my($self, $tree) = @_;
    $tree   = XMLin($$tree);
    my $config = {};
    while ( my ( $g, $h ) = each( %{ $tree->{groups} } ) ) {
        next unless ( ref($h) );
        $config->{groups}->{$h->{text}} = $h->{value};
    }
  VH: while ( my ( $vh, $h ) = each( %{ $tree->{virtualHosts} } ) ) {
        next VH unless ( ref($h) );
        my $lr;
        my $eh;
        foreach ( keys(%$h) ) {
            $lr = $h->{$_} if ( $_ =~ /locationRules/ );
            $eh = $h->{$_} if ( $_ =~ /exportedHeaders/ );
        }
      LR: foreach my $r ( values(%$lr) ) {
            next LR unless ( ref($r) );
            $config->{locationRules}->{$vh}->{ $r->{text} } = $r->{value};
        }
      EH: foreach my $h ( values(%$eh) ) {
            next EH unless ( ref($h) );
            $config->{exportedHeaders}->{$vh}->{ $h->{text} } = $h->{value};
        }
    }
    $config->{cookieName} = $tree->{generalParameters}->{cookieName}->{value};
    $config->{domain}     = $tree->{generalParameters}->{domain}->{value};
    $config->{globalStorage} = $tree->{generalParameters}->{sessionStorage}->{globalStorage}->{value};
    while ( my ( $v, $h ) = each( %{$tree->{generalParameters}->{sessionStorage}->{globalStorageOptions}})) {
        next unless ( ref($h) );
        $config->{globalStorageOptions}->{$v} = $h->{value};
    }
    foreach (qw(ldapBase ldapPort ldapServer managerDn managerPassword)) {
	$config->{$_} = $tree->{generalParameters}->{ldapParameters}->{$_}->{value};
	$config->{$_} = '' if(ref($config->{$_}));
	$config->{$_} =~ s/^\s*(.*?)\s*/$1/;
    }
    foreach (qw(authentication portal securedCookie)) {
	$config->{$_} = $tree->{generalParameters}->{authParams}->{$_}->{value};
	$config->{$_} = '' if(ref($config->{$_}));
	$config->{$_} =~ s/^\s*(.*?)\s*/$1/;
    }
    while ( my ( $v, $h ) = each( %{ $tree->{generalParameters}->{exportedVars} } ) ) {
        next unless ( ref($h) );
        $config->{exportedVars}->{$v} = $h->{value};
    }
    return $self->config->saveConf($config);
}

# Internal subroutines
sub _dir {
    my $d=$ENV{SCRIPT_FILENAME};
    $d =~ s#[^/]*$##;
    return $d;
}

sub config {
    my $self = shift;
    return $self->{_config} if $self->{_config};
    $self->{_config} = Lemonldap::NG::Manager::Conf->new($self->{configStorage});
    unless($self->{_config}) {
	die "Configuration not loaded\n";
    }
    return $self->{_config};
}

#1;
#__END__
# Autoload methods go after =cut, and are processed by the autosplit program.

=head1 NAME

Lemonldap::NG::Manager - Perl extension for managing Lemonldap::NG Web-SSO
system.

=head1 SYNOPSIS

  use Lemonldap::NG::Manager;
  my $h=new Lemonldap::NG::Manager(
      {
        configStorage=>{
            type=>'File',
            dirName=>"/tmp/",
        },
        dhtmlXTreeImageLocation=> "/devel/img/",
        jsFile => /path/to/lemonldap-ng-manager.js,
      }
    ) or die "Unable to start, see Apache logs";

  # Simple
  $h->doall();

=head1 DESCRIPTION

Lemonldap::NG::Manager provides a web interface to manage Lemonldap::NG Web-SSO
system.

=head2 EXPORT

None by default.

=head1 SEE ALSO

L<Lemonldap::NG::Handler>, L<Lemonldap::NG::Portal>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut

sub css {
    my $self = shift;
    print <<EOT;
/* xSplitter Styles */
.clsSplitter
{
  position: absolute;
  overflow: hidden;
  visibility: hidden;
  margin: 0;
  padding: 0;
  background: #FFF;
  border: none;
}

.clsPane
{
  position: absolute;
  overflow: auto;
  visibility: visible;
  margin: 0;
  padding: 0;
  background: #FFF;
  border: none;
}

.clsDragBar
{
  position: absolute;
  overflow: hidden;
  visibility: visible;
  margin: 0;
  padding: 0;
  background: lightgrey;
  border: none;
}

/* Application Styles */

#xBody { overflow: visible; background-color: #FFF; }
.clsTemporaryContainer /* replace this with something like xFenster */
{
  position: relative;
  overflow: visible;
  visibility: visible;
  background: transparent;
  border: none;
}
#idSplitter3 { border: 4px solid lightgrey; }
h3, p { padding: 0 0 0 6px; border: none; }
#buttons { text-align: center; }
#help { text-align: left; }
EOT
}

sub javascript {
    my $self = shift;
    print <<EOT;
var s3,s32;
window.onload=function(){
	var w=X.clientWidth()-12;
	var h=X.clientHeight()-12;
	//var h=window.outerHeight;
	s32=new xSplitter('idSplitter32',0,0,0,0,false,4,3*h/4,h/8,true,0);
	s3=new xSplitter('idSplitter3',0,0,w,h,true,4,w/4,w/8,true,4,null,s32);
	X.addEventListener(window,'resize',win_onresize,false);
	document.body.style.cursor='wait';
	tree=new dhtmlXTreeObject(document.getElementById('treeBox'),"100%","100%",0);
	tree.setImagePath("$self->{dhtmlXTreeImageLocation}");
	tree.setXMLAutoLoading("$ENV{SCRIPT_NAME}?lmQuery=conf");
	tree.loadXML("$ENV{SCRIPT_NAME}?lmQuery=conf");
	tree.setOnClickHandler(onNodeSelect);
	window.setTimeout("document.body.style.cursor='auto'",1000);
};

function win_onresize(){
	var cw=X.clientWidth();
	var w=X.clientWidth()-12;
	var h=X.clientHeight()-12;
	s3.paint(w,h,w/4,w/5);
}

var indice=-1;

function onNodeSelect(nodeId) {
  var k,v;
  if(tree.getUserData(nodeId,"modif")) {
    switch(tree.getUserData(nodeId,"modif")) {
      case 'text':
	k='valeur';
	v='<input value="'+nodeId+'" onChange="tree.setItemText('+"'"+nodeId+"'"+',this.value);tree.changeItemId('+"'"+nodeId+"'"+',this.value);">';
	break;
      case 'both':
	k='<input value="'+tree.getItemText(nodeId)+'" onChange="tree.setItemText('+"'"+nodeId+"'"+',this.value)">';
	v='<textarea cols=40 rows=2 onChange="tree.setUserData('+"'"+nodeId+"'"+','+"'"+'value'+"'"+',this.value)">'+tree.getUserData(nodeId,'value')+'</textarea>';
	//v='<input size=80 name="value" value="'+tree.getUserData(nodeId,'value')+'" onChange="tree.setUserData('+"'"+nodeId+"'"+','+"'"+'value'+"'"+',this.value)">';
	break;
      case 'value':
	k=tree.getItemText(nodeId);
	v='<textarea cols=40 rows=2 onChange="tree.setUserData('+"'"+nodeId+"'"+','+"'"+'value'+"'"+',this.value)">'+tree.getUserData(nodeId,'value')+'</textarea>';
	//v='<input size=80 name="value" value="'+tree.getUserData(nodeId,'value')+'" onChange="tree.setUserData('+"'"+nodeId+"'"+','+"'"+'value'+"'"+',this.value)">';
    }
    document.getElementById('formulaire').style.display='block';
    document.getElementById('name').innerHTML = k;
    document.getElementById('value').innerHTML = v;
  }
  else {
    document.getElementById('formulaire').style.display='none';
  }
  var but='';
  if(nodeIs(nodeId,"virtualHosts")){
    but+=button('Nouvel Hôte Virtuel','newVirtualHost',nodeId);
    if(nodeIs(nodeId,"virtualHost")){
      but+=button('Nouvelle règle','newRule',nodeId);
      but+=button('Nouvel en-tête','newHeader',nodeId);
    }
    help('virtualHosts');
  }
  else if(nodeIs(nodeId,"groups")){
    but+=button('Nouveau groupe','newGroup',nodeId);
    help('groups');
  }
  else if(nodeIs(nodeId,"generalParameters")){
    if(nodeIs(nodeId,"ldapParameters")){
      help('ldap');
    }
    else if(nodeIs(nodeId,"exportedVars")){
      but+=button('Nouvelle variable','newVar',nodeId);
      help('vars');
    }
    else if(nodeIs(nodeId,'sessionStorage')){
      if(nodeIs(nodeId,"globalStorageOptions")){
        but+=button('Nouvelle option','newGSOpt',nodeId);
      }
      help('storage');
    }
  }
  if(tree.getUserData(nodeId,"modif")=='both') but+=button("Supprimer",'deleteNode',nodeId);
  but+=button('Sauvegarder','saveConf');
  document.getElementById('buttons').innerHTML = but;
}

function nodeIs(id,type) {
  if(id==type)return 1;
  if(id=="root")return 0;
  var next=tree.getParentId(id);
  if(type=="virtualHost" && next=="virtualHosts")return 1;
  return nodeIs(next,type);
}

function vhostId(id){
  var next=tree.getParentId(id);
  if(next=="virtualHosts") return id;
  return vhostId(next);
}

function button(text,func,nodeId){
  return '<input type=button value="'+text+'" onclick="'+func+'('+"'"+nodeId+"'"+')"> &nbsp; ';
}

function insertNewChild(a,b,c) {
  tree.insertNewChild(a,b,c);
  tree.setItemColor(b,"#000000","#0000FF");
}

function newVirtualHost() {
  var rep=prompt("Nouvel hôte virtuel");
  if(rep) {
    insertNewChild('virtualHosts',rep,rep)
    tree.setUserData(rep,'modif','text');
    insertNewChild(rep,rep+'_exportedHeaders','Headers');
    insertNewChild(rep+'_exportedHeaders',rep+'_exportedHeaders_1','Auth-User');
    tree.setUserData(rep+'_exportedHeaders_1','modif','both');
    tree.setUserData(rep+'_exportedHeaders_1','value','\$uid');
    insertNewChild(rep,rep+'_locationRules','Règles');
    insertNewChild(rep+'_locationRules',rep+'_locationRules_default','default');
    tree.setUserData(rep+'_locationRules_default','modif','value');
    tree.setUserData(rep+'_locationRules_default','value','deny');
  }
}

function newValue(id,text,type,value){
  indice--;
  insertNewChild(id,'j_'+indice,text);
  tree.setUserData('j_'+indice,'modif',type);
  tree.setUserData('j_'+indice,'value',value);
  tree.selectItem('j_'+indice,true);
}

function newRule(id){
  var lr=tree.getItemIdByIndex(vhostId(id),1);
  newValue(lr,'New rule','both','deny');
}

function newHeader(id){
  var eh=tree.getItemIdByIndex(vhostId(id),0);
  newValue(eh,'New-Header','both','\$uid');
}

function newGroup(id){
  newValue('groups','New-group','both','');
}

function newVar(id){
  newValue('exportedVars','New-var','both','uid');
}

function newGSOpt(id){
  newValue('globalStorageOptions','New-Opt','both','');
}

function deleteNode(id){
  tree.deleteItem(id);
}

var xhr_object = null; 

if(window.XMLHttpRequest) // Firefox 
  xhr_object = new XMLHttpRequest(); 
else if(window.ActiveXObject) // Internet Explorer 
  xhr_object = new ActiveXObject("Microsoft.XMLHTTP"); 
else { // XMLHttpRequest non supporté par le navigateur 
  alert("Votre navigateur ne supporte pas les objets XMLHTTPRequest: sauvegarde impossible."); 
} 

function help(s){
  xhr_object.open("GET", "$ENV{SCRIPT_NAME}?lmQuery=help&help="+s, true); 
  xhr_object.onreadystatechange = function() { 
    if(xhr_object.readyState == 4) document.getElementById('help').innerHTML=xhr_object.responseText; 
  }
  xhr_object.send(null);
}

function saveConf(){
  var h=tree2txt('root');
  //document.getElementById('help').innerHTML="<pre>"+h+"</pre>";
  xhr_object.open("POST", "$ENV{SCRIPT_NAME}?lmQuery=upload",true);
  xhr_object.setRequestHeader("Content-type", "text/xml");
  xhr_object.setRequestHeader("Content-length", h.length);
  xhr_object.onreadystatechange = function() {
    if(xhr_object.readyState == 4){
      var r=xhr_object.responseText;
      if(r>0) {
	tree.setItemText('root','Configuration '+r);
        document.getElementById('help').innerHTML='<h3>Configuration sauvegardée sous le numéro : '+r+'</h3>';
      }
      else {
        document.getElementById('help').innerHTML='<h3>Échec de la sauvegarde</h3>';
      }
    }
    else  document.getElementById('help').innerHTML='<h3>Échec de la sauvegarde</h3>';
  }
  xhr_object.send(h);
}

function tree2txt(id){
  var s=tree.getSubItems(id);
  var c=s.split(',');
  var r='<'+id+"><text>"+ec(tree.getItemText(id))+"</text>\\n";
  if((!s) || s=='' || c.length==0){
    r+= '<value>'+ec(tree.getUserData(id,'value'))+"</value>\\n";
  }
  else {
    for(var i=0;i<c.length;i++){
      r+=tree2txt(c[i]);
    }
  }
  r+="</"+id+">\\n";
  return r;
}

function ec(s){
  if((!s) || s=='') return s;
  return s.replace(/>/g,'&gt;').replace(/</g,'&lt;');
}
EOT
}

sub start_html {
    my $self = shift;
    my %args = @_;
    $args{'-style'} = [ $args{'-style'} ] if($args{'-style'} and !ref($args{'-style'}));
    push @{$args{'-style'}}, "$ENV{SCRIPT_NAME}?lmQuery=css";
    $args{'-title'} ||= 'Lemonldap::NG Configuration';
    $self->SUPER::start_html(%args);
}

sub main {
    my $self = shift;
    # Lemonldap::Manager javascripts;
    print qq#<script type="text/javascript" src="$ENV{SCRIPT_NAME}?lmQuery=libjs"></script>#;
    print qq#<script type="text/javascript" src="$ENV{SCRIPT_NAME}?lmQuery=lmjs"></script>#;
    # HTML code
    print <<EOT;
  <div id='xBody'>
    <div class="clsTemporaryContainer">
      <div style="visibility: visible;" id="idSplitter3" class="clsSplitter">
        <div style="z-index: 2;" id="gauche" class="clsPane">
	   <div id="treeBox" style="width:200;height:200"></div>
        </div><!-- end Pane -->

        <div style="overflow: hidden; z-index: 2;" id="droit" class="clsPane">
          <div style="visibility: visible;" id="idSplitter32" class="clsSplitter">
            <div style="z-index: 2;" id="haut" class="clsPane">
	     <div id="buttons"></div>
             <div id="formulaire" style="display:none;">
              <form onSubmit="return false">
	       <p></p>
               <table border=1 width="100%" style="empty-cells:show;">
                <tr>
                 <th width=200>Champ</th>
                 <th width=400>Valeur</th>
                </tr>
                <tr>
                 <td>
                  <div id="name">&nbsp;</div>
                 </td>
                 <td>
                  <div id="value">&nbsp;</div>
                 </td>
                </tr>
               </table>
              </form>
             </div>
            </div><!-- end Pane -->

            <div style="z-index: 2;" id="bas" class="clsPane">
	    <div id="help"></div>
            </div><!-- end Pane -->

            <div style="z-index: 1; cursor: n-resize;" id="barre2" class="clsDragBar">
              &nbsp;
            </div>
          </div><!-- end Splitter -->
        </div><!-- end Pane -->

        <div style="z-index: 1; cursor: e-resize;" class="clsDragBar">
          &nbsp;
        </div>
      </div><!-- end Splitter -->
    </div><!-- end TemporaryContainer -->
  </div>
EOT
}

