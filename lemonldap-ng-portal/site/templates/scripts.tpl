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
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/portal.min.js"></script>
//elsif:useexternallibs
<script type="text/javascript" src="http://code.jquery.com/jquery-2.2.0.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/portal.min.js"></script>
//elsif:jsminified
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery/dist/jquery.min.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/portal.min.js"></script>
//else -->
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">bwr/jquery/dist/jquery.js"></script>
<script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">js/portal.js"></script>
<!-- //endif -->
