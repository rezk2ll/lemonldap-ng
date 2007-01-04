package Lemonldap::NG::Manager::_HTML;

# This package contains all subroutines that are provided after a
# 'header_public' call. So those functions are called only if the browser
# comes for the first time.

use AutoLoader qw(AUTOLOAD);
our $VERSION = '0.05';

1;
__END__

=pod
=cut
sub css {
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
    $args{'-style'} = { -src => [ $args{'-style'} ] }
      if ( $args{'-style'} and !ref( $args{'-style'} ) );
    push @{ $args{'-style'}->{'-src'} }, "$ENV{SCRIPT_NAME}?lmQuery=css";
    $args{'-title'} ||= 'Lemonldap::NG Configuration';
    $self->CGI::start_html(%args);
}

sub main {

    # Lemonldap::Manager javascripts;
    print
qq#<script type="text/javascript" src="$ENV{SCRIPT_NAME}?lmQuery=libjs"></script>\n#;
    print
qq#<script type="text/javascript" src="$ENV{SCRIPT_NAME}?lmQuery=lmjs"></script>\n#;

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

