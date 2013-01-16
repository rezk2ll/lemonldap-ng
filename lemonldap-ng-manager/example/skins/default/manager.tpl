<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>LemonLDAP::NG Manager</title>
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="icon" type="image/x-icon" />
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="shortcut icon" />
<!-- Offline doc CSS -->
<link rel="stylesheet" type="text/css" href="/doc/css/screen.css" />
<!-- jQuery UI CSS -->
<link rel="stylesheet" type="text/css" id="csstheme" href="<TMPL_VAR NAME="DIR">/<TMPL_VAR NAME="CSS_THEME">/jquery-ui-1.8.6.custom.css" />
<!-- Manager CSS -->
<link rel="stylesheet" type="text/css" id="cssmenu" href="<TMPL_VAR NAME="DIR">/css/<TMPL_VAR NAME="CSS">" />
<script src="<TMPL_VAR NAME="DIR">/js/jquery-1.4.2.min.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/jquery-ui-1.8.6.custom.min.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/jquery.cookie.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/jquery.ajaxfileupload.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/jquery.elastic.source.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/tree.js" type="text/JavaScript"></script>
<script type="text/JavaScript">//<![CDATA[
	var scriptname='<TMPL_VAR NAME="SCRIPT_NAME">';
	var imagepath='<TMPL_VAR NAME="DIR">/images/';
	var csspath='<TMPL_VAR NAME="DIR">/css/';
	var jqueryuiversion='1.8.6';
	var css_menu='<TMPL_VAR NAME="CSS">';
	var css_theme='<TMPL_VAR NAME="CSS_THEME">';
	var themepath='<TMPL_VAR NAME="DIR">/';
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
	var text4securedCookie2='<lang en="Double cookie (HTTP and HTTPS)" fr="Double cookie (HTTP et HTTPS)"/>';
        var text4securedCookie3='<lang en="Double cookie for single session" fr="Double cookie pour une seule session"/>';
	var text4newGeneratedFile='<lang en="Password (optional)" fr="Mot de passe (optionnel)" />';
	var text4edit='<lang en="Edit" fr="Éditer" />';
	var text4protect='<lang en="Protect" fr="Protéger" />';
	var text4newCategory='<lang en="Category identifier" fr="Identifiant de la catégorie" />';
	var text4newApplication='<lang en="Application identifier" fr="Identifiant de l\'application" />';
        var text4newCondition='<lang en="New Condition" fr="Nouvelle Condition" />';
//]]></script>
<script src="<TMPL_VAR NAME="DIR">/js/manager.js" type="text/JavaScript"></script>
<meta http-equiv="Content-Type" content="text/html; charset=utf8" />
</head>
<body>

<!-- Popup -->
<div id="popup" title="<lang en="Command result" fr="Résultat de la commande" />">
</div>

<!-- Skin picker-->
<div id="skinImagePicker" title="<lang en="Choose a skin" fr="Choisir un thème" />">
     <button><img src="<TMPL_VAR NAME="DIR">/images/portal-skins/pastel.png" alt="Pastel" title="pastel" width="200px" height="129px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/portal-skins/impact.png" alt="Impact" title="impact" width="200px" height="129px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/portal-skins/dark.png" alt="Dark" title="dark" width="200px" height="129px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/portal-skins/custom.png" alt="Custom" title="custom" width="200px" height="129px" /></button>
</div>

<!-- logo picker-->
<div id="appsLogoPicker" title="<lang en="Choose a logo" fr="Choisir un logo" />">
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/attach.png" title="attach" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/bell.png" title="bell" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/bookmark.png" title="bookmark" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/configure.png" title="configure" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/database.png" title="database" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/demo.png" title="demo" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/folder.png" title="folder" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/gear.png" title="gear" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/help.png" title="help" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/mailappt.png" title="mailappt" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/money.png" title="money" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/network.png" title="network" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/terminal.png" title="terminal" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/thumbnail.png" title="thumbnail" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/tux.png" title="tux" width="32px" height="32px" /></button>
     <button><img src="<TMPL_VAR NAME="DIR">/images/apps-logos/custom.png" title="custom" width="32px" height="32px" /></button>
</div>

<TMPL_INCLUDE NAME="top.tpl">

<!-- Page -->
<!-- <div id="page" class="ui-corner-all ui-helper-clearfix ui-widget-content"> -->

<!-- Menu (tree) -->
<div id="menu" class="ui-corner-all ui-helper-clearfix ui-widget-content">
   <TMPL_VAR NAME="MENU">
</div>

<!-- Data -->
<!-- <div id="data" class="ui-corner-all ui-helper-clearfix ui-widget-content"> -->

   <!-- Buttons -->
   <div id="buttons">

    <h1 class="ui-widget-header ui-corner-all">
     <img src="<TMPL_VAR NAME="DIR">/images/1downarrow_16x16.png" width="16px" height="16px" />
     <img src="<TMPL_VAR NAME="DIR">/images/1rightarrow_16x16.png" class="hidden" width="16px" height="16px" />
     <lang en="Available actions" fr="Actions disponibles" />
    </h1>

    <div id="buttons_content" class="ui-corner-all ui-widget-content">
    <button id="bsave" onclick="uploadConf()">
     <lang en="Save" fr="Sauver" />
    </button>

    <button id="bnewvh" style="display:none;" onclick="newVh();return false;" >
     <lang en="New virtual host" fr="Nouvel hôte virtuel" />
    </button>

    <button id="bdelvh" style="display:none;" onclick="delvh(currentId);" >
     <lang en="Delete virtual host" fr="Supprimer l'hôte virtuel" />
    </button>

    <button id="newkbr" style="display:none;" onclick="newKeyR();return false;" >
     <lang en="New key" fr="Nouvelle clef" />
    </button>

    <button id="newrbr" style="display:none;" onclick="newRuleR();return false;" >
     <lang en="New rule" fr="Nouvelle règle" />
    </button>

    <button id="newgsrbr" style="display:none;" onclick="newGrantSessionRuleR();return false;" >
     <lang en="New condition" fr="Nouvelle condition" />
    </button>

    <button id="newkb" style="display:none;" onclick="newKey();return false;" >
     <lang en="New key" fr="Nouvelle clef" />
    </button>

    <button id="newrb" style="display:none;" onclick="newRule();return false;" >
     <lang en="New rule" fr="Nouvelle règle" />
    </button>

    <button id="newgsrb" style="display:none;" onclick="newGrantSessionRule();return false;" >
     <lang en="New condition" fr="Nouvelle condition" />
    </button>

    <button id="delkb" style="display:none;" onclick="delKey();return false;" >
     <lang en="Delete key" fr="Effacer la clef" />
    </button>

    <button id="newidpsamlmetadatab" style="display:none;" onclick="newIdpSamlMetaData();return false;" >
     <lang en="New identity provider" fr="Nouveau fournisseur d'identité" />
    </button>

    <button id="delidpsamlmetadatab" style="display:none;" onclick="delIdpSamlMetaData(currentId);" >
     <lang en="Delete identity provider" fr="Supprimer le fournisseur d'identité" />
    </button>

    <button id="newspsamlmetadatab" style="display:none;" onclick="newSpSamlMetaData();return false;" >
     <lang en="New service provider" fr="Nouveau fournisseur de service" />
    </button>

    <button id="delspsamlmetadatab" style="display:none;" onclick="delSpSamlMetaData(currentId);" >
     <lang en="Delete service provider" fr="Supprimer le fournisseur de service" />
    </button>

    <button id="newsamlattributeb" style="display:none;" onclick="newSamlAttribute();return false;" >
     <lang en="New attribute" fr="Nouvel attribut" />
    </button>

    <button id="newsamlattributebr" style="display:none;" onclick="newSamlAttributeR();return false;" >
     <lang en="New attribute" fr="Nouvel attribut" />
    </button>

    <button id="delsamlattributeb" style="display:none;" onclick="delSamlAttribute();return false;" >
     <lang en="Delete attribute" fr="Supprimer l'attribut" />
    </button>

    <button id="newchoice" style="display:none;" onclick="newChoice();return false;" >
     <lang en="New choice" fr="Nouveau choix" />
    </button>

    <button id="newchoicer" style="display:none;" onclick="newChoiceR();return false;" >
     <lang en="New choice" fr="Nouveau choix" />
    </button>

    <button id="delchoice" style="display:none;" onclick="delChoice();return false;" >
     <lang en="Delete choice" fr="Supprimer le choix" />
    </button>

    <button id="newcategoryr" style="display:none;" onclick="newCategoryR();return false;" >
     <lang en="New category" fr="Nouvelle catégorie" />
    </button>

    <button id="delcategory" style="display:none;" onclick="delCategory();return false;" >
     <lang en="Delete category" fr="Supprimer la catégorie" />
    </button>

    <button id="newapplicationr" style="display:none;" onclick="newApplicationR();return false;" >
     <lang en="New application" fr="Nouvelle application" />
    </button>

    <button id="delapplication" style="display:none;" onclick="delApplication();return false;" >
     <lang en="Delete application" fr="Supprimer l'application" />
    </button>

    <button id="newpostr" style="display:none;" onclick="newPostR();return false;" >
     <lang en="New POST URL" fr="Nouvelle URL POST" />
    </button>

    <button id="delpost" style="display:none;" onclick="delPost();return false;" >
     <lang en="Delete POST URL" fr="Supprimer l'URL POST" />
    </button>

    <button id="newpostdatar" style="display:none;" onclick="newPostDataR();return false;" >
     <lang en="New POST data" fr="Nouvelle donnée POST" />
    </button>

    <button id="delpostdata" style="display:none;" onclick="delPostData();return false;" >
     <lang en="Delete POST data" fr="Supprimer la donnée POST" />
    </button>

    </div>

   <!-- Buttons -->
   </div>

  
   <!-- Edition -->
   <div id="edition" class="ui-corner-all">

   <form action="#" onsubmit="return false">

    <h1 class="ui-widget-header ui-corner-all">
     <img src="<TMPL_VAR NAME="DIR">/images/1downarrow_16x16.png" width="16px" height="16px" />
     <img src="<TMPL_VAR NAME="DIR">/images/1rightarrow_16x16.png" class="hidden" width="16px" height="16px" />
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
     <ul>
      <li><strong><lang en="Configuration number" fr="Numéro de configuration "/></strong>: <span id="cfgNum"><TMPL_VAR NAME="CFGNUM"></span></li>
      <li><strong><lang en="Author" fr="Auteur "/></strong>: <span id="cfgAuthor"></span></li>
      <li><strong><lang en="IP Address" fr="Adresse IP "/></strong>: <span id="cfgAuthorIP"></span></li>
      <li><strong><lang en="Date" fr="Date "/></strong>: <span id="cfgDate"></span></li>
     </ul>
    </div>

    <!-- Simple text -->
    <div id="content_text" class="hidden">
     <input type="text" id="text" />
     <br />
     <button onclick="setlminputdata(currentId,text);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Simple textarea -->
    <div id="content_textarea" class="hidden">
     <textarea id="textarea" cols="80" rows="10"></textarea>
     <br />
     <button onclick="setlminputdata(currentId,textarea);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- File textarea -->
    <div id="content_filearea" class="hidden">
     <textarea readonly="readonly" id="filearea" cols="80" rows="10"></textarea>
     <table>
      <tr>
       <td>
      <button id="downloadfile" onclick="downloadFile(currentId);return false;" >
       <lang en="Download this file" fr="T&eacute;l&eacute;charger ce fichier" />
      </button>
      <button id="generatefile" onclick="generateFile(currentId);return false;" >
       <lang en="Generate" fr="G&eacute;n&eacute;rer" />
      </button>
      <button id="switchreadonly" onclick="switchReadonly('#filearea');return false;" >
      </button>
      <button onclick="setlminputdata(currentId,filearea);return false;" >
       <lang en="Apply" fr="Appliquer" />
      </button>
       </td>
       <td>
        <span class="loadimg"><img class="hidden" id="button-loadimg" src="<TMPL_VAR NAME="DIR">/images/spinner.gif" width="16px" height="16px" /></span>
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
        <button onclick="setlmfile(currentId,file);return false;" ><lang en="Load" fr="Charger" /></button>
        <span class="loadimg"><img class="hidden" id="file-loadimg" src="<TMPL_VAR NAME="DIR">/images/spinner.gif" width="16px" height="16px" /></span>
       </td>
      </tr>
      <tr id="urlinput" class="hidden">
       <td><lang en="Load from a URL" fr="Charger depuis une URL" /> :</td>
       <td>
        <input type="text" name="url" id="url" size="40"/>
       </td>
       <td>
        <button onclick="setlmfile(currentId,url);return false;" ><lang en="Load" fr="Charger" /></button>
        <span class="loadimg"><img class="hidden" id="url-loadimg" src="<TMPL_VAR NAME="DIR">/images/spinner.gif" width="16px" height="16px" /></span>
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
     <button onclick="decrease();return false;" > - </button>
     <input type="text" id="int" />
     <button onclick="increase();return false;" > + </button>
     <br />
     <button onclick="setlminputdata(currentId,int);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Boolean -->
    <div id="content_bool" class="hidden">
     <input id="On" type="radio" name="boolean" value="1" onclick="setlmdata(currentId,1)"/><label for="On"><lang en="On" fr="Activé"/></label>
     <input id="Off" type="radio" name="boolean" value="0" onclick="setlmdata(currentId,0)"/><label for="Off"><lang en="Off" fr="Désactivé"/></label>
    </div>

    <!-- Troolean -->
    <div id="content_trool" class="hidden">
     <input id="TrOn" type="radio" name="troolean" value="1" onclick="setlmdata(currentId,1)"/><label for="TrOn"><lang en="On" fr="Activé"/></label>
     <input id="TrOff" type="radio" name="troolean" value="0" onclick="setlmdata(currentId,0)"/><label for="TrOff"><lang en="Off" fr="Désactivé"/></label>
     <input id="TrDefault" type="radio" name="troolean" value="-1" onclick="setlmdata(currentId,-1)"/><label for="TrDefault"><lang en="Default" fr="Par défaut"/></label>
    </div>

    <!-- Boolean or Perl Expr -->
    <div id="content_boolOrPerlExpr" class="hidden">
     <input id="bopeOn" type="radio" name="bope" value="1" onclick="setlmdata(currentId,1);$('#bopeValue').hide();"/><label for="bopeOn"><lang en="On" fr="Activé"/></label>
     <input id="bopeOff" type="radio" name="bope" value="0" onclick="setlmdata(currentId,0);$('#bopeValue').hide();"/><label for="bopeOff"><lang en="Off" fr="Désactivé"/></label>
     <input id="bopeExpr" type="radio" name="bope" value="-1" onclick="$('#bopeValue').show();"/><label for="bopeExpr"><lang en="Specific rule" fr="Règle spécifique"/></label>
     <br />
     <textarea id="bopeValue" cols="30" rows="2"></textarea>
     <br />
     <button onclick="setlmbope(currentId);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>


    <div id="content_btext" class="hidden">
     <textarea class="elastic" id="btextKey" rows="1" cols="25"></textarea>
     <textarea class="elastic" id="btextValue" rows="1" cols="40"></textarea>
     <br />
     <button onclick="setlminputtext(currentId,btextKey);setlminputdata(currentId,btextValue);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Rule -->
    <div id="content_rules" class="hidden">
     <table border="0"><tbody><tr><td>
      <div id="rulCommentDiv">
       <lang en="Comment" fr="Commentaire" /><br/>
       <textarea class="elastic" id="rulComment" rows="1" cols="30"></textarea>
      </div>
      <lang en="Expression" fr="Expression" /><br/>
      <textarea class="elastic" id="rulKey" rows="1" cols="30"></textarea>
     </td>
     <td>
      <lang en="Rule" fr="Règle" /><br/>
      <textarea class="elastic" id="rulValue" rows="1" cols="50"></textarea>
     </td></tr></tbody></table>
     <br />
     <button onclick="setlmrule(currentId,rulComment,rulKey,rulValue);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Grant session rule -->
    <div id="content_grantSessionRules" class="hidden">
     <table border="0"><tbody><tr><td>
      <div id="grantSessionRulCommentDiv">
       <lang en="Comment" fr="Commentaire" /><br/>
       <textarea class="elastic" id="grantSessionRulComment" rows="1" cols="30"></textarea>
      </div>
      <lang en="Condition" fr="Condition" /><br/>
      <textarea class="elastic" id="grantSessionRulKey" cols="30" rows="1"></textarea>
     </td>
     <td>
         <lang en="Message" fr="Message" /><br/>
         <textarea class="elastic" id="grantSessionRulValue" cols="50" rows="1"></textarea>
     </td></tr></tbody></table>
     <br />
     <button onclick="setlmgrantsessionrule(currentId,grantSessionRulComment,grantSessionRulKey,grantSessionRulValue);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- authParams -->
    <div id="content_authParams" class="hidden">
     <select id="authText"></select>
     <br/>
     <input type="text" id="authOptions" class="hidden" size="30"/>
     <br/>
     <button onclick="reloadAuthParams();return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Skin -->
    <div id="content_skin" class="hidden">
     <button class="current"><img src="" alt="" class="current" /></button>
     <br /> 
     <input id="skinText" type="text" readonly="readonly" />
     <br />
     <button onclick="setlminputdata(currentId,skinText);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Vhost -->
    <div id="content_vhost" class="hidden">
     <input type="text" id="vhost" size="30"/>
     <br />
     <button onclick="setlminputtext(currentId,vhost);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- samlIdpMetaData -->
    <div id="content_samlIdpMetaData" class="hidden">
     <input type="text" id="samlIdpMetaData" size="30"/>
     <br />
     <button onclick="setlminputtext(currentId,samlIdpMetaData);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- samlSpMetaData -->
    <div id="content_samlSpMetaData" class="hidden">
     <input type="text" id="samlSpMetaData" size="30"/>
     <br />
     <button onclick="setlminputtext(currentId,samlSpMetaData);return false;" >
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
       <td><input id="samlAttributeMandatoryOn" type="radio" name="boolean" value="1" /><label for="samlAttributeMandatoryOn"><lang en="On" fr="Activé"/></label>
           <input id="samlAttributeMandatoryOff" type="radio" name="boolean" value="0" /><label for="samlAttributeMandatoryOff"><lang en="Off" fr="Désactivé"/></label>
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
     <button onclick="setlmsamlattribute(currentId);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
   </div>

    <!-- samlAssertion -->
    <div id="content_samlAssertion" class="hidden">
     <table>
      <tr>
       <td><lang en="Default" fr="Par défaut"/></td>
       <td><input id="samlAssertionDefaultOn" type="radio" name="boolean" value="1" /><label for="samlAssertionDefaultOn"><lang en="On" fr="Activé"/></label>
           <input id="samlAssertionDefaultOff" type="radio" name="boolean" value="0" /><label for="samlAssertionDefaultOff"><lang en="Off" fr="Désactivé"/></label>
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
     <button onclick="setlmsamlassertion(currentId);return false;" >
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
     <button onclick="setlmsamlservice(currentId);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- OpenID black/white lists -->
    <div id="content_openid_serverlist" class="hidden">
     <table>
      <tr>
       <td><lang en="List type" fr="Type de liste"/></td>
       <td><input id="openid_serverlist_black" type="radio" name="boolean" value="0" /><label for="openid_serverlist_black"><lang en="Black list" fr="Liste noire"/></label>
           <input id="openid_serverlist_white" type="radio" name="boolean" value="1" /><label for="openid_serverlist_white"><lang en="White list" fr="Liste blanche"/></label>
       </td>
      </tr>
      <tr>
       <td><lang en="List" fr="Liste"/></td>
       <td><input type="text" size="50" id="openid_serverlist_text" /></td>
      </tr>
     </table>
     <br />
     <button onclick="setopenididplist(currentId);return false;" >
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
     <button onclick="setlmauthchoice(currentId);return false;" >
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
     <button onclick="setlminputtext(currentId,'#applicationListCategoryKey');setlminputdata(currentId,'#applicationListCategoryName');return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- applicationList Application-->
    <div id="content_applicationListApplication" class="hidden">
     <table>
      <tr>
       <td><lang en="Key" fr="Nom de la clef"/></td>
       <td><input type="text" id="applicationListApplicationKey" /></td>
       <td><lang en="Display name" fr="Nom à afficher"/></td>
       <td><input type="text" id="applicationListApplicationName" /></td>
      </tr>
      <tr>
       <td><lang en="Address" fr="Adresse"/></td>
       <td><input type="text" id="applicationListApplicationURL" /></td>
       <td><lang en="Display mode" fr="Mode d'affichage"/></td>
       <td><select id="applicationListApplicationDisplay"></select></td>
      </tr>
      <tr>
       <td><lang en="Description" fr="Description"/></td>
       <td><textarea id="applicationListApplicationDescription" /></textarea></td>
       <td><lang en="Logo" fr="Logo"/></td>
       <td>
         <button class="current"><img src="" alt="" class="current" /></button><br />
         <input type="text" id="applicationListApplicationLogo" readonly="readonly" />
       </td>
      </tr>
     </table>
     <br />
     <button onclick="setlmapplication(currentId);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Post -->
    <div id="content_post" class="hidden">
     <table>
      <tr>
       <td><lang en="POST URL" fr="URL POST"/></td>
       <td><input type="text" id="postKey" size="40"/></td>
      </tr>
      <tr>
       <td><lang en="Target URL (optional)" fr="URL cible (optionnelle)"/></td>
       <td><input type="text" id="postUrl" size="40"/></td>
      </tr>
     </table>
     <br />
     <button onclick="setlminputtext(currentId,postKey);setlminputdata(currentId,postUrl);return false;" >
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>
 
    <div id="content_postdata" class="hidden">
     <input type="text" id="postDataKey" /> <input type="text" id="postDataValue" />
     <br />
     <button onclick="setlminputtext(currentId,postDataKey,'postdata:');setlminputdata(currentId,postDataValue);return false;" >
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
    <img src="<TMPL_VAR NAME="DIR">/images/1downarrow_16x16.png" width="16px" height="16px" />
    <img src="<TMPL_VAR NAME="DIR">/images/1rightarrow_16x16.png" class="hidden" width="16px" height="16px" />
    <lang en="Help" fr="Aide"/>
  </h1>

  <div id="help_content" class="ui-widget-content ui-corner-all">
  <!-- AJAX content -->
     <lang en="Click on the configuration tree to edit parameters" fr="Cliquer sur l'arbre de configuration pour éditer les paramètres" />
  </div>

<!-- Help -->
</div>

<!-- Data -->
<!-- </div> -->

<!-- Page -->
<!-- </div> -->

<!-- Container -->
<!-- </div> -->

</body>
</html>
