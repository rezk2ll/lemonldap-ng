<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title><lang en="LemonLDAP::NG notification explorer" fr="Explorateur de notifications LemonLDAP::NG"/></title>
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="icon" type="image/x-icon" />
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="shortcut icon" />
<!-- jQuery UI CSS -->
<link rel="stylesheet" type="text/css" id="csstheme" href="<TMPL_VAR NAME="DIR">/<TMPL_VAR NAME="CSS_THEME">/jquery-ui-1.10.3.custom.min.css" />
<!-- Manager CSS -->
<link rel="stylesheet" type="text/css" id="cssmenu" href="<TMPL_VAR NAME="DIR">/css/<TMPL_VAR NAME="CSS">" />
<script src="<TMPL_VAR NAME="DIR">/js/jquery-1.10.2.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/jquery-ui-1.10.3.custom.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/jquery.cookie.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/tree.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/js/notifications.js" type="text/JavaScript"></script>
<script type="text/JavaScript">//<![CDATA[
	var scriptname='<TMPL_VAR NAME="SCRIPT_NAME">';
	var imagepath='<TMPL_VAR NAME="DIR">/images/';
	var csspath='<TMPL_VAR NAME="DIR">/css/';
        var jqueryuiversion='1.10.3';
        var css_menu='<TMPL_VAR NAME="CSS">';
        var css_theme='<TMPL_VAR NAME="CSS_THEME">';
        var themepath='<TMPL_VAR NAME="DIR">/';
	var treejquerycss='false';
	var treeautoclose='false';
//]]></script>
<script src="<TMPL_VAR NAME="DIR">/js/manager.js" type="text/JavaScript"></script>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>

<TMPL_INCLUDE NAME="top.tpl">

<!-- Menu (tree) -->
<div id="menu" class="ui-corner-all ui-helper-clearfix ui-widget-content">

   <!-- Query choice -->
   <div class="ui-corner-all ui-widget-header" style="text-align:center;">
      <span><lang en="Query" fr="Requête" /></span>
   </div>
   <div id="query-switch">
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">" alt="list"><lang en="Active" fr="Actives" /></a>
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">?listDone=1" alt="listDone"><lang en="Done" fr="Validées" /></a>
      <a alt="newNotif" onclick="newNotif()"><lang en="Create" fr="Créer" /></a>
   </div>

   <TMPL_VAR NAME="TREE">
</div>

<!-- Data -->
<div id="data" class="ui-corner-all ui-helper-clearfix ui-widget-content">
<!-- Container -->
</div>

<!-- Form to create a new notification -->
<div id="newNotif" style="display: none">
<h1 class="ui-widget-header ui-corner-all"><lang en="New notification" fr="Nouvelle notification" /></h1>
<table style="width:70%;margin: 10px auto;">
  <tr>
    <th style="text-align:right;"><label for="uid"><lang en="User login:" fr="Identifiant de l'utilisateur :" /></label></th>
    <td><input id="uid" type="text" /></td>
  </tr>
  <tr>
    <th style="text-align:right;"><label for="date"><lang en="Date:" fr="Date :" /></label></th>
    <td><input id="date" type="text" /></td>
  </tr>
  <tr>
    <th style="text-align:right;"><label for="ref"><lang en="Reference:" fr="Référence :" /></label></th>
    <td><input id="ref" type="text" /></td>
  </tr>
  <tr>
    <th style="text-align:right;"><label for="condition">Condition <lang en="(optional):" fr="(optionnelle) :" /></label></th>
    <td><input id="condition" type="text" /></td>
  </tr>
  <tr><td colspan="2">
<div id="newNotifHelp" class="ui-widget-content ui-corner-all" style="text-align:left;padding: 5px;">
<lang en="Set XML content here. You can use the following markups:" fr="Insérer le contenu XML ici. Vous pouvez utiliser les balises suivantes :" />
<ul>
<li><tt>&lt;title&gt;</tt><lang en="a title" fr="un titre" /><tt>&lt;/title&gt;</li>
<li><tt>&lt;subtitle&gt;</tt><lang en="a subtitle" fr="un sous-titre" /><tt>&lt;/subtitle&gt;</li>
<li><tt>&lt;text&gt;</tt><lang en="some text" fr="du texte" /><tt>&lt;/text&gt;</li>
<li><tt>&lt;check&gt;</tt><lang en="a checkbox" fr="une case à cocher" /><tt>&lt;/check&gt;</li>
</ul>
</div>
  </td></tr>
  <tr><td colspan="2">
    <textarea rows="10" cols="80" id="xml"></textarea><br />
  </td></tr>
  </table>
<a id="sendNewNotif" onclick=sendNewNotif()><lang en="Create" fr="Créer" /></a>
</div>
</body>
</html>
