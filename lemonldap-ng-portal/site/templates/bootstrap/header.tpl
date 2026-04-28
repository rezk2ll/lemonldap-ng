<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"<TMPL_IF "LANGUAGE"> lang="<TMPL_VAR "LANGUAGE">"</TMPL_IF>>
<head>
 <title trspan="authPortal">Authentication portal</title>
 <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
 <meta http-equiv="Content-Script-Type" content="text/javascript" />
 <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
 <meta http-equiv="Pragma" content="no-cache" />
 <meta http-equiv="Expires" content="0" />
 <meta name="viewport" content="width=device-width, initial-scale=1.0" />
<!-- Bootstrap 5 CSS is compiled (with the skin's custom Sass tokens) into
     styles.css, so it is always served from the skin — Debian's stock
     libjs-bootstrap5 CSS would drop the theme. Font Awesome 6 is not served
     under /javascript by Debian (the system package is v4), so it is also
     served from the skin, except in useexternallibs mode where a FA6 CDN is
     used. Only the Bootstrap JS bundle can come from libjs-bootstrap5. -->
<!-- //if:usedebianlibs
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/css/styles.min.css?v=<TMPL_VAR CACHE_TAG>" />
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/fontawesome/css/all.min.css?v=<TMPL_VAR CACHE_TAG>" />
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/fontawesome/css/v4-shims.min.css?v=<TMPL_VAR CACHE_TAG>" />
//elsif:useexternallibs
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/css/styles.min.css?v=<TMPL_VAR CACHE_TAG>" />
 <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
 <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/v4-shims.min.css" />
//elsif:cssminified
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/css/styles.min.css?v=<TMPL_VAR CACHE_TAG>" />
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/fontawesome/css/all.min.css?v=<TMPL_VAR CACHE_TAG>" />
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/fontawesome/css/v4-shims.min.css?v=<TMPL_VAR CACHE_TAG>" />
//else -->
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/css/styles.css?v=<TMPL_VAR CACHE_TAG>" />
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/fontawesome/css/all.css?v=<TMPL_VAR CACHE_TAG>" />
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/fontawesome/css/v4-shims.css?v=<TMPL_VAR CACHE_TAG>" />
<!-- //endif -->
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="SCRIPTNAME">portal.css" />
 <TMPL_IF NAME="CUSTOM_CSS">
 <link rel="stylesheet" type="text/css" href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="CUSTOM_CSS">" />
 </TMPL_IF>
 <link href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="FAVICON">" rel="icon" type="image/vnd.microsoft.icon" sizes="16x16 32x32 48x48 64x64 128x128" />
 <link href="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="FAVICON">" rel="shortcut icon" type="image/vnd.microsoft.icon" sizes="16x16 32x32 48x48 64x64 128x128" />
 <TMPL_IF NAME="PROVIDERURI">
  <link rel="openid.server" href="<TMPL_VAR NAME="PROVIDERURI">" />
  <link rel="openid2.provider" href="<TMPL_VAR NAME="PROVIDERURI">" />
 </TMPL_IF>
 <TMPL_INCLUDE NAME="../common/script.tpl">
<!-- //if:usedebianlibs
  <script type="text/javascript" src="/javascript/bootstrap5/js/bootstrap.bundle.min.js?v=<TMPL_VAR CACHE_TAG>"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/js/skin.min.js?v=<TMPL_VAR CACHE_TAG>"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/portal.min.js?v=<TMPL_VAR CACHE_TAG>"></script>
 //elsif:useexternallibs
  <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/js/skin.min.js?v=<TMPL_VAR CACHE_TAG>"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/portal.min.js?v=<TMPL_VAR CACHE_TAG>"></script>
 //elsif:jsminified
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/js/bootstrap.bundle.min.js?v=<TMPL_VAR CACHE_TAG>"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/js/skin.min.js?v=<TMPL_VAR CACHE_TAG>"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/portal.min.js?v=<TMPL_VAR CACHE_TAG>"></script>
 //else -->
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/js/bootstrap.bundle.js?v=<TMPL_VAR CACHE_TAG>"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/js/skin.js?v=<TMPL_VAR CACHE_TAG>"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/portal.js?v=<TMPL_VAR CACHE_TAG>"></script>
 <!-- //endif -->
 <TMPL_IF NAME="CUSTOM_JS">
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="CUSTOM_JS">"></script>
 </TMPL_IF>
 <TMPL_VAR NAME="CUSTOM_SCRIPT">
 <TMPL_INCLUDE NAME="customhead.tpl">
</head>
<body>

  <div id="wrap">

    <div id="header"><TMPL_INCLUDE NAME="customheader.tpl"></div>

