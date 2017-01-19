<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title trspan="authPortal">Authentication portal</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <meta http-equiv="Content-Script-Type" content="text/javascript" />
  <meta http-equiv="cache-control" content="no-cache" />
  <link href="<TMPL_VAR NAME="STATIC_PREFIX">common/favicon.ico" rel="icon" type="image/x-icon" />
  <link href="<TMPL_VAR NAME="STATIC_PREFIX">common/favicon.ico" rel="shortcut icon" />
</head>

<TMPL_IF NAME="HIDDEN_INPUTS">
<body onload="document.getElementById('form').submit()">
<TMPL_ELSE>
<body onload="document.location.href='<TMPL_VAR NAME="URL">'">
</TMPL_IF>

  <h1 trspan="redirectionInProgres">Redirection in progress...</h1>
  <noscript>
    <p>It appears that your browser<br/>does not support Javascript.</p>
  </noscript>
  <TMPL_IF NAME="HIDDEN_INPUTS">
    <form id="form" action="<TMPL_VAR NAME="URL">" method="<TMPL_VAR NAME="FORM_METHOD">" class="login">
      <TMPL_VAR NAME="HIDDEN_INPUTS">
      <noscript>
        <input type="submit" value="Please click here"/>
      </noscript>
    </form>
  <TMPL_ELSE>
    <noscript>
      <p><a href="<TMPL_VAR NAME="URL">" trspan="clickHere">Please click here</a></p>
    </noscript>
  </TMPL_IF>
</body>
</html>

