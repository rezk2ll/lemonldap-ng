<!-- Constants -->
<script type="text/JavaScript">
  var staticPrefix = '<TMPL_VAR NAME="STATIC_PREFIX">'.replace(/\/*$/,'/');
  var formPrefix = staticPrefix+'forms/';
  var scriptname='<TMPL_VAR NAME="SCRIPT_NAME">'.replace(/^$/,'.').replace(/\/*$/,'/');
  var confPrefix=scriptname+'confs/';
  var availableLanguages='<TMPL_VAR NAME="AVAILABLE_LANGUAGES">'.split(/[,;] */);
  var links=<TMPL_VAR NAME="LINKS">;
  var menulinks=<TMPL_VAR NAME="MENULINKS">;
  var portal   ='<TMPL_VAR NAME="PORTAL">';
</script>

<!-- //if:usedebianlibs
<script type="text/javascript" src="/javascript/jquery/jquery.min.js"></script>
<script type="text/javascript" src="/javascript/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/portal.min.js"></script>
//elsif:useexternallibs
<script type="text/javascript" src="http://code.jquery.com/jquery-2.2.0.min.js"></script>
<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/portal.min.js"></script>
//elsif:jsminified
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery/dist/jquery.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/bootstrap/dist/js/bootstrap.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/portal.min.js"></script>
//else -->
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery/dist/jquery.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/bootstrap/dist/js/bootstrap.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/portal.js"></script>
<!-- //endif -->

<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
<!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
  <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
<![endif]-->
