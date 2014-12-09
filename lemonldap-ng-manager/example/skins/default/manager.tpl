<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title>LemonLDAP::NG Manager</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="Content-Script-Type" content="text/javascript" />
<meta http-equiv="cache-control" content="no-cache" />
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="icon" type="image/x-icon" />
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="shortcut icon" />
<!-- Offline doc CSS -->
<link rel="stylesheet" type="text/css" href="/doc/css/screen.css" />
<!-- jQuery UI CSS -->
<link rel="stylesheet" type="text/css" id="csstheme" href="<TMPL_VAR NAME="DIR">/<TMPL_VAR NAME="CSS_THEME">/jquery-ui-1.10.3.custom.min.css" />
<!-- Bootstrap CSS -->
<link href="<TMPL_VAR NAME="DIR">/css/bootstrap.css" rel="stylesheet">
<link href="<TMPL_VAR NAME="DIR">/css/bootstrap-theme.css" rel="stylesheet">
<!-- Manager CSS -->
<link rel="stylesheet" type="text/css" id="cssmenu" href="<TMPL_VAR NAME="DIR">/css/<TMPL_VAR NAME="CSS">" />
<script src="<TMPL_VAR NAME="DIR">/js/jquery-1.10.2.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/bootstrap.js"></script>
<script src="<TMPL_VAR NAME="DIR">/js/jquery-ui-1.10.3.custom.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/jquery.cookie.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/jquery.ajaxfileupload.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/jquery.elastic.source.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/tree.js" type="text/JavaScript"></script>
<script type="text/JavaScript">//<![CDATA[
	var scriptname='<TMPL_VAR NAME="SCRIPT_NAME">';
	var imagepath='<TMPL_VAR NAME="DIR">/images/';
	var csspath='<TMPL_VAR NAME="DIR">/css/';
	var jqueryuiversion='1.10.3';
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
	var lang='<TMPL_VAR NAME="LANG">';
//]]></script>
<script src="<TMPL_VAR NAME="DIR">/js/manager.js" type="text/JavaScript"></script>
</head>
<body>

<!-- Popup -->
<div id="popup" title="<lang en="Command result" fr="Résultat de la commande" />">
</div>

<!-- Skin picker-->
<div id="skinImagePicker" title="<lang en="Choose a skin" fr="Choisir un thème" />">
     <button><img src="<TMPL_VAR NAME="DIR">/images/portal-skins/bootstrap.png" alt="Bootstrap" title="bootstrap" width="200px" height="129px" /></button>
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

<!-- Container -->
<div class="container-fluid">

  <div class="row">
    <div class="col-sm-3">

    <!-- Menu (tree) -->
    <div id="menu" class="panel panel-default panel-body">
      <TMPL_VAR NAME="MENU">
    </div>

    </div>
    <div class="col-sm-9">

   <!-- Buttons -->
   <div id="buttons" class="panel panel-default">
    <div class="panel-heading">
    <h1 class="panel-title">
     <lang en="Available actions" fr="Actions disponibles" />
    </h1>
    </div>

    <div id="buttons_content" class="panel-body">
    <button id="bsave" onclick="uploadConf()" class="btn btn-info">
     <i class=" glyphicon glyphicon-floppy-disk"></i>
     <lang en="Save" fr="Sauver" />
    </button>

    <button id="bnewvh" style="display:none;" onclick="newVh();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New virtual host" fr="Nouvel hôte virtuel" />
    </button>

    <button id="bdelvh" style="display:none;" onclick="delvh(currentId);" class="btn btn-danger">
     <i class=" glyphicon glyphicon-minus-sign"></i>
     <lang en="Delete virtual host" fr="Supprimer l'hôte virtuel" />
    </button>

    <button id="newkbr" style="display:none;" onclick="newKeyR();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New key" fr="Nouvelle clef" />
    </button>

    <button id="newrbr" style="display:none;" onclick="newRuleR();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New rule" fr="Nouvelle règle" />
    </button>

    <button id="newgsrbr" style="display:none;" onclick="newGrantSessionRuleR();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New condition" fr="Nouvelle condition" />
    </button>

    <button id="newkb" style="display:none;" onclick="newKey();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New key" fr="Nouvelle clef" />
    </button>

    <button id="newrb" style="display:none;" onclick="newRule();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New rule" fr="Nouvelle règle" />
    </button>

    <button id="newgsrb" style="display:none;" onclick="newGrantSessionRule();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New condition" fr="Nouvelle condition" />
    </button>

    <button id="delkb" style="display:none;" onclick="delKey();return false;" class="btn btn-danger">
     <i class=" glyphicon glyphicon-minus-sign"></i>
     <lang en="Delete key" fr="Effacer la clef" />
    </button>

    <button id="newidpsamlmetadatab" style="display:none;" onclick="newIdpSamlMetaData();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New identity provider" fr="Nouveau fournisseur d'identité" />
    </button>

    <button id="delidpsamlmetadatab" style="display:none;" onclick="delIdpSamlMetaData(currentId);" class="btn btn-danger">
     <i class=" glyphicon glyphicon-minus-sign"></i>
     <lang en="Delete identity provider" fr="Supprimer le fournisseur d'identité" />
    </button>

    <button id="newspsamlmetadatab" style="display:none;" onclick="newSpSamlMetaData();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New service provider" fr="Nouveau fournisseur de service" />
    </button>

    <button id="delspsamlmetadatab" style="display:none;" onclick="delSpSamlMetaData(currentId);" class="btn btn-danger">
     <i class=" glyphicon glyphicon-minus-sign"></i>
     <lang en="Delete service provider" fr="Supprimer le fournisseur de service" />
    </button>

    <button id="newsamlattributeb" style="display:none;" onclick="newSamlAttribute();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New attribute" fr="Nouvel attribut" />
    </button>

    <button id="newsamlattributebr" style="display:none;" onclick="newSamlAttributeR();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New attribute" fr="Nouvel attribut" />
    </button>

    <button id="delsamlattributeb" style="display:none;" onclick="delSamlAttribute();return false;" class="btn btn-danger">
     <i class=" glyphicon glyphicon-minus-sign"></i>
     <lang en="Delete attribute" fr="Supprimer l'attribut" />
    </button>

    <button id="newchoice" style="display:none;" onclick="newChoice();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New choice" fr="Nouveau choix" />
    </button>

    <button id="newchoicer" style="display:none;" onclick="newChoiceR();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New choice" fr="Nouveau choix" />
    </button>

    <button id="delchoice" style="display:none;" onclick="delChoice();return false;" class="btn btn-danger">
     <i class=" glyphicon glyphicon-minus-sign"></i>
     <lang en="Delete choice" fr="Supprimer le choix" />
    </button>

    <button id="newcategoryr" style="display:none;" onclick="newCategoryR();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New category" fr="Nouvelle catégorie" />
    </button>

    <button id="delcategory" style="display:none;" onclick="delCategory();return false;" class="btn btn-danger">
     <i class=" glyphicon glyphicon-minus-sign"></i>
     <lang en="Delete category" fr="Supprimer la catégorie" />
    </button>

    <button id="newapplicationr" style="display:none;" onclick="newApplicationR();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New application" fr="Nouvelle application" />
    </button>

    <button id="delapplication" style="display:none;" onclick="delApplication();return false;" class="btn btn-danger">
     <i class=" glyphicon glyphicon-minus-sign"></i>
     <lang en="Delete application" fr="Supprimer l'application" />
    </button>

    <button id="newpostr" style="display:none;" onclick="newPostR();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New form" fr="Nouveau formulaire" />
    </button>

    <button id="delpost" style="display:none;" onclick="delPost();return false;" class="btn btn-danger">
     <i class=" glyphicon glyphicon-minus-sign"></i>
     <lang en="Delete form" fr="Supprimer le formulaire" />
    </button>

    <button id="newpostdatar" style="display:none;" onclick="newPostDataR();return false;" class="btn btn-success">
     <i class=" glyphicon glyphicon-plus-sign"></i>
     <lang en="New POST data" fr="Nouvelle donnée POST" />
    </button>

    <button id="delpostdata" style="display:none;" onclick="delPostData();return false;" class="btn btn-danger">
     <i class=" glyphicon glyphicon-minus-sign"></i>
     <lang en="Delete POST data" fr="Supprimer la donnée POST" />
    </button>

    </div>

   <!-- Buttons -->
   </div>

  
   <!-- Edition -->
   <div id="edition" class="panel panel-default">

    <div class="panel-heading">
    <h1 class="panel-title">
     <lang en="Edit key " fr="Édition de la clé " /><span id="content_title">&nbsp;</span>
    </h1>
    </div>

   <form action="#" onsubmit="return false"i role="form">

   <!-- Edition content -->
   <div id="content" class="panel-body">

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
     <input type="text" id="text" class="form-control" />
     <br />
     <button onclick="setlminputdata(currentId,text);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Simple textarea -->
    <div id="content_textarea" class="hidden">
     <textarea id="textarea" cols="80" rows="10" class="form-control"></textarea>
     <br />
     <button onclick="setlminputdata(currentId,textarea);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- File textarea -->
    <div id="content_filearea" class="hidden">
     <textarea readonly="readonly" id="filearea" cols="80" rows="10" class="form-control"></textarea>
     <div class="buttons">
      <button id="downloadfile" onclick="downloadFile(currentId);return false;" class="btn btn-info">
       <i class="glyphicon glyphicon-floppy-save"></i>
       <lang en="Download this file" fr="T&eacute;l&eacute;charger ce fichier" />
      </button>
      <button id="generatefile" onclick="generateFile(currentId);return false;" class="btn btn-info">
       <i class="glyphicon glyphicon-flash"></i>
       <lang en="Generate" fr="G&eacute;n&eacute;rer" />
      </button>
      <button id="switchreadonly" onclick="switchReadonly('#filearea');return false;" class="btn btn-info">
       <i class="glyphicon glyphicon-lock"></i>
       <span></span>
      </button>
      <button onclick="setlminputdata(currentId,filearea);return false;" class="btn btn-info">
       <i class="glyphicon glyphicon-ok"></i>
       <lang en="Apply" fr="Appliquer" />
      </button>
      <span class="loadimg"><img class="hidden" id="button-loadimg" src="<TMPL_VAR NAME="DIR">/images/spinner.gif" width="16px" height="16px" /></span>
     </div>
     <table class="table">
      <tr id="fileinput">
       <th><lang en="Load from a file" fr="Charger depuis un fichier" /> :</th>
       <td>
        <input type="file" name="file" id="file" size="30" />
       </td>
       <td>
        <button onclick="setlmfile(currentId,file);return false;" class="btn btn-info"><i class="glyphicon glyphicon-floppy-open"></i> <lang en="Load" fr="Charger" /></button>
        <span class="loadimg"><img class="hidden" id="file-loadimg" src="<TMPL_VAR NAME="DIR">/images/spinner.gif" width="16px" height="16px" /></span>
       </td>
      </tr>
      <tr id="urlinput">
       <th><lang en="Load from a URL" fr="Charger depuis une URL" /> :</th>
       <td>
        <input type="text" name="url" id="url" size="40" class="form-control"/>
       </td>
       <td>
        <button onclick="setlmfile(currentId,url);return false;" class="btn btn-info"><i class="glyphicon glyphicon-cloud-upload"></i> <lang en="Load" fr="Charger" /></button>
        <span class="loadimg"><img class="hidden" id="url-loadimg" src="<TMPL_VAR NAME="DIR">/images/spinner.gif" width="16px" height="16px" /></span>
       </td>
      </tr>
     </table>
    </div>

    <!-- Select -->
    <div id="content_select" class="hidden">
     <select id="select" onchange="setlmdata(currentId,this.value);return false;" class="form-control"></select>
    </div>

    <!-- Integer -->
    <div id="content_int" class="hidden">
     <button onclick="decrease();return false;" class="btn btn-warning"><i class="glyphicon glyphicon-minus"></i></button>
     <input type="text" id="int" />
     <button onclick="increase();return false;" class="btn btn-warning"><i class="glyphicon glyphicon-plus"></i></button>
     <br />
     <button onclick="setlminputdata(currentId,int);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Boolean -->
    <div id="content_bool" class="hidden">
     <div class="btn-group" data-toggle="buttons">
     <label id="On" class="btn btn-info" onclick="setlmdata(currentId,1)">
     <input type="radio" name="boolean" autocomplete="off" /><lang en="On" fr="Activé"/>
     </label>
     <label id="Off" class="btn btn-info" onclick="setlmdata(currentId,0)">
     <input type="radio" name="boolean" autocomplete="off" /><lang en="Off" fr="Désactivé"/>
     </label>
     </div>
    </div>

    <!-- Troolean -->
    <div id="content_trool" class="hidden">
     <div class="btn-group" data-toggle="buttons">
     <label id="TrOn" class="btn btn-info" onclick="setlmdata(currentId,1)">
     <input type="radio" name="troolean" autocomplete="off" /><lang en="On" fr="Activé"/>
     </label>
     <label id="TrOff" class="btn btn-info" onclick="setlmdata(currentId,0)">
     <input type="radio" name="troolean" autocomplete="off" /><lang en="Off" fr="Désactivé"/>
     </label>
     <label id="TrDefault" class="btn btn-info" onclick="setlmdata(currentId,-1)">
     <input type="radio" name="troolean" autocomplete="off" /><lang en="Default" fr="Par défaut"/>
     </label>
     </div>
    </div>

    <!-- Boolean or Perl Expr -->
    <div id="content_boolOrPerlExpr" class="hidden">
     <div class="btn-group buttons" data-toggle="buttons">
     <label id="bopeOn" class="btn btn-info" onclick="setlmdata(currentId,1);$('#bopeValue').hide();">
     <input type="radio" name="bope" autocomplete="off" /><lang en="On" fr="Activé"/>
     </label>
     <label id="bopeOff" class="btn btn-info" onclick="setlmdata(currentId,0);$('#bopeValue').hide();">
     <input type="radio" name="bope" autocomplete="off" /><lang en="Off" fr="Désactivé"/>
     </label>
     <label id="bopeExpr" class="btn btn-info" onclick="$('#bopeValue').show();">
     <input type="radio" name="bope" autocomplete="off" /><lang en="Specific rule" fr="Règle spécifique"/>
     </label>
     </div>
     <textarea id="bopeValue" cols="30" rows="2" class="form-control"></textarea>
     <div class="buttons text-center">
     <button onclick="setlmbope(currentId);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
     </div>
    </div>


    <div id="content_btext" class="hidden">
     <textarea class="elastic" id="btextKey" rows="1" cols="25" class="form-control"></textarea>
     <textarea class="elastic" id="btextValue" rows="1" cols="40" class="form-control"></textarea>
     <br />
     <button onclick="setlminputtext(currentId,btextKey);setlminputdata(currentId,btextValue);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Rule -->
    <div id="content_rules" class="hidden">
     <table border="0"><tbody><tr><td>
      <div id="rulCommentDiv">
       <lang en="Comment" fr="Commentaire" /><br/>
       <textarea class="elastic" id="rulComment" rows="1" cols="30" class="form-control"></textarea>
      </div>
      <lang en="Expression" fr="Expression" /><br/>
      <textarea class="elastic" id="rulKey" rows="1" cols="30" class="form-control"></textarea>
     </td>
     <td>
      <lang en="Rule" fr="Règle" /><br/>
      <textarea class="elastic" id="rulValue" rows="1" cols="50" class="form-control"></textarea>
     </td></tr></tbody></table>
     <br />
     <button onclick="setlmrule(currentId,rulComment,rulKey,rulValue);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Grant session rule -->
    <div id="content_grantSessionRules" class="hidden">
     <table border="0"><tbody><tr><td>
      <div id="grantSessionRulCommentDiv">
       <lang en="Comment" fr="Commentaire" /><br/>
       <textarea class="elastic" id="grantSessionRulComment" rows="1" cols="30" class="form-control"></textarea>
      </div>
      <lang en="Condition" fr="Condition" /><br/>
      <textarea class="elastic" id="grantSessionRulKey" cols="30" rows="1" class="form-control"></textarea>
     </td>
     <td>
         <lang en="Message" fr="Message" /><br/>
         <textarea class="elastic" id="grantSessionRulValue" cols="50" rows="1" class="form-control"></textarea>
     </td></tr></tbody></table>
     <br />
     <button onclick="setlmgrantsessionrule(currentId,grantSessionRulComment,grantSessionRulKey,grantSessionRulValue);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- authParams -->
    <div id="content_authParams" class="hidden">
     <select id="authText" class="form-control"></select>
     <br/>
     <input type="text" id="authOptions" class="hidden" size="30" class="form-control"/>
     <br/>
     <button onclick="reloadAuthParams();return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Skin -->
    <div id="content_skin" class="hidden">
     <button class="current"><img src="" alt="" class="current" /></button>
     <br /> 
     <input id="skinText" type="text" readonly="readonly" class="form-control"/>
     <br />
     <button onclick="setlminputdata(currentId,skinText);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- Vhost -->
    <div id="content_vhost" class="hidden">
     <input type="text" id="vhost" size="30" class="form-control"/>
     <br />
     <button onclick="setlminputtext(currentId,vhost);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- samlIdpMetaData -->
    <div id="content_samlIdpMetaData" class="hidden">
     <input type="text" id="samlIdpMetaData" size="30" class="form-control"/>
     <br />
     <button onclick="setlminputtext(currentId,samlIdpMetaData);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- samlSpMetaData -->
    <div id="content_samlSpMetaData" class="hidden">
     <input type="text" id="samlSpMetaData" size="30" class="form-control"/>
     <br />
     <button onclick="setlminputtext(currentId,samlSpMetaData);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- samlAttribute -->
    <div id="content_samlAttribute" class="hidden">
     <table>
      <tr>
       <td><lang en="Key name" fr="Nom de la clef"/></td>
       <td><input type="text" id="samlAttributeKey" class="form-control"/></td>
      </tr>
      <tr>
       <td><lang en="Name" fr="Nom"/></td>
       <td><input type="text" id="samlAttributeName" class="form-control"/></td>
       <td><lang en="Mandatory" fr="Obligatoire"/></td>
       <td><input id="samlAttributeMandatoryOn" type="radio" name="samlAttributeMandatoryBoolean" value="1" /><label for="samlAttributeMandatoryOn"><lang en="On" fr="Activé"/></label>
           <input id="samlAttributeMandatoryOff" type="radio" name="samlAttributeMandatoryBoolean" value="0" /><label for="samlAttributeMandatoryOff"><lang en="Off" fr="Désactivé"/></label>
       </td>
      </tr>
      <tr>
       <td><lang en="Friendly name" fr="Nom alternatif"/></td>
       <td><input type="text" id="samlAttributeFriendlyName" class="form-control"/></td>
       <td><lang en="Format" fr="Format"/></td>
       <td><select id="samlAttributeFormat" class="form-control"></select></td>
      </tr>
     </table>
     <br />
     <button onclick="setlmsamlattribute(currentId);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
   </div>

    <!-- samlAssertion -->
    <div id="content_samlAssertion" class="hidden">
     <table>
      <tr>
       <td><lang en="Default" fr="Par défaut"/></td>
       <td><input id="samlAssertionDefaultOn" type="radio" name="samlAssertionDefaultBoolean" value="1" /><label for="samlAssertionDefaultOn"><lang en="On" fr="Activé"/></label>
           <input id="samlAssertionDefaultOff" type="radio" name="samlAssertionDefaultBoolean" value="0" /><label for="samlAssertionDefaultOff"><lang en="Off" fr="Désactivé"/></label>
       </td>
      </tr>
      <tr class="hidden">
       <td><lang en="Index" fr="Index"/></td>
       <td><input type="text" size="50" id="samlAssertionIndex" class="form-control"/></td>
      </tr>
      <tr>
       <td><lang en="Binding" fr="Binding"/></td>
       <td><select disabled="disabled" id="samlAssertionBinding" class="form-control"></select></td>
      </tr>
      <tr>
       <td><lang en="Location" fr="URL"/></td>
       <td><input type="text" size="50" id="samlAssertionLocation" class="form-control"/></td>
      </tr>
     </table>
     <br />
     <button onclick="setlmsamlassertion(currentId);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- samlService -->
    <div id="content_samlService" class="hidden">
     <table>
      <tr>
       <td><lang en="Binding" fr="Binding"/></td>
       <td><select disabled="disabled" id="samlServiceBinding" class="form-control"></select></td>
      </tr>
      <tr>
       <td><lang en="Location" fr="URL"/></td>
       <td><input type="text" size="50" id="samlServiceLocation" class="form-control"/></td>
      </tr>
      <tr>
       <td><lang en="Response Location" fr="URL de retour"/></td>
       <td><input type="text" size="50" id="samlServiceResponseLocation" class="form-control"/></td>
      </tr>
     </table>
     <br />
     <button onclick="setlmsamlservice(currentId);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- OpenID black/white lists -->
    <div id="content_openid_serverlist" class="hidden">
     <table>
      <tr>
       <td><lang en="List type" fr="Type de liste"/></td>
       <td><input id="openid_serverlist_black" type="radio" name="openIdServerlistBoolean" value="0" /><label for="openid_serverlist_black"><lang en="Black list" fr="Liste noire"/></label>
           <input id="openid_serverlist_white" type="radio" name="openIdServerlistBoolean" value="1" /><label for="openid_serverlist_white"><lang en="White list" fr="Liste blanche"/></label>
       </td>
      </tr>
      <tr>
       <td><lang en="List" fr="Liste"/></td>
       <td><input type="text" size="50" id="openid_serverlist_text" class="form-control"/></td>
      </tr>
     </table>
     <br />
     <button onclick="setopenididplist(currentId);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

    <!-- authChoice -->
    <div id="content_authChoice" class="hidden">
     <table>
      <tr>
       <td><lang en="Key name" fr="Nom de la clef"/></td>
       <td><input type="text" id="authChoiceKey" class="form-control"/></td>
      </tr>
      <tr>
       <td><lang en="Authentication module" fr="Module d'authentification"/></td>
       <td><select id="authChoiceAuth" class="form-control"></select></td>
      </tr>
      <tr>
       <td><lang en="User module" fr="Module d'utilisateurs"/></td>
       <td><select id="authChoiceUser" class="form-control"></select></td>
      </tr>
      <tr>
       <td><lang en="Password module" fr="Module de mots de passe"/></td>
       <td><select id="authChoicePassword" class="form-control"></select></td>
      </tr>
      <tr>
       <td><lang en="URL" fr="URL"/></td>
       <td><input type="text" id="authChoiceURL" class="form-control"/></td>
      </tr>
     </table>
     <br />
     <button onclick="setlmauthchoice(currentId);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
   </div>

    <!-- applicationList Category-->
    <div id="content_applicationListCategory" class="hidden">
     <table class="table">
      <tr>
       <th><lang en="Key" fr="Nom de la clef"/></th>
       <td><input type="text" id="applicationListCategoryKey" class="form-control"/></td>
      </tr>
      <tr>
       <th><lang en="Display name" fr="Nom à afficher"/></th>
       <td><input type="text" id="applicationListCategoryName" class="form-control"/></td>
      </tr>
     </table>
     <div class="buttons text-center">
     <button onclick="setlminputtext(currentId,'#applicationListCategoryKey');setlminputdata(currentId,'#applicationListCategoryName');return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
     </div>
    </div>

    <!-- applicationList Application-->
    <div id="content_applicationListApplication" class="hidden">
     <table class="table">
      <tr>
       <th><lang en="Key" fr="Nom de la clef"/></th>
       <td><input type="text" id="applicationListApplicationKey" class="form-control"/></td>
       <th><lang en="Display name" fr="Nom à afficher"/></th>
       <td><input type="text" id="applicationListApplicationName" class="form-control"/></td>
      </tr>
      <tr>
       <th><lang en="Address" fr="Adresse"/></th>
       <td><input type="text" id="applicationListApplicationURL" class="form-control"/></td>
       <th><lang en="Display mode" fr="Mode d'affichage"/></th>
       <td><select id="applicationListApplicationDisplay" class="form-control"></select></td>
      </tr>
      <tr>
       <th><lang en="Description" fr="Description"/></th>
       <td><textarea id="applicationListApplicationDescription" class="form-control"/></textarea></td>
       <th><lang en="Logo" fr="Logo"/></th>
       <td>
         <div class="input-group">
         <span class="input-group-btn">
         <button class="current btn btn-default" role="button"><img src="" alt="" class="current" /></button>
         </span>
         <input type="text" id="applicationListApplicationLogo" readonly="readonly" class="form-control"/>
         </div>
       </td>
      </tr>
     </table>
     <div class="buttons text-center">
     <button onclick="setlmapplication(currentId);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
     </div>
    </div>

    <!-- Post -->
    <div id="content_post" class="hidden">
     <table>
      <tr>
       <td><lang en="Form URL" fr="URL du formulaire"/></td>
       <td><input type="text" id="postKey" size="20" class="form-control"/></td>
       <td><lang en="jQuery form selector (optional)" fr="Sélecteur jQuery du formulaire (optionnel)"/></td>
       <td><input type="text" id="formSelector" size="20" class="form-control"/></td>
      </tr>
      <tr>
       <td><lang en="Target URL (optional)" fr="URL cible (optionnelle)"/></td>
       <td><input type="text" id="postUrl" size="20" class="form-control"/></td>
       <td><lang en="jQuery button selector (optional)" fr="Sélecteur jQuery du bouton (optionnel)"/></td>
       <td><input type="text" id="buttonSelector" size="20" class="form-control"/></td>
      </tr>
      <tr>
       <td><lang en="jQuery URL (optional)" fr="URL de jQuery (optionnelle)"/></td>
       <td colspan="3"><input type="text" id="jqueryUrl" size="60"/></td>
      </tr>
     </table>
     <br />
     <button onclick="setlminputtext(currentId,postKey);setlmpostform(currentId);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>
 
    <div id="content_postdata" class="hidden">
     <input type="text" id="postDataKey" class="form-control"/> <input type="text" id="postDataValue" class="form-control"/>
     <br />
     <button onclick="setlminputtext(currentId,postDataKey,'postdata:');setlminputdata(currentId,postDataValue);return false;" class="btn btn-info">
     <i class="glyphicon glyphicon-ok"></i>
     <lang en="Apply" fr="Appliquer" />
     </button>
    </div>

   </div>

   </form>

   <!-- Edition -->
   </div>


<!-- Help -->
<div id="help" class="panel panel-default">

  <div class="panel-heading">
  <h1 class="panel-title">
    <lang en="Help" fr="Aide"/>
  </h1>
  </div>

  <div id="help_content" class="panel-body">
  <!-- AJAX content -->
     <lang en="Click on the configuration tree to edit parameters" fr="Cliquer sur l'arbre de configuration pour éditer les paramètres" />
  </div>

<!-- Help -->
</div>

<!-- Container -->
    </div>
  </div>
</div>

</body>
</html>
