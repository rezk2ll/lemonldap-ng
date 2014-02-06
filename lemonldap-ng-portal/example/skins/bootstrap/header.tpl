<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
 <title><lang en="Authentication portal" fr="Portail d'authentification"/></title>
 <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
 <meta http-equiv="Content-Script-Type" content="text/javascript" />
 <meta http-equiv="cache-control" content="no-cache" />
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <TMPL_IF NAME="browserIdEnabled">
  <meta http-equiv="X-UA-Compatible" content="IE=Edge">
 </TMPL_IF>
 <link href="<TMPL_VAR NAME="SKIN_PATH">/<TMPL_VAR NAME="SKIN">/css/bootstrap.min.css" rel="stylesheet">
 <link href="<TMPL_VAR NAME="SKIN_PATH">/<TMPL_VAR NAME="SKIN">/css/bootstrap-theme.min.css" rel="stylesheet">
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="SKIN_PATH">/<TMPL_VAR NAME="SKIN">/css/styles.css" />
 <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
 <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
 <!--[if lt IE 9]>
   <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
   <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
 <![endif]-->
 <link href="<TMPL_VAR NAME="SKIN_PATH">/common/favicon.ico" rel="icon" type="image/x-icon" />
 <link href="<TMPL_VAR NAME="SKIN_PATH">/common/favicon.ico" rel="shortcut icon" />
 <TMPL_IF NAME="PROVIDERURI">
  <link rel="openid.server" href="<TMPL_VAR NAME="PROVIDERURI">" />
  <link rel="openid2.provider" href="<TMPL_VAR NAME="PROVIDERURI">" />
 </TMPL_IF>
 <script type="text/javascript" src="<TMPL_VAR NAME="SKIN_PATH">/common/js/jquery-1.10.2.min.js"></script>
 <script type="text/javascript" src="<TMPL_VAR NAME="SKIN_PATH">/common/js/jquery-ui-1.10.3.custom.min.js"></script>
 <script type="text/javascript" src="<TMPL_VAR NAME="SKIN_PATH">/common/js/jquery.base64.js"></script>
 <script type="text/javascript" src="<TMPL_VAR NAME="SKIN_PATH">/common/js/jquery.cookie.js"></script>
 <script src="<TMPL_VAR NAME="SKIN_PATH">/<TMPL_VAR NAME="SKIN">/js/skin.js"></script>
 <TMPL_IF NAME="browserIdEnabled">
  <script src="https://login.persona.org/include.js"></script>
 </TMPL_IF>
 <TMPL_IF NAME="browserIdLoadLoginScript">
  <script type="text/javascript">//<![CDATA[
     var browserIdSiteName="<TMPL_VAR NAME="browserIdSiteName">";
     var browserIdSiteLogo="<TMPL_VAR NAME="browserIdSiteLogo">";
     var browserIdBackgroundColor="<TMPL_VAR NAME="browserIdBackgroundColor">";
     var browserIdAutoLogin="<TMPL_VAR NAME="browserIdAutoLogin">";
  //]]></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="SKIN_PATH">/common/js/browserid.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="SKIN_PATH">/common/js/browseridlogin.js"></script>
 </TMPL_IF>
 <TMPL_IF NAME="browserIdLoadLogoutScript">
  <script type="text/javascript" src="<TMPL_VAR NAME="SKIN_PATH">/common/js/browserid.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="SKIN_PATH">/common/js/browseridlogout.js"></script>
 </TMPL_IF>
 <script type="text/javascript">//<![CDATA[
    var displaytab="<TMPL_VAR NAME="DISPLAY_TAB">";
    var choicetab="<TMPL_VAR NAME="CHOICE_VALUE">";
    var autocomplete="<TMPL_VAR NAME="AUTOCOMPLETE">";
    var login="<TMPL_VAR NAME="LOGIN">";
    var newwindow="<TMPL_VAR NAME="NEWWINDOW">";
    var antiframe="<TMPL_VAR NAME="ANTIFRAME">";
    var appslistorder="<TMPL_VAR NAME="APPSLIST_ORDER">";
    var scriptname="<TMPL_VAR NAME="SCRIPT_NAME">";
    var activeTimer="<TMPL_VAR NAME="ACTIVE_TIMER">";
 //]]></script>
 <script type="text/javascript" src="<TMPL_VAR NAME="SKIN_PATH">/common/js/portal.js"></script>
 <script src="<TMPL_VAR NAME="SKIN_PATH">/<TMPL_VAR NAME="SKIN">/js/bootstrap.min.js"></script>
 <TMPL_INCLUDE NAME="customhead.tpl">
</head>
<body>

  <div id="wrap">

    <div id="header"><TMPL_INCLUDE NAME="customheader.tpl"></div>

