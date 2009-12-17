<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
        <title><lang en="Authentication portal" fr="Portail d'authentification"/></title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta http-equiv="Content-Script-Type" content="text/javascript" />
	<meta http-equiv="cache-control" content="no-cache" />
        <link rel="stylesheet" type="text/css" href="skins/<TMPL_VAR NAME="SKIN">/styles.css" />
        <link href="skins/common/favicon.ico" rel="icon" type="image/x-icon" />
        <link href="skins/common/favicon.ico" rel="shortcut icon" />
        <script type="text/javascript" src="skins/common/jquery-1.3.2.min.js"></script>
        <script type="text/javascript" src="skins/common/jquery-ui-1.7.2.custom.min.js"></script>
        <script type="text/javascript">
        $(document).ready(function(){
          $("div.message").fadeIn('slow');
          $("input[name=timezone]").val( -(new Date().getTimezoneOffset()/60) );
          $("#menu").tabs({ fx: { opacity: 'toggle' } });
          $("#menu").tabs("select","#<TMPL_VAR NAME="DISPLAY_TAB">");
          $("input[type!=hidden]:first").focus();
          $("input[type='password']").attr("autocomplete","<TMPL_VAR NAME="AUTOCOMPLETE">");
          $("#appslist li[class!=catname]").hover(
                function(){
                        var appid = $(this).attr("title");
                        $("div.appsdesc").hide();
                        $("div#" + appid).show();},
                function(){}
          );
          <TMPL_IF NAME="LOGIN">$("input[type=password]:first").focus();</TMPL_IF>
          <TMPL_IF NAME="NEWWINDOW">$('a[href^="http://"]').attr("target", "_blank");</TMPL_IF>
        });
        </script>
</head>
<body>
        <div id="page">

        <div id="header"></div>

