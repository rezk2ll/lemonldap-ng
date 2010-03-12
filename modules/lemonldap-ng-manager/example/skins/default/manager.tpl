<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>Lemonldap::NG Manager</title>
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="icon" type="image/x-icon" />
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="shortcut icon" />
<link rel="stylesheet" type="text/css" title="menu" href="<TMPL_VAR NAME="DIR">/<TMPL_VAR NAME="CSS">" />
<link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="DIR">/jquery-ui-1.7.2.custom.css" />
<script src="<TMPL_VAR NAME="DIR">/jquery-1.3.2.min.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/jquery-ui-1.7.2.custom.min.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/jquery.cookie.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/tree.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/ajaxfileupload.js" type="text/JavaScript"></script>
<script type="text/JavaScript">//<![CDATA[
	var scriptname='<TMPL_VAR NAME="SCRIPT_NAME">';
	var imagepath='<TMPL_VAR NAME="DIR">/';
	var treeautoclose='<TMPL_VAR NAME="TREE_AUTOCLOSE">';
	var treejquerycss='<TMPL_VAR NAME="TREE_JQUERYCSS">';
	var text4newKey='<lang en="Key" fr="Clé" />';
	var value4newKey='<lang en="Value" fr="Valeur" />';
	var value4newSamlAttribute='<lang en="Value" fr="Valeur" />';
	var text4newVhost='<lang en="Virtual host name" fr="Nom de l\'hôte virtuel" />';
	var text4newSamlMetaData='<lang en="SAML Metadatas name" fr="Nom des métadatas SAML" />';
	var text4newSamlAttribute='<lang en="Attribute name" fr="Nom de l\'attribut" />';
//]]></script>
<script src="<TMPL_VAR NAME="DIR">/manager.js" type="text/JavaScript"></script>
<meta http-equiv="Content-Type" content="text/html; charset=utf8" />
</head>
<body>

<!-- Container -->
<div id="container" class="ui-widget ui-helper-clearfix">

<!-- Header -->
<div id="header">
   <img alt="Lemonldap::NG" src="<TMPL_VAR NAME="DIR">/logo_lemonldap-ng.png" class="logo" width="200" height="38" />
   <p class="ui-state-default ui-corner-all ui-state-active"><a href="index.pl"><lang en="Configuration management" fr="Gestion de la configuration"/></a></p>
   <p class="ui-state-default ui-corner-all"><a href="sessions.pl"><lang en="Sessions explorer" fr="Explorateur de sessions"/></a></p>
<!-- Header -->
</div>

<!-- Page -->
<div id="page" class="ui-corner-all ui-helper-clearfix ui-widget-content">

<!-- Menu (tree) -->
<div id="menu">
   <!-- Tree CSS choice -->
   <div id="css-switch" class="ui-corner-all ui-widget-content">
      <span><lang en="Menu style" fr="Style de menu" /></span>
      <a href="#" alt="tree"><lang en="Tree" fr="Arbre" /></a>
      <a href="#" alt="accordion"><lang en="Accordion" fr="Accordéon" /></a>
   </div>
   <TMPL_VAR NAME="MENU">
</div>

<!-- Data -->
<div id="data">

   <!-- Buttons -->
   <div id="buttons" class="ui-corner-all">

    <h1 class="ui-widget-header ui-corner-all">
     <lang en="Available actions" fr="Actions disponibles" />
    </h1>

    <div id="buttons_content" class="ui-corner-all ui-widget-content">
    <button id="bsave" onclick="uploadConf()" class="ui-state-default ui-corner-all" >
     <lang en="Save" fr="Sauver" />
    </button>

    <button id="bapply" onclick="$.post(scriptname,{apply:1},function(data){return 1},'html');" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
    </button>

    <button id="bnewvh" style="display:none;" onclick="newVh();return false;" class="ui-state-default ui-corner-all">
     <lang en="New virtual host" fr="Nouvel hôte virtuel" />
    </button>

    <button id="bdelvh" style="display:none;" onclick="delvh(currentId);" class="ui-state-default ui-corner-all">
     <lang en="Delete virtual host" fr="Supprimer l'hôte virtuel" />
    </button>

    <button id="newkbr" style="display:none;" onclick="newKeyR();return false;" class="ui-state-default ui-corner-all">
     <lang en="New key" fr="Nouvelle clef" />
    </button>

    <button id="newrbr" style="display:none;" onclick="newRuleR();return false;" class="ui-state-default ui-corner-all">
     <lang en="New rule" fr="Nouvelle règle" />
    </button>

    <button id="newkb" style="display:none;" onclick="newKey();return false;" class="ui-state-default ui-corner-all">
     <lang en="New key" fr="Nouvelle clef" />
    </button>

    <button id="newrb" style="display:none;" onclick="newRule();return false;" class="ui-state-default ui-corner-all">
     <lang en="New rule" fr="Nouvelle règle" />
    </button>

    <button id="delkb" style="display:none;" onclick="delKey();return false;" class="ui-state-default ui-corner-all">
     <lang en="Delete key" fr="Effacer la clef" />
    </button>

    <button id="newsamlmetadatab" style="display:none;" onclick="newSamlMetaData();return false;" class="ui-state-default ui-corner-all">
     <lang en="New metadatas" fr="Nouvelles métadatas" />
    </button>

    <button id="delsamlmetadatab" style="display:none;" onclick="delSamlMetaData(currentId);" class="ui-state-default ui-corner-all">
     <lang en="Delete metadatas" fr="Supprimer les métadatas" />
    </button>

    <button id="newsamlattributeb" style="display:none;" onclick="newSamlAttribute();return false;" class="ui-state-default ui-corner-all">
     <lang en="New attribute" fr="Nouvel attribut" />
    </button>

    <button id="newsamlattributebr" style="display:none;" onclick="newSamlAttributeR();return false;" class="ui-state-default ui-corner-all">
     <lang en="New attribute" fr="Nouvel attribut" />
    </button>

    <button id="delsamlattributeb" style="display:none;" onclick="delSamlAttribute();return false;" class="ui-state-default ui-corner-all">
     <lang en="Delete attribute" fr="Supprimer l'attribut" />
    </button>
    </div>

   <!-- Buttons -->
   </div>

  
   <!-- Edition -->
   <div id="edition" class="ui-corner-all">

   <form action="#" onsubmit="return false">

    <h1 class="ui-widget-header ui-corner-all">
     <lang en="Edit key " fr="Édition de la clé " />
     <span id="content_title">&nbsp;</span>
    </h1>


   <!-- Edition content -->
   <div id="content" class="ui-corner-all ui-widget-content">

    <!-- Default text -->
    <div id="content_default" class="content">
     <lang en="No value" fr="Pas de valeur" />
    </div>

    <!-- Configuration datas -->
    <div id="content_cfgDatas" class="hidden">
     <ul style="text-align:left;">
      <li><lang en="Configuration number" fr="Numéro de configuration"/>&nbsp;: <span id="cfgNum"><TMPL_VAR NAME="CFGNUM"></span></li>
      <li><lang en="Author" fr="Auteur"/>&nbsp;: <span id="cfgAuthor"></span></li>
      <li><lang en="IP Address" fr="Adresse IP"/>&nbsp;: <span id="cfgAuthorIP"></span></li>
      <li><lang en="Date" fr="Date"/>&nbsp;: <span id="cfgDate"></span></li>
     </ul>
    </div>

    <!-- Simple text -->
    <div id="content_text" class="hidden">
     <input type="text" id="text" onchange="setlmdata(currentId,this.value)"/>
    </div>

    <!-- Simple textarea -->
    <div id="content_textarea" class="hidden">
     <textarea id="textarea" cols="80" rows="10" onchange="setlmdata(currentId,this.value)"></textarea>
    </div>

    <!-- File textarea -->
    <div id="content_filearea" class="hidden">
     <textarea readonly id="filearea" cols="80" rows="10"></textarea>
     <p><lang en="Load from a file:" fr="Charger depuis un fichier:" /></p>
     <input type="file" name="file" id="file" size="50" style="margin-left:23px;"/>
     <button onclick="setlmfile(currentId);return false;" class="ui-state-default ui-corner-all">
      <lang en="Load" fr="Charger" />
     </button>
     <span style="display:inline-block;width:20px;"><img id="fileloading" name="fileloading" src="<TMPL_VAR NAME="DIR">/ajax-loader.gif" style="vertical-align:middle;" /></span>
    </div>

    <!-- Specific to securedCookie (TODO push in _Struct.pm) -->
    <div id="content_securedCookie" class="hidden">
    <input id="securedCookie0" type="radio" name="securedCookie" value="0" onclick="setlmdata('li_L3NlY3VyZWRDb29raWU1','0')" /> <lang en="Non secured cookie" fr="Cookie non sécurisé"/><br/>
    <input id="securedCookie1" type="radio" name="securedCookie" value="1" onclick="setlmdata('li_L3NlY3VyZWRDb29raWU1','1')" /> <lang en="Secured cookie (HTTPS)" fr="Cookie sécurisé (HTTPS)"/><br/>
    <input id="securedCookie2" type="radio" name="securedCookie" value="2" onclick="setlmdata('li_L3NlY3VyZWRDb29raWU1','2')" /> Double cookie (HTTP and HTTPS)<br/>
    </div>

    <!-- Integer -->
    <div id="content_int" class="hidden">
    <input type="text" id="int" onchange="setlmdata(currentId,this.value)"/>
    </div>

    <!-- Boolean -->
    <div id="content_bool" class="hidden">
    <input id="On" type="radio" name="boolean" value="1" onclick="setlmdata(currentId,1)"/> <lang en="On" fr="Activé"/>
    <input id="Off" type="radio" name="boolean" value="0" onclick="setlmdata(currentId,0)"/> <lang en="Off" fr="Désactivé"/>
    </div>

    <div id="content_btext" class="hidden">
    <input type="text" id="btextKey" onchange="setlmtext(currentId,this.value)"/> <input type="text" id="btextValue" onchange="setlmdata(currentId,this.value)"/>
    </div>

    <!-- Rule -->
    <div id="content_rules" class="hidden">
    <textarea id="rulKey" cols="30" rows="2" onchange="setlmtext(currentId,this.value)"></textarea>&nbsp;<textarea id="rulValue" cols="50" rows="2" onchange="setlmdata(currentId,this.value)"></textarea>
    </div>

    <!-- authParams -->
    <div id="content_authParams" class="hidden">
    <input type="text" id="authText" onchange="reloadAuthParams()"/>
    </div>

    <!-- Vhost -->
    <div id="content_vhost" class="hidden">
     <input type="text" id="vhost" onchange="setlmtext(currentId,this.value)"/>
    </div>

    <!-- samlMetaData -->
    <div id="content_samlMetaData" class="hidden">
      <input type="text" id="samlMetaData" onchange="setlmtext(currentId,this.value)"/>
    </div>

    <!-- samlAttribute -->
    <div id="content_samlAttribute" class="hidden">
     <table>
      <tr>
       <td><lang en="Key name" fr="Nom de la clef"/></td>
       <td><input type="text" id="samlAttributeKey" onchange="setlmsamlattribute(currentId)"/></td>
      </tr>
      <tr>
       <td><lang en="Name" fr="Nom"/></td>
       <td><input type="text" id="samlAttributeName" onchange="setlmsamlattribute(currentId)"/></td>
       <td><lang en="Mandatory" fr="Obligatoire"/></td>
       <td><input id="samlAttributeMandatoryOn" type="radio" name="boolean" value="1" onclick="setlmsamlattribute(currentId)"/> <lang en="On" fr="Activé"/>
           <input id="samlAttributeMandatoryOff" type="radio" name="boolean" value="0" onclick="setlmsamlattribute(currentId)"/> <lang en="Off" fr="Désactivé"/>
       </td>
      </tr>
      <tr>
       <td><lang en="Friendly name" fr="Nom alternatif"/></td>
       <td><input type="text" id="samlAttributeFriendlyName" onchange="setlmsamlattribute(currentId)"/></td>
       <td><lang en="Format" fr="Format"/></td>
       <td><input type="text" id="samlAttributeFormat" onchange="setlmsamlattribute(currentId)"/></td>
      </tr>
     </table>
   </div>

    <!-- samlAssertion -->
    <div id="content_samlAssertion" class="hidden">
     <table>
      <tr>
       <td><lang en="Default" fr="Par défaut"/></td>
       <td><input id="samlAssertionDefaultOn" type="radio" name="boolean" value="1" onclick="setlmsamlassertion(currentId)"/> <lang en="On" fr="Activé"/>
           <input id="samlAssertionDefaultOff" type="radio" name="boolean" value="0" onclick="setlmsamlassertion(currentId)"/> <lang en="Off" fr="Désactivé"/>
       </td>
      </tr>
      <tr>
       <td><lang en="Index" fr="Index"/></td>
       <td><input type="text" size="50" id="samlAssertionIndex" onchange="setlmsamlassertion(currentId)"/></td>
      </tr>
      <tr>
       <td><lang en="Binding" fr="Binding"/></td>
       <td><input type="text" size="50" id="samlAssertionBinding" onchange="setlmsamlassertion(currentId)" disabled="disabled"/></td>
      </tr>
      <tr>
       <td><lang en="Location" fr="URL"/></td>
       <td><input type="text" size="50" id="samlAssertionLocation" onchange="setlmsamlassertion(currentId)"/></td>
      </tr>
     </table>
    </div>

    <!-- samlService -->
    <div id="content_samlService" class="hidden">
     <table>
      <tr>
       <td><lang en="Binding" fr="Binding"/></td>
       <td><input type="text" size="50" id="samlServiceBinding" onchange="setlmsamlservice(currentId)" disabled="disabled"/></td>
      </tr>
      <tr>
       <td><lang en="Location" fr="URL"/></td>
       <td><input type="text" size="50" id="samlServiceLocation" onchange="setlmsamlservice(currentId)"/></td>
      </tr>
      <tr>
       <td><lang en="Response Location" fr="URL de retour"/></td>
       <td><input type="text" size="50" id="samlServiceResponseLocation" onchange="setlmsamlservice(currentId)"/></td>
      </tr>
     </table>
    </div>
   </div>

   </form>

   <!-- Edition -->
   </div>

<!-- Help -->
<div id="help" class="ui-corner-all">
  <h1 class="ui-widget-header ui-corner-all"><lang en="Help" fr="Aide"/></h1>

  <div id="help_content" class="ui-widget-content ui-corner-all">
  <!-- AJAX content -->
     <lang en="Click on the configuration tree to edit parameters" fr="Cliquer sur l'arbre de configuration pour éditer les paramètres" />
  </div>

<!-- Help -->
</div>

<!-- Data -->
</div>

<!-- Page -->
</div>

<!-- Container -->
</div>

</body>
</html>
