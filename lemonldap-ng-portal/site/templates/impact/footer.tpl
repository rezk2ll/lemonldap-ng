  <div id="layout-footer"><TMPL_INCLUDE NAME="customfooter.tpl"></div>

</div>

<!-- Constants -->
<script type="text/JavaScript">
  var staticPrefix = '<TMPL_VAR NAME="STATIC_PREFIX">'.replace(/\/*$/,'/');
  var scriptname='<TMPL_VAR NAME="SCRIPT_NAME">'.replace(/^$/,'.').replace(/\/*$/,'/');
  var availableLanguages='<TMPL_VAR NAME="AVAILABLE_LANGUAGES">'.split(/[,;] */);
  var portal   ='<TMPL_VAR NAME="PORTAL">';
</script>
</body>
</html>

