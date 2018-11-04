<html>
  <head>
    <title>Check Session</title>
 <script type="application/init">
 {"cookiename":"<TMPL_VAR NAME="COOKIENAME">"}
 </script>
<!-- //if:usedebianlibs
  <script type="text/javascript" src="/javascript/cryptojs/components/core-min.js"></script>
  <script type="text/javascript" src="/javascript/cryptojs/components/sha256-min.js"></script>
  <script type="text/javascript" src="/javascript/cryptojs/components/enc-base64-min.js"></script>
  <script type="text/javascript" src="/javascript/jquery/jquery.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/oidcchecksession.min.js"></script>
//elsif:jsminified
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/crypto-js/core.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/crypto-js/sha256.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/crypto-js/enc-base64.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery/dist/jquery.min.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/oidcchecksession.min.js"></script>
 //else -->
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/crypto-js/core.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/crypto-js/sha256.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/crypto-js/enc-base64.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery/dist/jquery.js"></script>
  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">common/js/oidcchecksession.js"></script>
<!-- //endif -->
  </head>
  <body>
  </body>
</html>
