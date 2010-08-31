<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
        <title>OpenID endpoint</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta http-equiv="Content-Script-Type" content="text/javascript" />
	<meta http-equiv="cache-control" content="no-cache" />
        <link rel="stylesheet" type="text/css" href="/skins/<TMPL_VAR NAME="SKIN">/impact.css" />
        <link href="skins/common/favicon.ico" rel="icon" type="image/x-icon" />
        <link href="skins/common/favicon.ico" rel="shortcut icon" />
	<link rel="openid.server" href="<TMPL_VAR NAME="PROVIDERURI">" />
	<link rel="openid2.provider" href="<TMPL_VAR NAME="PROVIDERURI">" />
</head>
<body>
    <div id="content">
    <div id="content-left">
      <p><img src="/skins/<TMPL_VAR NAME="SKIN">/images/logo-lock.png" /></p>
    </div>
    <div id="content-right">
		<p><span class="text-error"><TMPL_VAR NAME="AUTH_ERROR"></span></p>
		<TMPL_IF NAME="ID">
			<p><lang en="Your identity is" fr="Votre identit&eacute; est"/>&nbsp;:</p>
			<p><b><TMPL_VAR NAME="ID"></b></p>
		</TMPL_IF>
    </div>

<TMPL_INCLUDE NAME="footer.tpl">
