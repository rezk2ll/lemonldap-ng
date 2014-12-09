<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title><lang en="LemonLDAP::NG session explorer" fr="Explorateur de sessions LemonLDAP::NG"/></title>
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
<script src="<TMPL_VAR NAME="DIR">/js/sessions.js" type="text/JavaScript"></script>
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
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">" alt="user" class="btn btn-info"><i class="glyphicon glyphicon-user"></i> <lang en="User" fr="Utilisateur" /></a>
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">?ipclasses=1" alt="ip" class="btn btn-info"><i class="glyphicon glyphicon-tag"></i> <lang en="IP" fr="IP" /></a>
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">?doubleIp=1" alt="2ip" class="btn btn-info"><i class="glyphicon glyphicon-tags"></i> <lang en="Multi IP" fr="Multi IP" /></a>
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

</body>
</html>
