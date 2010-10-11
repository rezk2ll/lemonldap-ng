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
<script src="<TMPL_VAR NAME="DIR">/jquery-1.4.2.min.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/jquery-ui-1.7.2.custom.min.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/jquery.cookie.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/jquery.ajaxfileupload.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/tree.js" type="text/JavaScript"></script>
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
	var text4newFilename='<lang en="Filename" fr="Nom du fichier" />';
	var text4securedCookie0='<lang en="Non secured cookie" fr="Cookie non sécurisé"/>';
	var text4securedCookie1='<lang en="Secured cookie (HTTPS)" fr="Cookie sécurisé (HTTPS)"/>';
	var text4securedCookie2='Double cookie (HTTP and HTTPS)';
	var text4newGeneratedFile='<lang en="Password (optional)" fr="Mot de passe (optionnel)" />';
	var text4edit='<lang en="Edit" fr="Éditer" />';
	var text4protect='<lang en="Protect" fr="Protéger" />';
	var text4newCategory='<lang en="Category identifier" fr="Identifiant de la catégorie" />';
	var text4newApplication='<lang en="Application identifier" fr="Identifiant de l\'application" />';
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
     <img src="<TMPL_VAR NAME="DIR">/images/1downarrow_16x16.png" />
     <img src="<TMPL_VAR NAME="DIR">/images/1rightarrow_16x16.png" class="hidden" />
     <lang en="Available actions" fr="Actions disponibles" />
    </h1>

    <div id="buttons_content" class="ui-corner-all ui-widget-content">
    <button id="bsave" onclick="uploadConf()" class="ui-state-default ui-corner-all" >
     <lang en="Save" fr="Sauver" />
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

    <button id="newidpsamlmetadatab" style="display:none;" onclick="newIdpSamlMetaData();return false;" class="ui-state-default ui-corner-all">
     <lang en="New identity provider" fr="Nouveau fournisseur d'identité" />
    </button>

    <button id="delidpsamlmetadatab" style="display:none;" onclick="delIdpSamlMetaData(currentId);" class="ui-state-default ui-corner-all">
     <lang en="Delete identity provider" fr="Supprimer le fournisseur d'identité" />
    </button>

    <button id="newspsamlmetadatab" style="display:none;" onclick="newSpSamlMetaData();return false;" class="ui-state-default ui-corner-all">
     <lang en="New service provider" fr="Nouveau fournisseur de service" />
    </button>

    <button id="delspsamlmetadatab" style="display:none;" onclick="delSpSamlMetaData(currentId);" class="ui-state-default ui-corner-all">
     <lang en="Delete service provider" fr="Supprimer le fournisseur de service" />
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

    <button id="newchoice" style="display:none;" onclick="newChoice();return false;" class="ui-state-default ui-corner-all">
     <lang en="New choice" fr="Nouveau choix" />
    </button>

    <button id="newchoicer" style="display:none;" onclick="newChoiceR();return false;" class="ui-state-default ui-corner-all">
     <lang en="New choice" fr="Nouveau choix" />
    </button>

    <button id="delchoice" style="display:none;" onclick="delChoice();return false;" class="ui-state-default ui-corner-all">
     <lang en="Delete choice" fr="Supprimer le choix" />
    </button>

    <button id="newcategoryr" style="display:none;" onclick="newCategoryR();return false;" class="ui-state-default ui-corner-all">
     <lang en="New category" fr="Nouvelle catégorie" />
    </button>

    <button id="delcategory" style="display:none;" onclick="delCategory();return false;" class="ui-state-default ui-corner-all">
     <lang en="Delete category" fr="Supprimer la catégorie" />
    </button>

    <button id="newapplicationr" style="display:none;" onclick="newApplicationR();return false;" class="ui-state-default ui-corner-all">
     <lang en="New application" fr="Nouvelle application" />
    </button>

    <button id="delapplication" style="display:none;" onclick="delApplication();return false;" class="ui-state-default ui-corner-all">
     <lang en="Delete application" fr="Supprimer l'application" />
    </button>

    <button id="newpostr" style="display:none;" onclick="newPostR();return false;" class="ui-state-default ui-corner-all">
     <lang en="New POST URL" fr="Nouvelle URL POST" />
    </button>

    <button id="delpost" style="display:none;" onclick="delPost();return false;" class="ui-state-default ui-corner-all">
     <lang en="Delete POST URL" fr="Supprimer l'URL POST" />
    </button>

    <button id="newpostdatar" style="display:none;" onclick="newPostDataR();return false;" class="ui-state-default ui-corner-all">
     <lang en="New POST data" fr="Nouvelle donnée POST" />
    </button>

    <button id="delpostdata" style="display:none;" onclick="delPostData();return false;" class="ui-state-default ui-corner-all">
     <lang en="Delete POST data" fr="Supprimer la donnée POST" />
    </button>

    </div>

   <!-- Buttons -->
   </div>

  
   <!-- Edition -->
   <div id="edition" class="ui-corner-all">

   <form action="#" onsubmit="return false">

    <h1 class="ui-widget-header ui-corner-all">
     <img src="<TMPL_VAR NAME="DIR">/images/1downarrow_16x16.png" />
     <img src="<TMPL_VAR NAME="DIR">/images/1rightarrow_16x16.png" class="hidden" />
     <lang en="Edit key " fr="Édition de la clé " /><span id="content_title">&nbsp;</span>
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
     <input type="text" id="text" />
     <br />
     <button onclick="setlminputdata(currentId,text);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Simple textarea -->
    <div id="content_textarea" class="hidden">
     <textarea id="textarea" cols="80" rows="10"></textarea>
     <br />
     <button onclick="setlminputdata(currentId,textarea);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- File textarea -->
    <div id="content_filearea" class="hidden">
     <textarea readonly="readonly" id="filearea" cols="80" rows="10"></textarea>
     <table>
      <tr>
       <td>
      <button id="downloadfile" onclick="downloadFile(currentId);return false;" class="ui-state-default ui-corner-all">
       <lang en="Download this file" fr="T&eacute;l&eacute;charger ce fichier" />
      </button>
      <button id="generatefile" onclick="generateFile(currentId);return false;" class="ui-state-default ui-corner-all">
       <lang en="Generate" fr="G&eacute;n&eacute;rer" />
      </button>
      <button id="switchreadonly" onclick="switchReadonly('#filearea');return false;" class="ui-state-default ui-corner-all">
      </button>
      <button onclick="setlminputdata(currentId,filearea);return false;" class="ui-state-default ui-corner-all">
       <lang en="Apply" fr="Appliquer" />
      </button>
       </td>
       <td>
        <span class="loadimg"><img class="hidden" id="button-loadimg" src="<TMPL_VAR NAME="DIR">/spinner.gif" /></span>
       </td>
      </tr>
     </table>
     <table class="filearea">
      <tr id="fileinput">
       <td><lang en="Load from a file" fr="Charger depuis un fichier" /> :</td>
       <td>
        <input type="file" name="file" id="file" size="30"/>
       </td>
       <td>
        <button onclick="setlmfile(currentId,file);return false;" class="ui-state-default ui-corner-all"><lang en="Load" fr="Charger" /></button>
        <span class="loadimg"><img class="hidden" id="file-loadimg" src="<TMPL_VAR NAME="DIR">/spinner.gif" /></span>
       </td>
      </tr>
      <tr id="urlinput" class="hidden">
       <td><lang en="Load from a URL" fr="Charger depuis une URL" /> :</td>
       <td>
        <input type="text" name="url" id="url" size="40"/>
       </td>
       <td>
        <button onclick="setlmfile(currentId,url);return false;" class="ui-state-default ui-corner-all"><lang en="Load" fr="Charger" /></button>
        <span class="loadimg"><img class="hidden" id="url-loadimg" src="<TMPL_VAR NAME="DIR">/spinner.gif" /></span>
       </td>
      </tr>
     </table>
    </div>

    <!-- Select -->
    <div id="content_select" class="hidden">
     <select id="select" onchange="setlmdata(currentId,this.value);return false;"></select>
    </div>

    <!-- Integer -->
    <div id="content_int" class="hidden">
     <button onclick="decrease();return false;" class="ui-state-default ui-corner-all"> - </button>
     <input type="text" id="int" />
     <button onclick="increase();return false;" class="ui-state-default ui-corner-all"> + </button>
     <br />
     <button onclick="setlminputdata(currentId,int);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Boolean -->
    <div id="content_bool" class="hidden">
     <input id="On" type="radio" name="boolean" value="1" onclick="setlmdata(currentId,1)"/> <lang en="On" fr="Activé"/>
     <input id="Off" type="radio" name="boolean" value="0" onclick="setlmdata(currentId,0)"/> <lang en="Off" fr="Désactivé"/>
    </div>

    <!-- Troolean -->
    <div id="content_trool" class="hidden">
     <input id="TrOn" type="radio" name="troolean" value="1" onclick="setlmdata(currentId,1)"/> <lang en="On" fr="Activé"/>
     <input id="TrOff" type="radio" name="troolean" value="0" onclick="setlmdata(currentId,0)"/> <lang en="Off" fr="Désactivé"/>
     <input id="TrDefault" type="radio" name="troolean" value="-1" onclick="setlmdata(currentId,-1)"/> <lang en="Default" fr="Par défaut"/>
    </div>

    <div id="content_btext" class="hidden">
     <input type="text" id="btextKey" /> <input type="text" id="btextValue" />
     <br />
     <button onclick="setlminputtext(currentId,btextKey);setlminputdata(currentId,btextValue);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Rule -->
    <div id="content_rules" class="hidden">
     <textarea id="rulKey" cols="30" rows="2"></textarea>&nbsp;<textarea id="rulValue" cols="50" rows="2"></textarea>
     <br />
     <button onclick="setlminputtext(currentId,rulKey);setlminputdata(currentId,rulValue);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- authParams -->
    <div id="content_authParams" class="hidden">
     <select id="authText"></select>
     <br/>
     <input type="text" id="authOptions" class="hidden" />
     <br/>
     <button onclick="reloadAuthParams();return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Skin -->
    <div id="content_skin" class="hidden">
     <img src="" alt="" />
     <br /> 
     <select id="skinText" onchange="changeSkinImage(this.value);return false;"></select>
     <br />
     <button onclick="setlminputdata(currentId,skinText);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Vhost -->
    <div id="content_vhost" class="hidden">
     <input type="text" id="vhost" />
     <br />
     <button onclick="setlminputtext(currentId,vhost);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- samlIdpMetaData -->
    <div id="content_samlIdpMetaData" class="hidden">
     <input type="text" id="samlIdpMetaData" />
     <br />
     <button onclick="setlminputtext(currentId,samlIdpMetaData);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- samlSpMetaData -->
    <div id="content_samlSpMetaData" class="hidden">
     <input type="text" id="samlSpMetaData" />
     <br />
     <button onclick="setlminputtext(currentId,samlSpMetaData);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- samlAttribute -->
    <div id="content_samlAttribute" class="hidden">
     <table>
      <tr>
       <td><lang en="Key name" fr="Nom de la clef"/></td>
       <td><input type="text" id="samlAttributeKey" /></td>
      </tr>
      <tr>
       <td><lang en="Name" fr="Nom"/></td>
       <td><input type="text" id="samlAttributeName" /></td>
       <td><lang en="Mandatory" fr="Obligatoire"/></td>
       <td><input id="samlAttributeMandatoryOn" type="radio" name="boolean" value="1" /> <lang en="On" fr="Activé"/>
           <input id="samlAttributeMandatoryOff" type="radio" name="boolean" value="0" /> <lang en="Off" fr="Désactivé"/>
       </td>
      </tr>
      <tr>
       <td><lang en="Friendly name" fr="Nom alternatif"/></td>
       <td><input type="text" id="samlAttributeFriendlyName" /></td>
       <td><lang en="Format" fr="Format"/></td>
       <td><select id="samlAttributeFormat"></select></td>
      </tr>
     </table>
     <br />
     <button onclick="setlmsamlattribute(currentId);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
   </div>

    <!-- samlAssertion -->
    <div id="content_samlAssertion" class="hidden">
     <table>
      <tr>
       <td><lang en="Default" fr="Par défaut"/></td>
       <td><input id="samlAssertionDefaultOn" type="radio" name="boolean" value="1" /> <lang en="On" fr="Activé"/>
           <input id="samlAssertionDefaultOff" type="radio" name="boolean" value="0" /> <lang en="Off" fr="Désactivé"/>
       </td>
      </tr>
      <tr class="hidden">
       <td><lang en="Index" fr="Index"/></td>
       <td><input type="text" size="50" id="samlAssertionIndex" /></td>
      </tr>
      <tr>
       <td><lang en="Binding" fr="Binding"/></td>
       <td><select disabled="disabled" id="samlAssertionBinding"></select></td>
      </tr>
      <tr>
       <td><lang en="Location" fr="URL"/></td>
       <td><input type="text" size="50" id="samlAssertionLocation" /></td>
      </tr>
     </table>
     <br />
     <button onclick="setlmsamlassertion(currentId);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- samlService -->
    <div id="content_samlService" class="hidden">
     <table>
      <tr>
       <td><lang en="Binding" fr="Binding"/></td>
       <td><select disabled="disabled" id="samlServiceBinding"></select></td>
      </tr>
      <tr>
       <td><lang en="Location" fr="URL"/></td>
       <td><input type="text" size="50" id="samlServiceLocation" /></td>
      </tr>
      <tr>
       <td><lang en="Response Location" fr="URL de retour"/></td>
       <td><input type="text" size="50" id="samlServiceResponseLocation" /></td>
      </tr>
     </table>
     <br />
     <button onclick="setlmsamlservice(currentId);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- OpenID black/white lists -->
    <div id="content_openid_serverlist" class="hidden">
     <table>
      <tr>
       <td><lang en="List type" fr="Type de liste"/></td>
       <td><input id="openid_serverlist_black" type="radio" name="boolean" value="0" /> <lang en="Black list" fr="Liste noire"/>
           <input id="openid_serverlist_white" type="radio" name="boolean" value="1" /> <lang en="White list" fr="Liste blanche"/>
       </td>
      </tr>
      <tr>
       <td><lang en="List" fr="Liste"/></td>
       <td><input type="text" size="50" id="openid_serverlist_text" /></td>
      </tr>
     </table>
     <br />
     <button onclick="setopenididplist(currentId);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- authChoice -->
    <div id="content_authChoice" class="hidden">
     <table>
      <tr>
       <td><lang en="Key name" fr="Nom de la clef"/></td>
       <td><input type="text" id="authChoiceKey" /></td>
      </tr>
      <tr>
       <td><lang en="Authentication module" fr="Module d'authentification"/></td>
       <td><select id="authChoiceAuth"></select></td>
      </tr>
      <tr>
       <td><lang en="User module" fr="Module d'utilisateurs"/></td>
       <td><select id="authChoiceUser"></select></td>
      </tr>
      <tr>
       <td><lang en="Password module" fr="Module de mots de passe"/></td>
       <td><select id="authChoicePassword"></select></td>
      </tr>
     </table>
     <br />
     <button onclick="setlmauthchoice(currentId);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
   </div>

    <!-- applicationList Category-->
    <div id="content_applicationListCategory" class="hidden">
     <table>
      <tr>
       <td><lang en="Key" fr="Nom de la clef"/></td>
       <td><input type="text" id="applicationListCategoryKey" /></td>
      </tr>
      <tr>
       <td><lang en="Display name" fr="Nom à afficher"/></td>
       <td><input type="text" id="applicationListCategoryName" /></td>
      </tr>
     </table>
     <br />
     <button onclick="setlminputtext(currentId,'#applicationListCategoryKey');setlminputdata(currentId,'#applicationListCategoryName');return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- applicationList Application-->
    <div id="content_applicationListApplication" class="hidden">
     <table>
      <tr>
       <td><lang en="Key" fr="Nom de la clef"/></td>
       <td><input type="text" id="applicationListApplicationKey" /></td>
      </tr>
      <tr>
       <td><lang en="Display name" fr="Nom à afficher"/></td>
       <td><input type="text" id="applicationListApplicationName" /></td>
      </tr>
      <tr>
       <td><lang en="Adress" fr="Adresse"/></td>
       <td><input type="text" id="applicationListApplicationURL" /></td>
      </tr>
      <tr>
       <td><lang en="Description" fr="Description"/></td>
       <td><textarea id="applicationListApplicationDescription" /></textarea></td>
      </tr>
      <tr>
       <td><lang en="Logo (file name)" fr="Logo (nom du fichier)"/></td>
       <td><input type="text" id="applicationListApplicationLogo" /></td>
      </tr>
      <tr>
       <td><lang en="Display mode" fr="Mode d'affichage"/></td>
       <td><select id="applicationListApplicationDisplay"></select></td>
      </tr>
     </table>
     <br />
     <button onclick="setlmapplication(currentId);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Post -->
    <div id="content_post" class="hidden">
     <table>
      <tr>
       <td><lang en="POST URL" fr="URL POST"/></td>
       <td><input type="text" id="postKey" /></td>
      </tr>
      <tr>
       <td><lang en="Target URL (optional)" fr="URL cible (optionnelle)"/></td>
       <td><input type="text" id="postUrl" /></td>
      </tr>
     </table>
     <br />
     <button onclick="setlminputtext(currentId,postKey);setlminputdata(currentId,postUrl);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>
 
    <div id="content_postdata" class="hidden">
     <input type="text" id="postDataKey" /> <input type="text" id="postDataValue" />
     <br />
     <button onclick="setlminputtext(currentId,postDataKey,'postdata:');setlminputdata(currentId,postDataValue);return false;" class="ui-state-default ui-corner-all">
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

   </div>

   </form>

   <!-- Edition -->
   </div>

<!-- Help -->
<div id="help" class="ui-corner-all">
  <h1 class="ui-widget-header ui-corner-all">
    <img src="<TMPL_VAR NAME="DIR">/images/1downarrow_16x16.png" />
    <img src="<TMPL_VAR NAME="DIR">/images/1rightarrow_16x16.png" class="hidden" />
    <lang en="Help" fr="Aide"/>
  </h1>

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
