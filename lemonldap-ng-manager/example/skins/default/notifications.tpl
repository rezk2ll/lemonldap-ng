<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title><lang en="LemonLDAP::NG notification explorer" fr="Explorateur de notifications LemonLDAP::NG"/></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="Content-Script-Type" content="text/javascript" />
<meta http-equiv="cache-control" content="no-cache" />
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="icon" type="image/x-icon" />
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="shortcut icon" />
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
        var lang='<TMPL_VAR NAME="LANG">';
//]]></script>
<script src="<TMPL_VAR NAME="DIR">/js/manager.js" type="text/JavaScript"></script>
</head>
<body>

<TMPL_INCLUDE NAME="top.tpl">

<!-- Container -->
<div class="container-fluid">

  <div class="row">
    <div class="col-sm-3">

    <!-- Menu (tree) -->
    <div id="menu" class="panel panel-default panel-body text-center">

    <!-- Query choice -->
    <div id="query-switch" class="btn-group btn-group-justified" role="group">
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">" alt="list" class="btn btn-info"><i class="glyphicon glyphicon-eye-open"></i> <lang en="Active" fr="Actives" /></a>
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">?listDone=1" alt="listDone" class="btn btn-info"><i class="glyphicon glyphicon-eye-close"></i> <lang en="Done" fr="Validées" /></a>
      <a alt="newNotif" onclick="newNotif()" class="btn btn-info"><i class="glyphicon glyphicon-plus-sign"></i> <lang en="Create" fr="Créer" /></a>
    </div>

    <hr />
    <TMPL_VAR NAME="TREE">
    </div>

    </div>
    <div class="col-sm-9">

    <!-- Data -->
    <div id="data" class="panel panel-default">
    </div>

    </div>
  </div>
</div>

<!-- Form to create a new notification -->
<div id="newNotif" style="display: none">
<div class="panel-heading">
<h1 class="panel-title text-center"><lang en="New notification" fr="Nouvelle notification" /></h1>
</div>
<div class="panel-body">
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
<div id="newNotifHelp" class="alert alert-info">
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
<div class="text-center">
<a id="sendNewNotif" onclick=sendNewNotif() class="btn btn-success"><i class="glyphicon glyphicon-plus-sign"></i> <lang en="Create" fr="Créer" /></a>
</div>
</div>
</div>
</body>
</html>
