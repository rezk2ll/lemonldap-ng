<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title><lang en="Lemonldap::NG Session Explorer" fr="Explorateur de sessions Lemonldap::NG"/></title>
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="icon" type="image/x-icon" />
<link href="<TMPL_VAR NAME="DIR">/lemonldap-ng.ico" rel="shortcut icon" />
<link rel="stylesheet" type="text/css" title="menu" href="<TMPL_VAR NAME="DIR">/<TMPL_VAR NAME="CSS">" />
<link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="DIR">/jquery-ui-1.7.2.custom.css" />
<script src="/javascript/jquery/jquery.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/jquery-ui-1.7.2.custom.min.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/jquery.cookie.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/tree.js" type="text/JavaScript"></script>
<script src="<TMPL_VAR NAME="DIR">/sessions.js" type="text/JavaScript"></script>
<script type="text/JavaScript">//<![CDATA[
	var scriptname='<TMPL_VAR NAME="SCRIPT_NAME">';
	var imagepath='<TMPL_VAR NAME="DIR">/';
	var treeautoclose='<TMPL_VAR NAME="TREE_AUTOCLOSE">';
    var treejquerycss='false';
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
   <p class="ui-state-default ui-corner-all"><a href="index.pl"><lang en="Configuration management" fr="Gestion de la configuration"/></a></p>
   <p class="ui-state-default ui-corner-all ui-state-active"><a href="sessions.pl"><lang en="Sessions explorer" fr="Explorateur de sessions"/></a></p>
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

   <!-- Query choice -->
   <div class="ui-corner-all ui-widget-header" style="text-align:center;">
      <span><lang en="Query" fr="Requête" /></span>
   </div>
   <div id="query-switch" class="ui-corner-all ui-widget-content">
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">" alt="user"><lang en="per user" fr="par utilisateur" /></a>
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">?ipclasses=1" alt="ip"><lang en="per IP" fr="par IP" /></a>
      <a href="<TMPL_VAR NAME="SCRIPT_NAME">?doubleIp=1" alt="2ip"><lang en="double IP" fr="doubles IP" /></a>
   </div>

   <TMPL_VAR NAME="TREE">
</div>

<!-- Data -->
<div id="data">
<!-- Container -->
</div>

</body>
</html>
