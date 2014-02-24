<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title><lang en="LemonLDAP::NG session explorer" fr="Explorateur de sessions LemonLDAP::NG"/></title>
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
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">" alt="user"><lang en="per user" fr="par utilisateur" /></a>
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">?ipclasses=1" alt="ip"><lang en="per IP" fr="par IP" /></a>
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">?doubleIp=1" alt="2ip"><lang en="double IP" fr="doubles IP" /></a>
   </div>

   <TMPL_VAR NAME="TREE">
</div>

<!-- Data -->
<div id="data" class="ui-corner-all ui-helper-clearfix ui-widget-content">
<!-- Container -->
</div>

</body>
</html>
